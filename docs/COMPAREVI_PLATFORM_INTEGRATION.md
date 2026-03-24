# CompareVI Platform Integration

`LabviewGitHubCiTemplate` should help downstream consumers compose with the
CompareVI platform without copying platform ownership into the consumer repo.

## Ownership Boundary

- `compare-vi-cli-action`
  - owns CompareVI runtime/tooling orchestration
  - owns hosted Linux and Windows execution surfaces
  - owns release pins and capability contracts for CompareVI.Tools
- `LabviewGitHubCiTemplate`
  - distributes CompareVI capabilities into generated repositories
  - stamps lineage and capability manifests for descendants
  - keeps the consumer surface lightweight and workflow-driven
- `comparevi-history`
  - owns review bundle compilation and reviewer-facing rendering
  - owns pull-request diagnostics publication surfaces
- generated consumer repos
  - own their repository-specific triggers, docs, and proving decisions
  - should stay hosted-first
  - should not fork platform runtime logic into local scripts by default

## Branch-Role Semantics

When a generated repository adopts lineage-aware CompareVI distribution, keep
these branch roles explicit:

- `upstream/develop`
  - producer-lineage plane showing what arrived from the upstream producer
- `develop` or the generated repo's default branch
  - repository integration plane for local product work
- `downstream/develop`
  - descendant consumer-proving plane for future downstream reuse

The template distributes these roles as metadata first. Repositories can
materialize the extra branches when their own supply chain needs them.

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
3. use the distributed lineage and capability manifests as the local source of
   truth for `vi-history`
4. treat `execution_profile` as the generated consumer's declared proving mode:
   - `hosted`: no Docker-profile outputs in this template revision
   - `docker`: future Docker follow-up requested while hosted proof remains the
     current distributed surface
   - `mixed`: future Docker follow-up requested while hosted proof remains
     present
5. add comparevi integration as an opt-in lane after the baseline hosted
   workflow is healthy

This keeps the consumer template portable while still providing a clear path to
adopt the proven comparevi platform.
