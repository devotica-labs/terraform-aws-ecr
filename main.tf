# One ECR repository per name in local.image_names. Fintech defaults:
# IMMUTABLE tags (reproducible digests), scan-on-push, KMS encryption, and
# force_delete off so a repo holding images can't be destroyed by accident.
resource "aws_ecr_repository" "this" {
  for_each = toset(local.enabled ? local.image_names : [])

  name                 = each.value
  image_tag_mutability = var.image_tag_mutability
  force_delete         = var.force_delete

  encryption_configuration {
    encryption_type = var.encryption_type
    # kms_key applies only to encryption_type=KMS; null selects the AWS-managed
    # aws/ecr key. Must be null for AES256.
    kms_key = var.encryption_type == "KMS" ? var.kms_key_arn : null
  }

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  tags = local.tags
}

resource "aws_ecr_lifecycle_policy" "this" {
  for_each = toset(local.enabled && var.enable_lifecycle_policy ? local.image_names : [])

  repository = aws_ecr_repository.this[each.value].name
  policy     = local.lifecycle_policy
}

resource "aws_ecr_repository_policy" "this" {
  for_each = toset(local.need_policy ? local.image_names : [])

  repository = aws_ecr_repository.this[each.value].name
  policy     = data.aws_iam_policy_document.repository[0].json
}
