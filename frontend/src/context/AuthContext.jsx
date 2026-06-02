import { createContext, useContext, useState, useEffect } from 'react'
import axios from 'axios'

const AuthContext = createContext(null)

export function AuthProvider({ children }) {
  const [user, setUser]     = useState(null)
  const [token, setToken]   = useState(() => localStorage.getItem('token'))
  const [loading, setLoading] = useState(true)

  // Inyectar token en todas las peticiones axios
  useEffect(() => {
    if (token) {
      axios.defaults.headers.common['Authorization'] = `Bearer ${token}`
    } else {
      delete axios.defaults.headers.common['Authorization']
    }
  }, [token])

  // Al cargar, verificar si el token sigue siendo válido
  useEffect(() => {
    const verificar = async () => {
      if (!token) { setLoading(false); return }
      try {
        const res = await axios.get('/api/auth/me')
        setUser(res.data)
      } catch {
        logout()
      } finally {
        setLoading(false)
      }
    }
    verificar()
  }, [])

  const login = async (email, password) => {
    const res = await axios.post('/api/auth/login', { email, password })
    const { token: t, user: u } = res.data
    localStorage.setItem('token', t)
    setToken(t)
    setUser(u)
    return u
  }

  const register = async (nombre, email, password, telefono) => {
    const res = await axios.post('/api/auth/register', { nombre, email, password, telefono })
    const { token: t, user: u } = res.data
    localStorage.setItem('token', t)
    setToken(t)
    setUser(u)
    return u
  }

  const logout = () => {
    localStorage.removeItem('token')
    setToken(null)
    setUser(null)
    delete axios.defaults.headers.common['Authorization']
  }

  return (
    <AuthContext.Provider value={{ user, token, loading, login, register, logout }}>
      {children}
    </AuthContext.Provider>
  )
}

export const useAuth = () => useContext(AuthContext)
