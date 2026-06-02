-- ============================================================
-- SEED: Segundo piso para todas las plazas + locales
-- Ejecutar después de seed-locales-geojson.sql
-- ============================================================

-- ── Insertar Piso 2 para cada plaza ─────────────────────────
INSERT INTO pisos (plaza_id, numero, nombre) VALUES
  (1, 2, 'Primer Nivel'),
  (2, 2, 'Primer Nivel'),
  (3, 2, 'Primer Nivel'),
  (4, 2, 'Primer Nivel'),
  (5, 2, 'Primer Nivel')
ON CONFLICT (plaza_id, numero) DO NOTHING;

-- ── Plaza 1: Plaza Satélite — Piso 2 (11 locales) ───────────
DO $$
DECLARE v_plaza_id INT := 1; v_piso_id INT;
BEGIN
  SELECT id INTO v_piso_id FROM pisos WHERE plaza_id = v_plaza_id AND numero = 2;
  INSERT INTO locales (plaza_id, piso_id, numero, area, precio, estado, feature_index, giro)
  VALUES
    (v_plaza_id, v_piso_id, 'P2-L01', 42.00, 19000.00, 'disponible',  1, NULL),
    (v_plaza_id, v_piso_id, 'P2-L02', 36.00, 16200.00, 'disponible',  2, NULL),
    (v_plaza_id, v_piso_id, 'P2-L03', 30.00, 13500.00, 'disponible',  3, NULL),
    (v_plaza_id, v_piso_id, 'P2-L04', 28.00, 12600.00, 'disponible',  4, NULL),
    (v_plaza_id, v_piso_id, 'P2-L05', 33.00, 14850.00, 'disponible',  5, NULL),
    (v_plaza_id, v_piso_id, 'P2-L06', 39.00, 17550.00, 'disponible',  6, NULL),
    (v_plaza_id, v_piso_id, 'P2-L07', 27.00, 12150.00, 'disponible',  7, NULL),
    (v_plaza_id, v_piso_id, 'P2-L08', 44.00, 19800.00, 'disponible',  8, NULL),
    (v_plaza_id, v_piso_id, 'P2-L09', 31.00, 13950.00, 'disponible',  9, NULL),
    (v_plaza_id, v_piso_id, 'P2-L10', 37.00, 16650.00, 'disponible', 10, NULL),
    (v_plaza_id, v_piso_id, 'P2-L11', 29.00, 13050.00, 'disponible', 11, NULL)
  ON CONFLICT DO NOTHING;
END $$;

-- ── Plaza 2: Mundo E — Piso 2 (6 locales) ───────────────────
DO $$
DECLARE v_plaza_id INT := 2; v_piso_id INT;
BEGIN
  SELECT id INTO v_piso_id FROM pisos WHERE plaza_id = v_plaza_id AND numero = 2;
  INSERT INTO locales (plaza_id, piso_id, numero, area, precio, estado, feature_index, giro)
  VALUES
    (v_plaza_id, v_piso_id, 'P2-L01', 38.00, 15200.00, 'disponible', 1, NULL),
    (v_plaza_id, v_piso_id, 'P2-L02', 52.00, 20800.00, 'disponible', 2, NULL),
    (v_plaza_id, v_piso_id, 'P2-L03', 45.00, 18000.00, 'disponible', 3, NULL),
    (v_plaza_id, v_piso_id, 'P2-L04', 58.00, 23200.00, 'disponible', 4, NULL),
    (v_plaza_id, v_piso_id, 'P2-L05', 33.00, 13200.00, 'disponible', 5, NULL),
    (v_plaza_id, v_piso_id, 'P2-L06', 26.00, 10400.00, 'disponible', 6, NULL)
  ON CONFLICT DO NOTHING;
END $$;

-- ── Plaza 3: Las Américas — Piso 2 (15 locales) ─────────────
DO $$
DECLARE v_plaza_id INT := 3; v_piso_id INT;
BEGIN
  SELECT id INTO v_piso_id FROM pisos WHERE plaza_id = v_plaza_id AND numero = 2;
  INSERT INTO locales (plaza_id, piso_id, numero, area, precio, estado, feature_index, giro)
  VALUES
    (v_plaza_id, v_piso_id, 'P2-L01', 36.00, 14400.00, 'disponible',  1, NULL),
    (v_plaza_id, v_piso_id, 'P2-L02', 30.00, 12000.00, 'disponible',  2, NULL),
    (v_plaza_id, v_piso_id, 'P2-L03', 27.00, 10800.00, 'disponible',  3, NULL),
    (v_plaza_id, v_piso_id, 'P2-L04', 23.00,  9200.00, 'disponible',  4, NULL),
    (v_plaza_id, v_piso_id, 'P2-L05', 25.00, 10000.00, 'disponible',  5, NULL),
    (v_plaza_id, v_piso_id, 'P2-L06', 20.00,  8000.00, 'disponible',  6, NULL),
    (v_plaza_id, v_piso_id, 'P2-L07', 22.00,  8800.00, 'disponible',  7, NULL),
    (v_plaza_id, v_piso_id, 'P2-L08', 28.00, 11200.00, 'disponible',  8, NULL),
    (v_plaza_id, v_piso_id, 'P2-L09', 33.00, 13200.00, 'disponible',  9, NULL),
    (v_plaza_id, v_piso_id, 'P2-L10', 26.00, 10400.00, 'disponible', 10, NULL),
    (v_plaza_id, v_piso_id, 'P2-L11', 24.00,  9600.00, 'disponible', 11, NULL),
    (v_plaza_id, v_piso_id, 'P2-L12', 31.00, 12400.00, 'disponible', 12, NULL),
    (v_plaza_id, v_piso_id, 'P2-L13', 29.00, 11600.00, 'disponible', 13, NULL),
    (v_plaza_id, v_piso_id, 'P2-L14', 21.00,  8400.00, 'disponible', 14, NULL),
    (v_plaza_id, v_piso_id, 'P2-L15', 34.00, 13600.00, 'disponible', 15, NULL)
  ON CONFLICT DO NOTHING;
