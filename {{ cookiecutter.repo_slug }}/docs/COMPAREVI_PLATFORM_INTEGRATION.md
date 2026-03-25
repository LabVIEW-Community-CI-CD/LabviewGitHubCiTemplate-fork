# CompareVI Platform Integration

This generated repository should compose with the comparevi platform as a
consumer, not as a second runtime owner. The generated validation workflow now
resolves the authoritative CompareVI.Tools pin from the local capability
manifest and fails closed unless the released bundle exposes
`consumerContract.capabilities.viHistory`.

## Boundary

- `compare-vi-cli-action` owns runtime/tooling orchestration and released
  CompareVI.Tools assets
- `LabviewGitHubCiTemplate` distributed the `vi-history` capability into this
  repository as lightweight docs/workflow scaffolding
- `comparevi-history` owns reviewer-facing history bundle/render surfaces
- this repository should own only its consumer-specific workflow triggers,
  proving decisions, and documentation

## Distributed Capability

This repository inherits a distributed `vi-history` pack from the template.

Use these local surfaces as the consumer source of truth:

- `.github/comparevi/capabilities.json`
- `.github/comparevi/lineage.json`
- `.github/workflows/vi-history.yml`
- `docs/VI_HISTORY_CAPABILITY.md`

The distributed pin for CompareVI.Tools is
`{{ cookiecutter.comparevi_tools_consumer_pin }}`.

Generated `validate.yml` should stay lightweight while still consuming the
released CompareVI.Tools bundle through the distributed capability manifest:

1. read `.github/comparevi/capabilities.json`
2. resolve `authoritativeConsumerPin`
3. download `CompareVI.Tools-$pin.zip` from the released compare bundle
4. fail closed unless the manifest exposes `consumerContract.capabilities.viHistory`
5. run the hosted compare smoke against the same released producer-native pin

## Execution Profile

- selected profile: `{{ cookiecutter.execution_profile }}`
{% if cookiecutter.execution_profile == "hosted" -%}
- Docker-profile follow-up: not requested in this render
- Docker capability manifest entry: omitted in this render
- Docker workflow scaffold: omitted in this render
- Docker lane policy: omitted in this render
{% elif cookiecutter.execution_profile == "docker" -%}
- Docker-profile follow-up: requested in this render
- Docker capability manifest entry: `.github/comparevi/capabilities.json -> capabilities.dockerProfile`
- Docker workflow scaffold: `.github/workflows/docker-profile.yml`
- Docker lane policy: `.github/comparevi/docker-lane-policy.json`
- Docker execution doc: `docs/DOCKER_PROFILE.md`
- authoritative image-contract source: `consumerContract.dockerImageContract`
{% else -%}
- Docker-profile follow-up: requested alongside the hosted surface
- Docker capability manifest entry: `.github/comparevi/capabilities.json -> capabilities.dockerProfile`
- Docker workflow scaffold: `.github/workflows/docker-profile.yml`
- Docker lane policy: `.github/comparevi/docker-lane-policy.json`
- Docker execution doc: `docs/DOCKER_PROFILE.md`
- authoritative image-contract source: `consumerContract.dockerImageContract`
{% endif %}
- hosted Linux + hosted Windows remain the current distributed proof surface

{% if cookiecutter.execution_profile != "hosted" -%}
The Docker capability entry, lane policy, workflow scaffold, and execution doc
are distributor surfaces only.
Resolve the actual image contract from the pinned Producer-published
`comparevi-tools-release.json` payload instead of inventing repository-local
image naming rules or copying CompareVI runtime logic into this repository.
{% endif %}

## Branch Roles

When this repository adopts the full lineage model, treat these branches as the
role map:

- `upstream/develop`
  - upstream producer-lineage intake
- `{{ cookiecutter.default_branch }}`
  - repository integration and product authoring
- `downstream/develop`
  - downstream consumer proving for future descendants

## Reference Consumer

Use `LabVIEW-Community-CI-CD/labview-icon-editor-demo` on `develop` as the
reference downstream consumer example.

That reference shows the intended hosted-first relationship to the comparevi
platform without copying platform-owned runtime logic into the consumer repo.

## Adoption Rule

Treat comparevi integration as an opt-in lane:

1. keep the baseline hosted Linux and hosted Windows consumer workflow healthy
2. keep the distributed capability and lineage manifests current
3. pin released comparevi artifacts
4. add comparevi-specific proving only when the repository is ready for it
