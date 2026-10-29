# Compute Outputs
output "web_server_arn" {
  description = "ARN of the web server"
  value       = aws_instance.web.arn
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
