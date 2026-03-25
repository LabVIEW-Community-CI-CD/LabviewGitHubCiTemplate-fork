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
The selected execution profile is `docker`, which keeps hosted proving
authoritative while also distributing the Docker workflow/documentation
scaffold for consumer adoption.
Its `.github/comparevi/capabilities.json` manifest records the Producer-published
Docker capability contract and the authoritative image-contract source at
`consumerContract.dockerImageContract`.
This render also includes:
- `.github/workflows/docker-profile.yml`
- `.github/comparevi/docker-lane-policy.json`
- `docs/DOCKER_PROFILE.md`
{% else -%}
The selected execution profile is `mixed`, which keeps the hosted proving
surface and also distributes the Docker workflow/documentation scaffold.
Its `.github/comparevi/capabilities.json` manifest records the Producer-published
Docker capability contract and keeps the hosted surface metadata alongside it.
This render also includes:
- `.github/workflows/docker-profile.yml`
- `.github/comparevi/docker-lane-policy.json`
- `docs/DOCKER_PROFILE.md`
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
{% if cookiecutter.execution_profile != "hosted" %}
- Docker workflow scaffold: `.github/workflows/docker-profile.yml`
- Docker lane policy: `.github/comparevi/docker-lane-policy.json`
- Docker execution doc: `docs/DOCKER_PROFILE.md`
{% endif %}

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
- release asset name: `CompareVI.Tools-{{ cookiecutter.comparevi_tools_consumer_pin }}.zip`
- release metadata path: `comparevi-tools-release.json`
- requested execution profile: `{{ cookiecutter.execution_profile }}`
- hosted surface retained: `{{ "true" if cookiecutter.execution_profile == "mixed" else "false" }}`
- Producer contract owner: `LabVIEW-Community-CI-CD/compare-vi-cli-action`
- workflow scaffold: `.github/workflows/docker-profile.yml`
- lane policy: `.github/comparevi/docker-lane-policy.json`
- execution doc: `docs/DOCKER_PROFILE.md`
- receipt helper: `.github/comparevi/Emit-DockerProfileReceipt.ps1`
- receipt artifact: `docker-profile-plan`
- receipt path: `tests/results/docker-profile/docker-profile-plan.json`

Use a `comparevi_tools_consumer_pin` that publishes the Docker-profile
capability contract, such as `v0.6.4-rc.2` or later.
{% endif %}
