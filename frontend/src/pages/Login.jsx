import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import './Login.css'

export default function Login() {
  const { login, register } = useAuth()
  const navigate = useNavigate()
  const [modo, setModo] = useState('login') // 'login' | 'register'
  const [form, setForm] = useState({ nombre: '', email: '', password: '', telefono: '' })
  const [error, setError] = useState(null)
  const [loading, setLoading] = useState(false)

  const handleChange = e => setForm({ ...form, [e.target.name]: e.target.value })

  const handleSubmit = async e => {
    e.preventDefault()
    setLoading(true)
    setError(null)
    try {
      let user
      if (modo === 'login') {
        user = await login(form.email, form.password)
      } else {
        user = await register(form.nombre, form.email, form.password, form.telefono)
      }
      // Redirigir según rol
      navigate(user.rol === 'admin' ? '/admin-dashboard' : '/mi-cuenta')
    } catch (err) {
      setError(err.response?.data?.error || 'Error al procesar la solicitud')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="login-page">
      <div className="login-card">
        {/* Logo */}
        <div className="login-logo">
          <h1>Plazas Comerciales</h1>
          <p>Estado de México</p>
        </div>

        {/* Tabs */}
        <div className="login-tabs">
          <button
            className={modo === 'login' ? 'tab active' : 'tab'}
            onClick={() => { setModo('login'); setError(null) }}
          >
            Iniciar Sesión
          </button>
          <button
            className={modo === 'register' ? 'tab active' : 'tab'}
            onClick={() => { setModo('register'); setError(null) }}
          >
            Registrarse
          </button>
        </div>

        <form onSubmit={handleSubmit} className="login-form">
          {error && <div className="login-error">⚠️ {error}</div>}

          {modo === 'register' && (
            <>
              <div className="form-group">
                <label>Nombre completo</label>
                <input name="nombre" type="text" required placeholder="Tu nombre"
                  value={form.nombre} onChange={handleChange} />
              </div>
              <div className="form-group">
                <label>Teléfono</label>
                <input name="telefono" type="tel" placeholder="55 1234 5678"
                  value={form.telefono} onChange={handleChange} />
              </div>
            </>
          )}

          <div className="form-group">
            <label>Email</label>
            <input name="email" type="email" required placeholder="tu@email.com"
              value={form.email} onChange={handleChange} />
          </div>

          <div className="form-group">
            <label>Contraseña</label>
            <input name="password" type="password" required placeholder="••••••••"
              value={form.password} onChange={handleChange} />
          </div>

          <button type="submit" className="btn-login" disabled={loading}>
            {loading ? 'Procesando...' : modo === 'login' ? 'Entrar' : 'Crear cuenta'}
          </button>
        </form>

        <button className="btn-volver-home" onClick={() => navigate('/')}>
          ← Volver al inicio
        </button>
      </div>
    </div>
  )
}
