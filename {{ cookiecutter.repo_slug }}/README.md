# {{ cookiecutter.project_name }}

Generated from `LabviewGitHubCiTemplate`.

## Repository

- owner: `{{ cookiecutter.github_owner }}`
- slug: `{{ cookiecutter.repo_slug }}`
- default branch: `{{ cookiecutter.default_branch }}`
- execution profile: `{{ cookiecutter.execution_profile }}`

## Hosted Validation

This starter repository includes a hosted Linux lane and a hosted Windows lane
in `.github/workflows/validate.yml`.

The initial workflow is intentionally small so teams can add LabVIEW-specific
steps without first having to bootstrap a cross-OS GitHub Actions skeleton.

{% if cookiecutter.execution_profile == "hosted" -%}
The selected execution profile is `hosted`, so this generated repository does
not request Docker-profile outputs in this template revision.
Its `.github/comparevi/capabilities.json` manifest remains free of
Docker-specific capability requirements.
{% elif cookiecutter.execution_profile == "docker" -%}
The selected execution profile is `docker`, which records future Docker-profile
intent while this template revision still distributes the hosted proving
surface.
Its `.github/comparevi/capabilities.json` manifest records the Producer-published
Docker capability contract and the authoritative image-contract source at
`consumerContract.dockerImageContract`.
{% else -%}
The selected execution profile is `mixed`, which keeps the hosted proving
surface and records future Docker-profile intent for follow-up template slices.
Its `.github/comparevi/capabilities.json` manifest records the Producer-published
Docker capability contract and keeps the hosted surface metadata alongside it.
{% endif %}

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
{% if cookiecutter.execution_profile != "hosted" %}

## Docker Capability Contract

This generated repository also records the CompareVI Producer-owned Docker
capability contract in `.github/comparevi/capabilities.json`.

- capability id: `dockerProfile`
- authoritative image-contract source: `consumerContract.dockerImageContract`
- Producer contract owner: `LabVIEW-Community-CI-CD/compare-vi-cli-action`

Use a `comparevi_tools_consumer_pin` that publishes the Docker-profile
capability contract, such as `v0.6.4-rc.2` or later.
{% endif %}
