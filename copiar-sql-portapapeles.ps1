# ============================================================
# Script: Copiar SQL al portapapeles para pegar en pgAdmin
# ============================================================

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║       PREPARANDO SQL PARA pgAdmin                     ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$SQL_FILE = "database\migracion-auth.sql"

if (-not (Test-Path $SQL_FILE)) {
    Write-Host "❌ Error: No se encuentra el archivo $SQL_FILE" -ForegroundColor Red
    exit 1
}

# Leer el contenido del archivo SQL
$sqlContent = Get-Content $SQL_FILE -Raw

# Copiar al portapapeles
$sqlContent | Set-Clipboard

Write-Host "✅ SQL copiado al portapapeles" -ForegroundColor Green
Write-Host ""
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host ""
Write-Host "📋 PASOS PARA EJECUTAR EN pgAdmin:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1️⃣  Abre pgAdmin 4" -ForegroundColor White
Write-Host ""
Write-Host "2️⃣  En el panel izquierdo, expande:" -ForegroundColor White
Write-Host "    Servers > Plazas Azure > Databases > plazas_db" -ForegroundColor Gray
Write-Host ""
Write-Host "3️⃣  Click derecho en 'plazas_db'" -ForegroundColor White
Write-Host "    Selecciona: Query Tool" -ForegroundColor Gray
Write-Host ""
Write-Host "4️⃣  En la ventana del Query Tool:" -ForegroundColor White
Write-Host "    Presiona Ctrl+V para pegar el SQL" -ForegroundColor Gray
Write-Host "    (Ya está en tu portapapeles)" -ForegroundColor Green
Write-Host ""
Write-Host "5️⃣  Click en ▶️ (Execute) o presiona F5" -ForegroundColor White
Write-Host ""
Write-Host "6️⃣  Verifica que veas:" -ForegroundColor White
Write-Host "    'Query returned successfully'" -ForegroundColor Green
Write-Host ""
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host ""
Write-Host "⏰ Tiempo estimado: 1 minuto" -ForegroundColor Cyan
Write-Host ""
Write-Host "🔄 Después de ejecutar, recarga la página del login" -ForegroundColor Cyan
Write-Host "   y vuelve a intentar con:" -ForegroundColor Cyan
Write-Host ""
Write-Host "   Email:    admin@plazas.com" -ForegroundColor Green
Write-Host "   Password: Admin123!" -ForegroundColor Green
Write-Host ""
