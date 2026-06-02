# ═══════════════════════════════════════════════════════════════
# OUTPUTS — URLs y datos útiles después del apply
# ═══════════════════════════════════════════════════════════════

output "frontend_url" {
  description = "URL pública del frontend"
  value       = "http://${azurerm_container_group.frontend.fqdn}"
}

output "backend_url" {
  description = "URL pública del backend"
  value       = "http://${azurerm_container_group.backend.fqdn}:5000"
}

output "postgres_host" {
  description = "Host de PostgreSQL para conectar desde pgAdmin"
  value       = azurerm_container_group.postgres.fqdn
}

output "acr_login_server" {
  description = "URL del Azure Container Registry"
  value       = azurerm_container_registry.acr.login_server
}

output "acr_admin_username" {
  description = "Usuario admin del ACR (para docker login)"
  value       = azurerm_container_registry.acr.admin_username
}

output "acr_admin_password" {
  description = "Contraseña admin del ACR (para docker login)"
  value       = azurerm_container_registry.acr.admin_password
  sensitive   = true
}

output "resource_group_name" {
  description = "Nombre del Resource Group creado"
  value       = azurerm_resource_group.plazas.name
}

output "instrucciones_post_deploy" {
  description = "Pasos a seguir después del terraform apply"
  value = <<-EOT

    ╔══════════════════════════════════════════════════════════════╗
    ║           INFRAESTRUCTURA CREADA EXITOSAMENTE               ║
    ╚══════════════════════════════════════════════════════════════╝

    1. Construye y sube las imágenes Docker al ACR:

       docker build -t ${azurerm_container_registry.acr.login_server}/plazas-backend:latest ./backend
       docker build -t ${azurerm_container_registry.acr.login_server}/plazas-frontend:latest ./frontend

       az acr login --name ${var.acr_name}

       docker push ${azurerm_container_registry.acr.login_server}/plazas-backend:latest
       docker push ${azurerm_container_registry.acr.login_server}/plazas-frontend:latest

    2. Pobla la base de datos desde pgAdmin:
       Host:     ${azurerm_container_group.postgres.fqdn}
       Puerto:   5432
       BD:       ${var.db_name}
       Usuario:  ${var.db_user}

       Ejecuta en orden:
         - database/schema-postgres.sql
         - database/seed-postgres.sql
         - database/seed-plazas-2-5.sql

    3. Accede a la aplicación:
       Frontend: http://${azurerm_container_group.frontend.fqdn}
       Backend:  http://${azurerm_container_group.backend.fqdn}:5000

  EOT
}
