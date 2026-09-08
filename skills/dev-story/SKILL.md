---
name: dev-story
description: "Implements a story end-to-end: loads spec/contract/ADR/rules, routes to the right engineers (Go/PHP/Node/GraphQL/Angular/Vue/three.js/DB), drives code + tests, runs checks, confirms each acceptance criterion. The core implementation skill — run after stories exist, before /code-review and /story-done."
argument-hint: "[story-path or S-NNN]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, AskUserQuestion
model: sonnet
---

# Dev Story

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

File writes and any mutation (git, deploy) happen only after an explicit "May I write?" / "Proceed?" → "yes", asked as an `AskUserQuestion` with the recommended action first and the real alternatives (coordination-rules, rule 7); delegated agents follow the same protocol.

```
/create-stories → /dev-story (this) → /code-review → /story-done
```

## Phase 1: Story
Argument or `production/session-state/active.md` (`Task:`); none — ask. Status must be Ready/In Progress.
No `production/sprints/sprint-*.md` covers this story while the backlog holds more than three Ready
stories → say so before the plan question and include `/sprint-plan` in its options (Recommended for
the first story of a fresh backlog): the sprint layer must not be reachable only by the owner's memory.

## Phase 2: Context (read everything before starting)
**Architecture prerequisites first** — regardless of how the project entered `build` (brownfield
projects start there with the architecture phase unwalked): `docs/architecture/threat-model.md` and
`docs/architecture/test-strategy.md` must exist — the catalog marks both `required`. Either missing →
`BLOCKED (architecture prerequisites unmet — run /threat-model | /test-setup first)`; name only the
missing ones, never loop a question about it. Then read: the story; the feature spec (relevant
sections); the contract (`schema.graphql`/openapi) — if the story changes the contract, run
`/api-contract` first; ADRs; the data model; applicable `.claude/rules/*.md`; the stack reference for
the story's languages; the test strategy. A missing ADR/contract for a story that needs one →
`BLOCKED` naming what to run.

## Phase 3: Plan and branch
Files to create/change, order, tests per criterion — **the table rendered in the chat message** before the plan question (rule 7: readable rendering, on updates too). Branch per `.claude/docs/git-workflow.md`: `git fetch origin`; if the current branch is the default branch or is already merged into `origin/<default>` (session-start prints "no commits beyond"), `git switch <default> && git pull --ff-only`; then `git switch -c feat/S-NNN-slug` — with consent. Never continue on a merged branch. Update `session-state/active.md` (Task/Branch/Next). Show the plan, then one `AskUserQuestion`: continue (Recommended) · change the plan (say what) · stop.

## Phase 4: Implementation (via Task to the right engineers, by layer)
- Backend: `go-engineer` / `php-engineer` / `node-engineer`; GraphQL — `graphql-engineer`; DB — `database-engineer`.
- Frontend: `angular-engineer` / `vue-engineer`; styles — `css-engineer`.
- Game: `threejs-engineer` / `web-game-engineer` / `multiplayer-engineer`.
- Tests: the engineers themselves plus `test-engineer` for e2e.
Each gets the story context and the rule: show code before writing (the user approves), then run tests/lint with output.
Independent layers in parallel; dependent ones sequentially (contract → backend → frontend).

## Phase 5: Criteria check
Table "criterion → test → result (output)". Unmet ones explicitly. Lint/typecheck/dependency audit (if packages were added — health verified).

## Phase 6: Wrap-up and commit
Update the story status (`Review`), session state (`Next: /code-review`). Then, with consent as one `AskUserQuestion` — commit and push (Recommended) · commit only · not now (`git-workflow.md`, step "Implement"): stage the story's files, `git commit -m "feat(S-NNN): <story title>"`, `git push -u origin feat/S-NNN-slug`. Never commit on the default branch.

Verdict: `COMPLETE` | `PARTIAL (open: …)` | `BLOCKED`. Next step — one `AskUserQuestion`, never a bare "run /code-review?": `/code-review --diff <story-path>` (Recommended on COMPLETE) · commit first (when Phase 6 was declined) · show the diff · stop here. Run the next skill only on that answer.
