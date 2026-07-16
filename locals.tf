locals {
  # One repository per name; default to the composed label id.
  image_names = length(var.image_names) > 0 ? var.image_names : [local.id]

  # ── Repository policy ─────────────────────────────────────────────────────
  need_policy = local.enabled && (
    length(var.read_principals) + length(var.write_principals) + length(var.additional_policy_statements) > 0
  )

  # Resource-level ECR actions. GetAuthorizationToken is registry-scoped and is
  # granted through IAM, not a repository policy, so it is intentionally absent.
  pull_actions = [
    "ecr:GetDownloadUrlForLayer",
    "ecr:BatchGetImage",
    "ecr:BatchCheckLayerAvailability",
    "ecr:DescribeImages",
    "ecr:DescribeRepositories",
    "ecr:GetRepositoryPolicy",
    "ecr:GetLifecyclePolicy",
    "ecr:ListImages",
    "ecr:ListTagsForResource",
  ]
  push_actions = concat(local.pull_actions, [
    "ecr:PutImage",
    "ecr:InitiateLayerUpload",
    "ecr:UploadLayerPart",
    "ecr:CompleteLayerUpload",
  ])

  # ── Lifecycle policy ──────────────────────────────────────────────────────
  # Protected tag prefixes are evaluated first (lowest priority numbers) so the
  # catch-all count rule never expires a release image.
  protected_rules = [
    for i, tag in var.protected_tags : {
      rulePriority = i + 1
      description  = "Keep last ${var.protected_tags_keep_count} images tagged with prefix '${tag}'"
      selection = {
        tagStatus     = "tagged"
        tagPrefixList = [tag]
        countType     = "imageCountMoreThan"
        countNumber   = var.protected_tags_keep_count
      }
      action = { type = "expire" }
    }
  ]

  untagged_rule = var.untagged_image_expiry_days > 0 ? [{
    rulePriority = length(var.protected_tags) + 1
    description  = "Expire untagged images older than ${var.untagged_image_expiry_days} days"
    selection = {
      tagStatus   = "untagged"
      countType   = "sinceImagePushed"
      countUnit   = "days"
      countNumber = var.untagged_image_expiry_days
    }
    action = { type = "expire" }
  }] : []

  # Catch-all count rule must be last (highest priority number → evaluated last).
  count_rule = [{
    rulePriority = length(var.protected_tags) + (var.untagged_image_expiry_days > 0 ? 1 : 0) + 1
    description  = "Keep at most ${var.max_image_count} images"
    selection = {
      tagStatus   = "any"
      countType   = "imageCountMoreThan"
      countNumber = var.max_image_count
    }
    action = { type = "expire" }
  }]

  lifecycle_policy = jsonencode({
    rules = concat(local.protected_rules, local.untagged_rule, local.count_rule)
  })
}
