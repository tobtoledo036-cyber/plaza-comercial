import express from 'express'
import pool from '../db/connection.js'
import { requireAuth, requireAdmin } from '../middleware/auth.js'
import {
  enviarConfirmacionSolicitud,
  notificarAdminNuevaSolicitud,
  enviarAprobacion,
  enviarRechazo,
  emailValido,
} from '../utils/mailer.js'

const router = express.Router()

// ── POST /api/solicitudes ────────────────────────────────────
// Crear nueva solicitud de renta
router.post('/', async (req, res) => {
  try {
    const {
      local_id,
      nombre,
      email,
      telefono,
      empresa,
      giro_propuesto,
      plan_negocio,
    } = req.body

    // Validaciones
    if (!local_id || !nombre || !email || !giro_propuesto || !plan_negocio)
      return res.status(400).json({ error: 'Faltan campos requeridos: local_id, nombre, email, giro_propuesto, plan_negocio' })

    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email))
      return res.status(400).json({ error: 'Email inválido' })

    if (!emailValido(email))
      return res.status(400).json({ error: 'Por favor usa un correo electrónico real y válido (ej: tu@gmail.com)' })

    if (plan_negocio.trim().length < 20)
      return res.status(400).json({ error: 'El plan de negocio debe tener al menos 20 caracteres' })

    // Verificar que el local existe y está disponible
    const localResult = await pool.query(`
      SELECT l.*, p.nombre AS plaza_nombre, p.id AS plaza_id
      FROM locales l
      JOIN plazas p ON p.id = l.plaza_id
      WHERE l.id = $1
    `, [local_id])

    if (!localResult.rows.length)
      return res.status(404).json({ error: 'Local no encontrado' })

    const local = localResult.rows[0]

    if (local.estado !== 'disponible')
      return res.status(400).json({ error: `El local no está disponible (estado actual: ${local.estado})` })

    // Verificar que no haya una solicitud pendiente para este local
    const solicitudExistente = await pool.query(
      "SELECT id FROM solicitudes WHERE local_id = $1 AND estado = 'pendiente'",
      [local_id]
    )
    if (solicitudExistente.rows.length)
      return res.status(409).json({ error: 'Ya existe una solicitud pendiente para este local' })

    // Crear solicitud
    const usuario_id = req.user?.id || null

    const result = await pool.query(`
      INSERT INTO solicitudes
        (local_id, nombre, email, telefono, empresa, giro_propuesto, plan_negocio, usuario_id)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
      RETURNING *
    `, [local_id, nombre.trim(), email.trim().toLowerCase(), telefono || null,
        empresa || null, giro_propuesto.trim(), plan_negocio.trim(), usuario_id])

    const solicitud = result.rows[0]

    // Cambiar estado del local a "negociacion"
    await pool.query(
      "UPDATE locales SET estado = 'negociacion', updated_at = CURRENT_TIMESTAMP WHERE id = $1",
      [local_id]
    )

    // Enviar correos (no bloqueante)
    const plaza = { nombre: local.plaza_nombre, id: local.plaza_id }
    enviarConfirmacionSolicitud({ solicitud, local, plaza }).catch(console.error)
    notificarAdminNuevaSolicitud({ solicitud, local, plaza }).catch(console.error)

    res.status(201).json({
      message: 'Solicitud enviada correctamente',
      solicitud_id: solicitud.id,
      estado: solicitud.estado,
    })
  } catch (err) {
    console.error('Error POST /solicitudes:', err.message)
    res.status(500).json({ error: err.message })
  }
})

// ── GET /api/solicitudes ─────────────────────────────────────
// Admin: listar solicitudes con filtros
router.get('/', requireAdmin, async (req, res) => {
  try {
    const { status, piso_id, giro, limit = 50, offset = 0 } = req.query

    let where = []
    let params = []
    let i = 1

    if (status) { where.push(`s.estado = $${i++}`); params.push(status) }
    if (piso_id) { where.push(`l.piso_id = $${i++}`); params.push(piso_id) }
    if (giro) { where.push(`s.giro_propuesto ILIKE $${i++}`); params.push(`%${giro}%`) }

    const whereClause = where.length ? 'WHERE ' + where.join(' AND ') : ''

    params.push(parseInt(limit), parseInt(offset))

    const result = await pool.query(`
      SELECT
        s.id, s.nombre, s.email, s.telefono, s.empresa,
        s.giro_propuesto, s.plan_negocio, s.estado,
        s.respuesta_admin, s.created_at, s.updated_at,
        l.id AS local_id, l.numero AS local_numero,
        l.area, l.precio, l.estado AS local_estado,
        p.id AS plaza_id, p.nombre AS plaza_nombre,
        pi.numero AS piso_numero, pi.nombre AS piso_nombre
      FROM solicitudes s
      JOIN locales l ON l.id = s.local_id
      JOIN plazas p ON p.id = l.plaza_id
      LEFT JOIN pisos pi ON pi.id = l.piso_id
      ${whereClause}
      ORDER BY s.created_at DESC
      LIMIT $${i++} OFFSET $${i++}
    `, params)

    // Conteo total para paginación
    const countResult = await pool.query(`
      SELECT COUNT(*)::int AS total
      FROM solicitudes s
      JOIN locales l ON l.id = s.local_id
      ${whereClause}
    `, params.slice(0, -2))

    res.json({
      solicitudes: result.rows,
      total: countResult.rows[0].total,
    })
  } catch (err) {
    console.error('Error GET /solicitudes:', err.message)
    res.status(500).json({ error: err.message })
  }
})

