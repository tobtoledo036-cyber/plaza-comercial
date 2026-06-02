import { useState, useEffect, useRef, useCallback } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { MapContainer, TileLayer, useMap } from 'react-leaflet'
import L from 'leaflet'
import axios from '../api/axios'
import 'leaflet/dist/leaflet.css'
import { plazas } from '../data/plazas'
import LocalModal from '../components/LocalModal'
import './PlazaMap.css'

const INICIO_LAT = 19.4326
const INICIO_LNG = -99.1332
const INICIO_ZOOM = 9

const isMobile = () =>
  /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ||
  window.innerWidth <= 768

const COLORES = {
  disponible:  '#10b981',
  negociacion: '#3b82f6',
  ocupado:     '#ef4444',
  apartado:    '#3b82f6',
  vendido:     '#ef4444',
}

// GeoJSON usa [lng, lat] — Leaflet usa [lat, lng]
function lngLatToLatLng(coords) {
  return coords.map(([lng, lat]) => [lat, lng])
}

// ── Animación de vuelo ──────────────────────────────────────────────
function FlyToPlaza({ plaza, onZoomComplete }) {
  const map = useMap()
  const done = useRef(false)

  useEffect(() => {
    if (!plaza || done.current) return
    done.current = true

    if (isMobile()) {
      map.setView([plaza.lat, plaza.lng], plaza.zoom_final, { animate: false })
      setTimeout(() => onZoomComplete(), 300)
      return
    }

    map.setView([INICIO_LAT, INICIO_LNG], INICIO_ZOOM, { animate: false })
    setTimeout(() => {
      map.flyTo([plaza.lat, plaza.lng], plaza.zoom_final, {
        animate: true, duration: 2.5, easeLinearity: 0.25,
      })
    }, 300)
    setTimeout(() => onZoomComplete(), 3000)
  }, [plaza, map, onZoomComplete])

  return null
}

// ── Capa GeoJSON: perímetro + locales ───────────────────────────────
function GeoJSONOverlay({ geojson, pisoNombre, onLocalClick }) {
  const map = useMap()
  const layerRef = useRef(null)

  useEffect(() => {
    if (!geojson?.features?.length) return
    if (layerRef.current) { layerRef.current.remove(); layerRef.current = null }

    const group = L.layerGroup()

    geojson.features.forEach((feature) => {
      const props = feature.properties || {}
      const geom  = feature.geometry

      // ── Perímetro (Polygon) ──────────────────────────────────────
      if (geom.type === 'Polygon' && props.tipo === 'perimetro') {
        const coords = lngLatToLatLng(geom.coordinates[0])
        L.polygon(coords, {
          color: '#b026ff',
          fillColor: 'rgba(176,38,255,0.06)',
          fillOpacity: 1,
          weight: 3,
          dashArray: '8 4',
          opacity: 0.9,
          interactive: false,
        }).addTo(group)
        return
      }

      // ── Locales (LineString cerrado → polígono) ──────────────────
      if (geom.type === 'LineString' && props.tipo === 'local') {
        const color  = COLORES[props.estado] || COLORES.disponible
        const coords = lngLatToLatLng(geom.coordinates)

        const poly = L.polygon(coords, {
          color,
          fillColor: color,
          fillOpacity: 0.75,
          weight: 2,
          opacity: 1,
        })

        // Tooltip con número, área, precio y piso
        const precio = props.precio
          ? `$${Number(props.precio).toLocaleString('es-MX')} MXN`
          : 'Sin precio'
        const pisoLabel = pisoNombre ? `<div class="tt-piso">📍 ${pisoNombre}</div>` : ''
        poly.bindTooltip(
          `<div class="tt-num">${props.numero || '—'}</div>
           <div class="tt-info">${props.area || '?'} m² · ${precio}</div>
           ${pisoLabel}`,
          { permanent: false, direction: 'top', className: 'local-tooltip' }
        )

        poly.on('click', () => {
          if (props.id) onLocalClick(props)
        })
        poly.on('mouseover', function () {
          this.setStyle({ fillOpacity: 1, weight: 3, color: '#fff' })
          this.bringToFront()
        })
        poly.on('mouseout', function () {
          this.setStyle({ fillOpacity: 0.75, weight: 2, color })
        })

        poly.addTo(group)
      }
    })

    group.addTo(map)
    layerRef.current = group

    return () => { if (layerRef.current) layerRef.current.remove() }
  }, [geojson, map, onLocalClick])

  return null
}

