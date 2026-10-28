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

resource "aws_s3_bucket" "bucket_1" {
  bucket = "egiflames-tf-demo"

  tags = {
    Name        = "My First bucket"
    Environment = "Dev"
  }
}
