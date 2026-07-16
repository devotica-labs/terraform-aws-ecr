output "repository_urls" {
  description = "Repository name → URL."
  value       = module.ecr.repository_urls
}

output "registry_id" {
  description = "Registry (account) ID."
  value       = module.ecr.registry_id
}
