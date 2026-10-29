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

variable "bucket_name_suffixes" {
  description = "Suffixes for S3 buckets"
  type        = list(string)
  default     = ["foo", "bar"]
}
