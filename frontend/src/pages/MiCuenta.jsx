import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import axios from '../api/axios'
import { useAuth } from '../context/AuthContext'
import './MiCuenta.css'

const ESTADO_SOL = {
  pendiente: { label: 'Pendiente de revisión', color: '#fbbf24', icon: '⏳' },
  aprobada:  { label: 'Aprobada',              color: '#10b981', icon: '✅' },
  rechazada: { label: 'Rechazada',             color: '#ef4444', icon: '❌' },
}

// ── Botón de pago PayPal para solicitudes aprobadas ──────────
function PagarButton({ solicitudId, precio, local, plaza }) {
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)

  const handlePagar = async () => {
    setLoading(true)
    setError(null)
    try {
      // 1. Crear transacción desde la solicitud aprobada
      const transRes = await axios.post(`/api/solicitudes/${solicitudId}/pagar`)
      const { transaccionId } = transRes.data

      // 2. Crear orden PayPal
      const paypalRes = await axios.post('/api/paypal/create-order', { transaccionId })
      
      // 3. Redirigir a PayPal
      window.location.href = paypalRes.data.approveLink
    } catch (err) {
      setError(err.response?.data?.error || 'Error al iniciar el pago')
      setLoading(false)
    }
  }

  return (
    <div className="pagar-section">
      <div className="pagar-info">
        <span>💰 Tu solicitud fue aprobada. Completa el pago para confirmar el local.</span>
        {precio && <strong>${Number(precio).toLocaleString('es-MX')} MXN</strong>}
      </div>
      {error && <p className="pagar-error">⚠️ {error}</p>}
      <button className="btn-pagar-paypal" onClick={handlePagar} disabled={loading}>
        {loading ? 'Redirigiendo...' : '💳 Pagar con PayPal'}
      </button>
    </div>
  )
}

