# Changelog

All notable changes to this module are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the module
follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Releases are cut automatically by `release-please` on merge to `main`,
driven by Conventional Commit prefixes (`feat:` → minor, `fix:`/`docs:`/`chore:` → patch,
`feat!:`/`BREAKING CHANGE:` → major).

## 0.1.0 (2026-07-16)


### Features

* **ci:** add architecture-diagram workflow + renderer ([7d5ad61](https://github.com/devotica-labs/terraform-aws-ecr/commit/7d5ad611850ea95d2f0d890bfceafc995eedc070))
* initial release of terraform-aws-ecr ([e07b672](https://github.com/devotica-labs/terraform-aws-ecr/commit/e07b6723df910cfb233b2fae1845e3f8ba6c1682))


### Bug Fixes

* **ci:** drop dead pip/scripts dependabot entry; tflint clean ([f2e46c0](https://github.com/devotica-labs/terraform-aws-ecr/commit/f2e46c06e51e9b5701c77461d774505d1163c1b6))

## [Unreleased]

### Added

- Initial release: one or more Amazon ECR private repositories with fintech-safe
  defaults — IMMUTABLE tags, scan-on-push, KMS encryption, `force_delete` off —
  a batteries-included lifecycle policy (untagged expiry + image-count cap with
  `protected_tags`), and an optional repository access policy driven by
  `read_principals` / `write_principals` (+ an `additional_policy_statements`
  escape hatch). Native `label.tf` naming; derived from `cloudposse/terraform-aws-ecr`.
