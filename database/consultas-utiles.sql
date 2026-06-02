-- ═══════════════════════════════════════════════════════════════
-- CONSULTAS ÚTILES PARA LA BASE DE DATOS DE PLAZAS COMERCIALES
-- ═══════════════════════════════════════════════════════════════

-- ───────────────────────────────────────────────────────────────
-- 1. CONSULTAS BÁSICAS
-- ───────────────────────────────────────────────────────────────

-- Ver todas las plazas
SELECT * FROM plazas ORDER BY nombre;

-- Ver todos los locales de una plaza específica
SELECT * FROM locales WHERE plaza_id = 1 ORDER BY numero;

-- Ver todas las transacciones
SELECT * FROM transacciones ORDER BY created_at DESC;

-- Ver todos los clientes
SELECT * FROM clientes ORDER BY created_at DESC;


-- ───────────────────────────────────────────────────────────────
-- 2. ESTADÍSTICAS POR PLAZA
-- ───────────────────────────────────────────────────────────────

-- Resumen de locales por estado en cada plaza
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

-- Ingresos totales por plaza
SELECT 
    p.nombre as plaza,
    COUNT(t.id) as total_transacciones,
    SUM(CASE WHEN t.estado_pago = 'completado' THEN t.monto ELSE 0 END) as ingresos_confirmados,
    SUM(CASE WHEN t.estado_pago = 'pendiente' THEN t.monto ELSE 0 END) as ingresos_pendientes,
    SUM(t.monto) as ingresos_totales
FROM plazas p
LEFT JOIN locales l ON p.id = l.plaza_id
LEFT JOIN transacciones t ON l.id = t.local_id
GROUP BY p.id, p.nombre
ORDER BY ingresos_totales DESC;


-- ───────────────────────────────────────────────────────────────
-- 3. CONSULTAS DE LOCALES
-- ───────────────────────────────────────────────────────────────

-- Locales disponibles con su información completa
SELECT 
    p.nombre as plaza,
    l.numero,
    l.area,
    l.precio,
    l.es_grande,
    l.estado
FROM locales l
JOIN plazas p ON l.plaza_id = p.id
WHERE l.estado = 'disponible'
ORDER BY p.nombre, l.numero;

-- Locales más caros disponibles
SELECT 
    p.nombre as plaza,
    l.numero,
    l.area,
    l.precio,
    ROUND(l.precio / l.area, 2) as precio_por_m2
FROM locales l
JOIN plazas p ON l.plaza_id = p.id
WHERE l.estado = 'disponible'
ORDER BY l.precio DESC
LIMIT 10;

-- Locales grandes vs pequeños por plaza
SELECT 
    p.nombre as plaza,
    COUNT(CASE WHEN l.es_grande = true THEN 1 END) as locales_grandes,
    COUNT(CASE WHEN l.es_grande = false THEN 1 END) as locales_pequeños,
    COUNT(*) as total
FROM plazas p
LEFT JOIN locales l ON p.id = l.plaza_id
GROUP BY p.id, p.nombre
ORDER BY p.nombre;


-- ───────────────────────────────────────────────────────────────
-- 4. CONSULTAS DE TRANSACCIONES
-- ───────────────────────────────────────────────────────────────

-- Historial completo de transacciones con detalles
SELECT 
    t.id,
    t.tipo,
    t.monto,
    t.estado_pago,
    t.paypal_order_id,
    p.nombre as plaza,
    l.numero as local,
    l.area,
    c.nombre as cliente,
    c.email,
    c.telefono,
    t.created_at as fecha
FROM transacciones t
JOIN locales l ON t.local_id = l.id
JOIN plazas p ON l.plaza_id = p.id
JOIN clientes c ON t.cliente_id = c.id
ORDER BY t.created_at DESC;

-- Transacciones completadas vs pendientes
SELECT 
    estado_pago,
    COUNT(*) as cantidad,
    SUM(monto) as monto_total
FROM transacciones
GROUP BY estado_pago;

-- Transacciones por tipo (compra vs apartado)
SELECT 
    tipo,
    COUNT(*) as cantidad,
    SUM(monto) as monto_total,
    AVG(monto) as monto_promedio
FROM transacciones
WHERE estado_pago = 'completado'
GROUP BY tipo;

