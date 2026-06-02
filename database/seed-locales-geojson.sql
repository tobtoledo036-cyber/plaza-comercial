-- ============================================================
-- SEED: Locales con feature_index para GeoJSON
-- Ejecutar DESPUÉS de migracion-completa.sql
-- Cada local tiene feature_index = índice del LineString en el GeoJSON
-- (Feature[0] es el Polygon del perímetro, locales empiezan en índice 1)
-- ============================================================

-- Limpiar locales existentes (opcional — comentar si ya tienes datos reales)
-- DELETE FROM locales;

-- ── PLAZA 1: Plaza Satélite (24 LineStrings → índices 1-24) ──────────
DO $$
DECLARE v_plaza_id INT := 1; v_piso_id INT;
BEGIN
  SELECT id INTO v_piso_id FROM pisos WHERE plaza_id = v_plaza_id AND numero = 1;

  INSERT INTO locales (plaza_id, piso_id, numero, area, precio, estado, feature_index, giro)
  VALUES
    (v_plaza_id, v_piso_id, 'L-01', 45.00,  18000.00, 'disponible',  1, NULL),
    (v_plaza_id, v_piso_id, 'L-02', 38.50,  15500.00, 'disponible',  2, NULL),
    (v_plaza_id, v_piso_id, 'L-03', 32.00,  13000.00, 'disponible',  3, NULL),
    (v_plaza_id, v_piso_id, 'L-04', 29.00,  11500.00, 'disponible',  4, NULL),
    (v_plaza_id, v_piso_id, 'L-05', 35.00,  14000.00, 'disponible',  5, NULL),
    (v_plaza_id, v_piso_id, 'L-06', 42.00,  17000.00, 'disponible',  6, NULL),
    (v_plaza_id, v_piso_id, 'L-07', 28.00,  11000.00, 'disponible',  7, NULL),
    (v_plaza_id, v_piso_id, 'L-08', 31.00,  12500.00, 'disponible',  8, NULL),
    (v_plaza_id, v_piso_id, 'L-09', 36.00,  14500.00, 'disponible',  9, NULL),
    (v_plaza_id, v_piso_id, 'L-10', 40.00,  16000.00, 'disponible', 10, NULL),
    (v_plaza_id, v_piso_id, 'L-11', 33.00,  13200.00, 'disponible', 11, NULL),
    (v_plaza_id, v_piso_id, 'L-12', 27.00,  10800.00, 'disponible', 12, NULL),
    (v_plaza_id, v_piso_id, 'L-13', 44.00,  17600.00, 'disponible', 13, NULL),
    (v_plaza_id, v_piso_id, 'L-14', 39.00,  15600.00, 'disponible', 14, NULL),
    (v_plaza_id, v_piso_id, 'L-15', 30.00,  12000.00, 'disponible', 15, NULL),
    (v_plaza_id, v_piso_id, 'L-16', 34.00,  13600.00, 'disponible', 16, NULL),
    (v_plaza_id, v_piso_id, 'L-17', 37.00,  14800.00, 'disponible', 17, NULL),
    (v_plaza_id, v_piso_id, 'L-18', 41.00,  16400.00, 'disponible', 18, NULL),
    (v_plaza_id, v_piso_id, 'L-19', 26.00,  10400.00, 'disponible', 19, NULL),
    (v_plaza_id, v_piso_id, 'L-20', 43.00,  17200.00, 'disponible', 20, NULL),
    (v_plaza_id, v_piso_id, 'L-21', 38.00,  15200.00, 'disponible', 21, NULL),
    (v_plaza_id, v_piso_id, 'L-22', 32.00,  12800.00, 'disponible', 22, NULL),
    (v_plaza_id, v_piso_id, 'L-23', 29.00,  11600.00, 'disponible', 23, NULL),
    (v_plaza_id, v_piso_id, 'L-24', 35.00,  14000.00, 'disponible', 24, NULL)
  ON CONFLICT DO NOTHING;
