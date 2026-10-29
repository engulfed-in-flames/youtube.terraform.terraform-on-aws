locals {
  mandatory_tags = {
    Environment = var.environment
    Project     = "${var.project_name}"
    ManagedBy   = "terraform"
    CreatedAt   = formatdate("YYYY-MM-DD", timestamp())
  }
  common_tags = merge(local.mandatory_tags, var.custom_tags)

  name_prefix = "${var.project_name}-${var.environment}"
  bucket_name = "${local.name_prefix}-${random_id.bucket_suffix.hex}"

  all_bucket_ids = merge(
    { for idx, b in aws_s3_bucket.bucket_using_list : "list-${idx}" => b.id },
    { for key, b in aws_s3_bucket.bucket_using_for_each : "each-${key}" => b.id },
  )
}

resource "random_id" "bucket_suffix" {
  byte_length = 4

  keepers = {
    project     = var.project_name
    environment = var.environment
  }
}
