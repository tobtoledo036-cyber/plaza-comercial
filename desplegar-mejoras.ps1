# ═══════════════════════════════════════════════════════════════
# SCRIPT PARA DESPLEGAR MEJORAS
# ═══════════════════════════════════════════════════════════════
# Mejoras incluidas:
# 1. Optimización para móviles (sin animación en móvil)
# 2. Precio diferente para compra vs apartado
# 3. Panel de administración para ver transacciones
# ═══════════════════════════════════════════════════════════════

Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  DESPLIEGUE DE MEJORAS - PLAZAS COMERCIALES" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Variables
$RESOURCE_GROUP = "plazas-rg-eastus"
$ACR_NAME = "plazasacr2024"
$ACR_LOGIN_SERVER = "$ACR_NAME.azurecr.io"
$BACKEND_IMAGE = "$ACR_LOGIN_SERVER/plazas-backend:latest"
$FRONTEND_IMAGE = "$ACR_LOGIN_SERVER/plazas-frontend:latest"
$BACKEND_CONTAINER = "plazas-backend-2024"
$FRONTEND_CONTAINER = "plazas-frontend-2024"
$LOCATION = "eastus"

# ───────────────────────────────────────────────────────────────
# PASO 1: Verificar Docker
# ───────────────────────────────────────────────────────────────
Write-Host "📋 Paso 1: Verificando Docker..." -ForegroundColor Yellow
$dockerRunning = docker info 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error: Docker no está corriendo" -ForegroundColor Red
    Write-Host "   Por favor inicia Docker Desktop" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Docker está corriendo" -ForegroundColor Green
Write-Host ""

# ───────────────────────────────────────────────────────────────
# PASO 2: Login a ACR
# ───────────────────────────────────────────────────────────────
Write-Host "📋 Paso 2: Login a Azure Container Registry..." -ForegroundColor Yellow
az acr login --name $ACR_NAME
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error en login a ACR" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Login exitoso" -ForegroundColor Green
Write-Host ""

# ───────────────────────────────────────────────────────────────
# PASO 3: Construir y subir Backend
# ───────────────────────────────────────────────────────────────
Write-Host "📋 Paso 3: Construyendo Backend..." -ForegroundColor Yellow
Set-Location backend
docker build -t $BACKEND_IMAGE .
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error construyendo backend" -ForegroundColor Red
    Set-Location ..
    exit 1
}
Write-Host "✅ Backend construido" -ForegroundColor Green

Write-Host "📤 Subiendo backend a ACR..." -ForegroundColor Yellow
docker push $BACKEND_IMAGE
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error subiendo backend" -ForegroundColor Red
    Set-Location ..
    exit 1
}
Write-Host "✅ Backend subido" -ForegroundColor Green
Set-Location ..
Write-Host ""

# ───────────────────────────────────────────────────────────────
# PASO 4: Construir y subir Frontend
# ───────────────────────────────────────────────────────────────
Write-Host "📋 Paso 4: Construyendo Frontend..." -ForegroundColor Yellow
Set-Location frontend
docker build -t $FRONTEND_IMAGE .
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error construyendo frontend" -ForegroundColor Red
    Set-Location ..
    exit 1
}
Write-Host "✅ Frontend construido" -ForegroundColor Green

Write-Host "📤 Subiendo frontend a ACR..." -ForegroundColor Yellow
docker push $FRONTEND_IMAGE
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error subiendo frontend" -ForegroundColor Red
    Set-Location ..
    exit 1
}
Write-Host "✅ Frontend subido" -ForegroundColor Green
Set-Location ..
Write-Host ""

# ───────────────────────────────────────────────────────────────
# PASO 5: Obtener credenciales ACR
# ───────────────────────────────────────────────────────────────
Write-Host "📋 Paso 5: Obteniendo credenciales ACR..." -ForegroundColor Yellow
$ACR_USERNAME = az acr credential show --name $ACR_NAME --query "username" -o tsv
$ACR_PASSWORD = az acr credential show --name $ACR_NAME --query "passwords[0].value" -o tsv
Write-Host "✅ Credenciales obtenidas" -ForegroundColor Green
Write-Host ""

# ───────────────────────────────────────────────────────────────
# PASO 6: Redesplegar Backend
# ───────────────────────────────────────────────────────────────
Write-Host "📋 Paso 6: Redesp legando Backend..." -ForegroundColor Yellow
az container delete --resource-group $RESOURCE_GROUP --name $BACKEND_CONTAINER --yes