// ── Página principal ─────────────────────────────────────────
export default function MiCuenta() {
  const { user, logout } = useAuth()
  const navigate = useNavigate()
  const [tab, setTab] = useState('solicitudes')
  const [locales, setLocales] = useState([])
  const [solicitudes, setSolicitudes] = useState([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (!user) { navigate('/login'); return }
    Promise.all([
      axios.get('/api/usuario/mis-locales').catch(() => ({ data: [] })),
      axios.get('/api/solicitudes/mis-solicitudes').catch(() => ({ data: [] })),
    ]).then(([locRes, solRes]) => {
      setLocales(locRes.data)
      setSolicitudes(solRes.data)
    }).finally(() => setLoading(false))
  }, [user])

  const descargarPDF = async (id) => {
    try {
      const response = await axios.get(`/api/pdf/transaccion/${id}`, {
        responseType: 'blob',
      })
      const url = window.URL.createObjectURL(new Blob([response.data], { type: 'application/pdf' }))
      const link = document.createElement('a')
      link.href = url
      link.setAttribute('download', `comprobante-${String(id).padStart(6, '0')}.pdf`)
      document.body.appendChild(link)
      link.click()
      link.remove()
      window.URL.revokeObjectURL(url)
    } catch (err) {
      alert('Error al descargar el comprobante: ' + (err.response?.data?.error || err.message))
    }
  }

  const diasRestantes = (fecha) => {
    if (!fecha) return null
    const diff = new Date(fecha) - new Date()
    return Math.max(0, Math.ceil(diff / (1000 * 60 * 60 * 24)))
  }

  if (loading) return (
    <div className="cuenta-loading"><div className="spinner" /><p>Cargando tu cuenta...</p></div>
  )

  return (
    <div className="cuenta-page">
      <header className="cuenta-header">
        <button className="btn-back-cuenta" onClick={() => navigate('/')}>← Inicio</button>
        <div className="cuenta-title">
          <h1>Mi Cuenta</h1>
          <p>Bienvenido, <strong>{user?.nombre}</strong></p>
        </div>
        <button className="btn-logout" onClick={() => { logout(); navigate('/login') }}>
          Cerrar sesión
        </button>
      </header>

      <div className="cuenta-tabs">
        <button className={`cuenta-tab ${tab === 'solicitudes' ? 'active' : ''}`} onClick={() => setTab('solicitudes')}>
          📋 Mis Solicitudes
          {solicitudes.filter(s => s.estado === 'pendiente').length > 0 && (
            <span className="tab-badge">{solicitudes.filter(s => s.estado === 'pendiente').length}</span>
          )}
        </button>
        <button className={`cuenta-tab ${tab === 'locales' ? 'active' : ''}`} onClick={() => setTab('locales')}>
          🏪 Mis Locales
        </button>
      </div>

      <div className="cuenta-content">

        {/* ── TAB: SOLICITUDES ── */}
        {tab === 'solicitudes' && (
          solicitudes.length === 0 ? (
            <div className="cuenta-empty">
              <div className="empty-icon">📋</div>
              <h2>No tienes solicitudes aún</h2>
              <p>Explora nuestras plazas y solicita el local ideal para tu negocio.</p>
              <button className="btn-explorar" onClick={() => navigate('/')}>Ver Plazas</button>
            </div>
          ) : (
            <>
              <h2 className="seccion-titulo">Mis Solicitudes ({solicitudes.length})</h2>
              <div className="solicitudes-list">
                {solicitudes.map(sol => {
                  const est = ESTADO_SOL[sol.estado] || ESTADO_SOL.pendiente
                  return (
                    <div key={sol.id} className={`solicitud-card estado-${sol.estado}`}>
                      <div className="sol-header">
                        <div>
                          <h3>Local {sol.local_numero} — {sol.plaza_nombre}</h3>
                          <span className="sol-giro">{sol.giro_propuesto}</span>
                        </div>
                        <span className="sol-badge" style={{ background: `${est.color}22`, color: est.color, border: `1px solid ${est.color}55` }}>
                          {est.icon} {est.label}
                        </span>
                      </div>

                      <div className="sol-meta">
                        <span>Folio #{sol.id}</span>
                        <span>Enviada el {new Date(sol.created_at).toLocaleDateString('es-MX', { year: 'numeric', month: 'short', day: 'numeric' })}</span>
                      </div>

                      {sol.respuesta_admin && (
                        <div className={`sol-respuesta ${sol.estado}`}>
                          <strong>Respuesta del administrador:</strong>
                          <p>{sol.respuesta_admin}</p>
                        </div>
                      )}

                      {sol.estado === 'pendiente' && (
                        <p className="sol-aviso">Tu solicitud está siendo revisada. Te notificaremos por correo.</p>
                      )}

                      {sol.estado === 'aprobada' && (
                        <PagarButton
                          solicitudId={sol.id}
                          precio={sol.area * 500}
                          local={sol.local_numero}
                          plaza={sol.plaza_nombre}
                        />
                      )}
                    </div>
                  )
                })}
              </div>
            </>
          )
        )}

        {/* ── TAB: LOCALES ── */}
        {tab === 'locales' && (
          locales.length === 0 ? (
            <div className="cuenta-empty">
              <div className="empty-icon">🏪</div>
              <h2>No tienes locales aún</h2>
              <p>Completa el pago de una solicitud aprobada para ver tu local aquí.</p>
              <button className="btn-explorar" onClick={() => setTab('solicitudes')}>Ver Solicitudes</button>
            </div>
          ) : (
            <>
              <h2 className="seccion-titulo">Mis Locales ({locales.length})</h2>
              <div className="locales-grid">
                {locales.map(local => {
                  const dias = diasRestantes(local.fecha_vencimiento_apartado)
                  const esApartado = local.tipo === 'apartado'
                  const restante = Number(local.precio_compra) - Number(local.monto)
                  return (
                    <div key={local.transaccion_id} className={`local-card ${local.tipo}`}>
                      <div className={`local-badge ${local.tipo}`}>
                        {local.tipo === 'compra' ? '🏪 Comprado' : '🔒 Apartado'}
                      </div>
                      <div className="local-card-header">
                        <h3>Local {local.numero}</h3>
                        <span className="local-plaza">{local.plaza_nombre}</span>
                      </div>
                      <div className="local-info-grid">
                        <div className="info-item"><span className="info-label">Área</span><span className="info-value">{local.area} m²</span></div>
                        <div className="info-item"><span className="info-label">Precio total</span><span className="info-value">${Number(local.precio_compra).toLocaleString('es-MX')} MXN</span></div>
                        <div className="info-item"><span className="info-label">Pagado</span><span className="info-value pagado">${Number(local.monto).toLocaleString('es-MX')} MXN</span></div>
                        <div className="info-item"><span className="info-label">Ubicación</span><span className="info-value">{local.plaza_ubicacion}</span></div>
                      </div>
                      {esApartado && (
                        <div className="apartado-info">
                          <div className="apartado-row"><span>Porcentaje pagado</span><strong>{local.porcentaje_apartado || 30}%</strong></div>
                          <div className="apartado-row"><span>Saldo restante</span><strong className="restante">${restante.toLocaleString('es-MX')} MXN</strong></div>
                          {dias !== null && (
                            <div className="apartado-row">
                              <span>Días restantes</span>
                              <strong className={dias <= 7 ? 'urgente' : 'dias-ok'}>{dias === 0 ? '⚠️ Vencido' : `${dias} días`}</strong>
                            </div>
                          )}
                        </div>
                      )}
                      <div className="local-card-footer">
                        <span className="fecha-trans">
                          {local.tipo === 'compra' ? 'Comprado' : 'Apartado'} el {new Date(local.fecha_transaccion).toLocaleDateString('es-MX', { year: 'numeric', month: 'short', day: 'numeric' })}
                        </span>
                        <button className="btn-pdf-local" onClick={() => descargarPDF(local.transaccion_id)}>📄 Comprobante</button>
                      </div>
                    </div>
                  )
                })}
              </div>
            </>
          )
        )}
      </div>
    </div>
  )
}
