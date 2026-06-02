-- ═══════════════════════════════════════════════════════════════
-- CONSULTAS PARA PANEL DE ADMINISTRACIÓN - USAR EN PGADMIN
-- ═══════════════════════════════════════════════════════════════
-- Copia y pega estas consultas directamente en pgAdmin Query Tool
-- ═══════════════════════════════════════════════════════════════

-- ───────────────────────────────────────────────────────────────
-- 1. VER TODAS LAS TRANSACCIONES (COMPLETO)
-- ───────────────────────────────────────────────────────────────
SELECT 
    t.id,
    t.created_at as fecha,
    c.nombre as cliente,
    c.email,
    c.telefono,
    p.nombre as plaza,
    l.numero as local,
    t.tipo,
    t.monto,
    t.estado_pago,
    t.paypal_order_id,
    t.paypal_payment_id,
    t.completed_at
FROM transacciones t
JOIN clientes c ON t.cliente_id = c.id
JOIN locales l ON t.local_id = l.id
JOIN plazas p ON l.plaza_id = p.id
ORDER BY t.created_at DESC;


-- ───────────────────────────────────────────────────────────────
-- 2. ESTADÍSTICAS GENERALES
-- ───────────────────────────────────────────────────────────────
SELECT 
    COUNT(*) as total_transacciones,
    COUNT(CASE WHEN estado_pago = 'completado' THEN 1 END) as completadas,
    COUNT(CASE WHEN estado_pago = 'pendiente' THEN 1 END) as pendientes,
    COUNT(CASE WHEN estado_pago = 'cancelado' THEN 1 END) as canceladas,
    COUNT(CASE WHEN tipo = 'compra' AND estado_pago = 'completado' THEN 1 END) as compras,
    COUNT(CASE WHEN tipo = 'apartado' AND estado_pago = 'completado' THEN 1 END) as apartados,
    SUM(CASE WHEN estado_pago = 'completado' THEN monto ELSE 0 END) as ingresos_totales
FROM transacciones;


-- ───────────────────────────────────────────────────────────────
-- 3. TRANSACCIONES COMPLETADAS
-- ───────────────────────────────────────────────────────────────
SELECT 
    t.id,
    t.created_at as fecha,
    c.nombre as cliente,
    c.email,
    p.nombre as plaza,
    l.numero as local,
    t.tipo,
    t.monto,
    t.paypal_payment_id
FROM transacciones t
JOIN clientes c ON t.cliente_id = c.id
JOIN locales l ON t.local_id = l.id
JOIN plazas p ON l.plaza_id = p.id
WHERE t.estado_pago = 'completado'
ORDER BY t.created_at DESC;


-- ───────────────────────────────────────────────────────────────
-- 4. TRANSACCIONES PENDIENTES
-- ───────────────────────────────────────────────────────────────
SELECT 
    t.id,
    t.created_at as fecha,
    c.nombre as cliente,
    c.email,
    p.nombre as plaza,
    l.numero as local,
    t.tipo,
    t.monto,
    EXTRACT(EPOCH FROM (NOW() - t.created_at))/60 as minutos_pendiente
FROM transacciones t
JOIN clientes c ON t.cliente_id = c.id
JOIN locales l ON t.local_id = l.id
JOIN plazas p ON l.plaza_id = p.id
WHERE t.estado_pago = 'pendiente'
ORDER BY t.created_at DESC;


-- ───────────────────────────────────────────────────────────────
-- 5. INGRESOS POR PLAZA
-- ───────────────────────────────────────────────────────────────
SELECT 
    p.nombre as plaza,
    COUNT(t.id) as total_transacciones,
    COUNT(CASE WHEN t.tipo = 'compra' AND t.estado_pago = 'completado' THEN 1 END) as compras,
    COUNT(CASE WHEN t.tipo = 'apartado' AND t.estado_pago = 'completado' THEN 1 END) as apartados,
    SUM(CASE WHEN t.estado_pago = 'completado' THEN t.monto ELSE 0 END) as ingresos_totales,
    ROUND(AVG(CASE WHEN t.estado_pago = 'completado' THEN t.monto END), 2) as ticket_promedio
