# Consumer Proving Rail

This generated repository assumes a hosted-first proving model.

## Recommended topology

1. canonical repo on `{{ cookiecutter.default_branch }}`
2. optional same-owner fork for shared proving
3. optional personal fork for manual proving and remote worker routing

## Labels

- canonical repos: `standing-priority`
- forks: `fork-standing-priority`

## Hosted-first rule

Hosted Linux and hosted Windows workflows should be the authoritative proof
surfaces. Local/manual lanes can accelerate work, but they should not silently
replace hosted evidence.
