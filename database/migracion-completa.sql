-- ============================================================
-- MIGRACIÓN COMPLETA: Agregar pisos, solicitudes, giro, imágenes
-- Ejecutar en pgAdmin Query Tool sobre la BD existente
-- ============================================================

-- ── 1. Tabla de pisos ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS pisos (
    id          SERIAL PRIMARY KEY,
    plaza_id    INT NOT NULL REFERENCES plazas(id) ON DELETE CASCADE,
    numero      INT NOT NULL DEFAULT 1,
    nombre      VARCHAR(50) NOT NULL DEFAULT 'Planta Baja',
    geojson     JSONB,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(plaza_id, numero)
);

CREATE INDEX IF NOT EXISTS idx_pisos_plaza ON pisos(plaza_id);

-- ── 2. Nuevas columnas en locales ────────────────────────────
ALTER TABLE locales
    ADD COLUMN IF NOT EXISTS piso_id    INT REFERENCES pisos(id),
    ADD COLUMN IF NOT EXISTS giro       VARCHAR(100),
    ADD COLUMN IF NOT EXISTS imagenes   TEXT[] DEFAULT '{}',
    ADD COLUMN IF NOT EXISTS nombre     VARCHAR(100),
    ADD COLUMN IF NOT EXISTS descripcion TEXT,
    ADD COLUMN IF NOT EXISTS feature_index INT; -- índice del LineString en el GeoJSON

-- ── 3. Actualizar CHECK de estado en locales ────────────────
-- Primero eliminar el constraint viejo
ALTER TABLE locales DROP CONSTRAINT IF EXISTS locales_estado_check;

-- Agregar nuevo constraint con los estados correctos
-- Mantenemos compatibilidad: disponible | negociacion | ocupado
-- (apartado y vendido siguen funcionando para el flujo PayPal existente)
ALTER TABLE locales ADD CONSTRAINT locales_estado_check
    CHECK (estado IN ('disponible', 'negociacion', 'ocupado', 'apartado', 'vendido'));

-- ── 4. Tabla de solicitudes ──────────────────────────────────
CREATE TABLE IF NOT EXISTS solicitudes (
    id              SERIAL PRIMARY KEY,
    local_id        INT NOT NULL REFERENCES locales(id),
    -- Datos del solicitante
    nombre          VARCHAR(100) NOT NULL,
    email           VARCHAR(100) NOT NULL,
    telefono        VARCHAR(20),
    empresa         VARCHAR(100),
    -- Datos de la solicitud
    giro_propuesto  VARCHAR(100) NOT NULL,
    plan_negocio    TEXT NOT NULL,
    -- Estado y gestión
    estado          VARCHAR(20) NOT NULL
                      CHECK (estado IN ('pendiente', 'aprobada', 'rechazada'))
                      DEFAULT 'pendiente',
    respuesta_admin TEXT,
    -- Metadatos
    usuario_id      INT REFERENCES usuarios(id),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_solicitudes_local   ON solicitudes(local_id);
CREATE INDEX IF NOT EXISTS idx_solicitudes_estado  ON solicitudes(estado);
CREATE INDEX IF NOT EXISTS idx_solicitudes_email   ON solicitudes(email);
CREATE INDEX IF NOT EXISTS idx_solicitudes_usuario ON solicitudes(usuario_id);

-- ── 5. Insertar pisos (uno por plaza, Planta Baja) ───────────
-- Los GeoJSON se cargan desde archivos en el backend, aquí solo creamos el registro
INSERT INTO pisos (plaza_id, numero, nombre) VALUES
    (1, 1, 'Planta Baja'),
    (2, 1, 'Planta Baja'),
    (3, 1, 'Planta Baja'),
    (4, 1, 'Planta Baja'),
    (5, 1, 'Planta Baja')
ON CONFLICT (plaza_id, numero) DO NOTHING;

-- ── 6. Asignar piso a locales existentes ────────────────────
UPDATE locales l
SET piso_id = p.id
FROM pisos p
WHERE p.plaza_id = l.plaza_id
  AND p.numero = 1
  AND l.piso_id IS NULL;

-- ── 7. Asignar feature_index a locales existentes ───────────
-- Los locales se numeran por orden dentro de su plaza
-- El índice 0 es el Polygon (perímetro), los LineStrings empiezan en 1
UPDATE locales l
SET feature_index = sub.rn
FROM (
    SELECT id,
           ROW_NUMBER() OVER (PARTITION BY plaza_id ORDER BY id) AS rn
    FROM locales
) sub
WHERE l.id = sub.id
  AND l.feature_index IS NULL;

-- ── 8. Verificación ─────────────────────────────────────────
SELECT 'Migración completada exitosamente' AS mensaje;
SELECT 'Pisos creados: ' || COUNT(*) AS pisos FROM pisos;
SELECT 'Solicitudes tabla: OK' AS solicitudes FROM information_schema.tables WHERE table_name = 'solicitudes';
