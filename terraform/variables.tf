variable "resource_group" {
  description = "Nombre del Resource Group en Azure"
  type        = string
  default     = "plazas-rg-eastus"
}

variable "location" {
  description = "Región de Azure"
  type        = string
  default     = "eastus"
}

variable "acr_name" {
  description = "Nombre del Azure Container Registry (debe ser único globalmente)"
  type        = string
  default     = "plazasacr2024"
}

variable "db_name" {
  description = "Nombre de la base de datos"
  type        = string
  default     = "plazas_db"
}

variable "db_user" {
  description = "Usuario de PostgreSQL"
  type        = string
  default     = "plazasadmin"
}

variable "db_password" {
  description = "Contraseña de PostgreSQL"
  type        = string
  sensitive   = true
}

variable "paypal_mode" {
  description = "Modo de PayPal: sandbox o live"
  type        = string
  default     = "sandbox"
}

variable "paypal_client_id" {
  description = "Client ID de PayPal"
  type        = string
  sensitive   = true
}

variable "paypal_client_secret" {
  description = "Client Secret de PayPal"
  type        = string
  sensitive   = true
}

variable "backend_image_tag" {
  description = "Tag de la imagen del backend"
  type        = string
  default     = "latest"
}

variable "frontend_image_tag" {
  description = "Tag de la imagen del frontend"
  type        = string
  default     = "latest"
}

variable "frontend_url" {
  description = "URL pública del frontend (para correos y PayPal return_url)"
  type        = string
  default     = "http://plazas-frontend-2024.eastus.azurecontainer.io"
}

variable "admin_email" {
  description = "Email del administrador"
  type        = string
  default     = "tobtoledo036@gmail.com"
}

variable "email_from" {
  description = "Nombre y email del remitente"
  type        = string
  default     = "Plazas Comerciales <tobtoledo036@gmail.com>"
}

variable "gmail_user" {
  description = "Email de Gmail para envío de correos"
  type        = string
  sensitive   = true
}

variable "gmail_pass" {
  description = "App Password de Gmail"
  type        = string
  sensitive   = true
}
