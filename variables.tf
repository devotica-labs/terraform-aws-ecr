# ---------------------------------------------------------------------------
# Repositories
# ---------------------------------------------------------------------------
variable "image_names" {
  type        = list(string)
  description = "Repository names to create. Empty (default) creates a single repository named after the composed label id. Provide a list for a multi-repo registry, e.g. [\"api\", \"worker\"]."
  default     = []
}

variable "image_tag_mutability" {
  type        = string
  description = "IMMUTABLE (recommended — a pushed tag can't be overwritten, so a deployed digest stays reproducible) or MUTABLE."
  default     = "IMMUTABLE"

  validation {
    condition     = contains(["IMMUTABLE", "MUTABLE"], var.image_tag_mutability)
    error_message = "image_tag_mutability must be IMMUTABLE or MUTABLE."
  }
}

variable "scan_on_push" {
  type        = bool
  description = "Run a vulnerability scan automatically when an image is pushed."
  default     = true
}

variable "force_delete" {
  type        = bool
  description = "Allow the repository to be deleted even if it still contains images. Fintech default is false — deleting a repo with images should be a deliberate act."
  default     = false
}

# ---------------------------------------------------------------------------
# Encryption
# ---------------------------------------------------------------------------
variable "encryption_type" {
  type        = string
  description = "KMS (recommended) or AES256. KMS with kms_key_arn=null uses the AWS-managed aws/ecr key; supply kms_key_arn for a customer-managed key."
  default     = "KMS"

  validation {
    condition     = contains(["KMS", "AES256"], var.encryption_type)
    error_message = "encryption_type must be KMS or AES256."
  }
}

variable "kms_key_arn" {
  type        = string
  description = "Customer-managed KMS key ARN used when encryption_type=KMS. Null uses the AWS-managed aws/ecr key. Ignored for AES256."
  default     = null

  validation {
    condition     = var.kms_key_arn == null || can(regex("^arn:aws[a-z-]*:kms:", var.kms_key_arn))
    error_message = "kms_key_arn must be a KMS ARN (arn:aws*:kms:...) or null."
  }
}

# ---------------------------------------------------------------------------
# Lifecycle policy
# ---------------------------------------------------------------------------
variable "enable_lifecycle_policy" {
  type        = bool
  description = "Attach a lifecycle policy that expires untagged / surplus images."
  default     = true
}

variable "max_image_count" {
  type        = number
  description = "Keep at most this many tagged images per repository; older ones beyond the count are expired. Images matching protected_tags are exempt."
  default     = 100

  validation {
    condition     = var.max_image_count >= 1
    error_message = "max_image_count must be at least 1."
  }
}

variable "untagged_image_expiry_days" {
  type        = number
  description = "Expire untagged images older than this many days. 0 disables the untagged-image rule."
  default     = 14

  validation {
    condition     = var.untagged_image_expiry_days >= 0
    error_message = "untagged_image_expiry_days must be 0 or greater."
  }
}

variable "protected_tags" {
  type        = list(string)
  description = "Tag prefixes shielded from the max_image_count rule (kept up to protected_tags_keep_count), e.g. [\"prod\", \"release\"]."
  default     = []
}

variable "protected_tags_keep_count" {
  type        = number
  description = "How many images to keep per protected tag prefix."
  default     = 100

  validation {
    condition     = var.protected_tags_keep_count >= 1
    error_message = "protected_tags_keep_count must be at least 1."
  }
}

# ---------------------------------------------------------------------------
# Repository access policy
# ---------------------------------------------------------------------------
variable "read_principals" {
  type        = list(string)
  description = "IAM principal ARNs granted pull (read) access via the repository policy — e.g. cross-account ECS/EKS execution roles."
  default     = []
}

variable "write_principals" {
  type        = list(string)
  description = "IAM principal ARNs granted push (write) access via the repository policy — e.g. CI/CD roles."
  default     = []
}

variable "additional_policy_statements" {
  type = list(object({
    sid            = string
    effect         = string
    actions        = list(string)
    principal_arns = list(string)
  }))
  description = "Escape hatch: extra repository-policy statements merged onto the generated read/write statements."
  default     = []
}
