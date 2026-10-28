terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 6.7"
    }
  }

  required_version = "~> 1.2"
}


provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_default_vpc" "default" {}
