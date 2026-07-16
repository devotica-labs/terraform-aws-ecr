# Changelog

All notable changes to this module are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the module
follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Releases are cut automatically by `release-please` on merge to `main`,
driven by Conventional Commit prefixes (`feat:` → minor, `fix:`/`docs:`/`chore:` → patch,
`feat!:`/`BREAKING CHANGE:` → major).

## [Unreleased]

### Added

- Initial release: one or more Amazon ECR private repositories with fintech-safe
  defaults — IMMUTABLE tags, scan-on-push, KMS encryption, `force_delete` off —
  a batteries-included lifecycle policy (untagged expiry + image-count cap with
  `protected_tags`), and an optional repository access policy driven by
  `read_principals` / `write_principals` (+ an `additional_policy_statements`
  escape hatch). Native `label.tf` naming; derived from `cloudposse/terraform-aws-ecr`.
