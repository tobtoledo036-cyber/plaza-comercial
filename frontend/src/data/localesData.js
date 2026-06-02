// Genera locales distribuidos en una cuadrícula dentro del bbox de la plaza
const estados = ['disponible', 'apartado', 'vendido']

function randomEstado() {
  const r = Math.random()
  if (r < 0.5) return 'disponible'
  if (r < 0.75) return 'apartado'
  return 'vendido'
}

/**
 * Genera locales en una cuadrícula dentro del área delimitada de la plaza.
 * Algunos locales son más grandes (ocupan 2 celdas).
 */
export function generarLocales(plaza) {
  const { localesBounds, totalLocales } = plaza
  const { latMin, latMax, lngMin, lngMax } = localesBounds

  const cols = 6
  const rows = Math.ceil(totalLocales / cols)

  const cellLat = (latMax - latMin) / rows
  const cellLng = (lngMax - lngMin) / cols
  const padding = 0.08 // 8% de padding interno

  const locales = []
  let id = 1

  for (let row = 0; row < rows && locales.length < totalLocales; row++) {
    for (let col = 0; col < cols && locales.length < totalLocales; col++) {
      const esGrande = Math.random() > 0.72

      // Coordenadas de la celda con padding
      const latA = latMin + row * cellLat + cellLat * padding
      const latB = latMin + (row + 1) * cellLat - cellLat * padding
      const lngA = lngMin + col * cellLng + cellLng * padding
      const lngB = lngMin + (col + 1) * cellLng - cellLng * padding

      // Si es grande, extiende hacia la siguiente columna
      const lngBig = esGrande && col + 1 < cols
        ? lngMin + (col + 2) * cellLng - cellLng * padding
        : lngB

      locales.push({
        id: id++,
        plazaId: plaza.id,
        numero: `L-${String(locales.length + 1).padStart(3, '0')}`,
        estado: randomEstado(),
        esGrande,
        precio: esGrande ? 850000 : 450000,
        area: esGrande ? 120 : 60,
        // Bounds del rectángulo en coordenadas reales
        bounds: [
          [latA, lngA],
          [latB, lngBig],
        ],
      })

      // Si era grande, saltar la siguiente columna
      if (esGrande && col + 1 < cols) col++
    }
  }

  return locales
}
