terraform {
  required_version = "1.14.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.33.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.8.1"
    }
  }
  backend "s3" {}
}

provider "aws" {
  region  = var.aws_region
  profile = var.profile
}

data aws_caller_identity "current" {}

resource "aws_s3_bucket" "aws_terraform" {
  bucket = "aws_terraform-${data.aws_caller_identity.current.account_id}"
  tags = local.common_tags
}
resource "aws_s3_bucket_versioning" "versioning_aws_terraform" {
  bucket = aws_s3_bucket.aws_terraform.id
  versioning_configuration {
    status = "Enabled"
  }
}