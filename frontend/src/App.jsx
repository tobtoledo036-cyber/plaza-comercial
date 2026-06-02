import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom'
import { AuthProvider, useAuth } from './context/AuthContext'
import Home from './pages/Home'
import PlazaMap from './pages/PlazaMap'
import PagoExitoso from './pages/PagoExitoso'
import PagoCancelado from './pages/PagoCancelado'
import Login from './pages/Login'
import AdminDashboard from './pages/AdminDashboard'
import MiCuenta from './pages/MiCuenta'
import './App.css'

// Ruta protegida: redirige a /login si no hay sesión
function PrivateRoute({ children, adminOnly = false }) {
  const { user, loading } = useAuth()
  if (loading) return null
  if (!user) return <Navigate to="/login" replace />
  if (adminOnly && user.rol !== 'admin') return <Navigate to="/mi-cuenta" replace />
  return children
}

function AppRoutes() {
  return (
    <Routes>
      <Route path="/"               element={<Home />} />
      <Route path="/plaza/:id"      element={<PlazaMap />} />
      <Route path="/pago-exitoso"   element={<PagoExitoso />} />
      <Route path="/pago-cancelado" element={<PagoCancelado />} />
      <Route path="/login"          element={<Login />} />

      <Route path="/admin-dashboard" element={
        <PrivateRoute adminOnly>
          <AdminDashboard />
        </PrivateRoute>
      } />

      <Route path="/mi-cuenta" element={
        <PrivateRoute>
          <MiCuenta />
        </PrivateRoute>
      } />

      {/* Ruta legacy /admin redirige al nuevo dashboard */}
      <Route path="/admin" element={<Navigate to="/admin-dashboard" replace />} />
    </Routes>
  )
}

function App() {
  return (
    <AuthProvider>
      <Router>
        <AppRoutes />
      </Router>
    </AuthProvider>
  )
}

export default App
