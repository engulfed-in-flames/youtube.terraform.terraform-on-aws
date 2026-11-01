# Storage Outputs
output "website_domain_name" {
  description = "ARN of the website"
  value       = aws_cloudfront_distribution.web.domain_name
}

# General Outputs
output "account_id" {
  description = "Current AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "current_region" {
  description = "Current AWS region"
  value       = data.aws_region.current.region
}

output "available_availability_zones" {
  description = "Available availability zones"
  value       = data.aws_availability_zones.available.names
}

output "current_environment" {
  description = "Environment name"
  value       = var.environment
}
