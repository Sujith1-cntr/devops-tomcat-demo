terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.112"
    }
  }
}

provider "azurerm" {
  features {}
}

# ---------------- Variables ----------------
variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "env_name"            { type = string  default = "aca-env" }
variable "app_name"            { type = string  default = "tomcat-aca" }

# Docker image to run (e.g. sujith/docker-tomcat:latest)
variable "docker_image"        { type = string }

# Only required if your Docker Hub repo is private.
variable "dockerhub_username"  { type = string  default = "" }
variable "dockerhub_token"     { type = string  default = ""  sensitive = true }

# ---------------- Resources ----------------

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# ACA requires a workspace
resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.env_name}-logs"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "env" {
  name                       = var.env_name
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
}

resource "azurerm_container_app" "app" {
  name                         = var.app_name
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  # Public ingress on 8080 (Tomcat default)
  ingress {
    external_enabled = true
    target_port      = 8080
    transport        = "auto"
  }

  template {
    container {
      name   = "tomcat"
      image  = var.docker_image
      cpu    = 0.5
      memory = "1.0Gi"

      # optional readiness check
      probes {
        type = "http"
        port = 8080
        path = "/"
      }
    }

    # simple autoscale rule
    http_scale_rule {
      name = "http"
      metadata = {
        concurrentRequests = "50"
      }
    }
  }

  # If your Docker Hub repo is private, keep the registry+secret blocks.
  # If public, you can delete registry{} and secret{} entirely.
  dynamic "registry" {
    for_each = var.dockerhub_username != "" && var.dockerhub_token != "" ? [1] : []
    content {
      server              = "index.docker.io"
      username            = var.dockerhub_username
      password_secret_name = "dockerhub-token"
    }
  }

  dynamic "secret" {
    for_each = var.dockerhub_username != "" && var.dockerhub_token != "" ? [1] : []
    content {
      name  = "dockerhub-token"
      value = var.dockerhub_token
    }
  }
}

output "container_app_url" {
  value       = "https://${azurerm_container_app.app.latest_revision_fqdn}"
  description = "Public URL of the Container App"
}
