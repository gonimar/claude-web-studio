---
name: team-feature
description: "Orchestrates a full vertical slice for one feature: feature-spec check → branch → API contract (GraphQL/REST) → data model → backend → frontend/game → tests → security review → commit and PR → code review, spawning the right leads and engineers in parallel where independent. Use to deliver a feature end-to-end."
argument-hint: "[F-NNN or feature name] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, Skill, AskUserQuestion
model: opus
---

# Team: Feature

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

Orchestration. File writes and any mutation (git, deploy) happen only after an explicit "May I write?" / "Proceed?" — each one `AskUserQuestion` (proceed (Recommended) · show the draft/diff first · not now) → "yes". After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker). A partial report on BLOCKED at any stage is mandatory.

**Consent for delegated work is collected by this skill.** A subagent spawned through `Task` cannot ask the user. Before each `Task` batch, the "Proceed?" question names the agents and the files each will create or change; that answer covers those files. A specialist that needs to go beyond its brief (another file, a new dependency, a contract or schema change) stops and reports it, and the parent asks.

Agents below are spawned with a studio `subagent_type`: `web-studio:<name>` in plugin mode, `<name>` in copy mode. Commands are `/web-studio:<name>` in plugin mode and `/<name>` in copy mode; a bare `/code-review` in plugin mode runs Claude Code's built-in review, not the studio's (coordination-rules § Subagents). **This skill runs another studio skill through the `Skill` tool**, one skill after another; the called skill keeps all of its phases and gates, and its verdict comes back as text this skill quotes. `‖` below means one `Task` batch of agents launched together — never two skills at once. In the commands below, `<hooks>` is `.claude/hooks/` in copy mode and `${CLAUDE_PLUGIN_ROOT}/hooks/` in plugin mode.

