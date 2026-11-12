output "passwords" {
  value = {
    for user, profile in aws_iam_user_login_profile.users :
    user => "Password created - a user must reset the password on the first login. "
  }
  sensitive = true
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
