---
name: architecture-review
description: "Cross-checks ADRs, API contracts, data model, threat model and feature specs for consistency and feasibility before build; verifies stack facts against the stack reference. Read-only report with PASS / CONCERNS / FAIL. Run at the architecture→build gate."
argument-hint: "[full | adrs | contracts]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Task
model: opus
agent: technical-director
---

# Architecture Review

Read-only; writes nothing. The report goes to the chat.

## Phase 1: Collect
All `docs/architecture/adr-*.md`, `docs/architecture/api/*`, `data-model.md`, `threat-model.md`, `test-strategy.md`, `docs/specs/features/*.md`, `technical-preferences.md`, `stack-reference/index.md`.

## Phase 2: Checks
1. **Consistency**: ADRs do not contradict each other or technical-preferences; the contract covers the feature-spec operations; the data model covers the contract's data; the threat model covers the contract's surfaces (GraphQL/WS/uploads).
2. **ADR completeness**: Status/Options/Consequences/Verification; accepted ADRs are `Accepted`.
3. **Stack facts**: versions and claims in ADRs match the reference (e.g. three.js has no SemVer, Vue 3.6 is RC, GraphQL @defer is outside the spec).
4. **Feasibility**: performance budgets realistic; basic security measures present; the test strategy covers the levels.
5. In parallel via Task: `backend-lead`, `frontend-lead`, `security-lead` (and `game-lead` for games) — top 3 risks in their area.

## Phase 3: Report
Table "document → status → findings (BLOCKING/WARNING/INFO)", then the verdict `PASS` / `CONCERNS` / `FAIL` with reasons. Never change `stage.txt` — only recommend.

Next step: on PASS — `/create-stories`; otherwise the specific `/architecture-decision retrofit …` / `/api-contract`.
