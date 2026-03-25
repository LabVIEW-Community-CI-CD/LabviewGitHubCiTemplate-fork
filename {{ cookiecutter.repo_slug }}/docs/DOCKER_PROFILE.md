# Docker Profile

This generated repository includes a consumer-facing Docker workflow and
documentation scaffold.

It is distributed by `LabviewGitHubCiTemplate` and anchored to the Producer
contract published by `compare-vi-cli-action`.

## Distributed Surfaces

- workflow scaffold: `.github/workflows/docker-profile.yml`
- lane policy: `.github/comparevi/docker-lane-policy.json`
- capability manifest: `.github/comparevi/capabilities.json`
- authoritative image-contract source: `consumerContract.dockerImageContract`
- CompareVI.Tools pin: `{{ cookiecutter.comparevi_tools_consumer_pin }}`

## Selected Profile

- execution profile: `{{ cookiecutter.execution_profile }}`
- hosted surface retained: `{{ "true" if cookiecutter.execution_profile == "mixed" else "false" }}`

{% if cookiecutter.execution_profile == "docker" -%}
This render enables the Docker-profile scaffold without retaining a mixed-mode
hosted surface contract inside the Docker lane policy.
{% else -%}
This render keeps the hosted surface and also distributes the Docker-profile
scaffold.
{% endif %}

## Boundary

This scaffold does not make the generated repository a CompareVI runtime owner.

Keep these boundaries intact:

- `compare-vi-cli-action` publishes the runtime/tooling contracts
- `LabviewGitHubCiTemplate` distributes consumer-facing Docker metadata,
  workflow scaffolds, and documentation
- generated repositories consume the pinned release surface instead of
  vendoring CompareVI internals

## Consumer Rule

Use `.github/comparevi/capabilities.json` and
`.github/comparevi/docker-lane-policy.json` as the local source of truth for:

- requested execution profile
- pinned CompareVI.Tools release
- authoritative image-contract source
- whether the hosted surface remains retained

Resolve the actual Docker image contract from the pinned
`comparevi-tools-release.json` payload instead of inventing repository-local
image naming rules.
