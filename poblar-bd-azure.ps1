# Script para poblar PostgreSQL en Azure
$host_azure = "plazas-postgres-2024.eastus.azurecontainer.io"
$port = "5432"
$database = "plazas_db"
$user = "plazasadmin"
$password = "TuPassword123!"

Write-Host "Poblando base de datos PostgreSQL en Azure..." -ForegroundColor Cyan

# Ejecutar schema
Write-Host "`nEjecutando schema-postgres.sql..." -ForegroundColor Yellow
$env:PGPASSWORD = $password
psql -h $host_azure -p $port -U $user -d $database -f "database/schema-postgres.sql"

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Schema creado exitosamente" -ForegroundColor Green
} else {
    Write-Host "❌ Error al crear schema" -ForegroundColor Red
    exit 1
}

# Ejecutar seed principal
Write-Host "`nEjecutando seed-postgres.sql..." -ForegroundColor Yellow
psql -h $host_azure -p $port -U $user -d $database -f "database/seed-postgres.sql"

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Datos principales insertados" -ForegroundColor Green
} else {
    Write-Host "❌ Error al insertar datos principales" -ForegroundColor Red
    exit 1
}

# Ejecutar seed de plazas 2-5
Write-Host "`nEjecutando seed-plazas-2-5.sql..." -ForegroundColor Yellow
psql -h $host_azure -p $port -U $user -d $database -f "database/seed-plazas-2-5.sql"

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Locales de plazas 2-5 insertados" -ForegroundColor Green
} else {
    Write-Host "❌ Error al insertar locales" -ForegroundColor Red
    exit 1
}

# Verificar datos
Write-Host "`nVerificando datos..." -ForegroundColor Yellow
$count = psql -h $host_azure -p $port -U $user -d $database -t -c "SELECT COUNT(*) FROM locales;"

Write-Host "✅ Total de locales en la base de datos: $count" -ForegroundColor Green
Write-Host "`n🎉 Base de datos poblada exitosamente!" -ForegroundColor Cyan
