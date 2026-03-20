# CompareVI Platform Integration

This generated repository should compose with the comparevi platform as a
consumer, not as a second runtime owner.

## Boundary

- `compare-vi-cli-action` owns runtime/tooling orchestration and released
  CompareVI.Tools assets
- `comparevi-history` owns reviewer-facing history bundle/render surfaces
- this repository should own only its consumer-specific workflow triggers,
  proving decisions, and documentation

## Reference Consumer

Use `LabVIEW-Community-CI-CD/labview-icon-editor-demo` on `develop` as the
reference downstream consumer example.

That reference shows the intended hosted-first relationship to the comparevi
platform without copying platform-owned runtime logic into the consumer repo.

## Adoption Rule

Treat comparevi integration as an opt-in lane:

1. keep the baseline hosted Linux and hosted Windows consumer workflow healthy
2. pin released comparevi artifacts
3. add comparevi-specific proving only when the repository is ready for it
