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
    use_lockfile = true  # Enable S3 native state locking to prevent concurrent modifications (S3 versioning must be enabled)
    encrypt      = true
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_s3_bucket" "bucket_1" {
  bucket = "egiflames-tf-demo"

  tags = {
    Name        = "My First bucket"
    Environment = "Dev"
  }
}
