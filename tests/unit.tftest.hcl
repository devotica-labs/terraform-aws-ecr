# Plan-only unit tests — no AWS credentials required. The repository policy
# resource validates its JSON, so mock aws_iam_policy_document to valid JSON.

mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

variables {
  namespace = "dvtca"
  stage     = "test"
  name      = "unit"
}

run "single_repository_by_default" {
  command = plan
  assert {
    condition     = length(aws_ecr_repository.this) == 1
    error_message = "Exactly one repository (named after the label) by default."
  }
}

run "fintech_defaults" {
  command = plan
  assert {
    condition     = one([for r in aws_ecr_repository.this : r.image_tag_mutability]) == "IMMUTABLE"
    error_message = "Image tags must be IMMUTABLE by default."
  }
  assert {
    condition     = one([for r in aws_ecr_repository.this : r.image_scanning_configuration[0].scan_on_push]) == true
    error_message = "scan_on_push must default to true."
  }
  assert {
    condition     = one([for r in aws_ecr_repository.this : r.encryption_configuration[0].encryption_type]) == "KMS"
    error_message = "encryption_type must default to KMS."
  }
  assert {
    condition     = one([for r in aws_ecr_repository.this : r.force_delete]) == false
    error_message = "force_delete must default to false."
  }
}

run "lifecycle_policy_on_by_default" {
  command = plan
  assert {
    condition     = length(aws_ecr_lifecycle_policy.this) == 1
    error_message = "A lifecycle policy must be attached by default."
  }
}

run "no_repository_policy_by_default" {
  command = plan
  assert {
    condition     = length(aws_ecr_repository_policy.this) == 0
    error_message = "No repository policy unless principals are supplied."
  }
}

run "multi_repository_from_image_names" {
  command = plan
  variables {
    image_names = ["api", "worker", "migrations"]
  }
  assert {
    condition     = length(aws_ecr_repository.this) == 3
    error_message = "One repository per image name."
  }
  assert {
    condition     = length(aws_ecr_lifecycle_policy.this) == 3
    error_message = "Lifecycle policy must attach to every repository."
  }
}

run "repository_policy_when_principals_supplied" {
  command = plan
  variables {
    read_principals  = ["arn:aws:iam::444455556666:role/ecs-task-execution"]
    write_principals = ["arn:aws:iam::111122223333:role/github-actions-ecr-push"]
  }
  assert {
    condition     = length(aws_ecr_repository_policy.this) == 1
    error_message = "A repository policy must be attached when principals are supplied."
  }
  assert {
    condition     = length(data.aws_iam_policy_document.repository) == 1
    error_message = "The policy document must render when principals are supplied."
  }
}

run "lifecycle_can_be_disabled" {
  command = plan
  variables {
    enable_lifecycle_policy = false
  }
  assert {
    condition     = length(aws_ecr_lifecycle_policy.this) == 0
    error_message = "No lifecycle policy when enable_lifecycle_policy = false."
  }
}

run "aes256_encryption_type" {
  command = plan
  variables {
    encryption_type = "AES256"
  }
  assert {
    condition     = one([for r in aws_ecr_repository.this : r.encryption_configuration[0].encryption_type]) == "AES256"
    error_message = "encryption_type must pass through as AES256 when selected."
  }
}
