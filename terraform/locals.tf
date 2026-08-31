locals {
  name = "${var.project_name}-${var.environment}"
  common_tags = {
    Project     = "QuickCart Order Queue"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
