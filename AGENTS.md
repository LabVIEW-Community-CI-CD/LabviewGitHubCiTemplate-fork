# Agent Handbook

This file is the bounded agent entrypoint for the canonical
`LabviewGitHubCiTemplate` repository.
Keep it short, stable, and focused on the contract future agents need.

## Primary Directive

- Work the issue carrying `standing-priority` in the canonical template repo.
- Start from canonical `develop`.
- Inspect open issues first.
- Inspect the latest supported `template-smoke` proof state before opening or
  refreshing work.
- Treat `queue-empty` as a valid monitoring state. If no eligible issue exists,
  do not invent new work.
- Consumer forks are proving rails, not the default working context.

## First Actions

1. Confirm you are on canonical `develop`.
2. Check open issues in `LabVIEW-Community-CI-CD/LabviewGitHubCiTemplate`.
3. Check the latest `template-smoke` state for:
   - canonical repo
   - `LabVIEW-Community-CI-CD/LabviewGitHubCiTemplate-fork`
   - `svelderrainruiz/LabviewGitHubCiTemplate`
4. If no eligible issue exists, remain in monitoring mode.
5. If an eligible issue exists, treat that issue as the top objective.

## Monitoring Contract

- canonical template repo open issues are the primary wake signal
- both consumer forks must stay aligned to canonical `develop`
- supported consumer proof is `workflow_dispatch` on `template-smoke` from
  aligned fork `develop`
- fork-local `pull_request` validation remains unsupported and must not reopen
  work by itself
- generated consumers inherit their own `AGENTS.md`; this root file governs the
  canonical template repo itself

## Working Rules

- keep the template repo lightweight and docs/workflow-driven
- do not import comparevi platform tooling into this repository unless the repo
  explicitly adopts it later
- prefer issue-driven work over ad hoc local notes
- keep hosted proving authoritative

## References

- `AGENT_HANDOFF.txt`
- `README.md`
- `docs/CONSUMER_PROVING_RAIL.md`
- `docs/COMPAREVI_PLATFORM_INTEGRATION.md`
