# CompareVI Platform Integration

`LabviewGitHubCiTemplate` should help downstream consumers compose with the
CompareVI platform without copying platform ownership into the consumer repo.
The generated consumer validation workflow now resolves the authoritative
CompareVI.Tools pin from the local capability manifest and fails closed unless
the released bundle exposes `consumerContract.capabilities.viHistory`.

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

Generated `validate.yml` should stay lightweight while still consuming the
released CompareVI.Tools bundle through the distributed capability manifest:

1. read `.github/comparevi/capabilities.json`
   - canonical capability-manifest schema source:
     `LabVIEW-Community-CI-CD/LabviewGitHubCiTemplate/docs/schemas/labview-template-comparevi-capabilities-v1.schema.json`
2. resolve `authoritativeConsumerPin`
3. download `CompareVI.Tools-$pin.zip` from the released compare bundle
4. fail closed unless the manifest exposes `consumerContract.capabilities.viHistory`
5. run the hosted compare smoke against the same released producer-native pin

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
   truth for `vi-history` and generated validation
4. for `docker` and `mixed`, read
   `.github/comparevi/capabilities.json -> capabilities.dockerProfile` as the
   template-distributed pointer to the Producer-owned image contract surface
5. treat `execution_profile` as the generated consumer's declared proving mode:
   - `hosted`: no Docker-profile outputs in this template revision
   - `docker`: Docker capability metadata, lane policy, workflow scaffold, and
     consumer documentation are distributed while hosted proof remains the
     current authoritative workflow surface
   - `mixed`: the hosted surface remains present while the Docker capability
     metadata, lane policy, workflow scaffold, and consumer documentation are
     also distributed
6. resolve the actual Docker image contract from the pinned
   `comparevi-tools-release.json` payload at
   `consumerContract.dockerImageContract`
7. treat `.github/comparevi/docker-lane-policy.json` and
   `.github/workflows/docker-profile.yml` as consumer-facing scaffolds, not as
   local ownership of CompareVI runtime logic
8. add comparevi integration as an opt-in lane after the baseline hosted
   workflow is healthy

This keeps the consumer template portable while still providing a clear path to
adopt the proven comparevi platform.
