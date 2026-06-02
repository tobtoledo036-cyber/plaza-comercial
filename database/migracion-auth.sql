-- ============================================================
-- MIGRACIÓN: Agregar autenticación y campos de apartado
-- Ejecutar en pgAdmin sobre plazas_db
-- ============================================================

-- 1. Tabla de usuarios (login)
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

-- 2. Insertar usuario admin por defecto
--    contraseña: Admin123! (se hashea en el backend al primer uso)
--    Aquí guardamos el hash bcrypt de "Admin123!"
INSERT INTO usuarios (nombre, email, password_hash, rol)
VALUES (
  'Administrador',
  'admin@plazas.com',
  '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', -- password: "Admin123!"
  'admin'
) ON CONFLICT (email) DO NOTHING;

-- 3. Agregar columnas de apartado a transacciones
ALTER TABLE transacciones
  ADD COLUMN IF NOT EXISTS duracion_apartado_dias  INT,
  ADD COLUMN IF NOT EXISTS porcentaje_apartado      DECIMAL(5,2),
  ADD COLUMN IF NOT EXISTS fecha_vencimiento_apartado TIMESTAMP,
  ADD COLUMN IF NOT EXISTS usuario_id              INT REFERENCES usuarios(id);

-- 4. Agregar columna precio_apartado a locales (si no existe)
ALTER TABLE locales
  ADD COLUMN IF NOT EXISTS precio_apartado DECIMAL(12,2);

-- Calcular precio_apartado como 30% del precio de compra donde sea NULL
UPDATE locales
SET precio_apartado = ROUND(precio * 0.30, 2)
WHERE precio_apartado IS NULL;

-- 5. Índices nuevos
CREATE INDEX IF NOT EXISTS idx_usuarios_email ON usuarios(email);
CREATE INDEX IF NOT EXISTS idx_trans_usuario  ON transacciones(usuario_id);

-- 6. Verificar
SELECT 'usuarios' AS tabla, COUNT(*) FROM usuarios
UNION ALL
SELECT 'transacciones', COUNT(*) FROM transacciones;