// ── Página principal ────────────────────────────────────────────────
export default function PlazaMap() {
  const { id } = useParams()
  const navigate = useNavigate()
  const plaza = plazas.find((p) => p.id === parseInt(id))

  const [zoomDone,     setZoomDone]     = useState(false)
  const [animating,    setAnimating]    = useState(true)
  const [selectedLocal, setSelectedLocal] = useState(null)
  const [geojson,      setGeojson]      = useState(null)
  const [pisos,        setPisos]        = useState([])
  const [pisoActual,   setPisoActual]   = useState(null)
  const [loading,      setLoading]      = useState(true)
  const [error,        setError]        = useState(null)

  // Cargar pisos de la plaza — sin esperar el zoom
  useEffect(() => {
    if (!plaza) return
    axios.get(`/api/floors/plaza/${plaza.id}`)
      .then(res => {
        setPisos(res.data)
        if (res.data.length > 0) setPisoActual(res.data[0])
        else setLoading(false)
      })
      .catch(() => setLoading(false))
  }, [plaza])

  // Cargar GeoJSON del piso seleccionado
  useEffect(() => {
    if (!pisoActual) return
    setLoading(true)
    setError(null)
    axios.get(`/api/floors/${pisoActual.id}/geojson`)
      .then(res => {
        setGeojson(res.data)
        setLoading(false)
      })
      .catch(err => {
        setError('No se pudo cargar el mapa de locales')
        setLoading(false)
        console.error(err)
      })
  }, [pisoActual])

  useEffect(() => {
    if (zoomDone) setAnimating(false)
  }, [zoomDone])

  const handleZoomComplete = useCallback(() => setZoomDone(true), [])

  // Actualizar estado del local en el GeoJSON local tras enviar solicitud
  const handleSolicitudEnviada = useCallback((localId) => {
    setGeojson(prev => {
      if (!prev) return prev
      return {
        ...prev,
        features: prev.features.map(f =>
          f.properties?.id === localId
            ? { ...f, properties: { ...f.properties, estado: 'negociacion' } }
            : f
        ),
      }
    })
    setSelectedLocal(null)
  }, [])

  if (!plaza) return <div className="error-page">Plaza no encontrada</div>

  // Calcular stats desde el GeoJSON
  const localesFeatures = geojson?.features?.filter(f => f.properties?.tipo === 'local') || []
  const stats = {
    disponible:  localesFeatures.filter(f => f.properties.estado === 'disponible').length,
    negociacion: localesFeatures.filter(f => f.properties.estado === 'negociacion').length,
    ocupado:     localesFeatures.filter(f => f.properties.estado === 'ocupado').length,
  }

  // Construir objeto local para el modal desde properties del GeoJSON
  const localParaModal = selectedLocal ? {
    id:          selectedLocal.id,
    numero:      selectedLocal.numero,
    estado:      selectedLocal.estado,
    area:        selectedLocal.area,
    precio:      selectedLocal.precio,
    giro:        selectedLocal.giro,
    imagenes:    selectedLocal.imagenes || [],
    descripcion: selectedLocal.descripcion,
    piso:        pisoActual?.nombre || 'Planta Baja',
  } : null

  return (
    <div className="plaza-map-container">

      {/* Header */}
      <header className="map-header">
        <button className="btn-back" onClick={() => navigate('/')}>← Volver</button>
        <div className="header-info">
          <h1>{plaza.nombre}</h1>
          <p>📍 {plaza.ubicacion}</p>
        </div>
      </header>

      {/* Selector de piso (si hay más de uno) */}
      {pisos.length > 1 && (
        <div className="piso-tabs">
          {pisos.map(p => (
            <button
              key={p.id}
              className={`piso-tab ${pisoActual?.id === p.id ? 'active' : ''}`}
              onClick={() => setPisoActual(p)}
            >
              {p.nombre}
            </button>
          ))}
        </div>
      )}

      {/* Leyenda */}
      <div className="legend">
        <div className="legend-item">
          <span className="legend-color disponible"></span>
          <span>Disponible <strong>({stats.disponible})</strong></span>
        </div>
        <div className="legend-item">
          <span className="legend-color apartado"></span>
          <span>En Negociación <strong>({stats.negociacion})</strong></span>
        </div>
        <div className="legend-item">
          <span className="legend-color vendido"></span>
          <span>Ocupado <strong>({stats.ocupado})</strong></span>
        </div>
      </div>

      {/* Overlay de animación */}
      {animating && (
        <div className="zoom-overlay">
          <div className="zoom-text">
            <div className="zoom-spinner"></div>
            <p>Volando hacia <strong>{plaza.nombre}</strong>…</p>
          </div>
        </div>
      )}

      {/* Loading de GeoJSON */}
      {loading && !animating && (
        <div className="geojson-loading">Cargando locales…</div>
      )}

      {error && (
        <div className="geojson-error">⚠️ {error}</div>
      )}

      {/* Mapa */}
      <div className="map-wrapper">
        <MapContainer
          center={[INICIO_LAT, INICIO_LNG]}
          zoom={INICIO_ZOOM}
          style={{ width: '100%', height: '620px', borderRadius: '18px' }}
          zoomControl
          scrollWheelZoom
        >
          <TileLayer
            url="https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}"
            attribution="Tiles © Esri"
            maxZoom={20}
          />

          <FlyToPlaza plaza={plaza} onZoomComplete={handleZoomComplete} />

          {/* Mostrar GeoJSON en cuanto cargue, sin esperar el zoom */}
          {geojson && (
            <GeoJSONOverlay
              geojson={geojson}
              pisoNombre={pisoActual?.nombre}
              onLocalClick={setSelectedLocal}
            />
          )}
        </MapContainer>
      </div>

      {/* Modal */}
      {selectedLocal && localParaModal && (
        <LocalModal
          local={localParaModal}
          plaza={plaza}
          onClose={() => setSelectedLocal(null)}
          onSolicitudEnviada={handleSolicitudEnviada}
        />
      )}
    </div>
  )
}
