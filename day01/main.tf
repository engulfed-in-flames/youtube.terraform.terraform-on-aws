# Configure the Terraform AWS Provider
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 6.7"
    }
  }

  required_version = "~> 1.2"
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-northeast-1"
}
