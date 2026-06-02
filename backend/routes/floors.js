import express from 'express'
import { readFileSync, existsSync } from 'fs'
import { join, dirname } from 'path'
import { fileURLToPath } from 'url'
import pool from '../db/connection.js'

const router = express.Router()
const __dirname = dirname(fileURLToPath(import.meta.url))

// Mapa de plaza_id + numero_piso → nombre de archivo GeoJSON
const GEOJSON_FILES = {
  '1-1': 'Plaza Satelite.geojson',
  '1-2': 'Plaza Satelite-P2.geojson',
  '2-1': 'Mundo E.geojson',
  '2-2': 'Mundo E-P2.geojson',
  '3-1': 'Las Americas-Toluca.geojson',
  '3-2': 'Las Americas-Toluca-P2.geojson',
  '4-1': 'Metepec.geojson',
  '4-2': 'Metepec-P2.geojson',
  '5-1': 'Sendero.geojson',
  '5-2': 'Sendero-P2.geojson',
}

function cargarGeoJSON(plazaId, numeroPiso = 1) {
  const key = `${plazaId}-${numeroPiso}`
  const filename = GEOJSON_FILES[key]
  if (!filename) return null
  const filePath = join(__dirname, '..', 'data', 'geojson', filename)
  if (!existsSync(filePath)) return null
  try {
    return JSON.parse(readFileSync(filePath, 'utf-8'))
  } catch {
    return null
  }
}

// ── GET /api/floors/plaza/:plazaId ───────────────────────────
// Lista los pisos de una plaza
router.get('/plaza/:plazaId', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, plaza_id, numero, nombre FROM pisos WHERE plaza_id = $1 ORDER BY numero',
      [req.params.plazaId]
    )
    res.json(result.rows)
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
})

// ── GET /api/floors/:pisoId/geojson ─────────────────────────
// Devuelve el GeoJSON del piso enriquecido con datos de locales de la BD
router.get('/:pisoId/geojson', async (req, res) => {
  try {
    const { pisoId } = req.params

    // Obtener datos del piso
    const pisoResult = await pool.query(
      'SELECT p.*, pl.nombre AS plaza_nombre FROM pisos p JOIN plazas pl ON pl.id = p.plaza_id WHERE p.id = $1',
      [pisoId]
    )
    if (!pisoResult.rows.length)
      return res.status(404).json({ error: 'Piso no encontrado' })

    const piso = pisoResult.rows[0]

    // Cargar GeoJSON base desde archivo usando plaza_id + numero de piso
    const geojsonBase = cargarGeoJSON(piso.plaza_id, piso.numero)
    if (!geojsonBase)
      return res.status(404).json({ error: 'GeoJSON no encontrado para esta plaza' })

    // Obtener locales de la BD para este piso
    const localesResult = await pool.query(`
      SELECT id, numero, area, precio, estado, giro, imagenes,
             nombre, descripcion, feature_index, piso_id
      FROM locales
      WHERE piso_id = $1
      ORDER BY feature_index
    `, [pisoId])

    const localesPorIndex = {}
    localesResult.rows.forEach(l => {
      if (l.feature_index != null) localesPorIndex[l.feature_index] = l
    })

    // Enriquecer features del GeoJSON con datos de la BD
    const featuresEnriquecidas = geojsonBase.features.map((feature, idx) => {
      // Feature[0] es el Polygon del perímetro — lo dejamos como está
      if (idx === 0 && feature.geometry.type === 'Polygon') {
        return {
          ...feature,
          properties: {
            ...feature.properties,
            tipo: 'perimetro',
          },
        }
      }

      // LineStrings = locales
      const local = localesPorIndex[idx]
      if (!local) {
        // Local sin datos en BD — mostrar como disponible sin info
        return {
          ...feature,
          properties: {
            tipo: 'local',
            estado: 'disponible',
            feature_index: idx,
          },
        }
      }

      return {
        ...feature,
        properties: {
          tipo: 'local',
          id: local.id,
          numero: local.numero,
          area: parseFloat(local.area),
          precio: parseFloat(local.precio),
          estado: local.estado,
          giro: local.giro || null,
          imagenes: local.imagenes || [],
          nombre: local.nombre || null,
          descripcion: local.descripcion || null,
          feature_index: idx,
          piso_id: local.piso_id,
        },
      }
    })

    res.json({
      type: 'FeatureCollection',
      features: featuresEnriquecidas,
      metadata: {
        piso_id: piso.id,
        piso_numero: piso.numero,
        piso_nombre: piso.nombre,
        plaza_id: piso.plaza_id,
        plaza_nombre: piso.plaza_nombre,
        total_locales: localesResult.rows.length,
      },
    })
  } catch (err) {
    console.error('Error GET /floors/:pisoId/geojson:', err.message)
    res.status(500).json({ error: err.message })
  }
})

export default router
