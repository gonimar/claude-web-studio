---
name: dev-story
description: "Implements a story end-to-end: loads spec/contract/ADR/rules, routes to the right engineers (Go/PHP/Node/GraphQL/Angular/Vue/three.js/DB), drives code + tests, runs checks, confirms each acceptance criterion. The core implementation skill — run after stories exist, before /code-review and /story-done."
argument-hint: "[story-path or S-NNN]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, AskUserQuestion
model: sonnet
---

# Dev Story

File writes and any mutation (git, deploy) happen only after an explicit "May I write?" / "Proceed?" → "yes"; delegated agents follow the same protocol.

```
/create-stories → /dev-story (this) → /code-review → /story-done
```

## Phase 1: Story
Argument or `production/session-state/active.md` (`Task:`); none — ask. Status must be Ready/In Progress.

## Phase 2: Context (read everything before starting)
The story; the feature spec (relevant sections); the contract (`schema.graphql`/openapi) — if the story changes the contract, run `/api-contract` first; ADRs; the data model; applicable `.claude/rules/*.md`; the stack reference for the story's languages; the test strategy. A missing ADR/contract for a story that needs one → `BLOCKED` naming what to run.

## Phase 3: Plan
Files to create/change, order, tests per criterion (table). Branch `feat/S-NNN-slug` (create with consent). Update `session-state/active.md` (Task/Branch/Next). Show the plan — "continue?".

## Phase 4: Implementation (via Task to the right engineers, by layer)
- Backend: `go-engineer` / `php-engineer` / `node-engineer`; GraphQL — `graphql-engineer`; DB — `database-engineer`.
- Frontend: `angular-engineer` / `vue-engineer`; styles — `css-engineer`.
- Game: `threejs-engineer` / `web-game-engineer` / `multiplayer-engineer`.
- Tests: the engineers themselves plus `test-engineer` for e2e.
Each gets the story context and the rule: show code before writing (the user approves), then run tests/lint with output.
Independent layers in parallel; dependent ones sequentially (contract → backend → frontend).

## Phase 5: Criteria check
Table "criterion → test → result (output)". Unmet ones explicitly. Lint/typecheck/dependency audit (if packages were added — health verified).

## Phase 6: Wrap-up
Update the story status (`Review`), session state (`Next: /code-review`). Commit on request, Conventional Commits.

Verdict: `COMPLETE` | `PARTIAL (open: …)` | `BLOCKED`. Next step: `/code-review --diff <story-path>`.
