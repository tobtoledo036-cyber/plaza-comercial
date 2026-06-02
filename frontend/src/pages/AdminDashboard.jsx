import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import axios from '../api/axios'
import {
  BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer,
  PieChart, Pie, Cell, Legend, LineChart, Line, CartesianGrid
} from 'recharts'
import { useAuth } from '../context/AuthContext'
import './AdminDashboard.css'

const COLORS = ['#10b981', '#3b82f6', '#ef4444', '#b026ff']

export default function AdminDashboard() {
  const { user, logout } = useAuth()
  const navigate = useNavigate()
  const [data, setData] = useState(null)
  const [transacciones, setTransacciones] = useState([])
  const [solicitudes, setSolicitudes] = useState([])
  const [solTotal, setSolTotal] = useState(0)
  const [loading, setLoading] = useState(true)
  const [tab, setTab] = useState('resumen')

  const [filtroEstado, setFiltroEstado] = useState('')
  const [filtroGiro,   setFiltroGiro]   = useState('')
  const [respuestaModal, setRespuestaModal] = useState(null)
  const [respuestaTexto, setRespuestaTexto] = useState('')
  const [procesando, setProcesando] = useState(false)

  useEffect(() => {
    if (!user || user.rol !== 'admin') { navigate('/login'); return }
    cargar()
  }, [user])

  const cargar = async () => {
    try {
      const [dash, trans] = await Promise.all([
        axios.get('/api/admin/dashboard'),
        axios.get('/api/admin/transacciones'),
      ])
      setData(dash.data)
      setTransacciones(trans.data)
    } catch (err) {
      console.error(err)
    } finally {
      setLoading(false)
    }
  }

  const cargarSolicitudes = async () => {
    try {
      const params = new URLSearchParams()
      if (filtroEstado) params.append('status', filtroEstado)
      if (filtroGiro)   params.append('giro', filtroGiro)
      const res = await axios.get(`/api/solicitudes?${params}`)
      setSolicitudes(res.data.solicitudes)
      setSolTotal(res.data.total)
    } catch (err) { console.error(err) }
  }

  useEffect(() => {
    if (tab === 'solicitudes') cargarSolicitudes()
  }, [tab, filtroEstado, filtroGiro])

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
      alert('Error al descargar: ' + (err.response?.data?.error || err.message))
    }
  }
  const descargarCSV = async () => {
    try {
      const params = new URLSearchParams()
      if (filtroEstado) params.append('status', filtroEstado)
      if (filtroGiro)   params.append('giro', filtroGiro)
      const response = await axios.get(`/api/admin/export/csv?${params}`, {
        responseType: 'blob',
      })
      const url = window.URL.createObjectURL(new Blob([response.data], { type: 'text/csv;charset=utf-8;' }))
      const link = document.createElement('a')
      link.href = url
      link.setAttribute('download', `solicitudes-${Date.now()}.csv`)
      document.body.appendChild(link)
      link.click()
      link.remove()
      window.URL.revokeObjectURL(url)
    } catch (err) {
      alert('Error al exportar: ' + (err.response?.data?.error || err.message))
    }
  }

  const abrirRespuesta = (id, accion) => { setRespuestaModal({ id, accion }); setRespuestaTexto('') }

  const confirmarAccion = async () => {
    if (!respuestaModal) return
    setProcesando(true)
    try {
      const ep = respuestaModal.accion === 'aprobar'
        ? `/api/solicitudes/${respuestaModal.id}/aprobar`
        : `/api/solicitudes/${respuestaModal.id}/rechazar`
      await axios.patch(ep, { respuesta: respuestaTexto })
      setRespuestaModal(null)
      cargarSolicitudes()
      cargar()
    } catch (err) {
      alert(err.response?.data?.error || 'Error al procesar')
    } finally { setProcesando(false) }
  }

  if (loading) return (
    <div className="dash-loading"><div className="spinner" /><p>Cargando dashboard...</p></div>
  )

  const pieLocales = [
    { name: 'Disponibles',    value: data.locales.disponibles    || 0 },
    { name: 'En Negociación', value: data.locales.en_negociacion || 0 },
    { name: 'Ocupados',       value: data.locales.ocupados       || 0 },
  ]
  const pieSolicitudes = [
    { name: 'Pendientes', value: data.solicitudes?.pendientes || 0 },
    { name: 'Aprobadas',  value: data.solicitudes?.aprobadas  || 0 },
    { name: 'Rechazadas', value: data.solicitudes?.rechazadas || 0 },
  ]

  return (
    <div className="dash-container">
      <aside className="dash-sidebar">
        <div className="sidebar-logo"><h2>Plazas</h2><span>Admin</span></div>
        <nav className="sidebar-nav">
          <button className={tab === 'resumen' ? 'nav-item active' : 'nav-item'} onClick={() => setTab('resumen')}>📊 Resumen</button>
          <button className={tab === 'solicitudes' ? 'nav-item active' : 'nav-item'} onClick={() => setTab('solicitudes')}>
            📋 Solicitudes
            {(data.solicitudes?.pendientes || 0) > 0 && (
              <span className="badge-pending">{data.solicitudes.pendientes}</span>
            )}
          </button>
          <button className={tab === 'transacciones' ? 'nav-item active' : 'nav-item'} onClick={() => setTab('transacciones')}>💳 Transacciones</button>
          <button className="nav-item" onClick={() => navigate('/')}>🏠 Ver Sitio</button>
        </nav>
        <div className="sidebar-user">
          <p>{user?.nombre}</p>
          <button onClick={() => { logout(); navigate('/login') }}>Cerrar sesión</button>
        </div>
      </aside>

      <main className="dash-main">
        <header className="dash-header">
          <h1>{tab === 'resumen' ? 'Dashboard' : tab === 'solicitudes' ? 'Solicitudes de Renta' : 'Transacciones'}</h1>
          <button className="btn-refresh" onClick={cargar}>🔄 Actualizar</button>
        </header>

        {tab === 'resumen' && (
          <>
            <div className="kpi-grid">
              <div className="kpi-card green"><span className="kpi-icon">🏪</span><div><p className="kpi-label">Disponibles</p><p className="kpi-value">{data.locales.disponibles}</p></div></div>
              <div className="kpi-card blue"><span className="kpi-icon">🤝</span><div><p className="kpi-label">En Negociación</p><p className="kpi-value">{data.locales.en_negociacion || 0}</p></div></div>
              <div className="kpi-card red"><span className="kpi-icon">✅</span><div><p className="kpi-label">Ocupados</p><p className="kpi-value">{data.locales.ocupados || 0}</p></div></div>
              <div className="kpi-card purple"><span className="kpi-icon">📋</span><div><p className="kpi-label">Solicitudes Pendientes</p><p className="kpi-value">{data.solicitudes?.pendientes || 0}</p></div></div>
            </div>

            <div className="charts-row">
              <div className="chart-card">
                <h3>Estado de Locales</h3>
                <ResponsiveContainer width="100%" height={220}>
                  <PieChart>
                    <Pie data={pieLocales} cx="50%" cy="50%" innerRadius={55} outerRadius={85} dataKey="value">
                      {pieLocales.map((_, i) => <Cell key={i} fill={COLORS[i]} />)}
                    </Pie>
                    <Tooltip /><Legend />
                  </PieChart>
                </ResponsiveContainer>
              </div>
              <div className="chart-card">
                <h3>Solicitudes por Estado</h3>
                <ResponsiveContainer width="100%" height={220}>
                  <PieChart>
                    <Pie data={pieSolicitudes} cx="50%" cy="50%" innerRadius={55} outerRadius={85} dataKey="value">
                      {pieSolicitudes.map((_, i) => <Cell key={i} fill={COLORS[i]} />)}
                    </Pie>
                    <Tooltip /><Legend />
                  </PieChart>
                </ResponsiveContainer>
              </div>
              <div className="chart-card wide">
                <h3>Ingresos por Mes</h3>
                <ResponsiveContainer width="100%" height={220}>
                  <LineChart data={data.ingresosMes}>
                    <CartesianGrid strokeDasharray="3 3" stroke="#333" />
                    <XAxis dataKey="mes" stroke="#888" tick={{ fontSize: 11 }} />
                    <YAxis stroke="#888" tick={{ fontSize: 11 }} tickFormatter={v => `$${(v/1000).toFixed(0)}k`} />
                    <Tooltip formatter={v => [`$${Number(v).toLocaleString('es-MX')}`, 'Ingresos']} />
                    <Line type="monotone" dataKey="ingresos" stroke="#b026ff" strokeWidth={2} dot={{ fill: '#b026ff' }} />
                  </LineChart>
                </ResponsiveContainer>
              </div>
            </div>

            <div className="chart-card full">
              <h3>Locales por Plaza</h3>
              <ResponsiveContainer width="100%" height={260}>
                <BarChart data={data.porPlaza} margin={{ left: 10 }}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#333" />
                  <XAxis dataKey="nombre" stroke="#888" tick={{ fontSize: 11 }} />
                  <YAxis stroke="#888" tick={{ fontSize: 11 }} />
                  <Tooltip /><Legend />
                  <Bar dataKey="disponibles"    name="Disponibles"    fill="#10b981" radius={[4,4,0,0]} />
                  <Bar dataKey="en_negociacion" name="En Negociación" fill="#3b82f6" radius={[4,4,0,0]} />
                  <Bar dataKey="ocupados"       name="Ocupados"       fill="#ef4444" radius={[4,4,0,0]} />
                </BarChart>
              </ResponsiveContainer>
            </div>

            <div className="chart-card full">
              <h3>Últimas 20 Solicitudes</h3>
              <div className="mini-table-wrap">
                <table className="mini-table">
                  <thead><tr><th>Solicitante</th><th>Plaza</th><th>Local</th><th>Giro</th><th>Estado</th><th>Fecha</th></tr></thead>
                  <tbody>
                    {data.ultimasSolicitudes.map(s => (
                      <tr key={s.id}>
                        <td>{s.nombre}</td><td>{s.plaza_nombre}</td>
                        <td className="local-num">{s.local_numero}</td>
                        <td>{s.giro_propuesto}</td>
                        <td><span className={`badge-estado-sol ${s.estado}`}>{s.estado}</span></td>
                        <td>{new Date(s.created_at).toLocaleDateString('es-MX')}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          </>
        )}

        {tab === 'solicitudes' && (
          <div className="chart-card full">
            <div className="filtros-row">
              <select value={filtroEstado} onChange={e => setFiltroEstado(e.target.value)}>
                <option value="">Todos los estados</option>
                <option value="pendiente">Pendientes</option>
                <option value="aprobada">Aprobadas</option>
                <option value="rechazada">Rechazadas</option>
              </select>
              <input type="text" placeholder="Filtrar por giro..." value={filtroGiro} onChange={e => setFiltroGiro(e.target.value)} />
              <button className="btn-csv" onClick={descargarCSV}>⬇️ Exportar CSV</button>
            </div>
            <h3>Solicitudes ({solTotal})</h3>
            <div className="mini-table-wrap">
              <table className="mini-table">
                <thead><tr><th>#</th><th>Fecha</th><th>Solicitante</th><th>Email</th><th>Plaza</th><th>Local</th><th>Giro</th><th>Estado</th><th>Acciones</th></tr></thead>
                <tbody>
                  {solicitudes.map(s => (
                    <tr key={s.id} className={`row-sol-${s.estado}`}>
                      <td>#{s.id}</td>
                      <td>{new Date(s.created_at).toLocaleDateString('es-MX')}</td>
                      <td>{s.nombre}</td><td className="email-cell">{s.email}</td>
                      <td>{s.plaza_nombre}</td><td className="local-num">{s.local_numero}</td>
                      <td>{s.giro_propuesto}</td>
                      <td><span className={`badge-estado-sol ${s.estado}`}>{s.estado}</span></td>
                      <td>
                        {s.estado === 'pendiente' && (
                          <div className="acciones-btns">
                            <button className="btn-aprobar" onClick={() => abrirRespuesta(s.id, 'aprobar')}>✅</button>
                            <button className="btn-rechazar" onClick={() => abrirRespuesta(s.id, 'rechazar')}>❌</button>
                          </div>
                        )}
                      </td>
                    </tr>
                  ))}
                  {solicitudes.length === 0 && (
                    <tr><td colSpan={9} style={{ textAlign:'center', color:'#888', padding:'2rem' }}>Sin solicitudes</td></tr>
                  )}
                </tbody>
              </table>
            </div>
          </div>
        )}

        {tab === 'transacciones' && (
          <div className="chart-card full">
            <h3>Todas las Transacciones ({transacciones.length})</h3>
            <div className="mini-table-wrap">
              <table className="mini-table">
                <thead><tr><th>ID</th><th>Fecha</th><th>Cliente</th><th>Email</th><th>Plaza</th><th>Local</th><th>Tipo</th><th>Monto</th><th>Estado</th><th>PDF</th></tr></thead>
                <tbody>
                  {transacciones.map(t => (
                    <tr key={t.id} className={`row-${t.estado_pago}`}>
                      <td>#{t.id}</td>
                      <td>{new Date(t.created_at).toLocaleDateString('es-MX')}</td>
                      <td>{t.cliente_nombre}</td><td>{t.cliente_email}</td>
                      <td>{t.plaza_nombre}</td><td className="local-num">{t.local_numero}</td>
                      <td><span className={`badge-tipo ${t.tipo}`}>{t.tipo}</span></td>
                      <td className="monto">${Number(t.monto).toLocaleString('es-MX')}</td>
                      <td><span className={`badge-estado ${t.estado_pago}`}>{t.estado_pago}</span></td>
                      <td>{t.estado_pago === 'completado' && <button className="btn-pdf" onClick={() => descargarPDF(t.id)}>📄</button>}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}
      </main>

      {respuestaModal && (
        <div className="modal-overlay-admin" onClick={() => setRespuestaModal(null)}>
          <div className="modal-respuesta" onClick={e => e.stopPropagation()}>
            <h3>{respuestaModal.accion === 'aprobar' ? '✅ Aprobar solicitud' : '❌ Rechazar solicitud'}</h3>
            <p>Mensaje para el solicitante (opcional):</p>
            <textarea rows={4} value={respuestaTexto} onChange={e => setRespuestaTexto(e.target.value)}
              placeholder={respuestaModal.accion === 'aprobar' ? 'Ej: Bienvenido, nos pondremos en contacto...' : 'Ej: Lamentamos informarte que...'} />
            <div className="modal-respuesta-btns">
              <button className="btn-cancelar" onClick={() => setRespuestaModal(null)}>Cancelar</button>
              <button className={respuestaModal.accion === 'aprobar' ? 'btn-aprobar' : 'btn-rechazar'}
                onClick={confirmarAccion} disabled={procesando}>
                {procesando ? 'Procesando...' : (respuestaModal.accion === 'aprobar' ? 'Confirmar aprobación' : 'Confirmar rechazo')}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