END $$;

-- ── PLAZA 2: Mundo E (6 LineStrings → índices 1-6) ──────────────────
DO $$
DECLARE v_plaza_id INT := 2; v_piso_id INT;
BEGIN
  SELECT id INTO v_piso_id FROM pisos WHERE plaza_id = v_plaza_id AND numero = 1;

  INSERT INTO locales (plaza_id, piso_id, numero, area, precio, estado, feature_index, giro)
  VALUES
    (v_plaza_id, v_piso_id, 'L-01', 40.00, 16000.00, 'disponible', 1, NULL),
    (v_plaza_id, v_piso_id, 'L-02', 55.00, 22000.00, 'disponible', 2, NULL),
    (v_plaza_id, v_piso_id, 'L-03', 48.00, 19200.00, 'disponible', 3, NULL),
    (v_plaza_id, v_piso_id, 'L-04', 62.00, 24800.00, 'disponible', 4, NULL),
    (v_plaza_id, v_piso_id, 'L-05', 35.00, 14000.00, 'disponible', 5, NULL),
    (v_plaza_id, v_piso_id, 'L-06', 28.00, 11200.00, 'disponible', 6, NULL)
  ON CONFLICT DO NOTHING;
END $$;

-- ── PLAZA 3: Las Américas Toluca (15 LineStrings → índices 1-15) ────
DO $$
DECLARE v_plaza_id INT := 3; v_piso_id INT;
BEGIN
  SELECT id INTO v_piso_id FROM pisos WHERE plaza_id = v_plaza_id AND numero = 1;

  INSERT INTO locales (plaza_id, piso_id, numero, area, precio, estado, feature_index, giro)
  VALUES
    (v_plaza_id, v_piso_id, 'L-01', 38.00, 15200.00, 'disponible',  1, NULL),
    (v_plaza_id, v_piso_id, 'L-02', 32.00, 12800.00, 'disponible',  2, NULL),
    (v_plaza_id, v_piso_id, 'L-03', 29.00, 11600.00, 'disponible',  3, NULL),
    (v_plaza_id, v_piso_id, 'L-04', 25.00, 10000.00, 'disponible',  4, NULL),
    (v_plaza_id, v_piso_id, 'L-05', 27.00, 10800.00, 'disponible',  5, NULL),
    (v_plaza_id, v_piso_id, 'L-06', 22.00,  8800.00, 'disponible',  6, NULL),
    (v_plaza_id, v_piso_id, 'L-07', 24.00,  9600.00, 'disponible',  7, NULL),
    (v_plaza_id, v_piso_id, 'L-08', 30.00, 12000.00, 'disponible',  8, NULL),
    (v_plaza_id, v_piso_id, 'L-09', 35.00, 14000.00, 'disponible',  9, NULL),
    (v_plaza_id, v_piso_id, 'L-10', 28.00, 11200.00, 'disponible', 10, NULL),
    (v_plaza_id, v_piso_id, 'L-11', 26.00, 10400.00, 'disponible', 11, NULL),
    (v_plaza_id, v_piso_id, 'L-12', 33.00, 13200.00, 'disponible', 12, NULL),
    (v_plaza_id, v_piso_id, 'L-13', 31.00, 12400.00, 'disponible', 13, NULL),
    (v_plaza_id, v_piso_id, 'L-14', 23.00,  9200.00, 'disponible', 14, NULL),
    (v_plaza_id, v_piso_id, 'L-15', 36.00, 14400.00, 'disponible', 15, NULL)
  ON CONFLICT DO NOTHING;
END $$;

