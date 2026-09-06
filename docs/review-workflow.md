# Reviews and Gates

## Review mode (`production/review-mode.txt`)
- `full` — every significant artefact passes a director/lead plus security (team).
- `lean` — lead plus security only for auth/data/network-touching work (default for solo work).
- `solo` — reviews on request; phase gates are advisory.

## Phase gates (advisory — the user decides)
| Transition | Who | Checks |
|---|---|---|
| discovery → specification | `product-director` | product spec complete, scope realistic, stack pinned |
| specification → architecture | `technical-director` | specs feasible, risks named |
| architecture → build | `technical-director` + `security-lead` | ADRs accepted, threat model exists, test strategy exists |
| build → hardening | `qa-lead` | stories closed with tests, no open blocking bugs |
| hardening → release | `security-lead` + `qa-lead` | audits without blocking findings, performance budgets met |

## Finding classification
- **BLOCKING** — vulnerability, data loss, violation of an accepted ADR, failing test.
- **WARNING** — deviation from a standard, missing test, tech debt with an estimate.
- **INFO** — style, improvement ideas.
Every finding: file:line, what is wrong, the risk, how to fix it.

## Git workflow
One story = one branch = one PR; the pipeline skills drive branch → commits → merge. Details and hook behaviour: `git-workflow.md`.
