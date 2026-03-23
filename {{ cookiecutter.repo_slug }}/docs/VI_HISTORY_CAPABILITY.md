# VI History Capability

This repository was generated with the template-distributed `vi-history`
capability pack.

## Current Contract

- enabled: `{{ cookiecutter.enable_vi_history_capability }}`
- CompareVI.Tools pin: `{{ cookiecutter.comparevi_tools_consumer_pin }}`
- upstream producer: `LabVIEW-Community-CI-CD/compare-vi-cli-action`
- distribution model: release bundle

## Local Surfaces

- capability manifest: `.github/comparevi/capabilities.json`
- lineage manifest: `.github/comparevi/lineage.json`
- manual workflow scaffold: `.github/workflows/vi-history.yml`

## Branch Roles

- `upstream/develop`
  - upstream producer-lineage intake
- `{{ cookiecutter.default_branch }}`
  - repository integration
- `downstream/develop`
  - downstream consumer-proving plane

## What The Workflow Does

The distributed workflow is intentionally lightweight.

It will:

1. read the local capability and lineage manifests
2. download the pinned CompareVI.Tools release bundle
3. verify the bundle checksum and release metadata
4. resolve the advertised consumer contract paths from the release metadata
5. emit a bootstrap receipt for repository-specific adoption

It does not copy compare's runtime governor or heavy local tooling into this
repository.

## Next Adoption Step

When this repository is ready for repository-specific VI-history proving, bind
`.github/workflows/vi-history.yml` to a real target VI path and the preferred
baseline/head refs for your own workflow policy.
