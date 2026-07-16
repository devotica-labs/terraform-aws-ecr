output "repository_urls" {
  description = "Repository name → URL."
  value       = module.ecr.repository_urls
}

output "repository_arns" {
  description = "Repository name → ARN."
  value       = module.ecr.repository_arns
}

output "lifecycle_policy_json" {
  description = "The lifecycle policy applied to every repository."
  value       = module.ecr.lifecycle_policy_json
}
