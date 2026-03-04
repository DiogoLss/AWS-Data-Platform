locals {
  common_tags = {
    Project     = "AWS Data Platform"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = "Diogo Lessa"
  }
}