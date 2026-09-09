# Reviews and Gates

## Review mode (`production/review-mode.txt`)
- `full` — every significant artefact passes a director/lead plus security (team).
- `lean` — lead plus security only for auth/data/network-touching work (default for solo work).
- `solo` — reviews on request; phase gates are advisory. **Scope: reviews only.** No review mode
  skips the pipeline itself: `/start` (or `/adopt`), the specs and the catalog's required steps
  (threat model, test strategy, game concept for a game) still run — solo means nobody blocks the
  merge, not "code straight after /init".

## Phase gates (advisory — the user decides)
| Transition | Who | Checks |
|---|---|---|
| discovery → specification | `product-director` | product spec complete, scope realistic, stack pinned |
| specification → architecture | `technical-director` | specs feasible, risks named |
| architecture → build | `technical-director` + `security-lead` | ADRs accepted, threat model exists, test strategy exists |
| build → hardening | `qa-lead` | stories closed with tests, no open blocking bugs |
| hardening → release | `security-lead` + `qa-lead` | audits without blocking findings, performance budgets met |

## Change classes (`/impact`)
A proposal from the conversation is classified before code; only the triggered classes are verified, in parallel, by their owner. Evidence, not wording, claims a class.

| Class | Trigger (evidence) | Verifier | Commands after the verdict |
|---|---|---|---|
| architecture | an ADR names or contradicts it; a boundary/module owner moves; stack or pinned version; API contract; data model/migration; a new runtime dependency; deployment topology | `technical-director` | `/architecture-decision` → `/api-contract` / `/data-model` → `/create-stories` |
| security | a threat-model surface; a `security-sensitive` path; auth/session/authorisation; PII, secrets, tokens; CI permissions; network/proxy/TLS; uploads, webhooks, WebSocket | `security-lead` (veto) | `/threat-model` → security section of the spec → `/create-stories` |
| product | user-visible behaviour absent from the feature spec; a changed acceptance criterion; scope the product spec lists as out | `product-director` | `/feature-spec` → `/create-stories` |
| routine | none of the above, or inside the active story's criteria | — | `/dev-story` |

Mode: `full` — every triggered class; `lean` — architecture and security, product as classification only unless asked; `solo` — classification shown, verification on request. A verdict is ≤ 15 lines and names the commands in pipeline order; `BLOCKED` is surfaced immediately.

## Finding classification
- **BLOCKING** — vulnerability, data loss, violation of an accepted ADR, failing test.
- **WARNING** — deviation from a standard, missing test, tech debt with an estimate.
- **INFO** — style, improvement ideas.
Every finding: file:line, what is wrong, the risk, how to fix it.

## Git workflow
One story = one branch = one PR; the pipeline skills drive branch → commits → merge. Details and hook behaviour: `git-workflow.md`.
