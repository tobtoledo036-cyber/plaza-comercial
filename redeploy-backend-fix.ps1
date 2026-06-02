# ═══════════════════════════════════════════════════════════════
# SCRIPT PARA REDESPLEGAR BACKEND CON CORRECCIONES
# ═══════════════════════════════════════════════════════════════
# Este script reconstruye y redespliega el backend con las
# correcciones del bug de locales atascados
# ═══════════════════════════════════════════════════════════════

Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  REDESPLIEGUE DE BACKEND CON CORRECCIONES" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Variables
$RESOURCE_GROUP = "plazas-rg-eastus"
$ACR_NAME = "plazasacr2024"
$ACR_LOGIN_SERVER = "$ACR_NAME.azurecr.io"
$BACKEND_IMAGE = "$ACR_LOGIN_SERVER/plazas-backend:latest"
$CONTAINER_NAME = "plazas-backend-2024"
$LOCATION = "eastus"

# ───────────────────────────────────────────────────────────────
# PASO 1: Verificar que Docker esté corriendo
# ───────────────────────────────────────────────────────────────
Write-Host "📋 Paso 1: Verificando Docker..." -ForegroundColor Yellow
$dockerRunning = docker info 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error: Docker no está corriendo" -ForegroundColor Red
    Write-Host "   Por favor inicia Docker Desktop y vuelve a ejecutar este script" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Docker está corriendo" -ForegroundColor Green
Write-Host ""

# ───────────────────────────────────────────────────────────────
# PASO 2: Login a Azure Container Registry
# ───────────────────────────────────────────────────────────────
Write-Host "📋 Paso 2: Login a Azure Container Registry..." -ForegroundColor Yellow
az acr login --name $ACR_NAME
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error en login a ACR" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Login exitoso a ACR" -ForegroundColor Green
Write-Host ""

# ───────────────────────────────────────────────────────────────
# PASO 3: Construir nueva imagen del backend
# ───────────────────────────────────────────────────────────────
Write-Host "📋 Paso 3: Construyendo nueva imagen del backend..." -ForegroundColor Yellow
Write-Host "   Imagen: $BACKEND_IMAGE" -ForegroundColor Gray

Set-Location backend
docker build -t $BACKEND_IMAGE .
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error construyendo imagen" -ForegroundColor Red
    Set-Location ..
    exit 1
}
Set-Location ..

Write-Host "✅ Imagen construida exitosamente" -ForegroundColor Green
Write-Host ""

# ───────────────────────────────────────────────────────────────
# PASO 4: Subir imagen a ACR
# ───────────────────────────────────────────────────────────────
Write-Host "📋 Paso 4: Subiendo imagen a Azure Container Registry..." -ForegroundColor Yellow
docker push $BACKEND_IMAGE
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error subiendo imagen" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Imagen subida exitosamente" -ForegroundColor Green
Write-Host ""

# ───────────────────────────────────────────────────────────────
# PASO 5: Detener y eliminar contenedor actual
# ───────────────────────────────────────────────────────────────
Write-Host "📋 Paso 5: Eliminando contenedor actual..." -ForegroundColor Yellow
az container delete `
    --resource-group $RESOURCE_GROUP `
    --name $CONTAINER_NAME `
    --yes

Write-Host "✅ Contenedor eliminado" -ForegroundColor Green
Write-Host ""

# ───────────────────────────────────────────────────────────────
# PASO 6: Crear nuevo contenedor con la imagen actualizada
# ───────────────────────────────────────────────────────────────
Write-Host "📋 Paso 6: Creando nuevo contenedor..." -ForegroundColor Yellow

# Obtener credenciales de ACR
$ACR_USERNAME = az acr credential show --name $ACR_NAME --query "username" -o tsv
$ACR_PASSWORD = az acr credential show --name $ACR_NAME --query "passwords[0].value" -o tsv

# Crear contenedor
az container create `
    --resource-group $RESOURCE_GROUP `
    --name $CONTAINER_NAME `
    --image $BACKEND_IMAGE `
    --cpu 1 `
    --memory 1 `
    --registry-login-server $ACR_LOGIN_SERVER `
    --registry-username $ACR_USERNAME `
    --registry-password $ACR_PASSWORD `
    --dns-name-label $CONTAINER_NAME `
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
    Write-Host "❌ Error creando contenedor" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Contenedor creado exitosamente" -ForegroundColor Green
Write-Host ""

# ───────────────────────────────────────────────────────────────
# PASO 7: Verificar estado del contenedor
# ───────────────────────────────────────────────────────────────
Write-Host "📋 Paso 7: Verificando estado del contenedor..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

$containerState = az container show `
    --resource-group $RESOURCE_GROUP `
    --name $CONTAINER_NAME `
    --query "instanceView.state" -o tsv

Write-Host "   Estado: $containerState" -ForegroundColor Gray

if ($containerState -eq "Running") {
    Write-Host "✅ Contenedor corriendo correctamente" -ForegroundColor Green
} else {
    Write-Host "⚠️  Contenedor en estado: $containerState" -ForegroundColor Yellow
    Write-Host "   Esperando a que inicie..." -ForegroundColor Yellow
}
Write-Host ""

# ───────────────────────────────────────────────────────────────
# PASO 8: Mostrar logs del contenedor
# ───────────────────────────────────────────────────────────────
Write-Host "📋 Paso 8: Logs del contenedor (últimas 20 líneas)..." -ForegroundColor Yellow
Write-Host "───────────────────────────────────────────────────────────────" -ForegroundColor Gray
az container logs `
    --resource-group $RESOURCE_GROUP `
    --name $CONTAINER_NAME `
    --tail 20
Write-Host "───────────────────────────────────────────────────────────────" -ForegroundColor Gray
Write-Host ""

# ───────────────────────────────────────────────────────────────
# RESUMEN
# ───────────────────────────────────────────────────────────────
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  ✅ REDESPLIEGUE COMPLETADO" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "🌐 URL del Backend:" -ForegroundColor Yellow
Write-Host "   http://$CONTAINER_NAME.eastus.azurecontainer.io:5000" -ForegroundColor White
Write-Host ""
Write-Host "📝 Correcciones aplicadas:" -ForegroundColor Yellow
Write-Host "   ✓ Locales NO cambian de estado hasta que el pago se complete" -ForegroundColor Green
Write-Host "   ✓ Transacciones con rollback automático en caso de error" -ForegroundColor Green
Write-Host "   ✓ Mejor manejo de errores 422 de PayPal" -ForegroundColor Green
Write-Host "   ✓ Moneda en USD para evitar problemas con Sandbox" -ForegroundColor Green
Write-Host ""
Write-Host "🔧 Próximos pasos:" -ForegroundColor Yellow
Write-Host "   1. Ejecuta fix-locales-stuck.sql en pgAdmin para liberar locales atascados" -ForegroundColor White
Write-Host "   2. Prueba el flujo de pago completo con una cuenta PERSONAL de Sandbox" -ForegroundColor White
Write-Host "   3. Verifica que los locales cambien de estado solo después del pago" -ForegroundColor White
Write-Host ""
Write-Host "📚 Documentación actualizada:" -ForegroundColor Yellow
Write-Host "   - PAYPAL-SANDBOX-INSTRUCCIONES.md (con sección de correcciones)" -ForegroundColor White
Write-Host "   - fix-locales-stuck.sql (script de corrección para BD)" -ForegroundColor White
Write-Host "   - database/consultas-utiles.sql (queries actualizadas)" -ForegroundColor White
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
