import express from 'express'
import pool from '../db/connection.js'
import { requireAdmin } from '../middleware/auth.js'

const router = express.Router()

// ── GET /api/admin/dashboard ────────────────────────────────
router.get('/dashboard', requireAdmin, async (req, res) => {
  try {
    // Estadísticas de locales (incluye nuevos estados)
    const localesStats = await pool.query(`
      SELECT
        COUNT(*)::int                                                         AS total,
        SUM(CASE WHEN estado='disponible'  THEN 1 ELSE 0 END)::int           AS disponibles,
        SUM(CASE WHEN estado='negociacion' THEN 1 ELSE 0 END)::int           AS en_negociacion,
        SUM(CASE WHEN estado='ocupado'     THEN 1 ELSE 0 END)::int           AS ocupados,
        SUM(CASE WHEN estado='apartado'    THEN 1 ELSE 0 END)::int           AS apartados,
        SUM(CASE WHEN estado='vendido'     THEN 1 ELSE 0 END)::int           AS vendidos
      FROM locales
    `)

    // Estadísticas de solicitudes
    const solicitudesStats = await pool.query(`
      SELECT
        COUNT(*)::int                                                          AS total,
        SUM(CASE WHEN estado='pendiente'  THEN 1 ELSE 0 END)::int             AS pendientes,
        SUM(CASE WHEN estado='aprobada'   THEN 1 ELSE 0 END)::int             AS aprobadas,
        SUM(CASE WHEN estado='rechazada'  THEN 1 ELSE 0 END)::int             AS rechazadas
      FROM solicitudes
    `)

    // Estadísticas de transacciones PayPal
    const transStats = await pool.query(`
      SELECT
        COUNT(*)::int                                                              AS total,
        SUM(CASE WHEN estado_pago='completado' THEN 1 ELSE 0 END)::int            AS completadas,
        SUM(CASE WHEN estado_pago='pendiente'  THEN 1 ELSE 0 END)::int            AS pendientes,
        SUM(CASE WHEN estado_pago='cancelado'  THEN 1 ELSE 0 END)::int            AS canceladas,
        COALESCE(SUM(CASE WHEN estado_pago='completado' THEN monto END), 0)       AS ingresos_totales,
        SUM(CASE WHEN tipo='compra'   AND estado_pago='completado' THEN 1 ELSE 0 END)::int AS compras,
        SUM(CASE WHEN tipo='apartado' AND estado_pago='completado' THEN 1 ELSE 0 END)::int AS apartados_pagados
      FROM transacciones
    `)

    // Locales por plaza con nuevos estados
    const porPlaza = await pool.query(`
      SELECT
        p.nombre,
        COUNT(l.id)::int                                                       AS total,
        SUM(CASE WHEN l.estado='disponible'  THEN 1 ELSE 0 END)::int          AS disponibles,
        SUM(CASE WHEN l.estado='negociacion' THEN 1 ELSE 0 END)::int          AS en_negociacion,
        SUM(CASE WHEN l.estado='ocupado'     THEN 1 ELSE 0 END)::int          AS ocupados,
        COALESCE(SUM(CASE WHEN t.estado_pago='completado' THEN t.monto END), 0) AS ingresos
      FROM plazas p
      LEFT JOIN locales l ON l.plaza_id = p.id
      LEFT JOIN transacciones t ON t.local_id = l.id
      GROUP BY p.id, p.nombre
      ORDER BY p.nombre
    `)

    // Ingresos por mes (últimos 6 meses)
    const ingresosMes = await pool.query(`
      SELECT
        TO_CHAR(created_at, 'Mon YYYY') AS mes,
        TO_CHAR(created_at, 'YYYY-MM')  AS mes_orden,
        COUNT(*)::int                   AS transacciones,
        COALESCE(SUM(monto), 0)         AS ingresos
      FROM transacciones
      WHERE estado_pago = 'completado'
        AND created_at >= NOW() - INTERVAL '6 months'
      GROUP BY TO_CHAR(created_at, 'Mon YYYY'), TO_CHAR(created_at, 'YYYY-MM')
      ORDER BY mes_orden
    `)

    // Últimas 20 solicitudes
    const ultimasSolicitudes = await pool.query(`
      SELECT
        s.id, s.nombre, s.email, s.giro_propuesto, s.estado, s.created_at,
        l.numero AS local_numero,
        p.nombre AS plaza_nombre,
        pi.nombre AS piso_nombre
      FROM solicitudes s
      JOIN locales l ON l.id = s.local_id
      JOIN plazas p ON p.id = l.plaza_id
      LEFT JOIN pisos pi ON pi.id = l.piso_id
      ORDER BY s.created_at DESC
      LIMIT 20
    `)

    // Últimas 10 transacciones PayPal
    const ultimasTrans = await pool.query(`
      SELECT
        t.id, t.tipo, t.monto, t.estado_pago, t.created_at,
        c.nombre AS cliente, c.email,
        l.numero AS local,
        p.nombre AS plaza
      FROM transacciones t
      JOIN clientes c ON c.id = t.cliente_id
      JOIN locales  l ON l.id = t.local_id
      JOIN plazas   p ON p.id = l.plaza_id
      ORDER BY t.created_at DESC
      LIMIT 10
    `)

    res.json({
      locales:           localesStats.rows[0],
      solicitudes:       solicitudesStats.rows[0],
      transacciones:     transStats.rows[0],
      porPlaza:          porPlaza.rows,
      ingresosMes:       ingresosMes.rows,
      ultimasSolicitudes: ultimasSolicitudes.rows,
      ultimasTrans:      ultimasTrans.rows,
    })
  } catch (err) {
    console.error('Error dashboard:', err.message)
    res.status(500).json({ error: err.message })
  }
})

