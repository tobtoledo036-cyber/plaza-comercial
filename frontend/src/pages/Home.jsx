import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { plazas } from '../data/plazas'
import { useAuth } from '../context/AuthContext'
import './Home.css'

function Home() {
  const [hoveredPlaza, setHoveredPlaza] = useState(null)
  const navigate = useNavigate()
  const { user, logout } = useAuth()

  return (
    <div className="home">
      <div className="hero-section">
        <h1 className="main-title">Plazas Comerciales</h1>
        <p className="subtitle">Estado de México</p>
        <p className="description">
          Invierte en los mejores locales comerciales de la región
        </p>

        {/* Botones de acción */}
        <div className="hero-actions">
          {user ? (
            <>
              <button className="btn-admin" onClick={() => navigate(user.rol === 'admin' ? '/admin-dashboard' : '/mi-cuenta')}>
                {user.rol === 'admin' ? '📊 Dashboard Admin' : '👤 Mi Cuenta'}
              </button>
              <button className="btn-logout-home" onClick={() => logout()}>
                Cerrar sesión
              </button>
            </>
          ) : (
            <button className="btn-admin" onClick={() => navigate('/login')}>
              🔐 Iniciar Sesión
            </button>
          )}
        </div>
      </div>

      <div className="plazas-grid">
        {plazas.map((plaza) => (
          <div
            key={plaza.id}
            className={`plaza-card ${hoveredPlaza === plaza.id ? 'hovered' : ''}`}
            onMouseEnter={() => setHoveredPlaza(plaza.id)}
            onMouseLeave={() => setHoveredPlaza(null)}
            onClick={() => navigate(`/plaza/${plaza.id}`)}
          >
            <div 
              className="plaza-background"
              style={{
                backgroundImage: hoveredPlaza === plaza.id 
                  ? `url(${plaza.imagen})` 
                  : 'none'
              }}
            />
            
            <div className="plaza-content">
              <div className="plaza-logo">
                <h2>{plaza.nombre}</h2>
              </div>
              
              {hoveredPlaza === plaza.id && (
                <div className="plaza-info">
                  <p className="ubicacion">📍 {plaza.ubicacion}</p>
                  <p className="descripcion">{plaza.descripcion}</p>
                  <p className="locales">{plaza.locales} locales disponibles</p>
                  <button className="btn-ver">Ver Locales →</button>
                </div>
              )}
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}

export default Home
