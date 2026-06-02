# ============================================================
# Script: Abrir archivo SQL para ejecutar en pgAdmin
# ============================================================

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║       PREPARANDO MIGRACIÓN SQL                        ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$SQL_FILE = "database\migracion-auth.sql"
$SQL_PATH = Resolve-Path $SQL_FILE

Write-Host "📋 INSTRUCCIONES:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1️⃣  Abre pgAdmin 4" -ForegroundColor Cyan
Write-Host ""
Write-Host "2️⃣  Conéctate a tu servidor Azure:" -ForegroundColor Cyan
Write-Host "    Servers > Plazas Azure > Databases > plazas_db" -ForegroundColor White
Write-Host ""
Write-Host "3️⃣  Abre Query Tool:" -ForegroundColor Cyan
Write-Host "    Click derecho en plazas_db > Query Tool" -ForegroundColor White
Write-Host ""
Write-Host "4️⃣  Carga el archivo SQL:" -ForegroundColor Cyan
Write-Host "    Click en 📁 (Open File)" -ForegroundColor White
Write-Host "    Navega a: $SQL_PATH" -ForegroundColor Green
Write-Host ""
Write-Host "5️⃣  Ejecuta:" -ForegroundColor Cyan
Write-Host "    Click en ▶️ (Execute) o presiona F5" -ForegroundColor White
Write-Host ""
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host ""

# Abrir el archivo SQL en el editor predeterminado
Write-Host "📂 Abriendo archivo SQL..." -ForegroundColor Cyan
Start-Process notepad $SQL_PATH

Write-Host ""
Write-Host "✅ Archivo abierto en Notepad" -ForegroundColor Green
Write-Host ""
Write-Host "💡 Puedes copiar el contenido y pegarlo en pgAdmin Query Tool" -ForegroundColor Yellow
Write-Host "   O usar el botón 'Open File' en pgAdmin" -ForegroundColor Yellow
Write-Host ""
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "📊 Después de ejecutar la migración:" -ForegroundColor Cyan
Write-Host ""
Write-Host "   ✅ Tabla 'usuarios' creada" -ForegroundColor White
Write-Host "   ✅ Usuario admin: admin@plazas.com / Admin123!" -ForegroundColor White
Write-Host "   ✅ Columnas de apartado agregadas" -ForegroundColor White
Write-Host "   ✅ Sistema listo para usar" -ForegroundColor White
Write-Host ""
Write-Host "🌐 Luego abre: http://plazas-frontend-2024.eastus.azurecontainer.io" -ForegroundColor Cyan
Write-Host ""
