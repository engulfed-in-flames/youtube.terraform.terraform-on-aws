# Compute Outputs
output "web_server_arns" {
  description = "ARNs of the web servers"
  value       = aws_instance.web[*].arn
}

output "app_autoscaling_group_arn" {
  description = "ARN of the autoscaling group for app"
  value       = aws_autoscaling_group.app.arn
}

# Storage Outputs
output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.compliance.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.compliance.arn
}

output "log_bucket_name" {
  description = "Name of the access log bucket (null outside prod)"
  value       = one(aws_s3_bucket.logs[*].bucket)
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
