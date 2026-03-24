# Consumer Proving Rail

This generated repository assumes a hosted-first proving model.

## Recommended topology

1. canonical repo on `{{ cookiecutter.default_branch }}`
2. optional same-owner fork for shared proving
3. optional personal fork for manual proving and remote worker routing

## Execution Profile

- selected profile: `{{ cookiecutter.execution_profile }}`
{% if cookiecutter.execution_profile == "hosted" -%}
- current contract: hosted-only generated surface
{% elif cookiecutter.execution_profile == "docker" -%}
- current contract: hosted surface plus recorded future Docker follow-up intent
{% else -%}
- current contract: hosted surface plus recorded mixed-mode follow-up intent
{% endif %}
- authoritative proof surface in this revision: hosted Linux + hosted Windows

## Lineage Roles

This generated repository also carries a lightweight lineage contract.

- `upstream/develop`
  - upstream producer-lineage intake
- `{{ cookiecutter.default_branch }}`
  - repository integration and release direction
- `downstream/develop`
  - downstream consumer-proving plane for future descendants

## Labels

- canonical repos: `standing-priority`
- forks: `fork-standing-priority`

## Hosted-first rule

Hosted Linux and hosted Windows workflows should be the authoritative proof
surfaces. Local/manual lanes can accelerate work, but they should not silently
replace hosted evidence.
