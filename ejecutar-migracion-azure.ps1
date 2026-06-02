# ============================================================
# Script: Ejecutar migración de autenticación en Azure
# ============================================================

Write-Host "🔄 Ejecutando migración en PostgreSQL de Azure..." -ForegroundColor Cyan
Write-Host ""

# Variables de conexión
$SQL_FILE = "database/migracion-auth.sql"

# Verificar que el archivo SQL existe
if (-not (Test-Path $SQL_FILE)) {
    Write-Host "❌ Error: No se encuentra el archivo $SQL_FILE" -ForegroundColor Red
    exit 1
}

Write-Host "📋 INSTRUCCIONES PARA EJECUTAR EN pgAdmin:" -ForegroundColor Yellow
Write-Host "============================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "1️⃣  Abre pgAdmin 4" -ForegroundColor Cyan
Write-Host ""
Write-Host "2️⃣  En el panel izquierdo, busca y expande:" -ForegroundColor Cyan
Write-Host "    Servers > Plazas Azure > Databases > plazas_db" -ForegroundColor White
Write-Host ""
Write-Host "3️⃣  Click derecho en 'plazas_db' y selecciona:" -ForegroundColor Cyan
Write-Host "    Query Tool" -ForegroundColor White
Write-Host ""
Write-Host "4️⃣  En la ventana del Query Tool:" -ForegroundColor Cyan
Write-Host "    - Click en el icono de carpeta (Open File)" -ForegroundColor White
Write-Host "    - Navega a: $(Resolve-Path $SQL_FILE)" -ForegroundColor White
Write-Host "    - Abre el archivo" -ForegroundColor White
Write-Host ""
Write-Host "5️⃣  Click en el botón ▶️ (Execute/Refresh) o presiona F5" -ForegroundColor Cyan
Write-Host ""
Write-Host "6️⃣  Verifica que veas el mensaje:" -ForegroundColor Cyan
Write-Host "    'Query returned successfully'" -ForegroundColor Green
Write-Host ""
Write-Host "============================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "📊 Después de ejecutar, tendrás:" -ForegroundColor Cyan
Write-Host "   ✅ Tabla 'usuarios' creada" -ForegroundColor White
Write-Host "   ✅ Usuario admin: admin@plazas.com / Admin123!" -ForegroundColor White
Write-Host "   ✅ Columnas de apartado en 'transacciones'" -ForegroundColor White
Write-Host "   ✅ Columna precio_apartado en 'locales'" -ForegroundColor White
Write-Host ""
Write-Host "🚀 Una vez ejecutado, presiona cualquier tecla para redesplegar..." -ForegroundColor Green
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Write-Host ""
Write-Host "🔄 Iniciando redespliegue de backend y frontend..." -ForegroundColor Cyan
Write-Host ""

# ============================================================
# REDESPLIEGUE DE BACKEND
# ============================================================

Write-Host "📦 1/4 - Construyendo imagen de backend..." -ForegroundColor Yellow
Set-Location backend
docker build -t plazasacr2024.azurecr.io/plazas-backend:latest .
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al construir backend" -ForegroundColor Red
    Set-Location ..
    exit 1
}

Write-Host "☁️  2/4 - Subiendo backend a Azure Container Registry..." -ForegroundColor Yellow
docker push plazasacr2024.azurecr.io/plazas-backend:latest
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al subir backend" -ForegroundColor Red
    Set-Location ..
    exit 1
}

Set-Location ..

Write-Host "🔄 3/4 - Reiniciando contenedor de backend en Azure..." -ForegroundColor Yellow
az container restart --resource-group plazas-comerciales-rg --name plazas-backend-2024
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  Advertencia: No se pudo reiniciar automáticamente" -ForegroundColor Yellow
}

Start-Sleep -Seconds 10

# ============================================================
# REDESPLIEGUE DE FRONTEND
# ============================================================

Write-Host ""
Write-Host "📦 4/4 - Construyendo y desplegando frontend..." -ForegroundColor Yellow
Set-Location frontend

# Construir frontend
Write-Host "   🔨 Compilando React..." -ForegroundColor Cyan
npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al compilar frontend" -ForegroundColor Red
    Set-Location ..
    exit 1
}

# Construir imagen Docker
Write-Host "   🐳 Construyendo imagen Docker..." -ForegroundColor Cyan
docker build -t plazasacr2024.azurecr.io/plazas-frontend:latest .
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al construir imagen frontend" -ForegroundColor Red
    Set-Location ..
    exit 1
}

# Subir a ACR
Write-Host "   ☁️  Subiendo a Azure..." -ForegroundColor Cyan
docker push plazasacr2024.azurecr.io/plazas-frontend:latest
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al subir frontend" -ForegroundColor Red
    Set-Location ..
    exit 1
}

# Reiniciar contenedor
Write-Host "   🔄 Reiniciando contenedor..." -ForegroundColor Cyan
az container restart --resource-group plazas-comerciales-rg --name plazas-frontend-2024
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  Advertencia: No se pudo reiniciar automáticamente" -ForegroundColor Yellow
}

Set-Location ..

# ============================================================
# RESUMEN FINAL
# ============================================================

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "✅ DESPLIEGUE COMPLETADO" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 URLs de la aplicación:" -ForegroundColor Cyan
Write-Host "   Frontend: http://plazas-frontend-2024.eastus.azurecontainer.io" -ForegroundColor White
Write-Host "   Backend:  http://plazas-backend-2024.eastus.azurecontainer.io:5000" -ForegroundColor White
Write-Host ""
Write-Host "👤 Credenciales de administrador:" -ForegroundColor Cyan
Write-Host "   Email:    admin@plazas.com" -ForegroundColor White
Write-Host "   Password: Admin123!" -ForegroundColor White
Write-Host ""
Write-Host "🧪 Prueba el sistema:" -ForegroundColor Cyan
Write-Host "   1. Abre el frontend en tu navegador" -ForegroundColor White
Write-Host "   2. Click en 'Iniciar Sesión'" -ForegroundColor White
Write-Host "   3. Ingresa las credenciales de admin" -ForegroundColor White
Write-Host "   4. Verás el Dashboard con gráficas" -ForegroundColor White
Write-Host "   5. Prueba descargar un PDF de transacción" -ForegroundColor White
Write-Host ""
Write-Host "⏳ Espera 30-60 segundos para que los contenedores se inicien completamente" -ForegroundColor Yellow
Write-Host ""
