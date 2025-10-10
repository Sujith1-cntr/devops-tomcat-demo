variable "resource_group_name" {
  description = "Resource Group name"
  type        = string
  default     = "aca-rg"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "env_name" {
  description = "Container App Environment name"
  type        = string
  default     = "aca-env"
}

variable "app_name" {
  description = "Container App name"
  type        = string
  default     = "tomcat-aca"
}