// ── GET /api/solicitudes/mis-solicitudes ─────────────────────
// Usuario: ver sus propias solicitudes
router.get('/mis-solicitudes', requireAuth, async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        s.id, s.giro_propuesto, s.estado, s.respuesta_admin,
        s.created_at, s.updated_at,
        l.numero AS local_numero, l.area,
        p.nombre AS plaza_nombre
      FROM solicitudes s
      JOIN locales l ON l.id = s.local_id
      JOIN plazas p ON p.id = l.plaza_id
      WHERE s.email = $1 OR s.usuario_id = $2
      ORDER BY s.created_at DESC
    `, [req.user.email, req.user.id])

    res.json(result.rows)
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
})

// ── GET /api/solicitudes/:id ─────────────────────────────────
router.get('/:id', requireAdmin, async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT s.*, l.numero AS local_numero, l.area, l.precio,
             p.nombre AS plaza_nombre
      FROM solicitudes s
      JOIN locales l ON l.id = s.local_id
      JOIN plazas p ON p.id = l.plaza_id
      WHERE s.id = $1
    `, [req.params.id])

    if (!result.rows.length)
      return res.status(404).json({ error: 'Solicitud no encontrada' })

    res.json(result.rows[0])
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
})

// ── PATCH /api/solicitudes/:id/aprobar ───────────────────────
router.patch('/:id/aprobar', requireAdmin, async (req, res) => {
  const client = await pool.connect()
  try {
    await client.query('BEGIN')

    const { respuesta } = req.body

    const solResult = await client.query(`
      SELECT s.*, l.numero AS local_numero, l.area,
             p.nombre AS plaza_nombre, p.id AS plaza_id
      FROM solicitudes s
      JOIN locales l ON l.id = s.local_id
      JOIN plazas p ON p.id = l.plaza_id
      WHERE s.id = $1
    `, [req.params.id])

    if (!solResult.rows.length)
      return res.status(404).json({ error: 'Solicitud no encontrada' })

    const sol = solResult.rows[0]

    if (sol.estado !== 'pendiente')
      return res.status(400).json({ error: `La solicitud ya fue ${sol.estado}` })

    // Actualizar solicitud
    await client.query(`
      UPDATE solicitudes
      SET estado = 'aprobada', respuesta_admin = $1, updated_at = CURRENT_TIMESTAMP
      WHERE id = $2
    `, [respuesta || null, req.params.id])

    // Cambiar estado del local a "ocupado"
    await client.query(
      "UPDATE locales SET estado = 'ocupado', updated_at = CURRENT_TIMESTAMP WHERE id = $1",
      [sol.local_id]
    )

    await client.query('COMMIT')

    // Enviar correo de aprobación
    const solicitudActualizada = { ...sol, estado: 'aprobada', respuesta_admin: respuesta }
    const local = { numero: sol.local_numero, area: sol.area }
    const plaza = { nombre: sol.plaza_nombre }
    enviarAprobacion({ solicitud: solicitudActualizada, local, plaza }).catch(console.error)

    res.json({ message: 'Solicitud aprobada', local_estado: 'ocupado' })
  } catch (err) {
    await client.query('ROLLBACK')
    console.error('Error PATCH /solicitudes/aprobar:', err.message)
    res.status(500).json({ error: err.message })
  } finally {
    client.release()
  }
})

