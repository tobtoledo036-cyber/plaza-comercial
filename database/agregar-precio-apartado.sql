-- ═══════════════════════════════════════════════════════════════
-- AGREGAR COLUMNA PRECIO_APARTADO A LA TABLA LOCALES
-- ═══════════════════════════════════════════════════════════════
-- Este script agrega la columna precio_apartado para diferenciar
-- el precio de compra vs apartado
-- ═══════════════════════════════════════════════════════════════

-- 1. Agregar columna precio_apartado
ALTER TABLE locales 
ADD COLUMN IF NOT EXISTS precio_apartado DECIMAL(12,2);

-- 2. Establecer precio_apartado como 30% del precio de compra por defecto
UPDATE locales 
SET precio_apartado = ROUND(precio * 0.30, 2)
WHERE precio_apartado IS NULL;

-- 3. Verificar los cambios
SELECT 
    p.nombre as plaza,
    l.numero,
    l.precio as precio_compra,
    l.precio_apartado,
    l.estado
FROM locales l
JOIN plazas p ON l.plaza_id = p.id
ORDER BY p.nombre, l.numero
LIMIT 20;

-- 4. Resumen de precios por plaza
SELECT 
    p.nombre as plaza,
    COUNT(l.id) as total_locales,
    ROUND(AVG(l.precio), 2) as precio_compra_promedio,
    ROUND(AVG(l.precio_apartado), 2) as precio_apartado_promedio,
    ROUND(MIN(l.precio), 2) as precio_compra_min,
    ROUND(MAX(l.precio), 2) as precio_compra_max
FROM locales l
JOIN plazas p ON l.plaza_id = p.id
GROUP BY p.id, p.nombre
ORDER BY p.nombre;
