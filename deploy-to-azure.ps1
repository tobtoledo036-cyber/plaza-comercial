# Script de despliegue automatizado para Azure
# Ejecutar con: .\deploy-to-azure.ps1

param(
    [Parameter(Mandatory=$true)]
    [string]$AcrName,
    
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroup,
    
    [Parameter(Mandatory=$false)]
    [string]$Location = "centralus"
)

Write-Host "🚀 Iniciando despliegue en Azure..." -ForegroundColor Cyan

# Verificar que Azure CLI está instalado
Write-Host "`n📋 Verificando Azure CLI..." -ForegroundColor Yellow
try {
    az --version | Out-Null
    Write-Host "✅ Azure CLI encontrado" -ForegroundColor Green
} catch {
    Write-Host "❌ Azure CLI no está instalado. Descárgalo de: https://aka.ms/installazurecliwindows" -ForegroundColor Red
    exit 1
}

# Verificar que Docker está corriendo
Write-Host "`n🐳 Verificando Docker..." -ForegroundColor Yellow
try {
    docker ps | Out-Null
    Write-Host "✅ Docker está corriendo" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker no está corriendo. Inicia Docker Desktop." -ForegroundColor Red
    exit 1
}

# Iniciar sesión en Azure
Write-Host "`n🔐 Iniciando sesión en Azure..." -ForegroundColor Yellow
az login

# Crear grupo de recursos si no existe
Write-Host "`n📦 Creando grupo de recursos..." -ForegroundColor Yellow
az group create --name $ResourceGroup --location $Location

# Crear ACR si no existe
Write-Host "`n🏗️ Creando Azure Container Registry..." -ForegroundColor Yellow
az acr create --resource-group $ResourceGroup --name $AcrName --sku Basic
az acr update --name $AcrName --admin-enabled true

# Obtener credenciales de ACR
Write-Host "`n🔑 Obteniendo credenciales de ACR..." -ForegroundColor Yellow
$acrCredentials = az acr credential show --name $AcrName | ConvertFrom-Json
$acrUsername = $acrCredentials.username
$acrPassword = $acrCredentials.passwords[0].value

Write-Host "✅ Credenciales obtenidas" -ForegroundColor Green

# Iniciar sesión en ACR
Write-Host "`n🔐 Iniciando sesión en ACR..." -ForegroundColor Yellow
az acr login --name $AcrName

# Construir y subir imagen del backend
Write-Host "`n🏗️ Construyendo imagen del backend..." -ForegroundColor Yellow
Set-Location backend
docker build -t "$AcrName.azurecr.io/plazas-backend:latest" .
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Imagen del backend construida" -ForegroundColor Green
    
    Write-Host "`n📤 Subiendo imagen del backend..." -ForegroundColor Yellow
    docker push "$AcrName.azurecr.io/plazas-backend:latest"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Imagen del backend subida" -ForegroundColor Green
    } else {
        Write-Host "❌ Error al subir imagen del backend" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "❌ Error al construir imagen del backend" -ForegroundColor Red
    exit 1
}
Set-Location ..

# Construir y subir imagen del frontend
Write-Host "`n🏗️ Construyendo imagen del frontend..." -ForegroundColor Yellow
Set-Location frontend
docker build -t "$AcrName.azurecr.io/plazas-frontend:latest" .
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Imagen del frontend construida" -ForegroundColor Green
    
    Write-Host "`n📤 Subiendo imagen del frontend..." -ForegroundColor Yellow
    docker push "$AcrName.azurecr.io/plazas-frontend:latest"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Imagen del frontend subida" -ForegroundColor Green
    } else {
        Write-Host "❌ Error al subir imagen del frontend" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "❌ Error al construir imagen del frontend" -ForegroundColor Red
    exit 1
}
Set-Location ..

# Verificar imágenes en ACR
Write-Host "`n📋 Verificando imágenes en ACR..." -ForegroundColor Yellow
az acr repository list --name $AcrName --output table

Write-Host "`n✅ ¡Despliegue completado exitosamente!" -ForegroundColor Green
Write-Host "`n📝 Siguiente paso: Crear la base de datos PostgreSQL y desplegar los contenedores" -ForegroundColor Cyan
Write-Host "   Consulta AZURE_DEPLOYMENT.md para los siguientes pasos" -ForegroundColor Cyan

# Mostrar información útil
Write-Host "`n📊 Información del despliegue:" -ForegroundColor Yellow
Write-Host "   ACR Name: $AcrName" -ForegroundColor White
Write-Host "   ACR Login Server: $AcrName.azurecr.io" -ForegroundColor White
Write-Host "   Resource Group: $ResourceGroup" -ForegroundColor White
Write-Host "   Location: $Location" -ForegroundColor White
Write-Host "   ACR Username: $acrUsername" -ForegroundColor White
Write-Host "   ACR Password: $acrPassword" -ForegroundColor White
