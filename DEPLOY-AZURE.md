# Guía de Deploy en Azure — Plazas Comerciales

## Requisitos previos
- Docker Desktop instalado y corriendo
- Azure CLI instalado (`az --version` para verificar)
- Cuenta Azure for Students activa
- Git (opcional)

---

## PASO 1 — Base de datos en Neon.tech (GRATIS)

El PostgreSQL local no es accesible desde Azure, necesitas una BD en la nube.

1. Ve a https://neon.tech → **Start for free** → crea cuenta
2. Crea un proyecto llamado `plazas-comerciales`
3. Copia la **connection string** que se ve así:
   ```
   postgresql://usuario:password@ep-xxx.us-east-2.aws.neon.tech/plazas_db?sslmode=require
   ```
4. En el editor SQL de Neon ejecuta estos archivos **en orden**:
   - `database/COMPLETO-todo-en-uno.sql`
   - `database/migracion-completa.sql`
   - `database/seed-postgres.sql`
   - `database/HASH-CORRECTO-ADMIN.sql`
   - `database/seed-locales-geojson.sql`
   - `database/seed-piso2.sql`

5. Anota estos datos de Neon:
   - `DB_HOST` = el host (ej: `ep-xxx.us-east-2.aws.neon.tech`)
   - `DB_USER` = el usuario
   - `DB_PASSWORD` = la contraseña
   - `DB_NAME` = `plazas_db`

---

## PASO 2 — Login en Azure y Docker

Abre PowerShell y ejecuta:

```powershell
# Login Azure
$env:PYTHONHTTPSVERIFY = "0"
az login

# Login en el Container Registry
docker login plazasacr2024.azurecr.io `
  -u plazasacr2024 `
  -p "D4tgbOO2bANAh3EF9Gxu5bNwGLUGYy0h27NC9a5LYqq0UPOmbMgVJQQJ99CEACYeBjFEqg7NAAACAZCR5TqP"
```

---

## PASO 3 — Construir y subir imágenes Docker

Ejecutar desde la carpeta raíz del proyecto (`plaza-comercial/`):

```powershell
# ── Backend ──────────────────────────────────────────────────
cd backend
docker build -t plazasacr2024.azurecr.io/plazas-backend:latest .
docker push plazasacr2024.azurecr.io/plazas-backend:latest
cd ..

# ── Frontend ─────────────────────────────────────────────────
cd frontend
docker build -t plazasacr2024.azurecr.io/plazas-frontend:latest .
docker push plazasacr2024.azurecr.io/plazas-frontend:latest
cd ..
```

---

## PASO 4 — Crear Resource Group y desplegar Backend

```powershell
$env:PYTHONHTTPSVERIFY = "0"

# Crear resource group (si no existe)
az group create --name plazas-rg-eastus --location eastus

# Desplegar Backend — REEMPLAZA los valores de DB_HOST, DB_USER, DB_PASSWORD con los de Neon
az container create `
  --resource-group plazas-rg-eastus `
  --name plazas-backend-2024 `
  --image plazasacr2024.azurecr.io/plazas-backend:latest `
  --registry-login-server plazasacr2024.azurecr.io `
  --registry-username plazasacr2024 `
  --registry-password "D4tgbOO2bANAh3EF9Gxu5bNwGLUGYy0h27NC9a5LYqq0UPOmbMgVJQQJ99CEACYeBjFEqg7NAAACAZCR5TqP" `
  --dns-name-label plazas-backend-2024 `
  --ports 5000 `
  --cpu 1 `
  --memory 1 `
  --location eastus `
  --environment-variables `
    NODE_ENV=production `
    PORT=5000 `
    DB_HOST=PONER_HOST_NEON `
    DB_PORT=5432 `
    DB_NAME=plazas_db `
    DB_USER=PONER_USUARIO_NEON `
    PAYPAL_MODE=sandbox `
    FRONTEND_URL=http://plazas-frontend-2024.eastus.azurecontainer.io `
    GMAIL_USER=tobtoledo036@gmail.com `
    ADMIN_EMAIL=tobtoledo036@gmail.com `
    EMAIL_FROM="Plazas Comerciales <tobtoledo036@gmail.com>" `
  --secure-environment-variables `
    DB_PASSWORD=PONER_PASSWORD_NEON `
    JWT_SECRET=plazas_secret_2024 `
    PAYPAL_CLIENT_ID=Ad1COovx9SuHgYUAJzO9m_7_fGRtrENyA3rfv1vpB1BGT11kvp07mG9Xn9tG7193vQ76QLJvNYxNWdRK `
    PAYPAL_CLIENT_SECRET=EKlDtptwPrnxFFp9iTKlcpHtky6V-bR6jSNKmFXYYfgLN3H24Ai9cBQSR2PbOy6E1mza0rNsxVkRdM9x `
    GMAIL_PASS="tglr vufb cunw vuxz"
