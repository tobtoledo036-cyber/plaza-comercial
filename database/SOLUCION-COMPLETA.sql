-- ============================================================
-- SOLUCIÓN COMPLETA: Poblar base de datos con plazas y locales
-- ============================================================

-- Primero, insertar las 5 plazas
INSERT INTO plazas (nombre, ubicacion, descripcion, imagen_url, lat, lng, zoom_final) VALUES
('Plaza Satélite',    'Naucalpan de Juárez', 'Una de las plazas más emblemáticas del Estado de México', 'https://images.unsplash.com/photo-1555529669-e69e7aa0ba9a?w=800', 19.5085, -99.2285, 17),
('Mundo E',           'Ecatepec',            'Centro comercial moderno con gran afluencia de visitantes', 'https://images.unsplash.com/photo-1519567241046-7f570eee3ce6?w=800', 19.6012, -99.0300, 17),
('Plaza Las Américas','Toluca',              'Plaza comercial estratégica en el corazón de Toluca',      'https://images.unsplash.com/photo-1567958451986-2de427a4a0be?w=800', 19.2826, -99.6557, 17),
('Galerías Metepec',  'Metepec',             'Centro comercial premium con locales de alta plusvalía',   'https://images.unsplash.com/photo-1528698827591-e19ccd7bc23d?w=800', 19.2558, -99.6044, 17),
('Plaza Sendero',     'Tlalnepantla',        'Moderna plaza con excelente ubicación y conectividad',     'https://images.unsplash.com/photo-1582719471137-c3967ffb1c42?w=800', 19.5400, -99.1950, 17)
ON CONFLICT DO NOTHING;

-- Insertar locales de Plaza Satélite (24 locales)
INSERT INTO locales (plaza_id, numero, area, precio, estado, es_grande, lat_min, lat_max, lng_min, lng_max) VALUES
(1,'L-001',60,450000,'disponible',false,19.5065,19.5074,-99.2320,-99.2296),
(1,'L-002',120,850000,'disponible',true,19.5065,19.5074,-99.2296,-99.2272),
(1,'L-003',60,450000,'disponible',false,19.5065,19.5074,-99.2272,-99.2260),
(1,'L-004',60,450000,'disponible',false,19.5065,19.5074,-99.2260,-99.2255),
(1,'L-005',120,850000,'disponible',true,19.5074,19.5083,-99.2320,-99.2296),
(1,'L-006',60,450000,'disponible',false,19.5074,19.5083,-99.2296,-99.2272),
(1,'L-007',60,450000,'disponible',false,19.5074,19.5083,-99.2272,-99.2260),
(1,'L-008',60,450000,'disponible',false,19.5074,19.5083,-99.2260,-99.2255),
(1,'L-009',60,450000,'disponible',false,19.5083,19.5092,-99.2320,-99.2296),
(1,'L-010',60,450000,'disponible',false,19.5083,19.5092,-99.2296,-99.2272),
(1,'L-011',120,850000,'disponible',true,19.5083,19.5092,-99.2272,-99.2255),
(1,'L-012',60,450000,'disponible',false,19.5092,19.5101,-99.2320,-99.2296),
(1,'L-013',60,450000,'disponible',false,19.5092,19.5101,-99.2296,-99.2272),
(1,'L-014',60,450000,'disponible',false,19.5092,19.5101,-99.2272,-99.2260),
(1,'L-015',120,850000,'disponible',true,19.5092,19.5101,-99.2260,-99.2255),
(1,'L-016',60,450000,'disponible',false,19.5101,19.5110,-99.2320,-99.2296),
(1,'L-017',60,450000,'disponible',false,19.5101,19.5110,-99.2296,-99.2272),
(1,'L-018',60,450000,'disponible',false,19.5101,19.5110,-99.2272,-99.2260),
(1,'L-019',60,450000,'disponible',false,19.5101,19.5110,-99.2260,-99.2255),
(1,'L-020',120,850000,'disponible',true,19.5065,19.5074,-99.2255,-99.2248),
(1,'L-021',60,450000,'disponible',false,19.5074,19.5083,-99.2255,-99.2248),
(1,'L-022',60,450000,'disponible',false,19.5083,19.5092,-99.2255,-99.2248),
(1,'L-023',60,450000,'disponible',false,19.5092,19.5101,-99.2255,-99.2248),
(1,'L-024',120,850000,'disponible',true,19.5101,19.5110,-99.2255,-99.2248);

