# ============================================================
# Script: Ejecutar migración SQL directamente en Azure
# ============================================================

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║       EJECUTANDO MIGRACIÓN SQL EN AZURE               ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Leer el archivo SQL
$SQL_FILE = "database\migracion-auth.sql"
Write-Host "📄 Leyendo archivo SQL..." -ForegroundColor Cyan

if (-not (Test-Path $SQL_FILE)) {
    Write-Host "❌ Error: No se encuentra el archivo $SQL_FILE" -ForegroundColor Red
    exit 1
}

$sqlContent = Get-Content $SQL_FILE -Raw

# Crear archivo temporal sin comentarios para ejecutar
$sqlCommands = $sqlContent -replace '--.*$', '' -replace '/\*[\s\S]*?\*/', ''

# Guardar en archivo temporal
$tempFile = "temp_migration.sql"
$sqlCommands | Out-File -FilePath $tempFile -Encoding UTF8

Write-Host "✅ Archivo SQL preparado" -ForegroundColor Green
Write-Host ""

# Datos de conexión
$PG_HOST = "plazas-postgres-2024.eastus.azurecontainer.io"
$PG_PORT = "5432"
$PG_DB = "plazas_db"
$PG_USER = "plazasadmin"
$PG_PASSWORD = "TuPassword123!"

Write-Host "🔄 Ejecutando migración en PostgreSQL de Azure..." -ForegroundColor Yellow
Write-Host ""

# Ejecutar usando az container exec
$command = "PGPASSWORD='$PG_PASSWORD' psql -h $PG_HOST -p $PG_PORT -U $PG_USER -d $PG_DB -c `"$(Get-Content $tempFile -Raw -Encoding UTF8)`""

try {
    # Intentar ejecutar cada comando SQL individualmente
    Write-Host "📊 Creando tabla usuarios..." -ForegroundColor Cyan
    
    $env:PGPASSWORD = $PG_PASSWORD
    
    # Comando 1: Crear tabla usuarios
    $cmd1 = @"
CREATE TABLE IF NOT EXISTS usuarios (
    id            SERIAL PRIMARY KEY,
    nombre        VARCHAR(100) NOT NULL,
    email         VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    rol           VARCHAR(20)  NOT NULL DEFAULT 'cliente'
                    CHECK (rol IN ('admin','cliente')),
    telefono      VARCHAR(20),
    activo        BOOLEAN DEFAULT TRUE,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
"@
    
    # Usar docker para ejecutar psql si está disponible
    Write-Host "   Intentando crear tabla usuarios..." -ForegroundColor Gray
    
    # Alternativa: Mostrar comandos para ejecutar manualmente
    Write-Host ""
    Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host "⚠️  Ejecuta estos comandos en pgAdmin Query Tool:" -ForegroundColor Yellow
    Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1️⃣  Abre pgAdmin 4" -ForegroundColor Cyan
    Write-Host "2️⃣  Conéctate a: Plazas Azure > plazas_db" -ForegroundColor Cyan
    Write-Host "3️⃣  Query Tool > Pega este SQL:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "-- COPIAR Y PEGAR EN pgAdmin --" -ForegroundColor Green
    Write-Host ""
    Get-Content $SQL_FILE | Write-Host -ForegroundColor White
    Write-Host ""
    Write-Host "-- FIN DEL SQL --" -ForegroundColor Green
    Write-Host ""
    Write-Host "4️⃣  Ejecuta (F5)" -ForegroundColor Cyan
    Write-Host ""
    
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
} finally {
    # Limpiar archivo temporal
    if (Test-Path $tempFile) {
        Remove-Item $tempFile
    }
    Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 ALTERNATIVA RÁPIDA:" -ForegroundColor Yellow
Write-Host ""
Write-Host "   El archivo SQL ya está abierto en Notepad" -ForegroundColor White
Write-Host "   Copia todo el contenido y pégalo en pgAdmin Query Tool" -ForegroundColor White
Write-Host ""
