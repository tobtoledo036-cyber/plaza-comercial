import express from 'express'
import bcrypt from 'bcryptjs'
import jwt from 'jsonwebtoken'
import pool from '../db/connection.js'
import { requireAuth } from '../middleware/auth.js'

const router = express.Router()
const JWT_SECRET = process.env.JWT_SECRET || 'plazas_secret_2024'

// ── POST /api/auth/register ─────────────────────────────────
router.post('/register', async (req, res) => {
  try {
    const { nombre, email, password, telefono } = req.body

    if (!nombre || !email || !password)
      return res.status(400).json({ error: 'Nombre, email y contraseña son requeridos' })

    if (password.length < 6)
      return res.status(400).json({ error: 'La contraseña debe tener al menos 6 caracteres' })

    // Verificar si ya existe
    const existe = await pool.query('SELECT id FROM usuarios WHERE email = $1', [email])
    if (existe.rows.length)
      return res.status(409).json({ error: 'El email ya está registrado' })

    const hash = await bcrypt.hash(password, 10)

    const result = await pool.query(
      `INSERT INTO usuarios (nombre, email, password_hash, telefono, rol)
       VALUES ($1, $2, $3, $4, 'cliente') RETURNING id, nombre, email, rol`,
      [nombre, email, hash, telefono || null]
    )

    const user = result.rows[0]
    const token = jwt.sign({ id: user.id, email: user.email, rol: user.rol, nombre: user.nombre }, JWT_SECRET, { expiresIn: '7d' })

    res.status(201).json({ token, user })
  } catch (err) {
    console.error('Error register:', err.message)
    res.status(500).json({ error: err.message })
  }
})

// ── POST /api/auth/login ────────────────────────────────────
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body

    if (!email || !password)
      return res.status(400).json({ error: 'Email y contraseña requeridos' })

    const result = await pool.query(
      'SELECT * FROM usuarios WHERE email = $1 AND activo = true',
      [email]
    )

    if (!result.rows.length)
      return res.status(401).json({ error: 'Credenciales incorrectas' })

    const user = result.rows[0]
    const valid = await bcrypt.compare(password, user.password_hash)

    if (!valid)
      return res.status(401).json({ error: 'Credenciales incorrectas' })

    const token = jwt.sign(
      { id: user.id, email: user.email, rol: user.rol, nombre: user.nombre },
      JWT_SECRET,
      { expiresIn: '7d' }
    )

    res.json({
      token,
      user: { id: user.id, nombre: user.nombre, email: user.email, rol: user.rol, telefono: user.telefono }
    })
  } catch (err) {
    console.error('Error login:', err.message)
    res.status(500).json({ error: err.message })
  }
})

// ── GET /api/auth/me ────────────────────────────────────────
router.get('/me', requireAuth, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, nombre, email, rol, telefono, created_at FROM usuarios WHERE id = $1',
      [req.user.id]
    )
    if (!result.rows.length)
      return res.status(404).json({ error: 'Usuario no encontrado' })

    res.json(result.rows[0])
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
})

export default router