-- Insertar locales de Mundo E (20 locales)
INSERT INTO locales (plaza_id, numero, area, precio, estado, es_grande, lat_min, lat_max, lng_min, lng_max) VALUES
(2,'L-001',60,420000,'disponible',false,19.5992,19.6001,-99.0335,-99.0311),
(2,'L-002',120,800000,'disponible',true,19.5992,19.6001,-99.0311,-99.0287),
(2,'L-003',60,420000,'disponible',false,19.5992,19.6001,-99.0287,-99.0275),
(2,'L-004',60,420000,'disponible',false,19.5992,19.6001,-99.0275,-99.0270),
(2,'L-005',120,800000,'disponible',true,19.6001,19.6010,-99.0335,-99.0311),
(2,'L-006',60,420000,'disponible',false,19.6001,19.6010,-99.0311,-99.0287),
(2,'L-007',60,420000,'disponible',false,19.6001,19.6010,-99.0287,-99.0275),
(2,'L-008',60,420000,'disponible',false,19.6001,19.6010,-99.0275,-99.0270),
(2,'L-009',60,420000,'disponible',false,19.6010,19.6019,-99.0335,-99.0311),
(2,'L-010',60,420000,'disponible',false,19.6010,19.6019,-99.0311,-99.0287),
(2,'L-011',120,800000,'disponible',true,19.6010,19.6019,-99.0287,-99.0270),
(2,'L-012',60,420000,'disponible',false,19.6019,19.6028,-99.0335,-99.0311),
(2,'L-013',60,420000,'disponible',false,19.6019,19.6028,-99.0311,-99.0287),
(2,'L-014',60,420000,'disponible',false,19.6019,19.6028,-99.0287,-99.0275),
(2,'L-015',120,800000,'disponible',true,19.6019,19.6028,-99.0275,-99.0270),
(2,'L-016',60,420000,'disponible',false,19.6028,19.6037,-99.0335,-99.0311),
(2,'L-017',60,420000,'disponible',false,19.6028,19.6037,-99.0311,-99.0287),
(2,'L-018',60,420000,'disponible',false,19.6028,19.6037,-99.0287,-99.0275),
(2,'L-019',60,420000,'disponible',false,19.6028,19.6037,-99.0275,-99.0270),
(2,'L-020',120,800000,'disponible',true,19.5992,19.6001,-99.0270,-99.0263);

-- Insertar locales de Plaza Las Américas (22 locales)
INSERT INTO locales (plaza_id, numero, area, precio, estado, es_grande, lat_min, lat_max, lng_min, lng_max) VALUES
(3,'L-001',60,480000,'disponible',false,19.2806,19.2815,-99.6592,-99.6568),
(3,'L-002',120,900000,'disponible',true,19.2806,19.2815,-99.6568,-99.6544),
(3,'L-003',60,480000,'disponible',false,19.2806,19.2815,-99.6544,-99.6532),
(3,'L-004',60,480000,'disponible',false,19.2806,19.2815,-99.6532,-99.6527),
(3,'L-005',120,900000,'disponible',true,19.2815,19.2824,-99.6592,-99.6568),
(3,'L-006',60,480000,'disponible',false,19.2815,19.2824,-99.6568,-99.6544),
(3,'L-007',60,480000,'disponible',false,19.2815,19.2824,-99.6544,-99.6532),
(3,'L-008',60,480000,'disponible',false,19.2815,19.2824,-99.6532,-99.6527),
(3,'L-009',60,480000,'disponible',false,19.2824,19.2833,-99.6592,-99.6568),
(3,'L-010',60,480000,'disponible',false,19.2824,19.2833,-99.6568,-99.6544),
(3,'L-011',120,900000,'disponible',true,19.2824,19.2833,-99.6544,-99.6527),
(3,'L-012',60,480000,'disponible',false,19.2833,19.2842,-99.6592,-99.6568),
(3,'L-013',60,480000,'disponible',false,19.2833,19.2842,-99.6568,-99.6544),
(3,'L-014',60,480000,'disponible',false,19.2833,19.2842,-99.6544,-99.6532),
(3,'L-015',120,900000,'disponible',true,19.2833,19.2842,-99.6532,-99.6527),
(3,'L-016',60,480000,'disponible',false,19.2842,19.2851,-99.6592,-99.6568),
(3,'L-017',60,480000,'disponible',false,19.2842,19.2851,-99.6568,-99.6544),
(3,'L-018',60,480000,'disponible',false,19.2842,19.2851,-99.6544,-99.6532),
(3,'L-019',60,480000,'disponible',false,19.2842,19.2851,-99.6532,-99.6527),
(3,'L-020',120,900000,'disponible',true,19.2806,19.2815,-99.6527,-99.6520),
(3,'L-021',60,480000,'disponible',false,19.2815,19.2824,-99.6527,-99.6520),
(3,'L-022',60,480000,'disponible',false,19.2824,19.2833,-99.6527,-99.6520);

