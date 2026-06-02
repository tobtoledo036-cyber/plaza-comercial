import express from 'express'
import pool from '../db/connection.js'
import { requireAuth } from '../middleware/auth.js'

const router = express.Router()

// ── GET /api/usuario/mis-locales ────────────────────────────
// Devuelve los locales comprados/apartados por el usuario logueado
router.get('/mis-locales', requireAuth, async (req, res) => {
  try {
    // Buscar por email del usuario en la tabla clientes
    const result = await pool.query(`
      SELECT
        t.id            AS transaccion_id,
        t.tipo,
        t.monto,
        t.estado_pago,
        t.created_at    AS fecha_transaccion,
        t.completed_at  AS fecha_pago,
        t.duracion_apartado_dias,
        t.porcentaje_apartado,
        t.fecha_vencimiento_apartado,
        t.paypal_payment_id,
        l.id            AS local_id,
        l.numero,
        l.area,
        l.precio        AS precio_compra,
        l.precio_apartado,
        l.estado,
        p.nombre        AS plaza_nombre,
        p.ubicacion     AS plaza_ubicacion,
        p.lat, p.lng
      FROM transacciones t
      JOIN locales  l ON l.id = t.local_id
      JOIN plazas   p ON p.id = l.plaza_id
      JOIN clientes c ON c.id = t.cliente_id
      WHERE c.email = $1
        AND t.estado_pago = 'completado'
      ORDER BY t.created_at DESC
    `, [req.user.email])

    res.json(result.rows)
  } catch (err) {
    console.error('Error mis-locales:', err.message)
    res.status(500).json({ error: err.message })
  }
})

export default router
