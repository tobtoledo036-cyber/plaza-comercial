import express from 'express'
import pool from '../db/connection.js'

const router = express.Router()

// POST /api/transacciones — crear transacción (compra o apartado)
router.post('/', async (req, res) => {
  const client = await pool.connect()
  try {
    await client.query('BEGIN')

    const { localId, tipo, clienteInfo, apartadoOpciones } = req.body
    const { nombre, email, telefono } = clienteInfo

    // Opciones de apartado: { duracionDias, porcentaje }
    const duracionDias  = apartadoOpciones?.duracionDias  || 30
    const porcentaje    = apartadoOpciones?.porcentaje    || 30

    // 1. Verificar que el local esté disponible
    const localCheck = await client.query(
      'SELECT id, estado, precio, precio_apartado FROM locales WHERE id = $1',
      [localId]
    )

    if (!localCheck.rows.length)
      return res.status(404).json({ error: 'Local no encontrado' })

    const local = localCheck.rows[0]
    if (local.estado !== 'disponible')
      return res.status(400).json({ error: `El local no está disponible (estado: ${local.estado})` })

    // Determinar el precio según el tipo y opciones
    let precioFinal
    if (tipo === 'apartado') {
      precioFinal = parseFloat(local.precio) * (porcentaje / 100)
    } else {
      precioFinal = parseFloat(local.precio)
    }

    // 2. Crear o recuperar cliente
    let clienteId
    const clienteExiste = await client.query('SELECT id FROM clientes WHERE email = $1', [email])

    if (clienteExiste.rows.length) {
      clienteId = clienteExiste.rows[0].id
    } else {
      const nuevoCliente = await client.query(
        'INSERT INTO clientes (nombre, email, telefono) VALUES ($1, $2, $3) RETURNING id',
        [nombre, email, telefono || null]
      )
      clienteId = nuevoCliente.rows[0].id
    }

    // 3. Calcular fecha de vencimiento para apartado
    const fechaVencimiento = tipo === 'apartado'
      ? new Date(Date.now() + duracionDias * 24 * 60 * 60 * 1000)
      : null

    // 4. Crear transacción en estado pendiente
    const nuevaTrans = await client.query(
      `INSERT INTO transacciones
         (local_id, cliente_id, tipo, monto, estado_pago,
          duracion_apartado_dias, porcentaje_apartado, fecha_vencimiento_apartado)
       VALUES ($1, $2, $3, $4, 'pendiente', $5, $6, $7)
       RETURNING id`,
      [localId, clienteId, tipo, precioFinal.toFixed(2),
       tipo === 'apartado' ? duracionDias : null,
       tipo === 'apartado' ? porcentaje   : null,
       fechaVencimiento]
    )

    const transaccionId = nuevaTrans.rows[0].id

    await client.query('COMMIT')

    res.json({
      message: 'Transacción creada',
      transaccionId,
      monto: precioFinal,
      tipo,
    })
  } catch (err) {
    await client.query('ROLLBACK')
    console.error('Error POST /transacciones:', err.message)
    res.status(500).json({ error: err.message })
  } finally {
    client.release()
  }
})

// PATCH /api/transacciones/:id/completar — confirmar pago de PayPal
router.patch('/:id/completar', async (req, res) => {
  const client = await pool.connect()
  try {
    await client.query('BEGIN')

    const { paypalOrderId, paypalPaymentId } = req.body

    // Obtener la transacción
    const trans = await client.query(
      'SELECT * FROM transacciones WHERE id = $1',
      [req.params.id]
    )

    if (!trans.rows.length)
      return res.status(404).json({ error: 'Transacción no encontrada' })

    const t = trans.rows[0]

    // Actualizar transacción a completada
    await client.query(
      `UPDATE transacciones
       SET estado_pago='completado',
           paypal_order_id=$1,
           paypal_payment_id=$2,
           completed_at=CURRENT_TIMESTAMP
       WHERE id=$3`,
      [paypalOrderId || null, paypalPaymentId || null, req.params.id]
    )

    // Marcar local como vendido si fue compra, o apartado si fue apartado
    const nuevoEstado = t.tipo === 'compra' ? 'vendido' : 'apartado'
    await client.query(
      `UPDATE locales SET estado=$1, updated_at=CURRENT_TIMESTAMP WHERE id=$2`,
      [nuevoEstado, t.local_id]
    )

    await client.query('COMMIT')

    res.json({ message: 'Pago completado', estado: nuevoEstado })
  } catch (err) {
    await client.query('ROLLBACK')
    console.error('Error PATCH /transacciones/completar:', err.message)
    res.status(500).json({ error: err.message })
  } finally {
    client.release()
  }
})

// PATCH /api/transacciones/:id/cancelar — cancelar transacción
router.patch('/:id/cancelar', async (req, res) => {
  const client = await pool.connect()
  try {
    await client.query('BEGIN')

    const trans = await client.query(
      'SELECT * FROM transacciones WHERE id = $1',
      [req.params.id]
    )

    if (!trans.rows.length)
      return res.status(404).json({ error: 'Transacción no encontrada' })

    await client.query(
      `UPDATE transacciones SET estado_pago='cancelado' WHERE id=$1`,
      [req.params.id]
    )

    // Regresar local a disponible
    await client.query(
      `UPDATE locales SET estado='disponible', updated_at=CURRENT_TIMESTAMP WHERE id=$1`,
      [trans.rows[0].local_id]
    )

    await client.query('COMMIT')

    res.json({ message: 'Transacción cancelada, local liberado' })
  } catch (err) {
    await client.query('ROLLBACK')
    res.status(500).json({ error: err.message })
  } finally {
    client.release()
  }
})

// GET /api/transacciones — historial completo con joins
router.get('/', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        t.id, t.tipo, t.monto, t.estado_pago,
        t.paypal_order_id, t.created_at, t.completed_at,
        l.numero AS local_numero, l.area,
        p.nombre AS plaza_nombre, p.ubicacion,
        c.nombre AS cliente_nombre, c.email, c.telefono
      FROM transacciones t
      JOIN locales l ON t.local_id = l.id
      JOIN plazas p ON l.plaza_id = p.id
      JOIN clientes c ON t.cliente_id = c.id
      ORDER BY t.created_at DESC
    `)
    res.json(result.rows)
  } catch (err) {
    console.error('Error GET /transacciones:', err.message)
    res.status(500).json({ error: err.message })
  }
})

export default router
