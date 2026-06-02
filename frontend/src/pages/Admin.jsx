import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import axios from 'axios'
import './Admin.css'

export default function Admin() {
  const navigate = useNavigate()
  const [transacciones, setTransacciones] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)
  const [filtro, setFiltro] = useState('todas')
  const [tipoFiltro, setTipoFiltro] = useState('todos')

  useEffect(() => {
    cargarTransacciones()
  }, [])

  const cargarTransacciones = async () => {
    try {
      setLoading(true)
      setError(null)
      const response = await axios.get('/api/transacciones')
      setTransacciones(response.data)
      setLoading(false)
    } catch (error) {
      console.error('Error cargando transacciones:', error)
      setError('Error al cargar las transacciones')
      setLoading(false)
    }
  }

  if (loading) {
    return (
      <div className="admin-loading">
        <div className="spinner"></div>
        <p>Cargando transacciones...</p>
      </div>
    )
  }

  if (error) {
    return (
      <div className="admin-error">
        <h2>❌ Error</h2>
        <p>{error}</p>
        <button onClick={() => navigate('/')}>Volver al inicio</button>
      </div>
    )
  }

  const transaccionesFiltradas = transacciones.filter(t => {
    const cumpleFiltroEstado = filtro === 'todas' || t.estado_pago === filtro
    const cumpleFiltroTipo = tipoFiltro === 'todos' || t.tipo === tipoFiltro
    return cumpleFiltroEstado && cumpleFiltroTipo
  })

  const stats = {
    total: transacciones.length,
    completadas: transacciones.filter(t => t.estado_pago === 'completado').length,
    pendientes: transacciones.filter(t => t.estado_pago === 'pendiente').length,
    canceladas: transacciones.filter(t => t.estado_pago === 'cancelado').length,
    ingresoTotal: transacciones
      .filter(t => t.estado_pago === 'completado')
      .reduce((sum, t) => sum + parseFloat(t.monto || 0), 0),
    compras: transacciones.filter(t => t.tipo === 'compra' && t.estado_pago === 'completado').length,
    apartados: transacciones.filter(t => t.tipo === 'apartado' && t.estado_pago === 'completado').length,
  }

  return (
    <div className="admin-container">
      <header className="admin-header">
        <button className="btn-back-admin" onClick={() => navigate('/')}>
          ← Volver
        </button>
        <h1>📊 Panel de Administración</h1>
        <p>Gestión de Transacciones y Ventas</p>
      </header>

      {/* Estadísticas */}
      <div className="stats-grid">
        <div className="stat-card total">
          <div className="stat-icon">💰</div>
          <div className="stat-info">
            <h3>Ingresos Totales</h3>
            <p className="stat-value">${stats.ingresoTotal.toLocaleString('es-MX', {minimumFractionDigits: 2})} MXN</p>
          </div>
        </div>

        <div className="stat-card completadas">
          <div className="stat-icon">✅</div>
          <div className="stat-info">
            <h3>Completadas</h3>
            <p className="stat-value">{stats.completadas}</p>
          </div>
        </div>

        <div className="stat-card pendientes">
          <div className="stat-icon">⏳</div>
          <div className="stat-info">
            <h3>Pendientes</h3>
            <p className="stat-value">{stats.pendientes}</p>
          </div>
        </div>

        <div className="stat-card canceladas">
          <div className="stat-icon">❌</div>
          <div className="stat-info">
            <h3>Canceladas</h3>
            <p className="stat-value">{stats.canceladas}</p>
          </div>
        </div>

        <div className="stat-card compras">
          <div className="stat-icon">🏪</div>
          <div className="stat-info">
            <h3>Compras</h3>
            <p className="stat-value">{stats.compras}</p>
          </div>
        </div>

        <div className="stat-card apartados">
          <div className="stat-icon">🔒</div>
          <div className="stat-info">
            <h3>Apartados</h3>
            <p className="stat-value">{stats.apartados}</p>
          </div>
        </div>
      </div>

      {/* Filtros */}
      <div className="filters">
        <div className="filter-group">
          <label>Estado:</label>
          <select value={filtro} onChange={(e) => setFiltro(e.target.value)}>
            <option value="todas">Todas</option>
            <option value="completado">Completadas</option>
            <option value="pendiente">Pendientes</option>
            <option value="cancelado">Canceladas</option>
          </select>
        </div>

        <div className="filter-group">
          <label>Tipo:</label>
          <select value={tipoFiltro} onChange={(e) => setTipoFiltro(e.target.value)}>
            <option value="todos">Todos</option>
            <option value="compra">Compras</option>
            <option value="apartado">Apartados</option>
          </select>
        </div>

        <button className="btn-refresh" onClick={cargarTransacciones}>
          🔄 Actualizar
        </button>
      </div>

      {/* Tabla de transacciones */}
      <div className="transactions-table-container">
        <table className="transactions-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>Fecha</th>
              <th>Cliente</th>
              <th>Email</th>
              <th>Plaza</th>
              <th>Local</th>
              <th>Tipo</th>
              <th>Monto</th>
              <th>Estado</th>
            </tr>
          </thead>
          <tbody>
            {transaccionesFiltradas.length === 0 ? (
              <tr>
                <td colSpan="9" className="no-data">
                  No hay transacciones con los filtros seleccionados
                </td>
              </tr>
            ) : (
              transaccionesFiltradas.map((t) => (
                <tr key={t.id} className={`row-${t.estado_pago}`}>
                  <td>{t.id}</td>
                  <td>{new Date(t.created_at).toLocaleDateString('es-MX', {
                    year: 'numeric',
                    month: 'short',
                    day: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit'
                  })}</td>
                  <td>{t.cliente_nombre}</td>
                  <td>{t.cliente_email}</td>
                  <td>{t.plaza_nombre}</td>
                  <td className="local-numero">{t.local_numero}</td>
                  <td>
                    <span className={`badge-tipo ${t.tipo}`}>
                      {t.tipo === 'compra' ? '🏪 Compra' : '🔒 Apartado'}
                    </span>
                  </td>
                  <td className="monto">${parseFloat(t.monto || 0).toLocaleString('es-MX')}</td>
                  <td>
                    <span className={`badge-estado ${t.estado_pago}`}>
                      {t.estado_pago === 'completado' && '✅ Completado'}
                      {t.estado_pago === 'pendiente' && '⏳ Pendiente'}
                      {t.estado_pago === 'cancelado' && '❌ Cancelado'}
                    </span>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {/* Resumen */}
      <div className="summary">
        <p>
          Mostrando <strong>{transaccionesFiltradas.length}</strong> de{' '}
          <strong>{transacciones.length}</strong> transacciones
        </p>
      </div>
    </div>
  )
}
