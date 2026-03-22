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
  - uses `standing-priority`
  - open issues are the primary wake signal
- `LabVIEW-Community-CI-CD/LabviewGitHubCiTemplate-fork`
  - organization proving rail
  - good for shared manual validation and fork-scoped CI exercises
  - should stay aligned to canonical `develop`
- `svelderrainruiz/LabviewGitHubCiTemplate`
  - personal proving rail
  - good for manual dispatches, experimentation, and future remote-worker
    identity routing
  - should stay aligned to canonical `develop`

## Current Proof Contract

- canonical template repo
  - `template-smoke` on `push`, `pull_request`, and `workflow_dispatch` is the
    authoritative template-self-validation surface
- consumer forks
  - keep fork `develop` aligned to canonical `develop`
  - treat `workflow_dispatch` on `template-smoke` from aligned `develop` as the
    supported fork consumer proof lane
  - treat fork-local `pull_request` proof as unsupported and never reopen work
    from it by itself
- generated consumers
  - remain the hosted-first proving target for downstream validation
  - should not inherit fork-only proving assumptions without explicit evidence

## Monitoring Mode

When the canonical template repo has no eligible open issue, monitoring-only is
correct.
In that state:

- do not invent new work
- continue treating canonical open issues as the primary wake signal
- continue treating fork alignment plus supported `workflow_dispatch`
  `template-smoke` results as the consumer proving signal
- allow future agents arriving from compare-side pivot proof to start in the
  canonical template repo and remain idle here if no eligible issue exists

## Labels

- canonical repos should use `standing-priority`
- fork repos should prefer `fork-standing-priority`
- hosted-first CI should remain the authoritative proving plane
