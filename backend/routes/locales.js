import express from 'express'
import pool from '../db/connection.js'

const router = express.Router()

// GET /api/locales/plaza/:plazaId — todos los locales de una plaza
router.get('/plaza/:plazaId', async (req, res) => {
  try {
    const { plazaId } = req.params

    const result = await pool.query(`
      SELECT id, plaza_id, numero, area, precio, estado,
             es_grande, lat_min, lat_max, lng_min, lng_max
      FROM locales
      WHERE plaza_id = $1
      ORDER BY numero
    `, [plazaId])

    res.json(result.rows)
  } catch (err) {
    console.error('Error GET /locales/plaza:', err.message)
    res.status(500).json({ error: err.message })
  }
})

// GET /api/locales/:id — un local específico
router.get('/:id', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM locales WHERE id = $1', [req.params.id])

    if (!result.rows.length)
      return res.status(404).json({ error: 'Local no encontrado' })

    res.json(result.rows[0])
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
})

// PUT /api/locales/:id — actualizar estado de un local
router.put('/:id', async (req, res) => {
  try {
    const { estado } = req.body
    const estadosValidos = ['disponible', 'apartado', 'vendido']

    if (!estadosValidos.includes(estado))
      return res.status(400).json({ error: 'Estado inválido' })

    await pool.query(`
      UPDATE locales
      SET estado = $1, updated_at = CURRENT_TIMESTAMP
      WHERE id = $2
    `, [estado, req.params.id])

    res.json({ message: `Local actualizado a: ${estado}` })
  } catch (err) {
    console.error('Error PUT /locales:', err.message)
    res.status(500).json({ error: err.message })
  }
})

export default router
