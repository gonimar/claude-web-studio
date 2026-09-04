---
name: team-feature
description: "Orchestrates a full vertical slice for one feature: feature-spec check → API contract (GraphQL/REST) → data model → backend → frontend/game → tests → security review → code review, spawning the right leads and engineers in parallel where independent. Use to deliver a feature end-to-end."
argument-hint: "[F-NNN or feature name] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, AskUserQuestion
model: opus
---

# Team: Feature

Orchestration. File writes and any mutation (git, deploy) happen only after an explicit "May I write?" / "Proceed?" → "yes"; delegated agents follow the same protocol. A partial report on BLOCKED at any stage is mandatory.

## Phase 1: Readiness
A feature spec with criteria (missing → run `/feature-spec`); technical-preferences; review mode.

## Phase 2: Contract and data (in parallel)
`api-designer` (SDL/OpenAPI changes) ‖ `database-engineer` (schema/migrations). Results to the user for agreement; then codegen.

## Phase 3: Implementation
Backend (`go-engineer`/`php-engineer`/`node-engineer` + `graphql-engineer`) → once the contract is ready, in parallel frontend (`angular-engineer`/`vue-engineer`, `css-engineer`) and game (`threejs-engineer`/`web-game-engineer`) — the frontend may start on mocks from the contract. Engineers write the tests; e2e — `test-engineer`.

## Phase 4: Verification
`appsec-engineer` (mandatory for sensitive work, else per mode) ‖ `accessibility-specialist` (UI) ‖ `performance-engineer` (budget risk) — in parallel; then `/code-review --diff`.

## Phase 5: Summary
Table criteria ↔ tests ↔ results; open findings; propose `/story-done` per story and the PR.

Verdict: `COMPLETE` | `PARTIAL` | `BLOCKED (stage …)`. Next step: `/story-done` / `/release-checklist`.
