variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "egiflames-terraform-on-aws"
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

variable "allowed_availability_zones" {
  description = "Allowed availability zones for app server"
  type        = list(string)
  default     = ["ap-northeast-1a"]
}
