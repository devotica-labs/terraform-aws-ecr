# Contract tests — naming + the lifecycle-policy shape stay stable across versions.

mock_provider "aws" {}

variables {
  namespace = "dvtca"
  stage     = "test"
  name      = "contract"
}

run "repository_named_from_label" {
  command = plan
  assert {
    condition     = contains([for r in aws_ecr_repository.this : r.name], "dvtca-test-contract")
    error_message = "Repository name must compose namespace-stage-name."
  }
}

run "default_lifecycle_has_untagged_and_count_rules" {
  command = plan
  # Default: untagged-expiry rule + catch-all count rule = 2 rules.
  assert {
    condition     = length(jsondecode(one([for p in aws_ecr_lifecycle_policy.this : p.policy])).rules) == 2
    error_message = "Default lifecycle policy must contain exactly the untagged + count rules."
  }
}

run "protected_tags_add_rules_first" {
  command = plan
  variables {
    protected_tags = ["prod", "release"]
  }
  # 2 protected-tag rules + untagged + count = 4, protected first (priority 1..2).
  assert {
    condition     = length(jsondecode(one([for p in aws_ecr_lifecycle_policy.this : p.policy])).rules) == 4
    error_message = "Protected tags must add one rule each ahead of the count rule."
  }
  assert {
    condition     = jsondecode(one([for p in aws_ecr_lifecycle_policy.this : p.policy])).rules[0].selection.tagPrefixList[0] == "prod"
    error_message = "Protected-tag rules must be evaluated first (lowest priority)."
  }
}

run "untagged_rule_can_be_disabled" {
  command = plan
  variables {
    untagged_image_expiry_days = 0
  }
  # Only the catch-all count rule remains.
  assert {
    condition     = length(jsondecode(one([for p in aws_ecr_lifecycle_policy.this : p.policy])).rules) == 1
    error_message = "untagged_image_expiry_days = 0 must drop the untagged rule."
  }
}