// ── PATCH /api/solicitudes/:id/rechazar ──────────────────────
router.patch('/:id/rechazar', requireAdmin, async (req, res) => {
  const client = await pool.connect()
  try {
    await client.query('BEGIN')

    const { respuesta } = req.body

    const solResult = await client.query(`
      SELECT s.*, l.numero AS local_numero, l.area,
             p.nombre AS plaza_nombre
      FROM solicitudes s
      JOIN locales l ON l.id = s.local_id
      JOIN plazas p ON p.id = l.plaza_id
      WHERE s.id = $1
    `, [req.params.id])

    if (!solResult.rows.length)
      return res.status(404).json({ error: 'Solicitud no encontrada' })

    const sol = solResult.rows[0]

    if (sol.estado !== 'pendiente')
      return res.status(400).json({ error: `La solicitud ya fue ${sol.estado}` })

    // Actualizar solicitud
    await client.query(`
      UPDATE solicitudes
      SET estado = 'rechazada', respuesta_admin = $1, updated_at = CURRENT_TIMESTAMP
      WHERE id = $2
    `, [respuesta || null, req.params.id])

    // Regresar local a disponible
    await client.query(
      "UPDATE locales SET estado = 'disponible', updated_at = CURRENT_TIMESTAMP WHERE id = $1",
      [sol.local_id]
    )

    await client.query('COMMIT')

    // Enviar correo de rechazo
    const solicitudActualizada = { ...sol, estado: 'rechazada', respuesta_admin: respuesta }
    const local = { numero: sol.local_numero, area: sol.area }
    const plaza = { nombre: sol.plaza_nombre }
    enviarRechazo({ solicitud: solicitudActualizada, local, plaza }).catch(console.error)

    res.json({ message: 'Solicitud rechazada', local_estado: 'disponible' })
  } catch (err) {
    await client.query('ROLLBACK')
    console.error('Error PATCH /solicitudes/rechazar:', err.message)
    res.status(500).json({ error: err.message })
  } finally {
    client.release()
  }
})

// ── POST /api/solicitudes/:id/pagar ─────────────────────────
// Crea transacción PayPal para una solicitud aprobada
router.post('/:id/pagar', requireAuth, async (req, res) => {
  try {
    const { id } = req.params

    // Verificar que la solicitud existe, está aprobada y pertenece al usuario
    const solResult = await pool.query(`
      SELECT s.*, l.precio, l.numero AS local_numero,
             p.nombre AS plaza_nombre
      FROM solicitudes s
      JOIN locales l ON l.id = s.local_id
      JOIN plazas p ON p.id = l.plaza_id
      WHERE s.id = $1
    `, [id])

    if (!solResult.rows.length)
      return res.status(404).json({ error: 'Solicitud no encontrada' })

    const sol = solResult.rows[0]

    // Solo el dueño de la solicitud puede pagar
    if (sol.email !== req.user.email && sol.usuario_id !== req.user.id)
      return res.status(403).json({ error: 'No tienes permiso para pagar esta solicitud' })

    if (sol.estado !== 'aprobada')
      return res.status(400).json({ error: `La solicitud no está aprobada (estado: ${sol.estado})` })

    // Verificar que no haya ya una transacción pendiente o completada para esta solicitud
    const transExiste = await pool.query(
      `SELECT id FROM transacciones WHERE local_id = $1 AND estado_pago IN ('pendiente','completado')`,
      [sol.local_id]
    )
    if (transExiste.rows.length)
      return res.status(409).json({ error: 'Ya existe un pago en proceso para este local' })

    // Crear o recuperar cliente
    let clienteId
    const clienteExiste = await pool.query('SELECT id FROM clientes WHERE email = $1', [sol.email])
    if (clienteExiste.rows.length) {
      clienteId = clienteExiste.rows[0].id
    } else {
      const nuevoCliente = await pool.query(
        'INSERT INTO clientes (nombre, email, telefono) VALUES ($1, $2, $3) RETURNING id',
        [sol.nombre, sol.email, sol.telefono || null]
      )
      clienteId = nuevoCliente.rows[0].id
    }

    // Crear transacción en estado pendiente
    const nuevaTrans = await pool.query(
      `INSERT INTO transacciones (local_id, cliente_id, tipo, monto, estado_pago, usuario_id)
       VALUES ($1, $2, 'compra', $3, 'pendiente', $4) RETURNING id`,
      [sol.local_id, clienteId, parseFloat(sol.precio).toFixed(2), req.user.id]
    )

    res.json({
      transaccionId: nuevaTrans.rows[0].id,
      monto: parseFloat(sol.precio),
      local: sol.local_numero,
      plaza: sol.plaza_nombre,
    })
  } catch (err) {
    console.error('Error POST /solicitudes/pagar:', err.message)
    res.status(500).json({ error: err.message })
  }
})

export default router