-- Últimas 10 transacciones
SELECT 
    t.created_at as fecha,
    c.nombre as cliente,
    p.nombre as plaza,
    l.numero as local,
    t.tipo,
    t.monto,
    t.estado_pago
FROM transacciones t
JOIN clientes c ON t.cliente_id = c.id
JOIN locales l ON t.local_id = l.id
JOIN plazas p ON l.plaza_id = p.id
ORDER BY t.created_at DESC
LIMIT 10;


-- ───────────────────────────────────────────────────────────────
-- 5. CONSULTAS DE CLIENTES
-- ───────────────────────────────────────────────────────────────

-- Clientes con más transacciones
SELECT 
    c.nombre,
    c.email,
    COUNT(t.id) as total_transacciones,
    SUM(t.monto) as monto_total
FROM clientes c
LEFT JOIN transacciones t ON c.id = t.cliente_id
GROUP BY c.id, c.nombre, c.email
ORDER BY total_transacciones DESC;

-- Clientes que han comprado (no solo apartado)
SELECT 
    c.nombre,
    c.email,
    c.telefono,
    COUNT(t.id) as compras,
    SUM(t.monto) as total_gastado
FROM clientes c
JOIN transacciones t ON c.id = t.cliente_id
WHERE t.tipo = 'compra' AND t.estado_pago = 'completado'
GROUP BY c.id, c.nombre, c.email, c.telefono
ORDER BY total_gastado DESC;


-- ───────────────────────────────────────────────────────────────
-- 6. REPORTES FINANCIEROS
-- ───────────────────────────────────────────────────────────────

-- Reporte de ingresos por mes
SELECT 
    TO_CHAR(created_at, 'YYYY-MM') as mes,
    COUNT(*) as transacciones,
    SUM(monto) as ingresos_totales,
    AVG(monto) as ticket_promedio
FROM transacciones
WHERE estado_pago = 'completado'
GROUP BY TO_CHAR(created_at, 'YYYY-MM')
ORDER BY mes DESC;

-- Reporte de ingresos por día (últimos 30 días)
SELECT 
    DATE(created_at) as fecha,
    COUNT(*) as transacciones,
    SUM(monto) as ingresos
FROM transacciones
WHERE estado_pago = 'completado'
  AND created_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(created_at)
ORDER BY fecha DESC;

-- Valor total del inventario por estado
SELECT 
    estado,
    COUNT(*) as cantidad_locales,
    SUM(precio) as valor_total,
    AVG(precio) as precio_promedio
FROM locales
GROUP BY estado
ORDER BY valor_total DESC;


-- ───────────────────────────────────────────────────────────────
-- 7. CONSULTAS DE ANÁLISIS
-- ───────────────────────────────────────────────────────────────

-- Tasa de conversión por plaza (apartados que se convirtieron en ventas)
SELECT 
    p.nombre as plaza,
    COUNT(CASE WHEN l.estado = 'apartado' THEN 1 END) as apartados,
    COUNT(CASE WHEN l.estado = 'vendido' THEN 1 END) as vendidos,
    COUNT(CASE WHEN l.estado = 'disponible' THEN 1 END) as disponibles,
    ROUND(
        COUNT(CASE WHEN l.estado = 'vendido' THEN 1 END)::numeric / 
        NULLIF(COUNT(*), 0) * 100, 
        2
    ) as porcentaje_vendido
FROM plazas p
LEFT JOIN locales l ON p.id = l.plaza_id
GROUP BY p.id, p.nombre
ORDER BY porcentaje_vendido DESC;

-- Precio promedio por m² por plaza
SELECT 
    p.nombre as plaza,
    COUNT(l.id) as total_locales,
    ROUND(AVG(l.precio / l.area), 2) as precio_promedio_m2,
    MIN(l.precio / l.area) as precio_min_m2,
    MAX(l.precio / l.area) as precio_max_m2
FROM plazas p
LEFT JOIN locales l ON p.id = l.plaza_id
GROUP BY p.id, p.nombre
ORDER BY precio_promedio_m2 DESC;

-- Locales con mejor relación precio/área
SELECT 
    p.nombre as plaza,
    l.numero,
    l.area,
    l.precio,
    ROUND(l.precio / l.area, 2) as precio_por_m2,
    l.estado
