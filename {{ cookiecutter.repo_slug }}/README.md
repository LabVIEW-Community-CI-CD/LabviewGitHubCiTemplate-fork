# {{ cookiecutter.project_name }}

Generated from `LabviewGitHubCiTemplate`.

## Repository

- owner: `{{ cookiecutter.github_owner }}`
- slug: `{{ cookiecutter.repo_slug }}`
- default branch: `{{ cookiecutter.default_branch }}`

## Hosted Validation

This starter repository includes a hosted Linux lane and a hosted Windows lane
in `.github/workflows/validate.yml`.

The initial workflow is intentionally small so teams can add LabVIEW-specific
steps without first having to bootstrap a cross-OS GitHub Actions skeleton.

## CompareVI Integration

If this repository later opts into CompareVI diagnostics, start with
`docs/COMPAREVI_PLATFORM_INTEGRATION.md` and keep the platform/runtime boundary
intact instead of copying platform-owned scripts into the consumer repo.
