# ═══════════════════════════════════════════════════════════════
# REDESPLEGAR FRONTEND OPTIMIZADO PARA MÓVILES
# ═══════════════════════════════════════════════════════════════

Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  REDESPLIEGUE FRONTEND - OPTIMIZADO PARA MÓVILES" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Variables
$RESOURCE_GROUP = "plazas-rg-eastus"
$ACR_NAME = "plazasacr2024"
$ACR_LOGIN_SERVER = "$ACR_NAME.azurecr.io"
$FRONTEND_IMAGE = "$ACR_LOGIN_SERVER/plazas-frontend:latest"
$FRONTEND_CONTAINER = "plazas-frontend-2024"
$LOCATION = "eastus"

# ───────────────────────────────────────────────────────────────
# PASO 1: Verificar Docker
# ───────────────────────────────────────────────────────────────
Write-Host "📋 Paso 1: Verificando Docker..." -ForegroundColor Yellow
$dockerRunning = docker info 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error: Docker no está corriendo" -ForegroundColor Red
    Write-Host "   Inicia Docker Desktop y vuelve a ejecutar" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Docker corriendo" -ForegroundColor Green
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
# PASO 3: Construir Frontend Optimizado
# ───────────────────────────────────────────────────────────────
Write-Host "📋 Paso 3: Construyendo Frontend optimizado para móviles..." -ForegroundColor Yellow
Write-Host "   Optimizaciones aplicadas:" -ForegroundColor Gray
Write-Host "   - Sin efectos de fondo en móvil" -ForegroundColor Gray
Write-Host "   - Sin animaciones pesadas" -ForegroundColor Gray
Write-Host "   - Carga instantánea del mapa" -ForegroundColor Gray
Write-Host "   - Estilos responsive mejorados" -ForegroundColor Gray
Write-Host ""

docker build -t $FRONTEND_IMAGE ./frontend
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error construyendo frontend" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Frontend construido" -ForegroundColor Green
Write-Host ""

# ───────────────────────────────────────────────────────────────
# PASO 4: Subir a ACR
# ───────────────────────────────────────────────────────────────
Write-Host "📋 Paso 4: Subiendo imagen a ACR..." -ForegroundColor Yellow
docker push $FRONTEND_IMAGE
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error subiendo imagen" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Imagen subida" -ForegroundColor Green
Write-Host ""

# ───────────────────────────────────────────────────────────────
# PASO 5: Obtener credenciales ACR
# ───────────────────────────────────────────────────────────────
Write-Host "📋 Paso 5: Obteniendo credenciales..." -ForegroundColor Yellow
$ACR_USERNAME = az acr credential show --name $ACR_NAME --query "username" -o tsv
$ACR_PASSWORD = az acr credential show --name $ACR_NAME --query "passwords[0].value" -o tsv
Write-Host "✅ Credenciales obtenidas" -ForegroundColor Green
Write-Host ""

# ───────────────────────────────────────────────────────────────
# PASO 6: Eliminar contenedor actual
# ───────────────────────────────────────────────────────────────
Write-Host "📋 Paso 6: Eliminando contenedor actual..." -ForegroundColor Yellow
az container delete --resource-group $RESOURCE_GROUP --name $FRONTEND_CONTAINER --yes 2>$null
Write-Host "✅ Contenedor eliminado" -ForegroundColor Green
Write-Host ""

# ───────────────────────────────────────────────────────────────
# PASO 7: Crear nuevo contenedor
# ───────────────────────────────────────────────────────────────
Write-Host "📋 Paso 7: Creando nuevo contenedor..." -ForegroundColor Yellow

az container create `
    --resource-group $RESOURCE_GROUP `
    --name $FRONTEND_CONTAINER `
    --image $FRONTEND_IMAGE `
    --cpu 1 `
    --memory 1.5 `
    --registry-login-server $ACR_LOGIN_SERVER `
    --registry-username $ACR_USERNAME `
    --registry-password $ACR_PASSWORD `
    --dns-name-label $FRONTEND_CONTAINER `
    --ports 80 `
    --environment-variables `
        NODE_ENV=production `
    --location $LOCATION

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error creando contenedor" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Contenedor creado" -ForegroundColor Green
Write-Host ""

# ───────────────────────────────────────────────────────────────
# PASO 8: Verificar estado
# ───────────────────────────────────────────────────────────────
Write-Host "📋 Paso 8: Verificando estado..." -ForegroundColor Yellow
Write-Host "   Esperando 20 segundos..." -ForegroundColor Gray
Start-Sleep -Seconds 20

$state = az container show --resource-group $RESOURCE_GROUP --name $FRONTEND_CONTAINER --query "instanceView.state" -o tsv
Write-Host "   Estado: $state" -ForegroundColor Gray

if ($state -eq "Running") {
    Write-Host "✅ Contenedor corriendo" -ForegroundColor Green
} else {
    Write-Host "⚠️  Estado: $state (esperando...)" -ForegroundColor Yellow
}
Write-Host ""

# ───────────────────────────────────────────────────────────────
# PASO 9: Mostrar logs
# ───────────────────────────────────────────────────────────────
Write-Host "📋 Paso 9: Logs del contenedor..." -ForegroundColor Yellow
Write-Host "───────────────────────────────────────────────────────────────" -ForegroundColor Gray
az container logs --resource-group $RESOURCE_GROUP --name $FRONTEND_CONTAINER --tail 15
Write-Host "───────────────────────────────────────────────────────────────" -ForegroundColor Gray
Write-Host ""

# ───────────────────────────────────────────────────────────────
# RESUMEN
# ───────────────────────────────────────────────────────────────
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  ✅ REDESPLIEGUE COMPLETADO" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "🌐 URL del Frontend:" -ForegroundColor Yellow
Write-Host "   http://$FRONTEND_CONTAINER.eastus.azurecontainer.io" -ForegroundColor White
Write-Host ""
Write-Host "📱 Optimizaciones para Móviles:" -ForegroundColor Yellow
Write-Host "   ✓ Sin efectos de fondo pesados" -ForegroundColor Green
Write-Host "   ✓ Sin animaciones que consumen recursos" -ForegroundColor Green
Write-Host "   ✓ Carga instantánea del mapa en móviles" -ForegroundColor Green
Write-Host "   ✓ Estilos responsive optimizados" -ForegroundColor Green
Write-Host "   ✓ Compresión gzip mejorada" -ForegroundColor Green
Write-Host "   ✓ Timeouts ajustados para conexiones lentas" -ForegroundColor Green
Write-Host ""
Write-Host "🧪 Prueba en tu teléfono:" -ForegroundColor Yellow
Write-Host "   1. Abre el navegador en tu móvil" -ForegroundColor White
Write-Host "   2. Ve a: http://$FRONTEND_CONTAINER.eastus.azurecontainer.io" -ForegroundColor White
Write-Host "   3. Debe cargar en menos de 3 segundos" -ForegroundColor White
Write-Host "   4. Selecciona una plaza" -ForegroundColor White
Write-Host "   5. El mapa debe aparecer instantáneamente" -ForegroundColor White
Write-Host ""
Write-Host "⚠️  Si sigue sin funcionar:" -ForegroundColor Yellow
Write-Host "   - Limpia el caché del navegador móvil" -ForegroundColor White
Write-Host "   - Prueba en modo incógnito" -ForegroundColor White
Write-Host "   - Verifica que tengas conexión a internet" -ForegroundColor White
Write-Host "   - Espera 2-3 minutos y vuelve a intentar" -ForegroundColor White
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
