-- ============================================================
-- SCHEMA: Plazas Comerciales - PostgreSQL
-- ============================================================

-- Tabla de plazas
CREATE TABLE plazas (
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
CREATE TABLE locales (
    id          SERIAL PRIMARY KEY,
    plaza_id    INT NOT NULL REFERENCES plazas(id) ON DELETE CASCADE,
    numero      VARCHAR(20) NOT NULL,
    area        DECIMAL(10,2) NOT NULL,
    precio      DECIMAL(12,2) NOT NULL,  -- Precio de compra
    precio_apartado DECIMAL(12,2),        -- Precio de apartado (opcional, si NULL usa precio)
    estado      VARCHAR(20) NOT NULL
                  CHECK (estado IN ('disponible','apartado','vendido'))
                  DEFAULT 'disponible',
    es_grande   BOOLEAN DEFAULT FALSE,
    -- Bounds del rectángulo en el mapa
    lat_min     FLOAT,
    lat_max     FLOAT,
    lng_min     FLOAT,
    lng_max     FLOAT,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de clientes
CREATE TABLE clientes (
    id          SERIAL PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL,
    email       VARCHAR(100) NOT NULL UNIQUE,
    telefono    VARCHAR(20),
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de transacciones
CREATE TABLE transacciones (
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

-- Índices
CREATE INDEX idx_locales_plaza  ON locales(plaza_id);
CREATE INDEX idx_locales_estado ON locales(estado);
CREATE INDEX idx_trans_local    ON transacciones(local_id);
CREATE INDEX idx_trans_cliente  ON transacciones(cliente_id);
CREATE INDEX idx_trans_estado   ON transacciones(estado_pago);
