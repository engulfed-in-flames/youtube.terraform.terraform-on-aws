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

variable "main_region" {
  description = "AWS main region for resources"
  type        = string
  default     = "ap-northeast-1"
}

variable "main_cidr_block" {
  description = "CIDR block for the main VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "peer_region" {
  description = "AWS peer region for resources"
  type        = string
  default     = "us-east-1"
}

variable "peer_cidr_block" {
  description = "CIDR block for the peer VPC"
  type        = string
  default     = "192.168.0.0/16"
}
