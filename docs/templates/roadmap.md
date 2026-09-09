# <Project> — roadmap

<!-- roadmap-format: v3.1 · managed-by: web-studio · source-of-truth: file · ids: S- F- B- D- · board: none -->

> **Managed by:** Web Studio (`/create-stories`, `/sprint-plan`, `/story-done`, `/architecture-decision`); `/help` reads the first open item.
> **Source of truth:** this file. Board: none.
> **Updated:** YYYY-MM-DD · `/story-done S-002`

## Sprint 01 (YYYY-MM-DD → YYYY-MM-DD) — goal in one clause

<details>
<summary>closed · 2 stories — expand</summary>

- [x] [S-001](stories/F-001/S-001-project-skeleton.md) · Project skeleton and stack modernization 🏷 backend ~8h ⏱ 6h 🔗 [PR #1](https://github.com/<owner>/<repo>/pull/1)
- [x] [S-002](stories/F-001/S-002-graphql-contract.md) · GraphQL contract: gqlgen + codegen ⛔ [S-001](stories/F-001/S-001-project-skeleton.md) 🏷 backend/frontend ~10h ⏱ 9h 🔗 [PR #2](https://github.com/<owner>/<repo>/pull/2)
</details>

## Sprint 02 (YYYY-MM-DD → YYYY-MM-DD) — goal in one clause

- [ ] [S-003](stories/F-002/S-003-hot-reload-store.md) · Data store with hot reload ⏳ ⛔ [S-001](stories/F-001/S-001-project-skeleton.md), [ADR-0003](../docs/architecture/adr-0003-hot-reload-store.md) 🏷 backend ~10h 📅 YYYY-MM-DD → YYYY-MM-DD
- [ ] [S-004](stories/F-002/S-004-http-layer.md) · HTTP layer: timeouts, graceful shutdown 🔥 ⛔ [S-001](stories/F-001/S-001-project-skeleton.md) 🏷 backend ~10h

## Backlog

<details>
<summary>1 cancelled · 2 stories · 1 idea — expand</summary>

- [x] [S-005](stories/F-003/S-005-second-camera.md) · Second camera ❌ 🏷 infra
- [ ] [S-006](stories/F-004/S-006-lookup-api.md) · Lookup API ⛔ [S-004](stories/F-002/S-004-http-layer.md) 🏷 backend ~8h
- [ ] [S-007](stories/F-004/S-007-status-page.md) · Public status page 🅿 ⛔ [D-01](decisions.md#d-01) 🏷 frontend
- [ ] [F-003](backlog.md#f-003) · Feature idea before its spec, one line 🅿
</details>

## Docs

<!-- The blocks below are updated by the studio's commands (/story-done, /sprint-plan, /architecture-decision)
     together with the roadmap itself — never by hand, and never left to drift behind the lines above. -->

<details>
<summary><a href="stories/">production/stories/</a> — story cards: 2 Done</summary>

| | Story | Short | Status |
|---|---|---|---|
| ✅ | [S-001](stories/F-001/S-001-project-skeleton.md) | Project skeleton, stack modernization | Done · PR #1 |
| ✅ | [S-002](stories/F-001/S-002-graphql-contract.md) | GraphQL contract: gqlgen + codegen | Done · PR #2 |
</details>

<details>
<summary><a href="backlog.md">production/backlog.md</a> — no card yet: 1 idea</summary>

| | Item | Short |
|---|---|---|
| 💡 | [F-003](backlog.md#f-003) | Feature idea before its spec |
</details>

<details>
<summary><a href="decisions.md">production/decisions.md</a> — owner decisions: 1 open</summary>

| | Decision | Short | Date |
|---|---|---|---|
| ⬜ | [D-01](decisions.md#d-01) | Domain for the status page | open since YYYY-MM-DD |
| ✅ | [D-02](decisions.md#d-02) | CI platform — GitHub Actions | YYYY-MM-DD |
</details>

<details>
<summary><a href="sprints/">production/sprints/</a> — sprints: 1 closed</summary>

| | Sprint | Goal | Result |
|---|---|---|---|
| ✅ | [sprint-01](sprints/sprint-01.md) | Goal in one clause | S-001+S-002 Done · [qa-plan-01](sprints/qa-plan-01.md) |
</details>

<details>
<summary><a href="../docs/architecture/">docs/architecture/</a> — 1 ADR (Accepted) + threat model, test strategy, contract</summary>

| | Document | Short |
|---|---|---|
| ✅ | [ADR-0003](../docs/architecture/adr-0003-hot-reload-store.md) | Data store with hot reload |
| 📄 | [threat-model](../docs/architecture/threat-model.md) | STRIDE threats and mitigations |
| 📄 | [test-strategy](../docs/architecture/test-strategy.md) | Levels/tools, AC↔test map |
</details>

<details>
<summary><a href="../docs/specs/">docs/specs/</a> — product and features: 1 Approved</summary>

| | Spec | Short |
|---|---|---|
| ✅ | [product-spec](../docs/specs/product-spec.md) | Goals, users, scope, NFRs, risks |
</details>

<details>
<summary><a href="../docs/ops/">docs/ops/</a> — operational reports: 0</summary>

| | Report | Short |
|---|---|---|
</details>

## Legend

<details>
<summary>markers and format rules — expand</summary>

Task line: `- [ ] [ID](path) · Title` followed by markers in this order:

| Marker | Meaning |
|---|---|
| ⏳ | in progress |
| 🔥 · 🅿 | priority: now · later (no marker — next) |
| ❌ | cancelled (together with `[x]`) |
| ⛔ [S-NNN](path) · [ADR-NNNN](path) · [D-NN](path) · reason in words | waits for a story · a technical decision not yet accepted · an owner decision · an external blocker |
| 🏷 layer | backend · frontend · infra · docs · test · … combined with `/` |
| ~Nh · ⏱ Nh | estimate · actual, in hours |
| 📅 YYYY-MM-DD [→ YYYY-MM-DD] | target, or start → target |
| 🔗 [#N](url) · [PR #N](url) · [sha](url) | the issue, PR or commit where it was done |

Rules: an ID is stable forever and always an inline link `[ID](path)` — the address is file-relative to this
file's own directory (`production/roadmap.md`), never repo-root-relative, and tools maintain it, never hands ·
done lines are never deleted · new sprints go to the end · line order inside a sprint = priority · `[x]` only with
evidence (⏱ and/or 🔗) · dates are intentions · the roadmap references decisions by ID while they are open and never
restates them · details live in the story card (`production/stories/`), the decision register (`production/decisions.md`)
or the idea backlog (`production/backlog.md`) — the line carries only the title and markers · one heading level, no prose
between the heading and its list · a closed sprint, the Backlog and this Legend fold into `<details>` once there is
enough history to fold — an active sprint never does · a blank line always follows `<summary>`, or GitHub will not
render the markdown inside the block.

</details>
