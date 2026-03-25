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

## Capability Manifest Contract

Use `.github/comparevi/capabilities.json -> capabilities.dockerProfile` as the
machine-readable Docker manifest contract.

The canonical capability-manifest schema source is
`LabVIEW-Community-CI-CD/LabviewGitHubCiTemplate/docs/schemas/labview-template-comparevi-capabilities-v1.schema.json`.

That entry records:

- `authoritativeConsumerPin`
- `releaseAssetName`
- `releaseMetadataPath`
- `bundleImportPath`
- `authoritativeImageContractSource`
- `requestedExecutionProfile`
- `hostedSurfaceRetained`

Those fields tell the generated consumer which released CompareVI.Tools bundle
to trust and how to resolve the Producer-owned Docker image contract from the
same pinned release metadata.

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
- capability schema: `labview-template/comparevi-capabilities@v1`
- canonical capability-manifest schema source: `LabVIEW-Community-CI-CD/LabviewGitHubCiTemplate/docs/schemas/labview-template-comparevi-capabilities-v1.schema.json`
- lane-policy schema: `labview-template/docker-lane-policy@v1`
- canonical lane-policy schema source: `LabVIEW-Community-CI-CD/LabviewGitHubCiTemplate/docs/schemas/labview-template-docker-lane-policy-v1.schema.json`

Resolve the actual Docker image contract from the pinned
`comparevi-tools-release.json` payload instead of inventing repository-local
image naming rules.

## Workflow Receipt Contract

`.github/workflows/docker-profile.yml` emits a deterministic receipt so the
generated repository can prove which Docker contract surface it consumed.

- receipt helper: `.github/comparevi/Emit-DockerProfileReceipt.ps1`
- receipt path: `tests/results/docker-profile/docker-profile-plan.json`
- receipt schema: `labview-template/docker-profile-plan@v1`
- canonical schema source: `LabVIEW-Community-CI-CD/LabviewGitHubCiTemplate/docs/schemas/labview-template-docker-profile-plan-v1.schema.json`
- uploaded artifact name: `docker-profile-plan`

That receipt records:

- `requestedExecutionProfile`
- `authoritativeConsumerPin`
- `authoritativeImageContractSource`
- `hostedSurfaceRetained`
- `lanePolicyPath`
- `capabilityManifestPath`
- `integrationDocPath`
- `runtimeOwnership`