// ── GET /api/admin/transacciones ────────────────────────────
router.get('/transacciones', requireAdmin, async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        t.id, t.tipo, t.monto, t.estado_pago,
        t.duracion_apartado_dias, t.porcentaje_apartado,
        t.fecha_vencimiento_apartado,
        t.paypal_order_id, t.created_at, t.completed_at,
        l.numero AS local_numero, l.area,
        p.nombre AS plaza_nombre,
        c.nombre AS cliente_nombre, c.email, c.telefono
      FROM transacciones t
      JOIN locales  l ON l.id = t.local_id
      JOIN plazas   p ON p.id = l.plaza_id
      JOIN clientes c ON c.id = t.cliente_id
      ORDER BY t.created_at DESC
    `)
    res.json(result.rows)
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
})

// ── GET /api/admin/export/csv ────────────────────────────────
// Exportar solicitudes como CSV
router.get('/export/csv', requireAdmin, async (req, res) => {
  try {
    const { status, plaza_id, giro, fecha_inicio, fecha_fin } = req.query

    let where = []
    let params = []
    let i = 1

    if (status)      { where.push(`s.estado = $${i++}`);                    params.push(status) }
    if (plaza_id)    { where.push(`p.id = $${i++}`);                        params.push(plaza_id) }
    if (giro)        { where.push(`s.giro_propuesto ILIKE $${i++}`);        params.push(`%${giro}%`) }
    if (fecha_inicio){ where.push(`s.created_at >= $${i++}`);               params.push(fecha_inicio) }
    if (fecha_fin)   { where.push(`s.created_at <= $${i++}::date + 1`);     params.push(fecha_fin) }

    const whereClause = where.length ? 'WHERE ' + where.join(' AND ') : ''

    const result = await pool.query(`
      SELECT
        s.id AS folio,
        s.created_at AS fecha,
        s.nombre AS solicitante,
        s.email,
        s.telefono,
        s.empresa,
        s.giro_propuesto AS giro,
        s.estado,
        s.respuesta_admin AS respuesta,
        l.numero AS local,
        l.area AS area_m2,
        l.precio,
        p.nombre AS plaza,
        pi.nombre AS piso
      FROM solicitudes s
      JOIN locales l ON l.id = s.local_id
      JOIN plazas p ON p.id = l.plaza_id
      LEFT JOIN pisos pi ON pi.id = l.piso_id
      ${whereClause}
      ORDER BY s.created_at DESC
    `, params)

    // Generar CSV
    const headers = ['Folio','Fecha','Solicitante','Email','Teléfono','Empresa',
                     'Giro','Estado','Respuesta Admin','Local','Área m²','Precio',
                     'Plaza','Piso']

    const escapeCsv = (val) => {
      if (val == null) return ''
      const str = String(val)
      if (str.includes(',') || str.includes('"') || str.includes('\n'))
        return `"${str.replace(/"/g, '""')}"`
      return str
    }

    const rows = result.rows.map(row => [
      row.folio,
      row.fecha ? new Date(row.fecha).toLocaleDateString('es-MX') : '',
      row.solicitante, row.email, row.telefono, row.empresa,
      row.giro, row.estado, row.respuesta,
      row.local, row.area_m2, row.precio,
      row.plaza, row.piso,
    ].map(escapeCsv).join(','))

    const csv = [headers.join(','), ...rows].join('\n')

    res.setHeader('Content-Type', 'text/csv; charset=utf-8')
    res.setHeader('Content-Disposition', `attachment; filename="solicitudes-${Date.now()}.csv"`)
    res.send('\uFEFF' + csv) // BOM para Excel en español
  } catch (err) {
    console.error('Error export CSV:', err.message)
    res.status(500).json({ error: err.message })
  }
})

// ── GET /api/admin/stats/giros ───────────────────────────────
// Solicitudes agrupadas por giro (para métricas)
router.get('/stats/giros', requireAdmin, async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        giro_propuesto AS giro,
        COUNT(*)::int AS total,
        SUM(CASE WHEN estado='aprobada'  THEN 1 ELSE 0 END)::int AS aprobadas,
        SUM(CASE WHEN estado='pendiente' THEN 1 ELSE 0 END)::int AS pendientes,
        SUM(CASE WHEN estado='rechazada' THEN 1 ELSE 0 END)::int AS rechazadas
      FROM solicitudes
      GROUP BY giro_propuesto
      ORDER BY total DESC
      LIMIT 20
    `)
    res.json(result.rows)
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
})

export default router
