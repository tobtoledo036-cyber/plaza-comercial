-- Seed: 5 Plazas del Estado de México
INSERT INTO plazas (nombre, ubicacion, descripcion, imagen_url, lat, lng, zoom_final) VALUES
('Plaza Satélite',    'Naucalpan de Juárez','Una de las plazas más emblemáticas del Estado de México','https://images.unsplash.com/photo-1555529669-e69e7aa0ba9a?w=800',19.5085,-99.2285,17),
('Mundo E',           'Ecatepec',           'Centro comercial moderno con gran afluencia de visitantes','https://images.unsplash.com/photo-1519567241046-7f570eee3ce6?w=800',19.6012,-99.0300,17),
('Plaza Las Américas','Toluca',             'Plaza comercial estratégica en el corazón de Toluca','https://images.unsplash.com/photo-1567958451986-2de427a4a0be?w=800',19.2826,-99.6557,17),
('Galerías Metepec',  'Metepec',            'Centro comercial premium con locales de alta plusvalía','https://images.unsplash.com/photo-1528698827591-e19ccd7bc23d?w=800',19.2558,-99.6044,17),
('Plaza Sendero',     'Tlalnepantla',       'Moderna plaza con excelente ubicación y conectividad','https://images.unsplash.com/photo-1582719471137-c3967ffb1c42?w=800',19.5400,-99.1950,17);

-- Locales Plaza Satélite (id=1)
INSERT INTO locales (plaza_id,numero,area,precio,estado,es_grande,lat_min,lat_max,lng_min,lng_max) VALUES
(1,'L-001',60,450000,'disponible',false,19.5067,19.5075,-99.2318,-99.2305),
(1,'L-002',120,850000,'disponible',true,19.5067,19.5075,-99.2305,-99.2285),
(1,'L-003',60,450000,'apartado',false,19.5067,19.5075,-99.2285,-99.2272),
(1,'L-004',60,450000,'vendido',false,19.5067,19.5075,-99.2272,-99.2259),
(1,'L-005',60,450000,'disponible',false,19.5075,19.5083,-99.2318,-99.2305),
(1,'L-006',120,850000,'vendido',true,19.5075,19.5083,-99.2305,-99.2285),
(1,'L-007',60,450000,'disponible',false,19.5075,19.5083,-99.2285,-99.2272),
(1,'L-008',60,450000,'apartado',false,19.5075,19.5083,-99.2272,-99.2259),
(1,'L-009',60,450000,'disponible',false,19.5083,19.5091,-99.2318,-99.2305),
(1,'L-010',60,450000,'vendido',false,19.5083,19.5091,-99.2305,-99.2285),
(1,'L-011',120,850000,'disponible',true,19.5083,19.5091,-99.2285,-99.2259),
(1,'L-012',60,450000,'apartado',false,19.5091,19.5099,-99.2318,-99.2305),
(1,'L-013',60,450000,'disponible',false,19.5091,19.5099,-99.2305,-99.2285),
(1,'L-014',60,450000,'vendido',false,19.5091,19.5099,-99.2285,-99.2272),
(1,'L-015',120,850000,'disponible',true,19.5091,19.5099,-99.2272,-99.2259),
(1,'L-016',60,450000,'disponible',false,19.5099,19.5107,-99.2318,-99.2305),
(1,'L-017',60,450000,'apartado',false,19.5099,19.5107,-99.2305,-99.2285),
(1,'L-018',60,450000,'vendido',false,19.5099,19.5107,-99.2285,-99.2272),
(1,'L-019',60,450000,'disponible',false,19.5099,19.5107,-99.2272,-99.2259),
(1,'L-020',120,850000,'disponible',true,19.5107,19.5110,-99.2318,-99.2259);

-- Locales Mundo E (id=2)
INSERT INTO locales (plaza_id,numero,area,precio,estado,es_grande,lat_min,lat_max,lng_min,lng_max) VALUES
(2,'L-001',60,420000,'disponible',false,19.5993,19.6001,-99.0323,-99.0310),
(2,'L-002',120,780000,'apartado',true,19.5993,19.6001,-99.0310,-99.0290),
(2,'L-003',60,420000,'disponible',false,19.5993,19.6001,-99.0290,-99.0277),
(2,'L-004',60,420000,'vendido',false,19.6001,19.6009,-99.0323,-99.0310),
(2,'L-005',120,780000,'disponible',true,19.6001,19.6009,-99.0310,-99.0290),
(2,'L-006',60,420000,'apartado',false,19.6001,19.6009,-99.0290,-99.0277),
(2,'L-007',60,420000,'disponible',false,19.6009,19.6017,-99.0323,-99.0310),
(2,'L-008',60,420000,'vendido',false,19.6009,19.6017,-99.0310,-99.0290),
(2,'L-009',120,780000,'disponible',true,19.6009,19.6017,-99.0290,-99.0277),
(2,'L-010',60,420000,'disponible',false,19.6017,19.6025,-99.0323,-99.0310),
(2,'L-011',60,420000,'apartado',false,19.6017,19.6025,-99.0310,-99.0290),
(2,'L-012',60,420000,'vendido',false,19.6017,19.6025,-99.0290,-99.0277),
(2,'L-013',120,780000,'disponible',true,19.6025,19.6030,-99.0323,-99.0277);

