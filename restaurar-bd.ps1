# ═══════════════════════════════════════════════════════════════
# RESTAURAR BASE DE DATOS Y ENCENDER AZURE
# ═══════════════════════════════════════════════════════════════
# Uso: .\restaurar-bd.ps1 -archivo backup_plazas_2026-05-27.sql
# ═══════════════════════════════════════════════════════════════

param(
    [Parameter(Mandatory=$false)]
    [string]$archivo = ""
)

$host_bd = "plazas-postgres-2024.eastus.azurecontainer.io"
$puerto  = "5432"
$usuario = "plazasadmin"
$base    = "plazas_db"

# ── Encender contenedores ───────────────────────────────────
Write-Host "▶️  Encendiendo contenedores..." -ForegroundColor Cyan
az container start --resource-group plazas-rg-eastus --name plazas-postgres-2024
Write-Host "   Esperando 30 segundos para que PostgreSQL inicie..." -ForegroundColor Gray
Start-Sleep -Seconds 30

az container start --resource-group plazas-rg-eastus --name plazas-backend-2024
az container start --resource-group plazas-rg-eastus --name plazas-frontend-2024
Write-Host "✅ Contenedores encendidos" -ForegroundColor Green
Write-Host ""

# ── Restaurar backup si se proporcionó ─────────────────────
if ($archivo -ne "" -and (Test-Path $archivo)) {
    Write-Host "💾 Restaurando backup: $archivo" -ForegroundColor Cyan
    $env:PGPASSWORD = "TuPassword123!"
    psql -h $host_bd -p $puerto -U $usuario -d $base -f $archivo

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Base de datos restaurada" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Error restaurando. Hazlo manualmente desde pgAdmin." -ForegroundColor Yellow
    }
} elseif ($archivo -ne "") {
    Write-Host "⚠️  Archivo '$archivo' no encontrado." -ForegroundColor Yellow
    Write-Host "   Restaura manualmente desde pgAdmin." -ForegroundColor Yellow
} else {
    Write-Host "ℹ️  No se especificó archivo de backup." -ForegroundColor Yellow
    Write-Host "   Si es la primera vez, ejecuta los scripts SQL en pgAdmin:" -ForegroundColor Yellow
    Write-Host "   1. database/schema-postgres.sql" -ForegroundColor White
    Write-Host "   2. database/seed-postgres.sql" -ForegroundColor White
    Write-Host "   3. database/seed-plazas-2-5.sql" -ForegroundColor White
    Write-Host "   4. database/migracion-auth.sql" -ForegroundColor White
}

Write-Host ""
Write-Host "🌐 URLs:" -ForegroundColor Cyan
Write-Host "   Frontend: http://plazas-frontend-2024.eastus.azurecontainer.io" -ForegroundColor White
Write-Host "   Backend:  http://plazas-backend-2024.eastus.azurecontainer.io:5000" -ForegroundColor White
