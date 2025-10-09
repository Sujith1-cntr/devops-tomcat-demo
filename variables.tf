variable "subscription_id" { type = string }
variable "tenant_id"       { type = string }
variable "client_id"       { type = string }

variable "rg_name"   { type = string }
variable "location"  { type = string  default = "eastus" }
variable "plan_name" { type = string  default = "asp-tomcat-demo" }
variable "plan_sku"  { type = string  default = "B1" }
variable "app_name"  { type = string }
