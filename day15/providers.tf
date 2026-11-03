terraform {
  required_version = ">= 1.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.7"
    }
  }
}

provider "aws" {
  region = var.main_region
  # alias  = "main"  # Remove alias attribute so this provider becomes the default provider
}

provider "aws" {
  region = var.peer_region
  alias  = "peer"
}
