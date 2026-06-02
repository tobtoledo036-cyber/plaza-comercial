import express from 'express'
import pool from '../db/connection.js'
import { requireAuth } from '../middleware/auth.js'
import { generarPDFTransaccion } from '../utils/generarPDF.js'

const router = express.Router()

// GET /api/pdf/transaccion/:id
// Genera y descarga el PDF de una transacción
router.get('/transaccion/:id', requireAuth, async (req, res) => {
  try {
    const { id } = req.params

    const result = await pool.query(`
      SELECT
        t.id, t.tipo, t.monto, t.estado_pago,
        t.duracion_apartado_dias, t.porcentaje_apartado,
        t.fecha_vencimiento_apartado, t.paypal_payment_id,
        t.created_at,
        l.numero AS local_numero, l.area,
        l.precio AS precio_compra,
        p.nombre AS plaza_nombre, p.ubicacion AS plaza_ubicacion,
        c.nombre AS cliente_nombre, c.email AS cliente_email,
        c.telefono AS cliente_telefono
      FROM transacciones t
      JOIN locales  l ON l.id = t.local_id
      JOIN plazas   p ON p.id = l.plaza_id
      JOIN clientes c ON c.id = t.cliente_id
      WHERE t.id = $1
    `, [id])

    if (!result.rows.length)
      return res.status(404).json({ error: 'Transacción no encontrada' })

    const transaccion = result.rows[0]

    // Solo el admin o el dueño de la transacción puede descargar el PDF
    if (req.user.rol !== 'admin' && transaccion.cliente_email !== req.user.email)
      return res.status(403).json({ error: 'Sin permiso para este documento' })

    const tipo = transaccion.tipo === 'compra' ? 'compra' : 'apartado'
    const filename = `comprobante-${tipo}-${String(id).padStart(6, '0')}.pdf`

    res.setHeader('Content-Type', 'application/pdf')
    res.setHeader('Content-Disposition', `attachment; filename="${filename}"`)

    generarPDFTransaccion(transaccion, res)
  } catch (err) {
    console.error('Error generando PDF:', err.message)
    res.status(500).json({ error: err.message })
  }
})

export default router
