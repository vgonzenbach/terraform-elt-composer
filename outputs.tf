output "composer_env_name" {
  description = "Name of the Composer environment"
  value       = var.composer_env_name
}

output "composer_service_account" {
  description = "Email of the Composer environment service account"
  value       = module.service_accounts.email
  sensitive   = true
}

output "region" {
  description = "Region set by user (used by Composer)"
  value       = var.region
}