-- Locales Plaza Las Américas (id=3)
INSERT INTO locales (plaza_id,numero,area,precio,estado,es_grande,lat_min,lat_max,lng_min,lng_max) VALUES
(3,'L-001',60,480000,'disponible',false,19.2808,19.2816,-99.6578,-99.6565),
(3,'L-002',120,900000,'disponible',true,19.2808,19.2816,-99.6565,-99.6545),
(3,'L-003',60,480000,'vendido',false,19.2808,19.2816,-99.6545,-99.6532),
(3,'L-004',60,480000,'apartado',false,19.2816,19.2824,-99.6578,-99.6565),
(3,'L-005',120,900000,'disponible',true,19.2816,19.2824,-99.6565,-99.6545),
(3,'L-006',60,480000,'disponible',false,19.2816,19.2824,-99.6545,-99.6532),
(3,'L-007',60,480000,'vendido',false,19.2824,19.2832,-99.6578,-99.6565),
(3,'L-008',60,480000,'disponible',false,19.2824,19.2832,-99.6565,-99.6545),
(3,'L-009',120,900000,'apartado',true,19.2824,19.2832,-99.6545,-99.6532),
(3,'L-010',60,480000,'disponible',false,19.2832,19.2840,-99.6578,-99.6532);

-- Locales Galerías Metepec (id=4)
INSERT INTO locales (plaza_id,numero,area,precio,estado,es_grande,lat_min,lat_max,lng_min,lng_max) VALUES
(4,'L-001',60,520000,'disponible',false,19.2537,19.2545,-99.6068,-99.6055),
(4,'L-002',120,950000,'disponible',true,19.2537,19.2545,-99.6055,-99.6035),
(4,'L-003',60,520000,'vendido',false,19.2537,19.2545,-99.6035,-99.6022),
(4,'L-004',60,520000,'apartado',false,19.2545,19.2553,-99.6068,-99.6055),
(4,'L-005',120,950000,'disponible',true,19.2545,19.2553,-99.6055,-99.6035),
(4,'L-006',60,520000,'disponible',false,19.2545,19.2553,-99.6035,-99.6022),
(4,'L-007',60,520000,'vendido',false,19.2553,19.2561,-99.6068,-99.6055),
(4,'L-008',60,520000,'disponible',false,19.2553,19.2561,-99.6055,-99.6035),
(4,'L-009',120,950000,'apartado',true,19.2553,19.2561,-99.6035,-99.6022),
(4,'L-010',60,520000,'disponible',false,19.2561,19.2569,-99.6068,-99.6022);

-- Locales Plaza Sendero (id=5)
INSERT INTO locales (plaza_id,numero,area,precio,estado,es_grande,lat_min,lat_max,lng_min,lng_max) VALUES
(5,'L-001',60,440000,'disponible',false,19.5382,19.5390,-99.1973,-99.1960),
(5,'L-002',120,820000,'disponible',true,19.5382,19.5390,-99.1960,-99.1940),
(5,'L-003',60,440000,'vendido',false,19.5382,19.5390,-99.1940,-99.1927),
(5,'L-004',60,440000,'apartado',false,19.5390,19.5398,-99.1973,-99.1960),
(5,'L-005',120,820000,'disponible',true,19.5390,19.5398,-99.1960,-99.1940),
(5,'L-006',60,440000,'disponible',false,19.5390,19.5398,-99.1940,-99.1927),
(5,'L-007',60,440000,'vendido',false,19.5398,19.5406,-99.1973,-99.1960),
(5,'L-008',60,440000,'disponible',false,19.5398,19.5406,-99.1960,-99.1940),
(5,'L-009',120,820000,'apartado',true,19.5398,19.5406,-99.1940,-99.1927),
(5,'L-010',60,440000,'disponible',false,19.5406,19.5414,-99.1973,-99.1927);
