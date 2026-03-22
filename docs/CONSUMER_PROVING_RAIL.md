# Consumer Proving Rail

`LabviewGitHubCiTemplate` is designed around a three-repository proving model:

1. canonical template repo
2. organization fork proving lane
3. personal fork proving lane

## Why

This keeps the canonical template stable while still giving maintainers and
agents space to run manual workflows, parallel consumer proof, and fork-specific
standing-priority work.

## Operating Model

- `LabVIEW-Community-CI-CD/LabviewGitHubCiTemplate`
  - canonical template source
  - owns template semantics and release direction
- `LabVIEW-Community-CI-CD/LabviewGitHubCiTemplate-fork`
  - organization proving rail
  - good for shared manual validation and fork-scoped CI exercises
- `svelderrainruiz/LabviewGitHubCiTemplate`
  - personal proving rail
  - good for manual dispatches, experimentation, and future remote-worker
    identity routing

## Current Proof Contract

- canonical template repo
  - `template-smoke` on `push`, `pull_request`, and `workflow_dispatch` is the
    authoritative template-self-validation surface
- consumer forks
  - keep fork `develop` aligned to canonical `develop`
  - treat `workflow_dispatch` on `template-smoke` from aligned `develop` as the
    currently supported fork consumer proof lane
  - treat fork-local `pull_request` proof as an active investigation, not a
    guaranteed signal, until
    [issue #10](https://github.com/LabVIEW-Community-CI-CD/LabviewGitHubCiTemplate/issues/10)
    is resolved
- generated consumers
  - remain the hosted-first proving target for downstream validation
  - should not inherit fork-only proving assumptions without explicit evidence

## Labels

- canonical repos should use `standing-priority`
- fork repos should prefer `fork-standing-priority`
- hosted-first CI should remain the authoritative proving plane
