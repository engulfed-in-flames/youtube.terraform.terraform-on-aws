# Compute Outputs
output "web_server_arns" {
  description = "ARNs of the web servers"
  value       = aws_instance.web[*].arn
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
