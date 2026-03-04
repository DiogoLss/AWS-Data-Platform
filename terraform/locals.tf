locals {
  common_tags = {
    Service     = "Terraform Study"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = "Diogo Lessa"
  }
}