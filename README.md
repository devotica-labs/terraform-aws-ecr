# terraform-aws-ecr

[![CI](https://github.com/devotica-labs/terraform-aws-ecr/actions/workflows/ci.yml/badge.svg)](https://github.com/devotica-labs/terraform-aws-ecr/actions/workflows/ci.yml)
[![Release](https://github.com/devotica-labs/terraform-aws-ecr/actions/workflows/release.yml/badge.svg)](https://github.com/devotica-labs/terraform-aws-ecr/actions/workflows/release.yml)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)

> Part of the **Devotica** Terraform catalog. Follows the cloudposse module standard (README.yaml-driven docs, the `enabled`/`namespace`/`environment`/`stage`/`name`/`attributes`/`tags`/`label_order` label surface, `examples/complete`, Makefile targets) implemented **natively** — no external naming or build-harness dependencies.

## Introduction

Terraform module for one or more **Amazon ECR** private container repositories — the image registry that ECS Fargate and EKS pull from. It ships fintech-safe defaults and a batteries-included image-retention policy so a registry is secure and self-pruning out of the box.

Defaults are opinionated: **immutable tags** (a deployed digest is reproducible), **scan-on-push**, **KMS encryption**, **`force_delete` off**, and a **lifecycle policy** that expires untagged and surplus images while shielding release tags.

## Usage

```hcl
module "ecr" {
  source  = "devotica-labs/ecr/aws"
  version = "~> 0.1"

  namespace = "dvtca"
  stage     = "prod"
  name      = "api"          # repository → dvtca-prod-api

  # Cross-account: workload account pulls, CI/CD account pushes.
  read_principals  = [module.ecs_execution_role.arn]
  write_principals = ["arn:aws:iam::111122223333:role/github-actions-ecr-push"]

  # Fintech defaults cover encryption, scanning, immutability, and retention.
  tags = local.tags
}
```

A multi-repository registry with a customer-managed key and tuned retention:

```hcl
module "ecr" {
  source  = "devotica-labs/ecr/aws"
  version = "~> 0.1"

  namespace   = "dvtca"
  stage       = "prod"
  name        = "payments"
  image_names = ["payments/api", "payments/worker", "payments/migrations"]

  encryption_type = "KMS"
  kms_key_arn     = module.kms.key_arn

  max_image_count            = 200
  untagged_image_expiry_days = 7
  protected_tags             = ["prod", "release"]
}
```

See [`examples/basic`](examples/basic) and [`examples/complete`](examples/complete).

## Defaults that matter

| Setting | Default | Why |
|---------|---------|-----|
| `image_tag_mutability` | `IMMUTABLE` | A pushed tag can't be overwritten, so a deployed digest stays reproducible and auditable. |
| `scan_on_push` | `true` | Every image is vulnerability-scanned on push. |
| `encryption_type` | `KMS` | Images encrypted with KMS (supply `kms_key_arn` for a CMK; null uses `aws/ecr`). |
| `force_delete` | `false` | A repository holding images can't be destroyed by accident. |
| lifecycle policy | on | Expires untagged images after 14 days and caps the repo at 100 images; `protected_tags` are shielded. |

## How this fits the Devotica catalog

`terraform-aws-vpc` provisions the `ecr.api` / `ecr.dkr` interface endpoints; this module is the registry those endpoints reach. `terraform-aws-ecs-fargate` and `terraform-aws-eks-*` pull images from repositories created here — pass the workload execution role into `read_principals` and a CI role into `write_principals`.

## Makefile Targets

```
make fmt       # terraform fmt -recursive
make validate  # terraform init -backend=false && terraform validate
make test      # terraform test (unit + contract; integration needs AWS creds)
make readme    # regenerate the terraform-docs block below
```

<!-- BEGIN_TF_DOCS -->
<!-- terraform-docs regenerates this block via `make readme` / CI. Inputs and
     outputs are documented in variables.tf and outputs.tf. -->
<!-- END_TF_DOCS -->

## License

[Apache 2.0](LICENSE) © Devotica
