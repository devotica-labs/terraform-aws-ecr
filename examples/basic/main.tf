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

# Uses local path during development.
# Change to Registry source after first release:
#   source  = "devotica-labs/ecr/aws"
#   version = "~> 0.1"

module "ecr" {
  source = "../.."

  # Repository name composes to: dvtca-sandbox-api
  namespace = "dvtca"
  stage     = "sandbox"
  name      = "api"

  # Fintech defaults cover the rest: IMMUTABLE tags, scan-on-push, KMS
  # encryption (aws/ecr key), force_delete off, and a lifecycle policy that
  # expires untagged images after 14 days and caps the repo at 100 images.

  tags = {
    Environment = "sandbox"
    Project     = "terraform-aws-ecr"
    Owner       = "platform@devotica.com"
    CostCenter  = "PLATFORM-OSS"
    ManagedBy   = "Terraform"
    Repo        = "https://github.com/devotica-labs/terraform-aws-ecr"
  }
}
