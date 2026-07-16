# Repository access policy — assembled from the read/write principal lists plus
# any caller-supplied escape-hatch statements. Only rendered when at least one
# is set (local.need_policy); otherwise no repository policy is attached.
data "aws_iam_policy_document" "repository" {
  count = local.need_policy ? 1 : 0

  dynamic "statement" {
    for_each = length(var.read_principals) > 0 ? [1] : []
    content {
      sid    = "ReadAccess"
      effect = "Allow"
      principals {
        type        = "AWS"
        identifiers = var.read_principals
      }
      actions = local.pull_actions
    }
  }

  dynamic "statement" {
    for_each = length(var.write_principals) > 0 ? [1] : []
    content {
      sid    = "WriteAccess"
      effect = "Allow"
      principals {
        type        = "AWS"
        identifiers = var.write_principals
      }
      actions = local.push_actions
    }
  }

  dynamic "statement" {
    for_each = var.additional_policy_statements
    content {
      sid    = statement.value.sid
      effect = statement.value.effect
      principals {
        type        = "AWS"
        identifiers = statement.value.principal_arns
      }
      actions = statement.value.actions
    }
  }
}
