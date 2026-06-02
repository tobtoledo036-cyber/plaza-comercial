# ═══════════════════════════════════════════════════════════════
# BACKUP DE BASE DE DATOS ANTES DE APAGAR AZURE
# ═══════════════════════════════════════════════════════════════
# Requiere: pg_dump instalado (viene con PostgreSQL)
# ═══════════════════════════════════════════════════════════════

$fecha     = Get-Date -Format "yyyy-MM-dd_HH-mm"
$archivo   = "backup_plazas_$fecha.sql"
$host_bd   = "plazas-postgres-2024.eastus.azurecontainer.io"
$puerto    = "5432"
$usuario   = "plazasadmin"
$base      = "plazas_db"

Write-Host "💾 Haciendo backup de la base de datos..." -ForegroundColor Cyan
Write-Host "   Archivo: $archivo" -ForegroundColor Gray

$env:PGPASSWORD = "TuPassword123!"

pg_dump -h $host_bd -p $puerto -U $usuario -d $base -F p -f $archivo

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Backup guardado: $archivo" -ForegroundColor Green
    Write-Host ""
    Write-Host "🛑 Apagando contenedores de Azure..." -ForegroundColor Yellow
    az container stop --resource-group plazas-rg-eastus --name plazas-frontend-2024
    az container stop --resource-group plazas-rg-eastus --name plazas-backend-2024
    az container stop --resource-group plazas-rg-eastus --name plazas-postgres-2024
    Write-Host "✅ Contenedores apagados. Créditos guardados." -ForegroundColor Green
    Write-Host ""
    Write-Host "📌 Para restaurar ejecuta: .\restaurar-bd.ps1 -archivo $archivo" -ForegroundColor Yellow
} else {
    Write-Host "❌ Error en el backup. Contenedores NO apagados." -ForegroundColor Red
    Write-Host "   Instala PostgreSQL en tu PC para tener pg_dump disponible." -ForegroundColor Red
}
