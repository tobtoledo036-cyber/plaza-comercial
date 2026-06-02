# ============================================================
# Script: Verificación del sistema desplegado
# ============================================================

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         VERIFICACIÓN DEL SISTEMA                      ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# URLs
$BACKEND_URL = "http://plazas-backend-2024.eastus.azurecontainer.io:5000"
$FRONTEND_URL = "http://plazas-frontend-2024.eastus.azurecontainer.io"

# ============================================================
# 1. Verificar estado de contenedores
# ============================================================

Write-Host "📦 1. Estado de contenedores en Azure:" -ForegroundColor Yellow
Write-Host ""

$containers = az container list --resource-group plazas-rg-eastus --query "[].{Name:name, Status:instanceView.state, IP:ipAddress.fqdn}" -o json | ConvertFrom-Json

foreach ($container in $containers) {
    $status = $container.Status
    $color = if ($status -eq "Running") { "Green" } else { "Red" }
    $icon = if ($status -eq "Running") { "✅" } else { "❌" }
    
    Write-Host "   $icon $($container.Name): " -NoNewline
    Write-Host $status -ForegroundColor $color
}

Write-Host ""

# ============================================================
# 2. Verificar backend
# ============================================================

Write-Host "🔧 2. Verificando backend..." -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod -Uri "$BACKEND_URL/api/health" -Method Get -TimeoutSec 10
    if ($response.status -eq "OK") {
        Write-Host "   ✅ Backend funcionando correctamente" -ForegroundColor Green
        Write-Host "   Mensaje: $($response.message)" -ForegroundColor Gray
    } else {
        Write-Host "   ⚠️  Backend responde pero con estado inesperado" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ❌ Backend no responde" -ForegroundColor Red
    Write-Host "   Error: $_" -ForegroundColor Gray
    Write-Host "   💡 Espera 30-60 segundos y vuelve a intentar" -ForegroundColor Yellow
}

Write-Host ""

# ============================================================
# 3. Verificar frontend
# ============================================================

Write-Host "🌐 3. Verificando frontend..." -ForegroundColor Yellow

try {
    $response = Invoke-WebRequest -Uri $FRONTEND_URL -Method Get -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "   ✅ Frontend accesible" -ForegroundColor Green
        Write-Host "   Status Code: $($response.StatusCode)" -ForegroundColor Gray
    } else {
        Write-Host "   ⚠️  Frontend responde con código: $($response.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ❌ Frontend no accesible" -ForegroundColor Red
    Write-Host "   Error: $_" -ForegroundColor Gray
    Write-Host "   💡 Espera 30-60 segundos y vuelve a intentar" -ForegroundColor Yellow
}

Write-Host ""

# ============================================================
# 4. Verificar rutas de autenticación
# ============================================================

Write-Host "🔐 4. Verificando rutas de autenticación..." -ForegroundColor Yellow

$routes = @(
    "/api/auth/login",
    "/api/auth/register",
    "/api/admin/estadisticas",
    "/api/usuario/mis-locales",
    "/api/pdf/generar"
)

foreach ($route in $routes) {
    try {
        $response = Invoke-WebRequest -Uri "$BACKEND_URL$route" -Method Get -TimeoutSec 5 -ErrorAction SilentlyContinue
        Write-Host "   ✅ $route - Accesible" -ForegroundColor Green
    } catch {
        # Es normal que algunas rutas requieran autenticación (401) o método POST (405)
        $statusCode = $_.Exception.Response.StatusCode.value__
        if ($statusCode -eq 401 -or $statusCode -eq 405 -or $statusCode -eq 400) {
            Write-Host "   ✅ $route - Ruta existe (requiere auth/POST)" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  $route - Status: $statusCode" -ForegroundColor Yellow
        }
    }
}

Write-Host ""

# ============================================================
# 5. Información de la base de datos
# ============================================================

Write-Host "🗄️  5. Información de la base de datos:" -ForegroundColor Yellow
Write-Host ""
Write-Host "   Host: plazas-postgres-2024.eastus.azurecontainer.io" -ForegroundColor Gray
Write-Host "   Port: 5432" -ForegroundColor Gray
Write-Host "   Database: plazas_db" -ForegroundColor Gray
Write-Host "   User: plazasadmin" -ForegroundColor Gray
Write-Host ""
Write-Host "   ⚠️  IMPORTANTE: Ejecuta la migración SQL si no lo has hecho" -ForegroundColor Yellow
Write-Host "   Archivo: database\migracion-auth.sql" -ForegroundColor Cyan
Write-Host "   En pgAdmin: Query Tool > Open File > Execute (F5)" -ForegroundColor Cyan
Write-Host ""

# ============================================================
# RESUMEN
# ============================================================

Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║              RESUMEN DE VERIFICACIÓN                  ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 URLs:" -ForegroundColor Cyan
Write-Host "   Frontend: $FRONTEND_URL" -ForegroundColor White
Write-Host "   Backend:  $BACKEND_URL" -ForegroundColor White
Write-Host ""
Write-Host "👤 Credenciales de admin:" -ForegroundColor Cyan
Write-Host "   Email:    admin@plazas.com" -ForegroundColor White
Write-Host "   Password: Admin123!" -ForegroundColor White
Write-Host ""
Write-Host "📋 Próximos pasos:" -ForegroundColor Cyan
Write-Host "   1. Ejecuta la migración SQL en pgAdmin (si no lo has hecho)" -ForegroundColor White
Write-Host "   2. Abre el frontend en tu navegador" -ForegroundColor White
Write-Host "   3. Inicia sesión con las credenciales de admin" -ForegroundColor White
Write-Host "   4. Explora el dashboard y las funcionalidades" -ForegroundColor White
Write-Host ""
Write-Host "📖 Documentación completa: INSTRUCCIONES-FINALES.md" -ForegroundColor Cyan
Write-Host ""
