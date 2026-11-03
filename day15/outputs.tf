output "main_instance_arn" {
  description = "ARN of the EC2 instance in main VPC"
  value       = aws_instance.main.arn
}

output "peer_instance_arn" {
  description = "ARN of the EC2 instance in peer VPC"
  value       = aws_instance.peer.arn
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
