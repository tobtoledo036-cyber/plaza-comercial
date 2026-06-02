-- ═══════════════════════════════════════════════════════════════
-- SCRIPT PARA LIBERAR LOCALES ATASCADOS
-- ═══════════════════════════════════════════════════════════════
-- Este script libera locales que quedaron marcados como "apartado"
-- o "vendido" pero cuyas transacciones nunca se completaron en PayPal
-- ═══════════════════════════════════════════════════════════════

-- 1. Ver locales problemáticos ANTES de la corrección
SELECT 
    p.nombre as plaza,
    l.numero,
    l.estado as estado_local,
    t.estado_pago as estado_transaccion,
    t.created_at as fecha_transaccion,
    c.nombre as cliente,
    c.email
FROM locales l
JOIN plazas p ON l.plaza_id = p.id
JOIN transacciones t ON l.id = t.local_id
JOIN clientes c ON t.cliente_id = c.id
WHERE l.estado IN ('apartado', 'vendido')
AND t.estado_pago != 'completado'
ORDER BY t.created_at DESC;

-- 2. Liberar locales con transacciones pendientes o canceladas
UPDATE locales 
SET estado = 'disponible', updated_at = CURRENT_TIMESTAMP
WHERE id IN (
    SELECT l.id 
    FROM locales l
    JOIN transacciones t ON l.id = t.local_id
    WHERE l.estado IN ('apartado', 'vendido')
    AND t.estado_pago IN ('pendiente', 'cancelado')
);

-- 3. Ver resultado DESPUÉS de la corrección
SELECT 
    p.nombre as plaza,
    l.numero,
    l.estado as estado_local,
    COUNT(t.id) as total_transacciones,
    COUNT(CASE WHEN t.estado_pago = 'completado' THEN 1 END) as completadas,
    COUNT(CASE WHEN t.estado_pago = 'pendiente' THEN 1 END) as pendientes,
    COUNT(CASE WHEN t.estado_pago = 'cancelado' THEN 1 END) as canceladas
FROM locales l
JOIN plazas p ON l.plaza_id = p.id
LEFT JOIN transacciones t ON l.id = t.local_id
GROUP BY p.nombre, l.numero, l.estado
HAVING COUNT(t.id) > 0
ORDER BY p.nombre, l.numero;

-- 4. Resumen de locales por estado después de la corrección
SELECT 
    p.nombre as plaza,
    COUNT(CASE WHEN l.estado = 'disponible' THEN 1 END) as disponibles,
    COUNT(CASE WHEN l.estado = 'apartado' THEN 1 END) as apartados,
    COUNT(CASE WHEN l.estado = 'vendido' THEN 1 END) as vendidos,
    COUNT(*) as total_locales
FROM plazas p
LEFT JOIN locales l ON p.id = l.plaza_id
GROUP BY p.id, p.nombre
ORDER BY p.nombre;
