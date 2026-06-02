import bcrypt from 'bcryptjs';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
const __dirname = path.dirname(fileURLToPath(import.meta.url));

bcrypt.hash('Admin123!', 10).then(hash => {
  const sql = [
    '-- SQL generado automaticamente con hash correcto para Admin123!',
    "DELETE FROM usuarios WHERE email = 'admin@plazas.com';",
    '',
    'INSERT INTO usuarios (nombre, email, password_hash, rol, activo)',
    'VALUES (',
    "  'Administrador',",
    "  'admin@plazas.com',",
    "  '" + hash + "',",
    "  'admin',",
    '  true',
    ');',
    '',
    "SELECT id, nombre, email, rol, activo FROM usuarios WHERE email = 'admin@plazas.com';",
    "SELECT 'Hash correcto instalado - Password: Admin123!' AS resultado;"
  ].join('\n');

  const outPath = path.join(__dirname, '..', 'database', 'HASH-CORRECTO-ADMIN.sql');
  fs.writeFileSync(outPath, sql, 'utf8');
  console.log('✅ Archivo creado: database/HASH-CORRECTO-ADMIN.sql');
  console.log('Hash:', hash);
});