-- Insertar locales de Galerías Metepec (20 locales)
INSERT INTO locales (plaza_id, numero, area, precio, estado, es_grande, lat_min, lat_max, lng_min, lng_max) VALUES
(4,'L-001',60,520000,'disponible',false,19.2538,19.2547,-99.6079,-99.6055),
(4,'L-002',120,950000,'disponible',true,19.2538,19.2547,-99.6055,-99.6031),
(4,'L-003',60,520000,'disponible',false,19.2538,19.2547,-99.6031,-99.6019),
(4,'L-004',60,520000,'disponible',false,19.2538,19.2547,-99.6019,-99.6014),
(4,'L-005',120,950000,'disponible',true,19.2547,19.2556,-99.6079,-99.6055),
(4,'L-006',60,520000,'disponible',false,19.2547,19.2556,-99.6055,-99.6031),
(4,'L-007',60,520000,'disponible',false,19.2547,19.2556,-99.6031,-99.6019),
(4,'L-008',60,520000,'disponible',false,19.2547,19.2556,-99.6019,-99.6014),
(4,'L-009',60,520000,'disponible',false,19.2556,19.2565,-99.6079,-99.6055),
(4,'L-010',60,520000,'disponible',false,19.2556,19.2565,-99.6055,-99.6031),
(4,'L-011',120,950000,'disponible',true,19.2556,19.2565,-99.6031,-99.6014),
(4,'L-012',60,520000,'disponible',false,19.2565,19.2574,-99.6079,-99.6055),
(4,'L-013',60,520000,'disponible',false,19.2565,19.2574,-99.6055,-99.6031),
(4,'L-014',60,520000,'disponible',false,19.2565,19.2574,-99.6031,-99.6019),
(4,'L-015',120,950000,'disponible',true,19.2565,19.2574,-99.6019,-99.6014),
(4,'L-016',60,520000,'disponible',false,19.2574,19.2583,-99.6079,-99.6055),
(4,'L-017',60,520000,'disponible',false,19.2574,19.2583,-99.6055,-99.6031),
(4,'L-018',60,520000,'disponible',false,19.2574,19.2583,-99.6031,-99.6019),
(4,'L-019',60,520000,'disponible',false,19.2574,19.2583,-99.6019,-99.6014),
(4,'L-020',120,950000,'disponible',true,19.2538,19.2547,-99.6014,-99.6007);

-- Insertar locales de Plaza Sendero (20 locales)
INSERT INTO locales (plaza_id, numero, area, precio, estado, es_grande, lat_min, lat_max, lng_min, lng_max) VALUES
(5,'L-001',60,440000,'disponible',false,19.5380,19.5389,-99.1985,-99.1961),
(5,'L-002',120,820000,'disponible',true,19.5380,19.5389,-99.1961,-99.1937),
(5,'L-003',60,440000,'disponible',false,19.5380,19.5389,-99.1937,-99.1925),
(5,'L-004',60,440000,'disponible',false,19.5380,19.5389,-99.1925,-99.1920),
(5,'L-005',120,820000,'disponible',true,19.5389,19.5398,-99.1985,-99.1961),
(5,'L-006',60,440000,'disponible',false,19.5389,19.5398,-99.1961,-99.1937),
(5,'L-007',60,440000,'disponible',false,19.5389,19.5398,-99.1937,-99.1925),
(5,'L-008',60,440000,'disponible',false,19.5389,19.5398,-99.1925,-99.1920),
(5,'L-009',60,440000,'disponible',false,19.5398,19.5407,-99.1985,-99.1961),
(5,'L-010',60,440000,'disponible',false,19.5398,19.5407,-99.1961,-99.1937),
(5,'L-011',120,820000,'disponible',true,19.5398,19.5407,-99.1937,-99.1920),
(5,'L-012',60,440000,'disponible',false,19.5407,19.5416,-99.1985,-99.1961),
(5,'L-013',60,440000,'disponible',false,19.5407,19.5416,-99.1961,-99.1937),
(5,'L-014',60,440000,'disponible',false,19.5407,19.5416,-99.1937,-99.1925),
(5,'L-015',120,820000,'disponible',true,19.5407,19.5416,-99.1925,-99.1920),
(5,'L-016',60,440000,'disponible',false,19.5416,19.5425,-99.1985,-99.1961),
(5,'L-017',60,440000,'disponible',false,19.5416,19.5425,-99.1961,-99.1937),
(5,'L-018',60,440000,'disponible',false,19.5416,19.5425,-99.1937,-99.1925),
(5,'L-019',60,440000,'disponible',false,19.5416,19.5425,-99.1925,-99.1920),
(5,'L-020',120,820000,'disponible',true,19.5380,19.5389,-99.1920,-99.1913);

-- Actualizar precio_apartado para todos los locales (30% del precio)
UPDATE locales
SET precio_apartado = ROUND(precio * 0.30, 2)
WHERE precio_apartado IS NULL;

-- Verificar resultados
SELECT 'Plazas insertadas' AS mensaje, COUNT(*) AS total FROM plazas;
SELECT 'Locales insertados' AS mensaje, COUNT(*) AS total FROM locales;
SELECT plaza_id, COUNT(*) AS locales_por_plaza FROM locales GROUP BY plaza_id ORDER BY plaza_id;