END $$;

-- ── Plaza 4: Galerías Metepec — Piso 2 (16 locales) ─────────
DO $$
DECLARE v_plaza_id INT := 4; v_piso_id INT;
BEGIN
  SELECT id INTO v_piso_id FROM pisos WHERE plaza_id = v_plaza_id AND numero = 2;
  INSERT INTO locales (plaza_id, piso_id, numero, area, precio, estado, feature_index, giro)
  VALUES
    (v_plaza_id, v_piso_id, 'P2-L01', 48.00, 24000.00, 'disponible',  1, NULL),
    (v_plaza_id, v_piso_id, 'P2-L02', 43.00, 21500.00, 'disponible',  2, NULL),
    (v_plaza_id, v_piso_id, 'P2-L03', 75.00, 37500.00, 'disponible',  3, NULL),
    (v_plaza_id, v_piso_id, 'P2-L04', 70.00, 35000.00, 'disponible',  4, NULL),
    (v_plaza_id, v_piso_id, 'P2-L05', 28.00, 14000.00, 'disponible',  5, NULL),
    (v_plaza_id, v_piso_id, 'P2-L06', 60.00, 30000.00, 'disponible',  6, NULL),
    (v_plaza_id, v_piso_id, 'P2-L07', 40.00, 20000.00, 'disponible',  7, NULL),
    (v_plaza_id, v_piso_id, 'P2-L08', 36.00, 18000.00, 'disponible',  8, NULL),
    (v_plaza_id, v_piso_id, 'P2-L09', 33.00, 16500.00, 'disponible',  9, NULL),
    (v_plaza_id, v_piso_id, 'P2-L10', 26.00, 13000.00, 'disponible', 10, NULL),
    (v_plaza_id, v_piso_id, 'P2-L11', 30.00, 15000.00, 'disponible', 11, NULL),
    (v_plaza_id, v_piso_id, 'P2-L12', 52.00, 26000.00, 'disponible', 12, NULL),
    (v_plaza_id, v_piso_id, 'P2-L13', 65.00, 32500.00, 'disponible', 13, NULL),
    (v_plaza_id, v_piso_id, 'P2-L14', 38.00, 19000.00, 'disponible', 14, NULL),
    (v_plaza_id, v_piso_id, 'P2-L15', 45.00, 22500.00, 'disponible', 15, NULL),
    (v_plaza_id, v_piso_id, 'P2-L16', 31.00, 15500.00, 'disponible', 16, NULL)
  ON CONFLICT DO NOTHING;
END $$;

-- ── Plaza 5: Plaza Sendero — Piso 2 (9 locales) ─────────────
DO $$
DECLARE v_plaza_id INT := 5; v_piso_id INT;
BEGIN
  SELECT id INTO v_piso_id FROM pisos WHERE plaza_id = v_plaza_id AND numero = 2;
  INSERT INTO locales (plaza_id, piso_id, numero, area, precio, estado, feature_index, giro)
  VALUES
    (v_plaza_id, v_piso_id, 'P2-L01', 43.00, 17200.00, 'disponible', 1, NULL),
    (v_plaza_id, v_piso_id, 'P2-L02', 36.00, 14400.00, 'disponible', 2, NULL),
    (v_plaza_id, v_piso_id, 'P2-L03', 40.00, 16000.00, 'disponible', 3, NULL),
    (v_plaza_id, v_piso_id, 'P2-L04', 85.00, 34000.00, 'disponible', 4, NULL),
    (v_plaza_id, v_piso_id, 'P2-L05', 52.00, 20800.00, 'disponible', 5, NULL),
    (v_plaza_id, v_piso_id, 'P2-L06', 33.00, 13200.00, 'disponible', 6, NULL),
    (v_plaza_id, v_piso_id, 'P2-L07',115.00, 46000.00, 'disponible', 7, NULL),
    (v_plaza_id, v_piso_id, 'P2-L08', 57.00, 22800.00, 'disponible', 8, NULL),
    (v_plaza_id, v_piso_id, 'P2-L09', 28.00, 11200.00, 'disponible', 9, NULL)
  ON CONFLICT DO NOTHING;
END $$;

-- ── Verificación ─────────────────────────────────────────────
SELECT p.nombre AS plaza, pi.nombre AS piso, COUNT(l.id) AS locales
FROM plazas p
JOIN pisos pi ON pi.plaza_id = p.id
LEFT JOIN locales l ON l.piso_id = pi.id
GROUP BY p.id, p.nombre, pi.numero, pi.nombre
ORDER BY p.id, pi.numero;
