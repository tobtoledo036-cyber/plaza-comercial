terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# ═══════════════════════════════════════════════════════════════
# RESOURCE GROUP
# ═══════════════════════════════════════════════════════════════

resource "azurerm_resource_group" "plazas" {
  name     = var.resource_group
  location = var.location

  tags = {
    proyecto   = "plazas-comerciales"
    entorno    = "produccion"
    gestionado = "terraform"
  }
}

# ═══════════════════════════════════════════════════════════════
# AZURE CONTAINER REGISTRY (ACR)
# ═══════════════════════════════════════════════════════════════

resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.plazas.name
  location            = azurerm_resource_group.plazas.location
  sku                 = "Basic"
  admin_enabled       = true

  tags = {
    proyecto = "plazas-comerciales"
  }
}

# ═══════════════════════════════════════════════════════════════
# CONTENEDOR: POSTGRESQL
# ═══════════════════════════════════════════════════════════════

resource "azurerm_container_group" "postgres" {
  name                = "plazas-postgres-2024"
  location            = azurerm_resource_group.plazas.location
  resource_group_name = azurerm_resource_group.plazas.name
  ip_address_type     = "Public"
  dns_name_label      = "plazas-postgres-2024"
  os_type             = "Linux"

  container {
    name   = "postgres"
    image  = "postgres:15-alpine"
    cpu    = "1"
    memory = "1.5"

    ports {
      port     = 5432
      protocol = "TCP"
    }

    environment_variables = {
      POSTGRES_DB   = var.db_name
      POSTGRES_USER = var.db_user
    }

    secure_environment_variables = {
      POSTGRES_PASSWORD = var.db_password
    }
  }

  tags = {
    proyecto   = "plazas-comerciales"
    componente = "base-de-datos"
  }
}

# ═══════════════════════════════════════════════════════════════
# CONTENEDOR: BACKEND (Node.js + Express)
# ═══════════════════════════════════════════════════════════════

resource "azurerm_container_group" "backend" {
  name                = "plazas-backend-2024"
  location            = azurerm_resource_group.plazas.location
  resource_group_name = azurerm_resource_group.plazas.name
  ip_address_type     = "Public"
  dns_name_label      = "plazas-backend-2024"
  os_type             = "Linux"

  # Credenciales del ACR para descargar la imagen
  image_registry_credential {
    server   = azurerm_container_registry.acr.login_server
    username = azurerm_container_registry.acr.admin_username
    password = azurerm_container_registry.acr.admin_password
  }

  container {
    name   = "backend"
    image  = "${azurerm_container_registry.acr.login_server}/plazas-backend:${var.backend_image_tag}"
    cpu    = "1"
    memory = "1"

    ports {
      port     = 5000
      protocol = "TCP"
    }

    environment_variables = {
      NODE_ENV    = "production"
      PORT        = "5000"
      DB_HOST     = azurerm_container_group.postgres.fqdn
      DB_PORT     = "5432"
      DB_NAME     = var.db_name
      DB_USER     = var.db_user
      PAYPAL_MODE = var.paypal_mode
      FRONTEND_URL = var.frontend_url
      ADMIN_EMAIL  = var.admin_email
      EMAIL_FROM   = var.email_from
    }

    secure_environment_variables = {
      DB_PASSWORD          = var.db_password
      PAYPAL_CLIENT_ID     = var.paypal_client_id
      PAYPAL_CLIENT_SECRET = var.paypal_client_secret
      GMAIL_USER           = var.gmail_user
      GMAIL_PASS           = var.gmail_pass
    }
  }

  # El backend necesita que postgres esté listo primero
  depends_on = [azurerm_container_group.postgres]

  tags = {
    proyecto   = "plazas-comerciales"
    componente = "backend"
  }
}

# ═══════════════════════════════════════════════════════════════
# CONTENEDOR: FRONTEND (React + Nginx)
# ═══════════════════════════════════════════════════════════════

resource "azurerm_container_group" "frontend" {
  name                = "plazas-frontend-2024"
  location            = azurerm_resource_group.plazas.location
  resource_group_name = azurerm_resource_group.plazas.name
  ip_address_type     = "Public"
  dns_name_label      = "plazas-frontend-2024"
  os_type             = "Linux"

  # Credenciales del ACR para descargar la imagen
  image_registry_credential {
    server   = azurerm_container_registry.acr.login_server
    username = azurerm_container_registry.acr.admin_username
    password = azurerm_container_registry.acr.admin_password
  }

  container {
    name   = "frontend"
    image  = "${azurerm_container_registry.acr.login_server}/plazas-frontend:${var.frontend_image_tag}"
    cpu    = "1"
    memory = "1.5"

    ports {
      port     = 80
      protocol = "TCP"
    }
  }

  # El frontend necesita que el backend esté listo primero
  depends_on = [azurerm_container_group.backend]

  tags = {
    proyecto   = "plazas-comerciales"
    componente = "frontend"
  }
}
