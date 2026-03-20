# CompareVI Platform Integration

`LabviewGitHubCiTemplate` should help downstream consumers compose with the
CompareVI platform without copying platform ownership into the consumer repo.

## Ownership Boundary

- `compare-vi-cli-action`
  - owns CompareVI runtime/tooling orchestration
  - owns hosted Linux and Windows execution surfaces
  - owns release pins for CompareVI.Tools
- `comparevi-history`
  - owns review bundle compilation and reviewer-facing rendering
  - owns pull-request diagnostics publication surfaces
- generated consumer repos
  - own their repository-specific triggers, docs, and proving decisions
  - should stay hosted-first
  - should not fork platform runtime logic into local scripts by default

## Reference Consumer

Use `LabVIEW-Community-CI-CD/labview-icon-editor-demo` on `develop` as the
reference downstream consumer proof surface.

That repo is the right place to study how a consumer composes with:

- CompareVI.Tools release pins from `compare-vi-cli-action`
- reviewer-facing diagnostics from `comparevi-history`
- hosted proving lanes instead of self-hosted assumptions

## Template Guidance

Generated consumers should:

1. pin released platform artifacts instead of copying Docker/runtime helpers
2. keep hosted Linux and hosted Windows as the authoritative proving surfaces
3. add comparevi integration as an opt-in lane after the baseline hosted
   workflow is healthy

This keeps the consumer template portable while still providing a clear path to
adopt the proven comparevi platform.
