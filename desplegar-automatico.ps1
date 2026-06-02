# ============================================================
# Script: Despliegue automático (sin pausas)
# ============================================================

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  DESPLIEGUE SISTEMA DE AUTENTICACIÓN Y DASHBOARDS     ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ============================================================
# PASO 1: RECORDATORIO DE MIGRACIÓN
# ============================================================

Write-Host "⚠️  IMPORTANTE: Antes de continuar, ejecuta la migración SQL" -ForegroundColor Yellow
Write-Host ""
Write-Host "Archivo: database\migracion-auth.sql" -ForegroundColor Cyan
Write-Host "En pgAdmin: Servers > Plazas Azure > plazas_db > Query Tool" -ForegroundColor Cyan
Write-Host ""
Write-Host "Si ya lo ejecutaste, este script continuará con el despliegue..." -ForegroundColor Green
Write-Host ""
Start-Sleep -Seconds 3

# ============================================================
# PASO 2: REDESPLIEGUE DE BACKEND
# ============================================================

Write-Host "📦 DESPLEGANDO BACKEND" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════" -ForegroundColor Yellow

Write-Host "🔨 Construyendo imagen de backend..." -ForegroundColor Cyan
Set-Location backend
docker build -t plazasacr2024.azurecr.io/plazas-backend:latest .
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al construir backend" -ForegroundColor Red
    Set-Location ..
    exit 1
}
Write-Host "✅ Backend construido" -ForegroundColor Green

Write-Host "☁️  Subiendo a Azure Container Registry..." -ForegroundColor Cyan
docker push plazasacr2024.azurecr.io/plazas-backend:latest
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al subir backend" -ForegroundColor Red
    Set-Location ..
    exit 1
}
Write-Host "✅ Backend subido a ACR" -ForegroundColor Green

Write-Host "🔄 Reiniciando contenedor de backend..." -ForegroundColor Cyan
az container restart --resource-group plazas-comerciales-rg --name plazas-backend-2024 --no-wait
Write-Host "✅ Backend reiniciado" -ForegroundColor Green

Set-Location ..

# ============================================================
# PASO 3: REDESPLIEGUE DE FRONTEND
# ============================================================

Write-Host ""
Write-Host "📦 DESPLEGANDO FRONTEND" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════" -ForegroundColor Yellow

Set-Location frontend

Write-Host "🔨 Compilando React..." -ForegroundColor Cyan
npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al compilar frontend" -ForegroundColor Red
    Set-Location ..
    exit 1
}
Write-Host "✅ Frontend compilado" -ForegroundColor Green

Write-Host "🐳 Construyendo imagen Docker..." -ForegroundColor Cyan
docker build -t plazasacr2024.azurecr.io/plazas-frontend:latest .
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al construir imagen frontend" -ForegroundColor Red
    Set-Location ..
    exit 1
}
Write-Host "✅ Imagen construida" -ForegroundColor Green

Write-Host "☁️  Subiendo a Azure..." -ForegroundColor Cyan
docker push plazasacr2024.azurecr.io/plazas-frontend:latest
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al subir frontend" -ForegroundColor Red
    Set-Location ..
    exit 1
}
Write-Host "✅ Frontend subido a ACR" -ForegroundColor Green

Write-Host "🔄 Reiniciando contenedor..." -ForegroundColor Cyan
az container restart --resource-group plazas-comerciales-rg --name plazas-frontend-2024 --no-wait
Write-Host "✅ Frontend reiniciado" -ForegroundColor Green

Set-Location ..

# ============================================================
# RESUMEN FINAL
# ============================================================

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║           ✅ DESPLIEGUE COMPLETADO                     ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 URLs:" -ForegroundColor Cyan
Write-Host "   Frontend: http://plazas-frontend-2024.eastus.azurecontainer.io" -ForegroundColor White
Write-Host "   Backend:  http://plazas-backend-2024.eastus.azurecontainer.io:5000" -ForegroundColor White
Write-Host ""
Write-Host "👤 Admin:" -ForegroundColor Cyan
Write-Host "   Email:    admin@plazas.com" -ForegroundColor White
Write-Host "   Password: Admin123!" -ForegroundColor White
Write-Host ""
Write-Host "⏳ Espera 30-60 segundos para que los contenedores inicien" -ForegroundColor Yellow
Write-Host ""
