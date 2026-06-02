// Coordenadas extraídas directamente del bbox de cada GeoJSON
export const plazas = [
  {
    id: 1,
    nombre: "Plaza Satélite",
    ubicacion: "Naucalpan de Juárez",
    descripcion: "Una de las plazas comerciales más emblemáticas del Estado de México",
    imagen: "https://images.unsplash.com/photo-1555529669-e69e7aa0ba9a?w=800",
    // Centro calculado del bbox del GeoJSON: lng[-99.236549,-99.231407] lat[19.505932,19.513132]
    lat: 19.5095,
    lng: -99.2340,
    zoom_final: 17,
  },
  {
    id: 2,
    nombre: "Mundo E",
    ubicacion: "Ecatepec",
    descripcion: "Centro comercial moderno con gran afluencia de visitantes",
    imagen: "https://images.unsplash.com/photo-1519567241046-7f570eee3ce6?w=800",
    // Centro del bbox: lng[-99.048315,-99.044787] lat[19.604346,19.607791]
    lat: 19.6061,
    lng: -99.0466,
    zoom_final: 17,
  },
  {
    id: 3,
    nombre: "Plaza Las Américas",
    ubicacion: "Toluca",
    descripcion: "Plaza comercial estratégica en el corazón de Toluca",
    imagen: "https://images.unsplash.com/photo-1567958451986-2de427a4a0be?w=800",
    // Centro del bbox: lng[-99.62644,-99.624329] lat[19.259186,19.261211]
    lat: 19.2602,
    lng: -99.6254,
    zoom_final: 18,
  },
  {
    id: 4,
    nombre: "Galerías Metepec",
    ubicacion: "Metepec",
    descripcion: "Centro comercial premium con locales de alta plusvalía",
    imagen: "https://images.unsplash.com/photo-1528698827591-e19ccd7bc23d?w=800",
    // Centro del bbox: lng[-99.624381,-99.618877] lat[19.255371,19.26132]
    lat: 19.2583,
    lng: -99.6216,
    zoom_final: 16,
  },
  {
    id: 5,
    nombre: "Plaza Sendero",
    ubicacion: "Tlalnepantla",
    descripcion: "Moderna plaza con excelente ubicación y conectividad",
    imagen: "https://images.unsplash.com/photo-1582719471137-c3967ffb1c42?w=800",
    // Centro del bbox: lng[-99.211333,-99.206836] lat[19.543897,19.549409]
    lat: 19.5466,
    lng: -99.2091,
    zoom_final: 16,
  }
]