FROM plazas p
LEFT JOIN locales l ON p.id = l.plaza_id
LEFT JOIN transacciones t ON l.id = t.local_id
GROUP BY p.id, p.nombre
ORDER BY ingresos_totales DESC;


-- ───────────────────────────────────────────────────────────────
-- 6. TOP 10 CLIENTES
-- ───────────────────────────────────────────────────────────────
SELECT 
    c.nombre,
    c.email,
    c.telefono,
    COUNT(t.id) as total_transacciones,
    COUNT(CASE WHEN t.estado_pago = 'completado' THEN 1 END) as completadas,
    SUM(CASE WHEN t.estado_pago = 'completado' THEN t.monto ELSE 0 END) as monto_total
FROM clientes c
LEFT JOIN transacciones t ON c.id = t.cliente_id
GROUP BY c.id, c.nombre, c.email, c.telefono
HAVING COUNT(t.id) > 0
ORDER BY monto_total DESC
LIMIT 10;


-- ───────────────────────────────────────────────────────────────
-- 7. TRANSACCIONES DEL DÍA
-- ───────────────────────────────────────────────────────────────
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
WHERE DATE(t.created_at) = CURRENT_DATE
ORDER BY t.created_at DESC;


-- ───────────────────────────────────────────────────────────────
-- 8. TRANSACCIONES DE LA ÚLTIMA SEMANA
-- ───────────────────────────────────────────────────────────────
SELECT 
    DATE(t.created_at) as fecha,
    COUNT(*) as total_transacciones,
    COUNT(CASE WHEN t.estado_pago = 'completado' THEN 1 END) as completadas,
    SUM(CASE WHEN t.estado_pago = 'completado' THEN t.monto ELSE 0 END) as ingresos
FROM transacciones t
WHERE t.created_at >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY DATE(t.created_at)
ORDER BY fecha DESC;


-- ───────────────────────────────────────────────────────────────
-- 9. LOCALES MÁS VENDIDOS/APARTADOS
-- ───────────────────────────────────────────────────────────────
SELECT 
    p.nombre as plaza,
    l.numero as local,
    l.area,
    l.precio,
    l.estado,
    COUNT(t.id) as intentos_compra,
    MAX(t.created_at) as ultima_transaccion
FROM locales l
JOIN plazas p ON l.plaza_id = p.id
LEFT JOIN transacciones t ON l.id = t.local_id
WHERE l.estado IN ('vendido', 'apartado')
GROUP BY p.nombre, l.numero, l.area, l.precio, l.estado
ORDER BY intentos_compra DESC;


-- ───────────────────────────────────────────────────────────────
-- 10. RESUMEN DE LOCALES POR ESTADO
-- ───────────────────────────────────────────────────────────────
SELECT 
    p.nombre as plaza,
    COUNT(CASE WHEN l.estado = 'disponible' THEN 1 END) as disponibles,
    COUNT(CASE WHEN l.estado = 'apartado' THEN 1 END) as apartados,
    COUNT(CASE WHEN l.estado = 'vendido' THEN 1 END) as vendidos,
    COUNT(*) as total_locales,
    ROUND(
        COUNT(CASE WHEN l.estado = 'vendido' THEN 1 END)::numeric / 
        COUNT(*)::numeric * 100, 
        2
    ) as porcentaje_vendido
FROM plazas p
LEFT JOIN locales l ON p.id = l.plaza_id
GROUP BY p.id, p.nombre
ORDER BY p.nombre;


-- ───────────────────────────────────────────────────────────────
-- 11. INGRESOS POR MES
-- ───────────────────────────────────────────────────────────────
SELECT 
    TO_CHAR(created_at, 'YYYY-MM') as mes,
    COUNT(*) as transacciones,
    COUNT(CASE WHEN estado_pago = 'completado' THEN 1 END) as completadas,
    SUM(CASE WHEN estado_pago = 'completado' THEN monto ELSE 0 END) as ingresos_totales,
    ROUND(AVG(CASE WHEN estado_pago = 'completado' THEN monto END), 2) as ticket_promedio
