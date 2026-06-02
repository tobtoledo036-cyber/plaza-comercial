# ============================================================
# Script: Redesplegar backend con rutas de autenticación
# ============================================================

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║       REDESPLEGANDO BACKEND CON AUTENTICACIÓN         ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Verificar que Docker esté corriendo
Write-Host "🔍 Verificando Docker..." -ForegroundColor Cyan
docker ps > $null 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Docker no está corriendo. Inicia Docker Desktop primero." -ForegroundColor Red
    exit 1
}
Write-Host "✅ Docker corriendo" -ForegroundColor Green
Write-Host ""

# Autenticar con Azure Container Registry
Write-Host "🔐 Autenticando con Azure Container Registry..." -ForegroundColor Cyan
az acr login --name plazasacr2024
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al autenticar con ACR" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Autenticado con ACR" -ForegroundColor Green
Write-Host ""

# Construir imagen del backend
Write-Host "🔨 Construyendo imagen del backend..." -ForegroundColor Cyan
Set-Location backend
docker build -t plazasacr2024.azurecr.io/plazas-backend:latest .
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al construir backend" -ForegroundColor Red
    Set-Location ..
    exit 1
}
Write-Host "✅ Backend construido" -ForegroundColor Green
Write-Host ""

# Subir imagen a ACR
Write-Host "☁️  Subiendo imagen a Azure Container Registry..." -ForegroundColor Cyan
docker push plazasacr2024.azurecr.io/plazas-backend:latest
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al subir backend" -ForegroundColor Red
    Set-Location ..
    exit 1
}
Write-Host "✅ Backend subido a ACR" -ForegroundColor Green
Write-Host ""

Set-Location ..

# Reiniciar contenedor
Write-Host "🔄 Reiniciando contenedor de backend en Azure..." -ForegroundColor Cyan
az container restart --resource-group plazas-rg-eastus --name plazas-backend --no-wait
Write-Host "✅ Backend reiniciado" -ForegroundColor Green
Write-Host ""

Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║           ✅ REDESPLIEGUE COMPLETADO                   ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "⏳ Espera 30-60 segundos para que el contenedor se inicie" -ForegroundColor Yellow
Write-Host ""
Write-Host "🧪 Luego prueba:" -ForegroundColor Cyan
Write-Host "   http://plazas-backend-2024.eastus.azurecontainer.io:5000/api/health" -ForegroundColor White
Write-Host ""
Write-Host "🌐 Y el login en:" -ForegroundColor Cyan
Write-Host "   http://plazas-frontend-2024.eastus.azurecontainer.io/login" -ForegroundColor White
Write-Host ""
