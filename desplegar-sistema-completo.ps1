# ============================================================
# Script: Despliegue completo del sistema de autenticación
# ============================================================

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  DESPLIEGUE SISTEMA DE AUTENTICACIÓN Y DASHBOARDS     ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ============================================================
# PASO 1: MIGRACIÓN DE BASE DE DATOS
# ============================================================

Write-Host "📋 PASO 1: EJECUTAR MIGRACIÓN EN pgAdmin" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════" -ForegroundColor Yellow
Write-Host ""
Write-Host "Por favor, sigue estos pasos en pgAdmin:" -ForegroundColor White
Write-Host ""
Write-Host "  1. Abre pgAdmin 4" -ForegroundColor Cyan
Write-Host "  2. Expande: Servers > Plazas Azure > Databases > plazas_db" -ForegroundColor Cyan
Write-Host "  3. Click derecho en 'plazas_db' → Query Tool" -ForegroundColor Cyan
Write-Host "  4. Click en 📁 (Open File)" -ForegroundColor Cyan
Write-Host "  5. Abre: $(Resolve-Path 'database\migracion-auth.sql')" -ForegroundColor Green
Write-Host "  6. Click en ▶️ (Execute) o presiona F5" -ForegroundColor Cyan
Write-Host "  7. Verifica que veas: 'Query returned successfully'" -ForegroundColor Cyan
Write-Host ""
Write-Host "Esto creará:" -ForegroundColor White
Write-Host "  ✅ Tabla 'usuarios'" -ForegroundColor Green
Write-Host "  ✅ Usuario admin (admin@plazas.com / Admin123!)" -ForegroundColor Green
Write-Host "  ✅ Columnas de apartado en transacciones" -ForegroundColor Green
Write-Host "  ✅ Columna precio_apartado en locales" -ForegroundColor Green
Write-Host ""
Write-Host "═══════════════════════════════════════════" -ForegroundColor Yellow
Write-Host ""
Write-Host "⏸️  Presiona cualquier tecla cuando hayas ejecutado la migración..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# ============================================================
# PASO 2: REDESPLIEGUE DE BACKEND
# ============================================================

Write-Host ""
Write-Host "📦 PASO 2: DESPLEGANDO BACKEND" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════" -ForegroundColor Yellow
Write-Host ""

Write-Host "🔨 Construyendo imagen de backend..." -ForegroundColor Cyan
Set-Location backend
docker build -t plazasacr2024.azurecr.io/plazas-backend:latest . 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al construir backend" -ForegroundColor Red
    Set-Location ..
    exit 1
}
Write-Host "✅ Backend construido" -ForegroundColor Green

Write-Host "☁️  Subiendo a Azure Container Registry..." -ForegroundColor Cyan
docker push plazasacr2024.azurecr.io/plazas-backend:latest 2>&1 | Out-Null
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
Write-Host "📦 PASO 3: DESPLEGANDO FRONTEND" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════" -ForegroundColor Yellow
Write-Host ""

Set-Location frontend

Write-Host "🔨 Compilando React..." -ForegroundColor Cyan
npm run build 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al compilar frontend" -ForegroundColor Red
    Set-Location ..
    exit 1
}
Write-Host "✅ Frontend compilado" -ForegroundColor Green

Write-Host "🐳 Construyendo imagen Docker..." -ForegroundColor Cyan
docker build -t plazasacr2024.azurecr.io/plazas-frontend:latest . 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al construir imagen frontend" -ForegroundColor Red
    Set-Location ..
    exit 1
}
Write-Host "✅ Imagen construida" -ForegroundColor Green

Write-Host "☁️  Subiendo a Azure..." -ForegroundColor Cyan
docker push plazasacr2024.azurecr.io/plazas-frontend:latest 2>&1 | Out-Null
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
Write-Host "🌐 URLs de la aplicación:" -ForegroundColor Cyan
Write-Host "   Frontend: http://plazas-frontend-2024.eastus.azurecontainer.io" -ForegroundColor White
Write-Host "   Backend:  http://plazas-backend-2024.eastus.azurecontainer.io:5000" -ForegroundColor White
Write-Host ""
Write-Host "👤 Credenciales de administrador:" -ForegroundColor Cyan
Write-Host "   Email:    admin@plazas.com" -ForegroundColor White
Write-Host "   Password: Admin123!" -ForegroundColor White
Write-Host ""
Write-Host "🧪 Cómo probar el sistema:" -ForegroundColor Cyan
Write-Host ""
Write-Host "   PARA ADMIN:" -ForegroundColor Yellow
Write-Host "   1. Abre: http://plazas-frontend-2024.eastus.azurecontainer.io" -ForegroundColor White
Write-Host "   2. Click en 'Iniciar Sesión' (esquina superior derecha)" -ForegroundColor White
Write-Host "   3. Ingresa: admin@plazas.com / Admin123!" -ForegroundColor White
Write-Host "   4. Verás el Dashboard con 4 gráficas:" -ForegroundColor White
Write-Host "      • Distribución de locales por estado" -ForegroundColor Gray
Write-Host "      • Ingresos por plaza" -ForegroundColor Gray
Write-Host "      • Transacciones recientes" -ForegroundColor Gray
Write-Host "      • Tendencia de ventas" -ForegroundColor Gray
Write-Host ""
Write-Host "   PARA CLIENTES:" -ForegroundColor Yellow
Write-Host "   1. Click en 'Registrarse'" -ForegroundColor White
Write-Host "   2. Crea una cuenta nueva" -ForegroundColor White
Write-Host "   3. Compra o aparta un local" -ForegroundColor White
Write-Host "   4. Ve a 'Mi Cuenta' para ver tus locales" -ForegroundColor White
Write-Host "   5. Descarga el PDF de tu transacción" -ForegroundColor White
Write-Host ""
Write-Host "⏳ Espera 30-60 segundos para que los contenedores se inicien" -ForegroundColor Yellow
Write-Host ""
Write-Host "📊 Nuevas funcionalidades implementadas:" -ForegroundColor Cyan
Write-Host "   ✅ Sistema de login y registro" -ForegroundColor Green
Write-Host "   ✅ Dashboard de administrador con gráficas" -ForegroundColor Green
Write-Host "   ✅ Panel de cliente (Mi Cuenta)" -ForegroundColor Green
Write-Host "   ✅ Generación de PDFs con detalles de compra/apartado" -ForegroundColor Green
Write-Host "   ✅ Sistema de apartado con 4 opciones (15/30/60/90 días)" -ForegroundColor Green
Write-Host "   ✅ Porcentajes de apartado (15%/25%/35%/50%)" -ForegroundColor Green
Write-Host "   ✅ Autenticación JWT con tokens de 7 días" -ForegroundColor Green
Write-Host ""
