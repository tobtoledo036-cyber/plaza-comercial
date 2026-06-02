import pkg from 'pg'
const { Pool } = pkg
import dotenv from 'dotenv'
dotenv.config()

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'plazas_db',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres123',
})

pool.on('connect', () => {
  console.log('✅ Conectado a PostgreSQL')
})

pool.on('error', (err) => {
  console.error('❌ Error en PostgreSQL:', err.message)
})

export default pool