FROM locales l
JOIN plazas p ON l.plaza_id = p.id
WHERE l.estado = 'disponible'
ORDER BY precio_por_m2 ASC
LIMIT 10;


-- ───────────────────────────────────────────────────────────────
-- 8. CONSULTAS DE MANTENIMIENTO
-- ───────────────────────────────────────────────────────────────

-- Verificar integridad de datos
SELECT 
    'Plazas sin locales' as problema,
    COUNT(*) as cantidad
FROM plazas p
LEFT JOIN locales l ON p.id = l.plaza_id
WHERE l.id IS NULL

UNION ALL

SELECT 
    'Locales sin plaza' as problema,
    COUNT(*) as cantidad
FROM locales l
LEFT JOIN plazas p ON l.plaza_id = p.id
WHERE p.id IS NULL

UNION ALL

SELECT 
    'Transacciones sin cliente' as problema,
    COUNT(*) as cantidad
FROM transacciones t
LEFT JOIN clientes c ON t.cliente_id = c.id
WHERE c.id IS NULL

UNION ALL

SELECT 
    'Transacciones sin local' as problema,
    COUNT(*) as cantidad
FROM transacciones t
LEFT JOIN locales l ON t.local_id = l.id
WHERE l.id IS NULL;

-- Contar registros en cada tabla
SELECT 'plazas' as tabla, COUNT(*) as registros FROM plazas
UNION ALL
SELECT 'locales' as tabla, COUNT(*) as registros FROM locales
UNION ALL
SELECT 'clientes' as tabla, COUNT(*) as registros FROM clientes
UNION ALL
SELECT 'transacciones' as tabla, COUNT(*) as registros FROM transacciones;


-- ───────────────────────────────────────────────────────────────
-- 9. CONSULTAS DE ACTUALIZACIÓN
-- ───────────────────────────────────────────────────────────────

-- Cambiar estado de un local (ejemplo)
-- UPDATE locales SET estado = 'vendido' WHERE id = 1;

-- Actualizar precio de un local (ejemplo)
-- UPDATE locales SET precio = 500000 WHERE id = 1;

-- Marcar transacción como completada (ejemplo)
-- UPDATE transacciones SET estado_pago = 'completado' WHERE id = 1;

-- Liberar locales con transacciones pendientes/canceladas (resetear a disponible)
-- Útil cuando un pago no se completó pero el local quedó marcado como apartado
UPDATE locales 
SET estado = 'disponible', updated_at = CURRENT_TIMESTAMP
WHERE id IN (
    SELECT l.id 
    FROM locales l
    JOIN transacciones t ON l.id = t.local_id
    WHERE l.estado = 'apartado' 
    AND t.estado_pago IN ('pendiente', 'cancelado')
);

-- Ver locales que tienen transacciones pendientes pero están marcados como apartados
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


-- ───────────────────────────────────────────────────────────────
-- 10. VISTAS ÚTILES (OPCIONAL)
-- ───────────────────────────────────────────────────────────────

-- Crear vista para consultas frecuentes
CREATE OR REPLACE VIEW vista_locales_completa AS
SELECT 
    l.id,
    l.numero,
    l.area,
    l.precio,
    l.estado,
    l.es_grande,
    p.id as plaza_id,
    p.nombre as plaza_nombre,
    p.ubicacion as plaza_ubicacion,
    ROUND(l.precio / l.area, 2) as precio_por_m2
FROM locales l
JOIN plazas p ON l.plaza_id = p.id;

-- Usar la vista
-- SELECT * FROM vista_locales_completa WHERE estado = 'disponible';

-- Crear vista para transacciones completas
CREATE OR REPLACE VIEW vista_transacciones_completa AS
SELECT 
    t.id,
    t.tipo,
    t.monto,
    t.estado_pago,
    t.paypal_order_id,
    t.created_at,
    c.nombre as cliente_nombre,
    c.email as cliente_email,
    c.telefono as cliente_telefono,
    l.numero as local_numero,
    l.area as local_area,
    p.nombre as plaza_nombre,
    p.ubicacion as plaza_ubicacion
FROM transacciones t
JOIN clientes c ON t.cliente_id = c.id
JOIN locales l ON t.local_id = l.id
JOIN plazas p ON l.plaza_id = p.id;

-- Usar la vista
-- SELECT * FROM vista_transacciones_completa WHERE estado_pago = 'completado';
