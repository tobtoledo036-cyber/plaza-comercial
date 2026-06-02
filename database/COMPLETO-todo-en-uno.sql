-- ============================================================
-- SCRIPT COMPLETO: Crear base de datos desde cero
-- Ejecutar TODO este archivo en pgAdmin Query Tool
-- ============================================================

-- ============================================================
-- PARTE 1: SCHEMA (Crear tablas)
-- ============================================================

-- Tabla de plazas
CREATE TABLE IF NOT EXISTS plazas (
    id          SERIAL PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL,
    ubicacion   VARCHAR(100) NOT NULL,
    descripcion TEXT,
    imagen_url  VARCHAR(500),
    lat         FLOAT,
    lng         FLOAT,
    zoom_final  INT DEFAULT 17,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de locales
CREATE TABLE IF NOT EXISTS locales (
    id          SERIAL PRIMARY KEY,
    plaza_id    INT NOT NULL REFERENCES plazas(id) ON DELETE CASCADE,
    numero      VARCHAR(20) NOT NULL,
    area        DECIMAL(10,2) NOT NULL,
    precio      DECIMAL(12,2) NOT NULL,
    precio_apartado DECIMAL(12,2),
    estado      VARCHAR(20) NOT NULL
                  CHECK (estado IN ('disponible','apartado','vendido'))
                  DEFAULT 'disponible',
    es_grande   BOOLEAN DEFAULT FALSE,
    lat_min     FLOAT,
    lat_max     FLOAT,
    lng_min     FLOAT,
    lng_max     FLOAT,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de clientes
CREATE TABLE IF NOT EXISTS clientes (
    id          SERIAL PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL,
    email       VARCHAR(100) NOT NULL UNIQUE,
    telefono    VARCHAR(20),
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de transacciones
CREATE TABLE IF NOT EXISTS transacciones (
    id               SERIAL PRIMARY KEY,
    local_id         INT NOT NULL REFERENCES locales(id),
    cliente_id       INT NOT NULL REFERENCES clientes(id),
    tipo             VARCHAR(20) NOT NULL
                       CHECK (tipo IN ('compra','apartado')),
    monto            DECIMAL(12,2) NOT NULL,
    estado_pago      VARCHAR(20) NOT NULL
                       CHECK (estado_pago IN ('pendiente','completado','cancelado'))
                       DEFAULT 'pendiente',
    paypal_order_id  VARCHAR(100),
    paypal_payment_id VARCHAR(100),
    created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at     TIMESTAMP
);

-- Tabla de usuarios (para autenticación)
CREATE TABLE IF NOT EXISTS usuarios (
    id            SERIAL PRIMARY KEY,
    nombre        VARCHAR(100) NOT NULL,
    email         VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    rol           VARCHAR(20)  NOT NULL DEFAULT 'cliente'
                    CHECK (rol IN ('admin','cliente')),
    telefono      VARCHAR(20),
    activo        BOOLEAN DEFAULT TRUE,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Agregar columnas de apartado a transacciones (si no existen)
ALTER TABLE transacciones
  ADD COLUMN IF NOT EXISTS duracion_apartado_dias  INT,
  ADD COLUMN IF NOT EXISTS porcentaje_apartado      DECIMAL(5,2),
  ADD COLUMN IF NOT EXISTS fecha_vencimiento_apartado TIMESTAMP,
  ADD COLUMN IF NOT EXISTS usuario_id              INT REFERENCES usuarios(id);

-- Índices
CREATE INDEX IF NOT EXISTS idx_locales_plaza  ON locales(plaza_id);
CREATE INDEX IF NOT EXISTS idx_locales_estado ON locales(estado);
CREATE INDEX IF NOT EXISTS idx_trans_local    ON transacciones(local_id);
CREATE INDEX IF NOT EXISTS idx_trans_cliente  ON transacciones(cliente_id);
CREATE INDEX IF NOT EXISTS idx_trans_estado   ON transacciones(estado_pago);
CREATE INDEX IF NOT EXISTS idx_usuarios_email ON usuarios(email);
CREATE INDEX IF NOT EXISTS idx_trans_usuario  ON transacciones(usuario_id);

-- ============================================================
-- PARTE 2: INSERTAR USUARIO ADMIN
-- ============================================================

INSERT INTO usuarios (nombre, email, password_hash, rol)
VALUES (
  'Administrador',
  'admin@plazas.com',
  '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
  'admin'
) ON CONFLICT (email) DO NOTHING;

-- ============================================================
-- PARTE 3: MENSAJE DE CONFIRMACIÓN
-- ============================================================

SELECT 'Base de datos creada exitosamente' AS mensaje;
SELECT 'Usuario admin creado: admin@plazas.com / Admin123!' AS credenciales;
