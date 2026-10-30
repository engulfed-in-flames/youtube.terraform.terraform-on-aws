locals {
  mandatory_tags = {
    Environment = var.environment
    Project     = "${var.project_name}"
    ManagedBy   = "terraform"
  }
  common_tags = merge(local.mandatory_tags, var.custom_tags)

  is_prod     = var.environment == "prod"
  name_prefix = "${var.project_name}-${var.environment}"
  bucket_name = "${local.name_prefix}-${random_id.bucket_suffix.hex}"
}

resource "random_id" "bucket_suffix" {
  byte_length = 4

  keepers = {
    project     = var.project_name
    environment = var.environment
  }
}
