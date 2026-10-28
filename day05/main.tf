terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.7"
    }
  }

  required_version = "~> 1.2"

  backend "s3" {
    bucket       = "egiflames-tf-state"
    key          = "dev/terraform.tfstate"
    region       = "ap-northeast-1"
    use_lockfile = true # Enable S3 native state locking to prevent concurrent modifications (S3 versioning must be enabled)
    encrypt      = true
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

variable "environment" {
  type    = string
  default = "dev"
}

locals {
  bucket_name = "egiflames-tf-demo-${var.environment}"
}

resource "aws_s3_bucket" "bucket_1" {
  bucket = local.bucket_name

  tags = {
    project_name = "terraform-on-aws"
    environment  = var.environment
  }
}

output "environment" {
  value = var.environment
}

output "bucket_name" {
  value = aws_s3_bucket.bucket_1.bucket
}
