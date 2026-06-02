-- ============================================================
-- SEED: Datos iniciales - PostgreSQL
-- ============================================================

INSERT INTO plazas (nombre, ubicacion, descripcion, imagen_url, lat, lng, zoom_final) VALUES
('Plaza Satélite',    'Naucalpan de Juárez', 'Una de las plazas más emblemáticas del Estado de México', 'https://images.unsplash.com/photo-1555529669-e69e7aa0ba9a?w=800', 19.5085, -99.2285, 17),
('Mundo E',           'Ecatepec',            'Centro comercial moderno con gran afluencia de visitantes', 'https://images.unsplash.com/photo-1519567241046-7f570eee3ce6?w=800', 19.6012, -99.0300, 17),
('Plaza Las Américas','Toluca',              'Plaza comercial estratégica en el corazón de Toluca',      'https://images.unsplash.com/photo-1567958451986-2de427a4a0be?w=800', 19.2826, -99.6557, 17),
('Galerías Metepec',  'Metepec',             'Centro comercial premium con locales de alta plusvalía',   'https://images.unsplash.com/photo-1528698827591-e19ccd7bc23d?w=800', 19.2558, -99.6044, 17),
('Plaza Sendero',     'Tlalnepantla',        'Moderna plaza con excelente ubicación y conectividad',     'https://images.unsplash.com/photo-1582719471137-c3967ffb1c42?w=800', 19.5400, -99.1950, 17);

-- Locales de Plaza Satélite (id=1) - 24 locales
INSERT INTO locales (plaza_id, numero, area, precio, estado, es_grande, lat_min, lat_max, lng_min, lng_max) VALUES
(1,'L-001',60,450000,'disponible',false,19.5065,19.5074,-99.2320,-99.2296),
(1,'L-002',120,850000,'disponible',true,19.5065,19.5074,-99.2296,-99.2272),
(1,'L-003',60,450000,'apartado',false,19.5065,19.5074,-99.2272,-99.2260),
(1,'L-004',60,450000,'vendido',false,19.5065,19.5074,-99.2260,-99.2255),
(1,'L-005',120,850000,'disponible',true,19.5074,19.5083,-99.2320,-99.2296),
(1,'L-006',60,450000,'apartado',false,19.5074,19.5083,-99.2296,-99.2272),
(1,'L-007',60,450000,'disponible',false,19.5074,19.5083,-99.2272,-99.2260),
(1,'L-008',60,450000,'vendido',false,19.5074,19.5083,-99.2260,-99.2255),
(1,'L-009',60,450000,'disponible',false,19.5083,19.5092,-99.2320,-99.2296),
(1,'L-010',60,450000,'vendido',false,19.5083,19.5092,-99.2296,-99.2272),
(1,'L-011',120,850000,'disponible',true,19.5083,19.5092,-99.2272,-99.2255),
(1,'L-012',60,450000,'apartado',false,19.5092,19.5101,-99.2320,-99.2296),
(1,'L-013',60,450000,'disponible',false,19.5092,19.5101,-99.2296,-99.2272),
(1,'L-014',60,450000,'vendido',false,19.5092,19.5101,-99.2272,-99.2260),
(1,'L-015',120,850000,'apartado',true,19.5092,19.5101,-99.2260,-99.2255),
(1,'L-016',60,450000,'disponible',false,19.5101,19.5110,-99.2320,-99.2296),
(1,'L-017',60,450000,'disponible',false,19.5101,19.5110,-99.2296,-99.2272),
(1,'L-018',60,450000,'vendido',false,19.5101,19.5110,-99.2272,-99.2260),
(1,'L-019',60,450000,'apartado',false,19.5101,19.5110,-99.2260,-99.2255),
(1,'L-020',120,850000,'disponible',true,19.5065,19.5074,-99.2255,-99.2248),
(1,'L-021',60,450000,'vendido',false,19.5074,19.5083,-99.2255,-99.2248),
(1,'L-022',60,450000,'disponible',false,19.5083,19.5092,-99.2255,-99.2248),
(1,'L-023',60,450000,'apartado',false,19.5092,19.5101,-99.2255,-99.2248),
(1,'L-024',120,850000,'disponible',true,19.5101,19.5110,-99.2255,-99.2248);
