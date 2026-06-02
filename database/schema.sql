-- Plazas Comerciales - Estado de México
-- PostgreSQL Schema

CREATE TABLE IF NOT EXISTS plazas (
    id          SERIAL PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL,
    ubicacion   VARCHAR(100) NOT NULL,
    descripcion TEXT,
    imagen_url  VARCHAR(500),
    lat         FLOAT,
    lng         FLOAT,
    zoom_final  INT DEFAULT 17,
    created_at  TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS locales (
    id          SERIAL PRIMARY KEY,
    plaza_id    INT NOT NULL REFERENCES plazas(id) ON DELETE CASCADE,
    numero      VARCHAR(20) NOT NULL,
    area        DECIMAL(10,2) NOT NULL,
    precio      DECIMAL(12,2) NOT NULL,
    estado      VARCHAR(20) NOT NULL DEFAULT 'disponible'
                  CHECK (estado IN ('disponible','apartado','vendido')),
    es_grande   BOOLEAN DEFAULT FALSE,
    lat_min     FLOAT,
    lat_max     FLOAT,
    lng_min     FLOAT,
    lng_max     FLOAT,
    created_at  TIMESTAMP DEFAULT NOW(),
    updated_at  TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS clientes (
    id          SERIAL PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL,
    email       VARCHAR(100) NOT NULL UNIQUE,
    telefono    VARCHAR(20),
    created_at  TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS transacciones (
    id                SERIAL PRIMARY KEY,
    local_id          INT NOT NULL REFERENCES locales(id),
    cliente_id        INT NOT NULL REFERENCES clientes(id),
    tipo              VARCHAR(20) NOT NULL CHECK (tipo IN ('compra','apartado')),
    monto             DECIMAL(12,2) NOT NULL,
    estado_pago       VARCHAR(20) NOT NULL DEFAULT 'pendiente'
                        CHECK (estado_pago IN ('pendiente','completado','cancelado')),
    paypal_order_id   VARCHAR(100),
    paypal_payment_id VARCHAR(100),
    created_at        TIMESTAMP DEFAULT NOW(),
    completed_at      TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_locales_plaza  ON locales(plaza_id);
CREATE INDEX IF NOT EXISTS idx_locales_estado ON locales(estado);
CREATE INDEX IF NOT EXISTS idx_trans_local    ON transacciones(local_id);
CREATE INDEX IF NOT EXISTS idx_trans_cliente  ON transacciones(cliente_id);
