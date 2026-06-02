-- SQL generado automaticamente con hash correcto para Admin123!
DELETE FROM usuarios WHERE email = 'admin@plazas.com';

INSERT INTO usuarios (nombre, email, password_hash, rol, activo)
VALUES (
  'Administrador',
  'admin@plazas.com',
  '$2b$10$hsq7aOeQABG/INtYFT6h1.WOTXPCCR9qPY.UNYSL3SgToVEIetiQ.',
  'admin',
  true
);

SELECT id, nombre, email, rol, activo FROM usuarios WHERE email = 'admin@plazas.com';
SELECT 'Hash correcto instalado - Password: Admin123!' AS resultado;