## Phase 1: Readiness
1. A feature spec with criteria — missing → run `/feature-spec` through the `Skill` tool and read its verdict line: continue only on `APPROVED`; `NEEDS REVISION` or `BLOCKED` → stop with `BLOCKED (stage 1: feature-spec <verdict>)` and the partial report (the spec's open points, nothing else started). Technical-preferences; `.claude/docs/git-workflow.md`.
2. **Review mode**: `--review` when given, else `production/review-mode.txt` (`lean` when neither exists). The mode scopes **reviews only** (review-workflow.md § Review mode) — the "Proceed?", "May I write?" and commit gates are asked in every mode:
   - `full` — Phase 5 runs every check: `appsec-engineer` ‖ `accessibility-specialist` (UI) ‖ `performance-engineer`, all three.
   - `lean` — `appsec-engineer` only when the slice touches auth, data or the network; `accessibility-specialist` when there is UI; `performance-engineer` when a budget is at risk.
   - `solo` — no review gates: Phase 5 runs only what the user picks in one `AskUserQuestion` (`appsec-engineer` (Recommended when the slice is security-sensitive) · `accessibility-specialist` · `performance-engineer` · none); nothing blocks the slice. `appsec-engineer` stays mandatory for security-sensitive paths in every mode (rule 6).
3. **Scope**: the stories the slice delivers (`production/stories/F-NNN/`). One story → the branch and the commit scope are `S-NNN`; several → `F-NNN`.

## Phase 2: Branch
Per `.claude/docs/git-workflow.md` (one story = one branch = one PR), as `/dev-story` Phase 3:
1. One `AskUserQuestion`: branch `feat/<scope>-<slug>` from an up-to-date default branch and start (Recommended) · stay on the current branch `<name>` (it already belongs to this slice) · stop. The "start" answer is the consent for the branch and the session-state update.
2. `git fetch origin`. If the current branch is the default branch, or is already merged into `origin/<default>` (`git merge-base --is-ancestor HEAD origin/<default>`): `git switch <default> && git pull --ff-only origin <default>`. Never continue on a merged branch.
3. `git switch -c feat/<scope>-<slug>`.
4. Record the start through the studio's writer: `<hooks>session-state.sh set Task "F-NNN …" Branch feat/<scope>-<slug> Next "/code-review --diff"`.
5. **Stamp the story cards** (as `/dev-story` Phase 3 step 5): on the metadata line of every story card the slice implements (`production/stories/F-NNN/S-NNN-*.md`), set `Status: In Progress` and write `Started: YYYY-MM-DDTHH:MM` with the actual time — `/story-done` measures the story's actual duration from it and refuses a card that never left `Ready`. The "start" answer of step 1 covers these edits; the cards ride the slice's `feat(<scope>)` commit in Phase 6 (staged by name), so the stamp never lands on the default branch by itself.

## Phase 3: Contract and data (in parallel)
`api-designer` (SDL/OpenAPI changes) ‖ `database-engineer` (schema/migrations) — one `Task` batch after the "Proceed?" question. Results to the user for agreement; then codegen. A `BLOCKED` from either agent (e.g. `database-engineer` cannot migrate without a decision) is surfaced at once with a partial report; the slice does not continue on a guessed contract or schema.

## Phase 4: Implementation
Backend (`go-engineer`/`php-engineer`/`node-engineer` + `graphql-engineer`) → once the contract is ready, in parallel frontend (`angular-engineer`/`vue-engineer`, `css-engineer`) and game (`threejs-engineer`/`web-game-engineer`) — the frontend may start on mocks from the contract. Engineers write the tests; e2e — `test-engineer`. Product code and tests are written by these Tier-3 engineers, never by this skill (coordination-rules § Subagents).

## Phase 5: Verification
Per the review mode of Phase 1: `appsec-engineer` (mandatory for sensitive work, else per mode) ‖ `accessibility-specialist` (UI) ‖ `performance-engineer` (budget risk) — one `Task` batch. Findings go to the engineers of Phase 4 for fixes (with consent); open findings are listed in Phase 7. The code review itself runs after the commit, as the hand-off below.

## Phase 6: Commit and PR
As `/dev-story` Phase 6 (git-workflow, step "Implement"):
1. **Status.** On every story card stamped in Phase 2 set `Status: Review` (as `/dev-story` Phase 6 step 1 — `/story-done` requires it), and the session state to `Next: /code-review --diff` through `<hooks>session-state.sh`; the Phase 2 "start" answer covers this edit, and the card rides the commit below.
2. **Commit gate**, one `AskUserQuestion`: commit and push (Recommended) · commit only · not now. Before asking, record it — `<hooks>session-state.sh set Gate "/team-feature Phase 6: commit?"` — and clear it after the answer (`<hooks>session-state.sh set Gate "—"`), so an open gate survives the next turn (rule 7).
3. **Stage by name.** Read `git status --short` first and deal with every unplanned `??` entry (delete a spike, add a file deliberately if it belongs to the slice, otherwise leave it and name it); the story cards of Phase 2 are among the slice's files. Never `git add -A`.
4. `git commit -m "feat(<scope>): <feature title>"` (`feat(S-NNN): …` for one story, `feat(F-NNN): …` for several), then `git push -u origin feat/<scope>-<slug>`. Never commit on the default branch.
5. **Find out what starts CI** (`grep -l "pull_request" .github/workflows/*.yml`, each workflow's `on:`). When only `pull_request` starts the checks, open the PR as a draft in this step (`gh pr create --draft --fill`) so they run during review; `/story-done` marks it ready and merges it. Otherwise say which run to expect and its id.
6. **Wait for CI** only for a run that exists: one background `gh run watch <run-id> --exit-status`; no polling, no `AskUserQuestion` as a pause.

## Phase 7: Summary
Table criteria ↔ tests ↔ results; open findings; the branch, the commit and the PR (or why there is none); propose the code review, then `/story-done` per story.

Verdict: `COMPLETE` | `PARTIAL` | `BLOCKED (stage 1: feature-spec <verdict>)` | `BLOCKED (stage …)`. Next step — one `AskUserQuestion`: `/web-studio:code-review --diff` (copy mode `/code-review --diff`) — then `/story-done` per story (Recommended on COMPLETE) · commit first (when Phase 6 was declined) · `/story-done` per story (when the review already passed) · `/release-checklist` · fix the open findings first. Run the next skill only on that answer.
