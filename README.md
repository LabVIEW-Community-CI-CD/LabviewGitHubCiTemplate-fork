# LabviewGitHubCiTemplate

`LabviewGitHubCiTemplate` is the canonical BSD-3 licensed cookiecutter and
GitHub-template seed for hosted-first LabVIEW CI pipelines.

This repository is intended to be used in two ways:

1. As a GitHub template repository for maintainers who want a ready-made hosted
   Linux + Windows validation skeleton.
2. As a cookiecutter source for mass consumer bootstrapping from automation.

## What The First Revision Includes

- BSD-3 license at the root and in generated consumers
- `cookiecutter.json` prompts for repo identity and branch defaults
- a generated starter project with:
  - `AGENTS.md`
  - `README.md`
  - `LICENSE`
  - `.gitignore`
  - issue templates
  - consumer proving rail docs
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
```

## Direction

This repository is the mass-consumer cookiecutter surface for hosted GitHub CI
bootstrapping. Heavy compare/runtime orchestration should remain in the
platform repos; this template should stay focused on portable consumer setup and
hosted proving lanes.

See [docs/CONSUMER_PROVING_RAIL.md](docs/CONSUMER_PROVING_RAIL.md) for the
canonical repo, organization-fork, and personal-fork operating model.