-- ── PLAZA 4: Galerías Metepec (16 LineStrings → índices 1-16) ───────
DO $$
DECLARE v_plaza_id INT := 4; v_piso_id INT;
BEGIN
  SELECT id INTO v_piso_id FROM pisos WHERE plaza_id = v_plaza_id AND numero = 1;

  INSERT INTO locales (plaza_id, piso_id, numero, area, precio, estado, feature_index, giro)
  VALUES
    (v_plaza_id, v_piso_id, 'L-01', 50.00, 25000.00, 'disponible',  1, NULL),
    (v_plaza_id, v_piso_id, 'L-02', 45.00, 22500.00, 'disponible',  2, NULL),
    (v_plaza_id, v_piso_id, 'L-03', 80.00, 40000.00, 'disponible',  3, NULL),
    (v_plaza_id, v_piso_id, 'L-04', 75.00, 37500.00, 'disponible',  4, NULL),
    (v_plaza_id, v_piso_id, 'L-05', 30.00, 15000.00, 'disponible',  5, NULL),
    (v_plaza_id, v_piso_id, 'L-06', 65.00, 32500.00, 'disponible',  6, NULL),
    (v_plaza_id, v_piso_id, 'L-07', 42.00, 21000.00, 'disponible',  7, NULL),
    (v_plaza_id, v_piso_id, 'L-08', 38.00, 19000.00, 'disponible',  8, NULL),
    (v_plaza_id, v_piso_id, 'L-09', 35.00, 17500.00, 'disponible',  9, NULL),
    (v_plaza_id, v_piso_id, 'L-10', 28.00, 14000.00, 'disponible', 10, NULL),
    (v_plaza_id, v_piso_id, 'L-11', 32.00, 16000.00, 'disponible', 11, NULL),
    (v_plaza_id, v_piso_id, 'L-12', 55.00, 27500.00, 'disponible', 12, NULL),
    (v_plaza_id, v_piso_id, 'L-13', 70.00, 35000.00, 'disponible', 13, NULL),
    (v_plaza_id, v_piso_id, 'L-14', 40.00, 20000.00, 'disponible', 14, NULL),
    (v_plaza_id, v_piso_id, 'L-15', 48.00, 24000.00, 'disponible', 15, NULL),
    (v_plaza_id, v_piso_id, 'L-16', 33.00, 16500.00, 'disponible', 16, NULL)
  ON CONFLICT DO NOTHING;
END $$;

-- ── PLAZA 5: Plaza Sendero (9 LineStrings → índices 1-9) ────────────
DO $$
DECLARE v_plaza_id INT := 5; v_piso_id INT;
BEGIN
  SELECT id INTO v_piso_id FROM pisos WHERE plaza_id = v_plaza_id AND numero = 1;

  INSERT INTO locales (plaza_id, piso_id, numero, area, precio, estado, feature_index, giro)
  VALUES
    (v_plaza_id, v_piso_id, 'L-01', 45.00, 18000.00, 'disponible', 1, NULL),
    (v_plaza_id, v_piso_id, 'L-02', 38.00, 15200.00, 'disponible', 2, NULL),
    (v_plaza_id, v_piso_id, 'L-03', 42.00, 16800.00, 'disponible', 3, NULL),
    (v_plaza_id, v_piso_id, 'L-04', 90.00, 36000.00, 'disponible', 4, NULL),
    (v_plaza_id, v_piso_id, 'L-05', 55.00, 22000.00, 'disponible', 5, NULL),
    (v_plaza_id, v_piso_id, 'L-06', 35.00, 14000.00, 'disponible', 6, NULL),
    (v_plaza_id, v_piso_id, 'L-07',120.00, 48000.00, 'disponible', 7, NULL),
    (v_plaza_id, v_piso_id, 'L-08', 60.00, 24000.00, 'disponible', 8, NULL),
    (v_plaza_id, v_piso_id, 'L-09', 30.00, 12000.00, 'disponible', 9, NULL)
  ON CONFLICT DO NOTHING;
END $$;

-- ── Verificación ─────────────────────────────────────────────────────
SELECT p.nombre AS plaza, COUNT(l.id) AS locales
FROM plazas p
LEFT JOIN locales l ON l.plaza_id = p.id
GROUP BY p.id, p.nombre
ORDER BY p.id;
