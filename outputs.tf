output "repository_names" {
  description = "List of repository names created."
  value       = [for r in aws_ecr_repository.this : r.name]
}

output "repository_urls" {
  description = "Map of repository name → repository URL (the docker pull/push target)."
  value       = { for k, r in aws_ecr_repository.this : k => r.repository_url }
}

output "repository_arns" {
  description = "Map of repository name → repository ARN."
  value       = { for k, r in aws_ecr_repository.this : k => r.arn }
}

output "registry_id" {
  description = "The registry ID (AWS account ID) the repositories live in."
  value       = try(values(aws_ecr_repository.this)[0].registry_id, null)
}

output "lifecycle_policy_json" {
  description = "The JSON lifecycle policy applied to the repositories (null when disabled)."
  value       = local.enabled && var.enable_lifecycle_policy ? local.lifecycle_policy : null
}
