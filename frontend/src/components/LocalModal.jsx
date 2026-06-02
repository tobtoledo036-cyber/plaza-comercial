import { useState } from 'react'
import axios from 'axios'
import { useAuth } from '../context/AuthContext'
import './LocalModal.css'

const GIROS = [
  'Alimentos y Bebidas', 'Ropa y Accesorios', 'Calzado', 'Electrónica',
  'Salud y Belleza', 'Joyería y Relojes', 'Deportes', 'Juguetes',
  'Librería y Papelería', 'Hogar y Decoración', 'Servicios Financieros',
  'Telecomunicaciones', 'Óptica', 'Farmacia', 'Entretenimiento', 'Otro',
]

const ESTADO_CONFIG = {
  disponible:  { label: 'Disponible',    color: '#10b981' },
  negociacion: { label: 'En Negociación', color: '#3b82f6' },
  ocupado:     { label: 'Ocupado',        color: '#ef4444' },
  apartado:    { label: 'Apartado',       color: '#3b82f6' },
  vendido:     { label: 'Vendido',        color: '#ef4444' },
}

function LocalModal({ local, plaza, onClose, onSolicitudEnviada }) {
  const { user } = useAuth()

  const [formData, setFormData] = useState({
    nombre:        user?.nombre   || '',
    email:         user?.email    || '',
    telefono:      user?.telefono || '',
    empresa:       '',
    giro_propuesto: '',
    plan_negocio:  '',
  })
  const [loading,  setLoading]  = useState(false)
  const [error,    setError]    = useState(null)
  const [enviado,  setEnviado]  = useState(false)
  const [folioId,  setFolioId]  = useState(null)
  const [imgIdx,   setImgIdx]   = useState(0)

  const estadoInfo = ESTADO_CONFIG[local.estado] || ESTADO_CONFIG.disponible
  const isDisponible = local.estado === 'disponible'
  const imagenes = local.imagenes?.length ? local.imagenes : []

  const handleChange = e =>
    setFormData(prev => ({ ...prev, [e.target.name]: e.target.value }))

  const handleSubmit = async e => {
    e.preventDefault()
    setError(null)

    // Validaciones frontend
    if (!formData.giro_propuesto)
      return setError('Selecciona el giro de tu negocio')
    if (formData.plan_negocio.trim().length < 20)
      return setError('El plan de negocio debe tener al menos 20 caracteres')

    setLoading(true)
    try {
      const res = await axios.post('/api/solicitudes', {
        local_id:      local.id,
        nombre:        formData.nombre,
        email:         formData.email,
        telefono:      formData.telefono,
        empresa:       formData.empresa,
        giro_propuesto: formData.giro_propuesto,
        plan_negocio:  formData.plan_negocio,
      })
      setFolioId(res.data.solicitud_id)
      setEnviado(true)
      if (onSolicitudEnviada) onSolicitudEnviada(local.id)
    } catch (err) {
      setError(err.response?.data?.error || 'Error al enviar la solicitud')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-content" onClick={e => e.stopPropagation()}>
        <button className="modal-close" onClick={onClose}>✕</button>

        {/* Header */}
        <div className="modal-header">
          <h2>Local {local.numero}</h2>
          <span className="badge-estado" style={{ background: estadoInfo.color }}>
            {estadoInfo.label}
          </span>
        </div>

        <div className="modal-body">

          {/* Galería de imágenes */}
          {imagenes.length > 0 && (
            <div className="local-gallery">
              <img
                src={imagenes[imgIdx]}
                alt={`Local ${local.numero}`}
                className="gallery-main"
              />
              {imagenes.length > 1 && (
                <div className="gallery-thumbs">
                  {imagenes.map((img, i) => (
                    <img
                      key={i}
                      src={img}
                      alt=""
                      className={`gallery-thumb ${i === imgIdx ? 'active' : ''}`}
                      onClick={() => setImgIdx(i)}
                    />
                  ))}
                </div>
              )}
            </div>
          )}

          {/* Ficha del local */}
          <div className="local-details">
            <div className="detail-item">
              <span className="detail-label">Plaza</span>
              <span className="detail-value">{plaza.nombre}</span>
            </div>
            {local.piso && (
              <div className="detail-item">
                <span className="detail-label">Piso / Nivel</span>
                <span className="detail-value">📍 {local.piso}</span>
              </div>
            )}
            <div className="detail-item">
              <span className="detail-label">Área</span>
              <span className="detail-value">{local.area} m²</span>
            </div>
            <div className="detail-item">
              <span className="detail-label">Precio mensual</span>
              <span className="detail-value precio-compra">
                ${Number(local.precio).toLocaleString('es-MX')} MXN
              </span>
            </div>
            {local.giro && (
              <div className="detail-item">
                <span className="detail-label">Giro actual</span>
                <span className="detail-value">{local.giro}</span>
              </div>
            )}
            {local.descripcion && (
              <div className="detail-item full">
                <span className="detail-label">Descripción</span>
                <span className="detail-value">{local.descripcion}</span>
              </div>
            )}
          </div>

          {/* Formulario de solicitud */}
          {isDisponible && !enviado && (
            <form className="purchase-form" onSubmit={handleSubmit}>
              <h3>Solicitar este local</h3>

              {error && <div className="error-message">⚠️ {error}</div>}

              <div className="form-row">
                <div className="form-group">
                  <label>Nombre completo *</label>
                  <input
                    type="text" name="nombre" required
                    placeholder="Tu nombre completo"
                    value={formData.nombre} onChange={handleChange}
                  />
                </div>
                <div className="form-group">
                  <label>Email *</label>
                  <input
                    type="email" name="email" required
                    placeholder="tu@email.com"
                    value={formData.email} onChange={handleChange}
                  />
                </div>
              </div>

              <div className="form-row">
                <div className="form-group">
                  <label>Teléfono</label>
                  <input
                    type="tel" name="telefono"
                    placeholder="55 1234 5678"
                    value={formData.telefono} onChange={handleChange}
                  />
                </div>
                <div className="form-group">
                  <label>Empresa / Razón social</label>
                  <input
                    type="text" name="empresa"
                    placeholder="Nombre de tu empresa (opcional)"
                    value={formData.empresa} onChange={handleChange}
                  />
                </div>
              </div>

              <div className="form-group">
                <label>Giro del negocio *</label>
                <select
                  name="giro_propuesto" required
                  value={formData.giro_propuesto} onChange={handleChange}
                >
                  <option value="">— Selecciona un giro —</option>
                  {GIROS.map(g => (
                    <option key={g} value={g}>{g}</option>
                  ))}
                </select>
              </div>

              <div className="form-group">
                <label>Plan de negocio *</label>
                <textarea
                  name="plan_negocio" required rows={4}
                  placeholder="Describe brevemente tu negocio: qué vendes, a quién va dirigido, experiencia previa... (mínimo 20 caracteres)"
                  value={formData.plan_negocio} onChange={handleChange}
                />
                <span className="char-count">
                  {formData.plan_negocio.length} caracteres
                  {formData.plan_negocio.length < 20 && ' (mínimo 20)'}
                </span>
              </div>

              <button type="submit" className="btn-submit" disabled={loading}>
                {loading ? 'Enviando...' : '📋 Enviar Solicitud'}
              </button>
            </form>
          )}

          {/* Confirmación de envío */}
          {enviado && (
            <div className="solicitud-enviada">
              <div className="enviada-icon">✅</div>
              <h3>¡Solicitud enviada!</h3>
              <p>Tu folio es <strong>#{folioId}</strong></p>
              <p>Recibirás un correo de confirmación. Nuestro equipo revisará tu solicitud en 3-5 días hábiles.</p>
              <button className="btn-submit" onClick={onClose}>Cerrar</button>
            </div>
          )}

          {/* Local no disponible */}
          {!isDisponible && (
            <div className="not-available">
              <p>Este local no está disponible actualmente.</p>
              <p style={{ color: estadoInfo.color, fontWeight: 600 }}>
                Estado: {estadoInfo.label}
              </p>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}

export default LocalModal
