-- ============================================================
-- VERIFICACIÓN COMPLETA DE LA BASE DE DATOS
-- ============================================================

-- 1. Verificar que todas las tablas existen
SELECT 'TABLAS EXISTENTES:' AS verificacion;
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public'
ORDER BY table_name;

-- 2. Verificar plazas
SELECT 'PLAZAS:' AS verificacion;
SELECT id, nombre, ubicacion FROM plazas ORDER BY id;

-- 3. Contar locales por plaza
SELECT 'LOCALES POR PLAZA:' AS verificacion;
SELECT 
    p.nombre AS plaza,
    COUNT(l.id) AS total_locales,
    SUM(CASE WHEN l.estado = 'disponible' THEN 1 ELSE 0 END) AS disponibles,
    SUM(CASE WHEN l.estado = 'apartado' THEN 1 ELSE 0 END) AS apartados,
    SUM(CASE WHEN l.estado = 'vendido' THEN 1 ELSE 0 END) AS vendidos
FROM plazas p
LEFT JOIN locales l ON p.id = l.plaza_id
GROUP BY p.id, p.nombre
ORDER BY p.id;

-- 4. Verificar usuario admin
SELECT 'USUARIO ADMIN:' AS verificacion;
SELECT id, nombre, email, rol, activo, created_at 
FROM usuarios 
WHERE email = 'admin@plazas.com';

-- 5. Verificar columnas de transacciones
SELECT 'COLUMNAS DE TRANSACCIONES:' AS verificacion;
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'transacciones'
ORDER BY ordinal_position;

-- 6. Verificar columnas de locales
SELECT 'COLUMNAS DE LOCALES:' AS verificacion;
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'locales'
ORDER BY ordinal_position;

-- 7. Total de registros
SELECT 'TOTALES:' AS verificacion;
SELECT 
    (SELECT COUNT(*) FROM plazas) AS total_plazas,
    (SELECT COUNT(*) FROM locales) AS total_locales,
    (SELECT COUNT(*) FROM usuarios) AS total_usuarios,
    (SELECT COUNT(*) FROM clientes) AS total_clientes,
    (SELECT COUNT(*) FROM transacciones) AS total_transacciones;
