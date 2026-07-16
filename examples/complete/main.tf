# ---------------------------------------------------------------------------
# Provider block — CI-friendly skip flags + non-AWS-shaped placeholder creds.
# ---------------------------------------------------------------------------
provider "aws" {
  region                      = "ap-south-1"
  access_key                  = "not-a-real-aws-key"
  secret_key                  = "not-a-real-aws-secret"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

# A multi-repository registry for a service that ships several images, with a
# customer-managed KMS key, tuned image retention, and cross-account access:
# the workload account's ECS/EKS execution role may pull; the CI/CD role pushes.
module "ecr" {
  source = "../.."

  namespace = "dvtca"
  stage     = "prod"
  name      = "payments"

  # Registry holds three images (repo names composed from the label are not used
  # when image_names is set — these become the literal repository names).
  image_names = [
    "payments/api",
    "payments/worker",
    "payments/migrations",
  ]

  image_tag_mutability = "IMMUTABLE"
  scan_on_push         = true
  force_delete         = false

  # Customer-managed key instead of the AWS-managed aws/ecr key.
  encryption_type = "KMS"
  kms_key_arn     = "arn:aws:kms:ap-south-1:111122223333:key/00000000-0000-0000-0000-000000000000"

  # Retention: keep 200 images, expire untagged after 7 days, never expire
  # anything tagged prod-* or release-* (keep 300 of those).
  enable_lifecycle_policy    = true
  max_image_count            = 200
  untagged_image_expiry_days = 7
  protected_tags             = ["prod", "release"]
  protected_tags_keep_count  = 300

  # Cross-account: workload account pulls, CI/CD account pushes.
  read_principals  = ["arn:aws:iam::444455556666:role/ecs-task-execution"]
  write_principals = ["arn:aws:iam::111122223333:role/github-actions-ecr-push"]

  tags = {
    Environment = "prod"
    Project     = "terraform-aws-ecr"
    Owner       = "platform@devotica.com"
    CostCenter  = "PLATFORM-OSS"
    ManagedBy   = "Terraform"
    Repo        = "https://github.com/devotica-labs/terraform-aws-ecr"
  }
}
