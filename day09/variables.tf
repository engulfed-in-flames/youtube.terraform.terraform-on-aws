variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (dev | staging | prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "region" {
  description = "AWS region for resources"
  type        = string
  default     = "ap-northeast-1"
}

variable "custom_tags" {
  description = "Optional custom tags from the developer"
  type        = map(string)
  default     = {}
}

variable "allowed_instance_types" {
  description = "Allowed instance types for each environment"
  type        = map(string)
  default     = {}
}

variable "allowed_availability_zones" {
  description = "Allowed availability zones for app server"
  type        = list(string)
  default     = ["ap-northeast-1a"]
}

variable "app_port" {
  description = "Port the app tier listens on"
  type        = number
  default     = 8080

  validation {
    condition     = var.app_port > 0 && var.app_port <= 65535
    error_message = "App port must be between 1 and 65535."
  }
}
