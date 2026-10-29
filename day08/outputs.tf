# S3 Outputs
output "s3_bucket_names" {
  description = "Names of all S3 buckets"
  value       = local.all_bucket_ids
}

output "s3_bucket_arns" {
  description = "ARNs of all S3 buckets"
  value = merge(
    { for idx, b in aws_s3_bucket.bucket_using_list : "list-${idx}" => b.arn },
    { for key, b in aws_s3_bucket.bucket_using_for_each : "each-${key}" => b.arn },
  )
}

# Environment Outputs
output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "common_tags" {
  description = "Common tags applied to resources"
  value       = local.common_tags
}