FROM transacciones
GROUP BY TO_CHAR(created_at, 'YYYY-MM')
ORDER BY mes DESC;


-- ───────────────────────────────────────────────────────────────
-- 12. COMPARACIÓN COMPRAS VS APARTADOS
-- ───────────────────────────────────────────────────────────────
SELECT 
    tipo,
    COUNT(*) as cantidad,
    COUNT(CASE WHEN estado_pago = 'completado' THEN 1 END) as completadas,
    SUM(CASE WHEN estado_pago = 'completado' THEN monto ELSE 0 END) as ingresos_totales,
    ROUND(AVG(CASE WHEN estado_pago = 'completado' THEN monto END), 2) as ticket_promedio
FROM transacciones
GROUP BY tipo
ORDER BY ingresos_totales DESC;


-- ───────────────────────────────────────────────────────────────
-- 13. TRANSACCIONES CON PROBLEMAS (Pendientes > 1 hora)
-- ───────────────────────────────────────────────────────────────
SELECT 
    t.id,
    t.created_at as fecha,
    c.nombre as cliente,
    c.email,
    p.nombre as plaza,
    l.numero as local,
    t.tipo,
    t.monto,
    ROUND(EXTRACT(EPOCH FROM (NOW() - t.created_at))/3600, 2) as horas_pendiente
FROM transacciones t
JOIN clientes c ON t.cliente_id = c.id
JOIN locales l ON t.local_id = l.id
JOIN plazas p ON l.plaza_id = p.id
WHERE t.estado_pago = 'pendiente'
AND t.created_at < NOW() - INTERVAL '1 hour'
ORDER BY t.created_at ASC;


-- ───────────────────────────────────────────────────────────────
-- 14. ÚLTIMA ACTIVIDAD (Últimas 20 transacciones)
-- ───────────────────────────────────────────────────────────────
SELECT 
    t.id,
    t.created_at as fecha,
    c.nombre as cliente,
    p.nombre as plaza,
    l.numero as local,
    t.tipo,
    t.monto,
    t.estado_pago,
    CASE 
        WHEN t.created_at > NOW() - INTERVAL '1 hour' THEN '🔥 Reciente'
        WHEN t.created_at > NOW() - INTERVAL '24 hours' THEN '📅 Hoy'
        ELSE '📆 Anterior'
    END as antiguedad
FROM transacciones t
JOIN clientes c ON t.cliente_id = c.id
JOIN locales l ON t.local_id = l.id
JOIN plazas p ON l.plaza_id = p.id
ORDER BY t.created_at DESC
LIMIT 20;


-- ───────────────────────────────────────────────────────────────
-- 15. EXPORTAR TODO PARA EXCEL (Formato completo)
-- ───────────────────────────────────────────────────────────────
SELECT 
    t.id as "ID Transacción",
    TO_CHAR(t.created_at, 'DD/MM/YYYY HH24:MI:SS') as "Fecha y Hora",
    c.nombre as "Cliente",
    c.email as "Email",
    c.telefono as "Teléfono",
    p.nombre as "Plaza",
    l.numero as "Local",
    l.area as "Área (m²)",
    t.tipo as "Tipo",
    t.monto as "Monto (MXN)",
    t.estado_pago as "Estado",
    t.paypal_order_id as "PayPal Order ID",
    t.paypal_payment_id as "PayPal Payment ID",
    TO_CHAR(t.completed_at, 'DD/MM/YYYY HH24:MI:SS') as "Fecha Completado"
FROM transacciones t
JOIN clientes c ON t.cliente_id = c.id
JOIN locales l ON t.local_id = l.id
JOIN plazas p ON l.plaza_id = p.id
ORDER BY t.created_at DESC;


-- ═══════════════════════════════════════════════════════════════
-- NOTAS DE USO:
-- ═══════════════════════════════════════════════════════════════
-- 1. Copia la consulta que necesites
-- 2. Pégala en pgAdmin Query Tool
-- 3. Presiona F5 o el botón ▶️ para ejecutar
-- 4. Para exportar a Excel: Clic derecho en resultados → Export
-- ═══════════════════════════════════════════════════════════════
