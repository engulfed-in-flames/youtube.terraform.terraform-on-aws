terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.7"
    }
  }

  backend "s3" {
    bucket       = "terraform-on-aws-dev-tf-state"
    key          = "terraform.tfstate"
    region       = "ap-northeast-1"
    use_lockfile = true # Enable S3 native state locking to prevent concurrent modifications (S3 versioning must be enabled)
    encrypt      = true
  }
}
