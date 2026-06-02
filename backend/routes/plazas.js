import express from 'express'
import pool from '../db/connection.js'

const router = express.Router()

// GET /api/plazas — todas las plazas
router.get('/', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM plazas ORDER BY id')
    res.json(result.rows)
  } catch (err) {
    console.error('Error GET /plazas:', err.message)
    res.status(500).json({ error: err.message })
  }
})

// GET /api/plazas/:id — una plaza con sus estadísticas de locales
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params

    const plaza = await pool.query('SELECT * FROM plazas WHERE id = $1', [id])

    if (!plaza.rows.length)
      return res.status(404).json({ error: 'Plaza no encontrada' })

    const stats = await pool.query(`
      SELECT
        COUNT(*)::int AS total,
        SUM(CASE WHEN estado='disponible' THEN 1 ELSE 0 END)::int AS disponibles,
        SUM(CASE WHEN estado='apartado'   THEN 1 ELSE 0 END)::int AS apartados,
        SUM(CASE WHEN estado='vendido'    THEN 1 ELSE 0 END)::int AS vendidos
      FROM locales WHERE plaza_id = $1
    `, [id])

    res.json({ ...plaza.rows[0], stats: stats.rows[0] })
  } catch (err) {
    console.error('Error GET /plazas/:id:', err.message)
    res.status(500).json({ error: err.message })
  }
})

export default router
