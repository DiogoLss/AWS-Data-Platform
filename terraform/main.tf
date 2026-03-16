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
  backend "s3" {
    bucket = "aws-terraform-660273306079"
    key    = "dev/terraform-backend/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.profile
}

data aws_caller_identity "current" {}

resource "aws_s3_bucket" "aws_terraform" {
  bucket = "aws-terraform-${data.aws_caller_identity.current.account_id}"
  tags = local.common_tags
}
resource "aws_s3_bucket_versioning" "versioning_aws_terraform" {
  bucket = aws_s3_bucket.aws_terraform.id
  versioning_configuration {
    status = "Enabled"
  }
}

#---STORAGE

module "storage" {
  source = "./storage"
  main_bucket_name  = "aws-data-${data.aws_caller_identity.current.account_id}"
  common_tags   = local.common_tags
}

module "iam" {
  source      = "./iam"
  project     = "aws-data-platform"
  common_tags = local.common_tags
  bucket_arn  = module.storage.bucket_arn
}