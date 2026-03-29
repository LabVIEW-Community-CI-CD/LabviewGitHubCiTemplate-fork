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
  - canonical `develop` branch protection now requires the full
    `template-smoke` matrix plus the canonical governance checks recorded in
    `docs/policy/develop-branch-protection.json`
  - canonical promotions should route through the checked-in `production`
    environment so human-gated release acknowledgement is explicit
- generated execution-profile contract
  - `hosted` is the default generated profile
  - `docker` and `mixed` are accepted template inputs
  - this revision keeps hosted proof authoritative while `docker` and `mixed`
    now distribute a Docker workflow/documentation scaffold for downstream
    adoption
  - the checked-in execution-profile governance proof contract lives in
    `docs/policy/docker-execution-profile-governance-surface.json`
  - the checked-in CompareVI capability-manifest schema lives in
    `docs/schemas/labview-template-comparevi-capabilities-v1.schema.json`
  - the checked-in Docker lane-policy schema for that scaffold lives in
    `docs/schemas/labview-template-docker-lane-policy-v1.schema.json`
  - the checked-in Docker receipt schema for that scaffold lives in
    `docs/schemas/labview-template-docker-profile-plan-v1.schema.json`
- consumer forks
  - keep fork `develop` aligned to canonical `develop`
  - treat `workflow_dispatch` on `template-smoke` from aligned `develop` as the
    supported fork consumer proof lane
  - a successful fork smoke run on drifted fork `develop` is still not
    supported consumer proof
  - treat fork-local `pull_request` proof as unsupported and never reopen work
    from it by itself
  - keep the checked-in fork proving contract in
    `docs/policy/supported-consumer-fork-proving.json` aligned with that rule
- generated consumers
  - remain the hosted-first proving target for downstream validation
  - should not inherit fork-only proving assumptions without explicit evidence

## Lineage-Aware Descendants

Generated consumers now receive a lightweight lineage contract alongside the
hosted proving skeleton.

That contract distinguishes:

- `upstream/develop`
  - upstream producer-lineage intake
- `develop` or the generated repo's default branch
  - integration and product authoring
- `downstream/develop`
  - future descendant consumer proving

The template distributes those roles as machine-readable metadata so a
generated repository can later become a producer for its own downstream
consumers without copying compare's control plane.

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
