# LabviewGitHubCiTemplate

`LabviewGitHubCiTemplate` is the canonical BSD-3 licensed cookiecutter and
GitHub-template seed for hosted-first LabVIEW CI pipelines.

This repository is intended to be used in two ways:

1. As a GitHub template repository for maintainers who want a ready-made hosted
   Linux + Windows validation skeleton.
2. As a cookiecutter source for mass consumer bootstrapping from automation.

## What The First Revision Includes

- BSD-3 license at the root and in generated consumers
- `cookiecutter.json` prompts for repo identity, branch defaults, and
  execution-profile selection
- a generated starter project with:
  - `AGENTS.md`
  - `README.md`
  - `LICENSE`
  - `.gitignore`
  - issue templates
  - consumer proving rail docs
  - lineage and capability manifests for CompareVI integration
  - an opt-in `vi-history` distribution scaffold pinned to CompareVI.Tools
  - hosted Linux + Windows consumer-proving workflow
- a self-validation workflow that renders the template on both `ubuntu-latest`
  and `windows-latest`

## Quick Start

```bash
python -m pip install cookiecutter
cookiecutter https://github.com/LabVIEW-Community-CI-CD/LabviewGitHubCiTemplate.git
```

For unattended automation:

```bash
cookiecutter https://github.com/LabVIEW-Community-CI-CD/LabviewGitHubCiTemplate.git
  --no-input
  project_name="LabVIEW Hosted CI Sample"
  repo_slug="labview-hosted-ci-sample"
  github_owner="LabVIEW-Community-CI-CD"
  execution_profile="hosted"
  comparevi_tools_consumer_pin="v0.6.4-rc.2"
  enable_vi_history_capability="yes"
```

Supported `execution_profile` values:

- `hosted`
  - keep the generated repository hosted-first with no Docker-profile outputs
- `docker`
  - record Docker-profile intent for future follow-up slices while keeping the
    current hosted proving contract intact in this revision
- `mixed`
  - keep the hosted surface and record future Docker-profile intent in the
    generated consumer docs

## Canonical Operating Contract

This canonical repository is intentionally lightweight.
It should remain docs/workflow-driven and should not absorb comparevi platform
control-plane tooling unless it explicitly adopts that direction later.

Future agents should treat the canonical template repo this way:

- start from canonical `develop`
- inspect open issues first
- inspect the latest supported `template-smoke` state
- if no eligible issue exists, remain in monitoring mode
- if an eligible issue exists, use that issue as the top objective

Root repo agent entrypoints live in:

- `AGENTS.md`
- `AGENT_HANDOFF.txt`

Generated consumers still inherit their own `AGENTS.md`; the root files above
only govern the canonical template repository itself.

## Execution Profile Direction

This template now accepts an `execution_profile` input with these supported
values:

- `hosted`
- `docker`
- `mixed`

In this revision:

- `hosted` remains the default
- hosted Linux + hosted Windows stay the authoritative proving surfaces
- `docker` and `mixed` now stamp the Producer-published Docker capability
  contract into `.github/comparevi/capabilities.json`
- Docker workflow and lane-policy surfaces still stay in follow-up
  implementation slices
- `docker` and `mixed` currently record consumer intent without vendoring
  compare runtime logic into the template

## VI History Capability Distribution

This template now distributes `vi-history` as a lineage-aware CompareVI
capability.

The intended supply chain is:

1. `compare-vi-cli-action` publishes the upstream CompareVI release bundle
2. `LabviewGitHubCiTemplate` distributes the capability into generated repos
3. generated repos consume the pinned bundle without copying compare internals

Generated repositories now include:

- `.github/comparevi/capabilities.json`
- `.github/comparevi/lineage.json`
- `.github/workflows/vi-history.yml`
- `docs/VI_HISTORY_CAPABILITY.md`

Generated `validate.yml` now fails closed unless the pinned CompareVI.Tools
bundle exposes `consumerContract.capabilities.viHistory`, then runs the hosted
consumer smoke against the same released producer-native pin.

For `docker` and `mixed` renders, the capability manifest also records the
Producer-published Docker capability contract and
`authoritativeImageContractSource = consumerContract.dockerImageContract`.

The distributed lineage contract uses these branch-role semantics:

- `upstream/develop`: producer-lineage plane
- `develop` or the generated repo's default branch: repo integration plane
- `downstream/develop`: descendant consumer-proving plane

## Direction

This repository is the mass-consumer cookiecutter surface for hosted GitHub CI
bootstrapping. Heavy compare/runtime orchestration should remain in the
platform repos; this template should stay focused on portable consumer setup and
hosted proving lanes.

See [docs/CONSUMER_PROVING_RAIL.md](docs/CONSUMER_PROVING_RAIL.md) for the
canonical repo, organization-fork, and personal-fork operating model.

Current fork consumer proving guidance:

- keep fork `develop` aligned to canonical `develop`
- use manual `template-smoke` dispatches on aligned fork `develop` as the
  supported fork proof path
- treat fork-local `pull_request` proof as unsupported and do not reopen work
  from it by itself
- when the canonical template queue is empty, monitoring-only is the correct
  terminal state

See [docs/COMPAREVI_PLATFORM_INTEGRATION.md](docs/COMPAREVI_PLATFORM_INTEGRATION.md)
for the intended boundary between generated consumers and the comparevi
platform repos, and
[docs/VI_HISTORY_CAPABILITY_DISTRIBUTION.md](docs/VI_HISTORY_CAPABILITY_DISTRIBUTION.md)
for the canonical distributor contract.
