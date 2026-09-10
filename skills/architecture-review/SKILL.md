---
name: architecture-review
description: "Cross-checks ADRs, API contracts, data model, threat model and feature specs for consistency and feasibility before build; verifies stack facts against the stack reference; `code` mode checks the repository itself against the ADRs, contract and threat model (module boundaries, dependencies, entry points, surfaces) and records drift as findings. Read-only report with PASS / CONCERNS / FAIL. Run at the architecture→build gate, quarterly, and on an adopted project."
argument-hint: "[full | adrs | contracts | code]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Task, AskUserQuestion
model: opus
agent: technical-director
---

# Architecture Review

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

Read-only; writes nothing. The report goes to the chat.

## Phase 1: Collect
All `docs/architecture/adr-*.md`, `docs/architecture/api/*`, `data-model.md`, `threat-model.md`, `test-strategy.md`, `docs/specs/features/*.md`, `technical-preferences.md`, `stack-reference/index.md`.

## Phase 2: Checks
1. **Consistency**: ADRs do not contradict each other or technical-preferences; the contract covers the feature-spec operations; the data model covers the contract's data; the threat model covers the contract's surfaces (GraphQL/WS/uploads).
2. **ADR completeness**: Status/Options/Consequences/Verification; accepted ADRs are `Accepted`.
3. **Stack facts**: versions and claims in ADRs match the reference (e.g. three.js has no SemVer, Vue 3.6 is RC, GraphQL @defer is outside the spec).
4. **Feasibility**: performance budgets realistic; basic security measures present; the test strategy covers the levels.
5. In parallel via Task: `backend-lead`, `frontend-lead`, `security-lead` (and `game-lead` for games) — top 3 risks in their area.
6. **`code` mode (brownfield, quarterly)** — the repository against the documents, from evidence in the tree, never from the documents' claims: module boundaries and dependency direction (`go list -deps` / import graphs / `composer` autoload / TS project references) vs the ADRs that name them; every entry point (routes, resolvers, handlers, WebSocket endpoints, cron/queue consumers, webhooks) vs the contract and the threat model's surfaces table — an entry point absent from both is a **BLOCKING** drift; runtime dependencies in the manifests vs the ADRs that admit them (a dependency no ADR names → WARNING with the ADR to write); migrations vs the data model; the deployment topology (compose, workflows) vs the deployment ADR. Each finding: `file:line`, the document it contradicts, the fix (`/architecture-decision`, `/api-contract`, `/threat-model <surface>`, or a code story). BLOCKING/HIGH findings go to `production/findings.md` (`ARCH-NNN`, behind the same record-or-story gate the audits use) so `/create-stories` and `/sprint-plan` read them.

## Phase 3: Report
Table "document → status → findings (BLOCKING/WARNING/INFO)", then the verdict `PASS` / `CONCERNS` / `FAIL` with reasons. Never change `stage.txt` — only recommend.

Next step — one `AskUserQuestion`: on PASS `/create-stories` (Recommended) · re-run the review after fixes · stop here; otherwise the specific `/architecture-decision retrofit …` / `/api-contract` (Recommended) · proceed with the CONCERNS recorded · stop here.
