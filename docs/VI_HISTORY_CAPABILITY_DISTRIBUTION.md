# VI History Capability Distribution

`LabviewGitHubCiTemplate` distributes `vi-history` as a lightweight capability
pack sourced from `compare-vi-cli-action`.

The canonical template remains a distributor, not a second owner of compare's
runtime stack.

## Roles

- `compare-vi-cli-action`
  - upstream producer for CompareVI.Tools and the `vi-history` capability
- `LabviewGitHubCiTemplate`
  - distributor that stamps capability and lineage metadata into generated repos
- generated repositories
  - consumers of the pinned release bundle and the distributed workflow/docs
    scaffold

## Distributed Surfaces

Generated repositories receive:

- `.github/comparevi/capabilities.json`
- `.github/comparevi/lineage.json`
- `.github/workflows/vi-history.yml`
- `docs/VI_HISTORY_CAPABILITY.md`
- canonical capability-manifest schema source:
  `LabVIEW-Community-CI-CD/LabviewGitHubCiTemplate/docs/schemas/labview-template-comparevi-capabilities-v1.schema.json`

For `docker` and `mixed` renders, `.github/comparevi/capabilities.json` also
records the Producer-published Docker capability contract pointer:

- capability id: `dockerProfile`
- authoritative image-contract source: `consumerContract.dockerImageContract`
- contract owner: `LabVIEW-Community-CI-CD/compare-vi-cli-action`

## Current Pin

The default upstream consumer pin is `v0.6.4`.

That pin is intentionally stored in the template prompt surface so future
template revisions can advance the pin without forcing downstream repos to copy
compare internals.

## Branch Roles

The distributor contract defines three lineage planes:

- `upstream/develop`
  - upstream producer-lineage intake
- `develop`
  - canonical integration branch in the template repo
- `downstream/develop`
  - descendant consumer-proving plane

Generated repositories inherit the same semantics, with their own selected
default branch substituted for the integration plane where needed.

## Design Boundary

The distributed `vi-history` scaffold is intentionally lightweight:

- release pin and capability metadata
- manual hosted workflow scaffold
- docs for consumers and descendants

It does not copy compare's runtime governor, merge queue logic, or heavy local
tooling surfaces into the generated repository.

Generated `validate.yml` now consumes the Producer-native `vi-history`
capability contract directly from the pinned CompareVI.Tools bundle before it
runs the hosted compare smoke.

The Docker capability entry now ships with a lane policy file, a manual Docker
workflow scaffold, and a consumer-facing Docker doc. Generated repositories
must still resolve the actual image contract from the pinned Producer release
surface instead of vendoring compare implementation content.
