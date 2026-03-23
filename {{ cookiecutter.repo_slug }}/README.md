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

## Distributed VI History Capability

This generated repository includes a lightweight `vi-history` capability pack
distributed by `LabviewGitHubCiTemplate`.

- enabled: `{{ cookiecutter.enable_vi_history_capability }}`
- CompareVI.Tools pin: `{{ cookiecutter.comparevi_tools_consumer_pin }}`
- capability manifest: `.github/comparevi/capabilities.json`
- lineage manifest: `.github/comparevi/lineage.json`
- manual workflow scaffold: `.github/workflows/vi-history.yml`

Branch-role semantics for future lineage-aware automation are:

- `upstream/develop`: upstream producer lineage
- `{{ cookiecutter.default_branch }}`: repository integration
- `downstream/develop`: downstream consumer proving

See `docs/VI_HISTORY_CAPABILITY.md` for the distributed consumer contract.