az container create `
    --resource-group $RESOURCE_GROUP `
    --name $BACKEND_CONTAINER `
    --image $BACKEND_IMAGE `
    --cpu 1 `
    --memory 1 `
    --registry-login-server $ACR_LOGIN_SERVER `
    --registry-username $ACR_USERNAME `
    --registry-password $ACR_PASSWORD `
    --dns-name-label $BACKEND_CONTAINER `
    --ports 5000 `
    --environment-variables `
        NODE_ENV=production `
        PORT=5000 `
        DB_HOST=plazas-postgres-2024.eastus.azurecontainer.io `
        DB_PORT=5432 `
        DB_NAME=plazas_db `
        DB_USER=plazasadmin `
        DB_PASSWORD=TuPassword123! `
        PAYPAL_MODE=sandbox `
        PAYPAL_CLIENT_ID=Ad1COovx9SuHgYUAJzO9m_7_fGRtrENyA3rfv1vpB1BGT11kvp07mG9Xn9tG7193vQ76QLJvNYxNWdRK `
        PAYPAL_CLIENT_SECRET=EKlDtptwPrnxFFp9iTKlcpHtky6V-bR6jSNKmFXYYfgLN3H24Ai9cBQSR2PbOy6E1mza0rNsxVkRdM9x `
    --location $LOCATION

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error redesp legando backend" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Backend redesp legado" -ForegroundColor Green
Write-Host ""

# ───────────────────────────────────────────────────────────────
# PASO 7: Redesplegar Frontend
# ───────────────────────────────────────────────────────────────
Write-Host "📋 Paso 7: Redesp legando Frontend..." -ForegroundColor Yellow
az container delete --resource-group $RESOURCE_GROUP --name $FRONTEND_CONTAINER --yes

az container create `
    --resource-group $RESOURCE_GROUP `
    --name $FRONTEND_CONTAINER `
    --image $FRONTEND_IMAGE `
    --cpu 1 `
    --memory 1 `
    --registry-login-server $ACR_LOGIN_SERVER `
    --registry-username $ACR_USERNAME `
    --registry-password $ACR_PASSWORD `
    --dns-name-label $FRONTEND_CONTAINER `
    --ports 80 `
    --environment-variables `
        VITE_API_URL=http://$BACKEND_CONTAINER.eastus.azurecontainer.io:5000 `
    --location $LOCATION

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error redesp legando frontend" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Frontend redesp legado" -ForegroundColor Green
Write-Host ""

# ───────────────────────────────────────────────────────────────
# PASO 8: Verificar estado
# ───────────────────────────────────────────────────────────────
Write-Host "📋 Paso 8: Verificando estado de contenedores..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

$backendState = az container show --resource-group $RESOURCE_GROUP --name $BACKEND_CONTAINER --query "instanceView.state" -o tsv
$frontendState = az container show --resource-group $RESOURCE_GROUP --name $FRONTEND_CONTAINER --query "instanceView.state" -o tsv

Write-Host "   Backend: $backendState" -ForegroundColor Gray
Write-Host "   Frontend: $frontendState" -ForegroundColor Gray
Write-Host ""

# ───────────────────────────────────────────────────────────────
# RESUMEN
# ───────────────────────────────────────────────────────────────
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  ✅ DESPLIEGUE COMPLETADO" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "🌐 URLs:" -ForegroundColor Yellow
Write-Host "   Frontend: http://$FRONTEND_CONTAINER.eastus.azurecontainer.io" -ForegroundColor White
Write-Host "   Backend:  http://$BACKEND_CONTAINER.eastus.azurecontainer.io:5000" -ForegroundColor White
Write-Host "   Admin:    http://$FRONTEND_CONTAINER.eastus.azurecontainer.io/admin" -ForegroundColor White
Write-Host ""
Write-Host "✨ Mejoras implementadas:" -ForegroundColor Yellow
Write-Host "   ✓ Optimización para móviles (carga más rápida)" -ForegroundColor Green
Write-Host "   ✓ Precio diferente para compra vs apartado" -ForegroundColor Green
Write-Host "   ✓ Panel de administración para ver transacciones" -ForegroundColor Green
Write-Host ""
Write-Host "🔧 Próximos pasos:" -ForegroundColor Yellow
Write-Host "   1. Ejecuta agregar-precio-apartado.sql en pgAdmin" -ForegroundColor White
Write-Host "   2. Prueba la aplicación en tu teléfono" -ForegroundColor White
Write-Host "   3. Accede al panel de admin: /admin" -ForegroundColor White
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
