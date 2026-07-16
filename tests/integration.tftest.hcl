# Integration tests — apply + assert + destroy. Requires real AWS credentials.
# A single empty repository is cheap and fast to create/destroy. force_delete is
# on so teardown is clean regardless of any images pushed during the run.

provider "aws" {
  region = "ap-south-1"
}

variables {
  namespace    = "dvtca"
  stage        = "integ"
  name         = "ecr"
  force_delete = true

  tags = {
    Environment = "integration-test"
    Ephemeral   = "true"
  }
}

run "apply_and_assert" {
  command = apply

  assert {
    condition     = one([for r in aws_ecr_repository.this : r.arn]) != ""
    error_message = "Repository must be created with an ARN."
  }
  assert {
    condition     = one([for r in aws_ecr_repository.this : r.repository_url]) != ""
    error_message = "Repository must expose a pull/push URL."
  }
  assert {
    condition     = length(aws_ecr_lifecycle_policy.this) == 1
    error_message = "Lifecycle policy must apply cleanly against the real API."
  }
}