```

---

## PASO 5 — Desplegar Frontend

```powershell
$env:PYTHONHTTPSVERIFY = "0"

az container create `
  --resource-group plazas-rg-eastus `
  --name plazas-frontend-2024 `
  --image plazasacr2024.azurecr.io/plazas-frontend:latest `
  --registry-login-server plazasacr2024.azurecr.io `
  --registry-username plazasacr2024 `
  --registry-password "D4tgbOO2bANAh3EF9Gxu5bNwGLUGYy0h27NC9a5LYqq0UPOmbMgVJQQJ99CEACYeBjFEqg7NAAACAZCR5TqP" `
  --dns-name-label plazas-frontend-2024 `
  --ports 80 `
  --cpu 1 `
  --memory 1.5 `
  --location eastus
```

---

## PASO 6 — Verificar URLs

```powershell
$env:PYTHONHTTPSVERIFY = "0"

# URL del frontend
az container show --resource-group plazas-rg-eastus --name plazas-frontend-2024 --query ipAddress.fqdn -o tsv

# URL del backend
az container show --resource-group plazas-rg-eastus --name plazas-backend-2024 --query ipAddress.fqdn -o tsv
```

Las URLs serán:
- **Frontend:** http://plazas-frontend-2024.eastus.azurecontainer.io
- **Backend:**  http://plazas-backend-2024.eastus.azurecontainer.io:5000

---

## PASO 7 — Admin del sitio

- URL: http://plazas-frontend-2024.eastus.azurecontainer.io/admin-dashboard
- Email: `admin@plazas.com`
- Contraseña: `Admin123!`

---

## Solución de problemas

**Error SSL en Azure CLI:**
```powershell
$env:PYTHONHTTPSVERIFY = "0"
# Agregar esta línea antes de cualquier comando az
```

**Contenedor no inicia:**
```powershell
$env:PYTHONHTTPSVERIFY = "0"
az container logs --resource-group plazas-rg-eastus --name plazas-backend-2024
```

**Actualizar imagen después de cambios:**
```powershell
# Reconstruir y subir imagen
docker build -t plazasacr2024.azurecr.io/plazas-backend:latest ./backend
docker push plazasacr2024.azurecr.io/plazas-backend:latest

# Reiniciar contenedor en Azure
$env:PYTHONHTTPSVERIFY = "0"
az container restart --resource-group plazas-rg-eastus --name plazas-backend-2024
```

---

## Apagar los contenedores (para no gastar créditos)

Cuando no uses el proyecto, apaga los contenedores:

```powershell
$env:PYTHONHTTPSVERIFY = "0"
az container stop --resource-group plazas-rg-eastus --name plazas-backend-2024
az container stop --resource-group plazas-rg-eastus --name plazas-frontend-2024
```

Para volver a encenderlos:
```powershell
$env:PYTHONHTTPSVERIFY = "0"
az container start --resource-group plazas-rg-eastus --name plazas-backend-2024
az container start --resource-group plazas-rg-eastus --name plazas-frontend-2024
```
