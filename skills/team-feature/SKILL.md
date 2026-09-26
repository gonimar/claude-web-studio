---
name: team-feature
description: "Orchestrates a full vertical slice for one feature: feature-spec check → API contract (GraphQL/REST) → data model → backend → frontend/game → tests → security review → code review, spawning the right leads and engineers in parallel where independent. Use to deliver a feature end-to-end."
argument-hint: "[F-NNN or feature name] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, AskUserQuestion
model: opus
---

# Team: Feature

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

Orchestration. File writes and any mutation (git, deploy) happen only after an explicit "May I write?" / "Proceed?" — each one `AskUserQuestion` (proceed (Recommended) · show the draft/diff first · not now) → "yes". After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker). A partial report on BLOCKED at any stage is mandatory.

**Consent for delegated work is collected by this skill.** A subagent spawned through `Task` cannot ask the user. Before each `Task` batch, the "Proceed?" question names the agents and the files each will create or change; that answer covers those files. A specialist that needs to go beyond its brief (another file, a new dependency, a contract or schema change) stops and reports it, and the parent asks.

Agents below are spawned with a studio `subagent_type`: `web-studio:<name>` in plugin mode, `<name>` in copy mode. Commands are `/web-studio:<name>` in plugin mode and `/<name>` in copy mode; a bare `/code-review` in plugin mode runs Claude Code's built-in review, not the studio's (coordination-rules § Subagents).

## Phase 1: Readiness
A feature spec with criteria (missing → run `/feature-spec`); technical-preferences; review mode.

## Phase 2: Contract and data (in parallel)
`api-designer` (SDL/OpenAPI changes) ‖ `database-engineer` (schema/migrations). Results to the user for agreement; then codegen.

## Phase 3: Implementation
Backend (`go-engineer`/`php-engineer`/`node-engineer` + `graphql-engineer`) → once the contract is ready, in parallel frontend (`angular-engineer`/`vue-engineer`, `css-engineer`) and game (`threejs-engineer`/`web-game-engineer`) — the frontend may start on mocks from the contract. Engineers write the tests; e2e — `test-engineer`.

## Phase 4: Verification
`appsec-engineer` (mandatory for sensitive work, else per mode) ‖ `accessibility-specialist` (UI) ‖ `performance-engineer` (budget risk) — in parallel; then `/web-studio:code-review --diff` (copy mode `/code-review --diff`).

## Phase 5: Summary
Table criteria ↔ tests ↔ results; open findings; propose `/story-done` per story and the PR.

Verdict: `COMPLETE` | `PARTIAL` | `BLOCKED (stage …)`. Next step — one `AskUserQuestion`: `/story-done` per story (Recommended) · `/release-checklist` · fix the open findings first.
