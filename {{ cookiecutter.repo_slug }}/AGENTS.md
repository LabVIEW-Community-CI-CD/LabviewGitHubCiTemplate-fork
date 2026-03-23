# Agent Handbook

This repository was generated from `LabviewGitHubCiTemplate`.

## Primary Directive

- Work the issue carrying the active standing label for the current repository
  context:
  - canonical/upstream: `standing-priority`
  - forks: `fork-standing-priority` with fallback to `standing-priority`
- Prefer hosted Linux and hosted Windows proving lanes.
- Treat local/manual execution as acceleration, not as the authoritative release
  surface.

## Branch Model

- default integration branch: `{{ cookiecutter.default_branch }}`
- `upstream/develop` represents upstream producer lineage when this repository
  participates in a lineage-aware supply chain
- `downstream/develop` represents descendant consumer proving when this
  repository later distributes capabilities to downstream consumers
- canonical repo owns template/product direction
- forks are proving lanes and should avoid long-lived drift from upstream

## Working Rules

- keep workflows portable across hosted Linux and hosted Windows
- keep generated docs and issue templates in sync with the proving model
- keep `.github/comparevi/capabilities.json` and `.github/comparevi/lineage.json`
  aligned with any future capability adoption
- prefer issue-driven work and visible acceptance criteria over ad hoc notes
