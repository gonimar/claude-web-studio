---
name: team-game
description: "Delivers a playable web-game slice: game-concept check → engine ADR → branch → simulation + rendering (three.js/Pixi) + UI overlay (Angular/Vue) + optional multiplayer (Go server) in parallel → frame-budget measurement → accessibility settings → commit and PR → review. Use to build the prototype or a game feature."
argument-hint: "[prototype | feature F-NNN]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, Skill, AskUserQuestion
model: opus
agent: game-lead
---

# Team: Game

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

File writes and any mutation (git, deploy) happen only after an explicit "May I write?" / "Proceed?" — each one `AskUserQuestion` (proceed (Recommended) · show the draft/diff first · not now) → "yes". After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker). A partial report on BLOCKED at any stage is mandatory.

**Consent for delegated work is collected by this skill.** A subagent spawned through `Task` cannot ask the user. Before each `Task` batch, the "Proceed?" question names the agents and the files each will create or change; that answer covers those files. A specialist that needs to go beyond its brief (another file, a new dependency, a protocol or schema change) stops and reports it, and the parent asks.

Agents below are spawned with a studio `subagent_type`: `web-studio:<name>` in plugin mode, `<name>` in copy mode. Commands are `/web-studio:<name>` in plugin mode and `/<name>` in copy mode; a bare `/code-review` in plugin mode runs Claude Code's built-in review, not the studio's (coordination-rules § Subagents). **This skill runs another studio skill through the `Skill` tool**, one skill after another; the called skill keeps all of its phases and gates, and its verdict comes back as text this skill quotes. `‖` below means one `Task` batch of agents launched together — never two skills at once.

## Phase 1: Readiness
`docs/specs/game-concept.md` (missing → `/game-concept` through the `Skill` tool, then continue); the engine ADR (missing → `/architecture-decision` through the `Skill` tool); **budgets** in technical-preferences (frame time, draw calls, memory, load on 4G emulation) — quote them, they are the yardstick of Phase 4; `.claude/docs/git-workflow.md`. **Scope**: `prototype` → branch and commit scope `prototype`; `feature F-NNN` → the story `S-NNN` when the slice is one story, else `F-NNN`. **Multiplayer** (the concept or the feature is networked) → the protocol comes first: `api-designer` in Phase 3 before `multiplayer-engineer` starts.

## Phase 2: Branch
Per `.claude/docs/git-workflow.md` (one story = one branch = one PR), as `/dev-story` Phase 3:
1. One `AskUserQuestion`: branch `feat/<scope>-<slug>` from an up-to-date default branch and start (Recommended) · stay on the current branch `<name>` (it already belongs to this slice) · stop. The "start" answer is the consent for the branch and the session-state update.
2. `git fetch origin`. If the current branch is the default branch, or is already merged into `origin/<default>` (`git merge-base --is-ancestor HEAD origin/<default>`): `git switch <default> && git pull --ff-only origin <default>`. Never continue on a merged branch.
3. `git switch -c feat/<scope>-<slug>`.
4. Record the start through the studio's writer: `<hooks>session-state.sh set Task "<slice> …" Branch feat/<scope>-<slug> Next "/code-review --diff"`.

## Phase 3: Parallel implementation
`web-game-engineer` (simulation, loop, input, audio, saves) ‖ `threejs-engineer` or `web-game-engineer` (rendering) ‖ `angular-engineer`/`vue-engineer` (UI overlay/menus from the UX spec) ‖ `multiplayer-engineer` + `go-engineer` (if networked; protocol via `api-designer` first) — one `Task` batch after the "Proceed?" question. Product code and tests are written by these Tier-3 engineers, never by this skill (coordination-rules § Subagents).

## Phase 4: Measurements and accessibility
`performance-engineer` (frame, draw calls, memory, load on 4G emulation) ‖ `accessibility-specialist` (menus, settings) — one `Task` batch. The measurements are written to `docs/ops/measurements/YYYY-MM-DD-<topic>.md` (rule 12: a number cites an artefact) — the file is named in the "Proceed?" question.
**Budget exceeded**: every measured number is compared with its budget from Phase 1. Any number over budget → the verdict is `PARTIAL (over budget: frame 22 ms > 16.7 ms, draw calls 410 > 300, …)` with the measured value, the budget and the measurement file for each — never a `PLAYABLE` that hides the numbers, never a silent skip when a measurement could not be taken (then: `PARTIAL (not measured: …)`). The fixes go to the Phase 3 engineers as a new `Task` batch with consent, or to the next slice.

## Phase 5: Commit and PR
As `/dev-story` Phase 6 (git-workflow, step "Implement"):
1. **Commit gate**, one `AskUserQuestion`: commit and push (Recommended) · commit only · not now.
2. **Stage by name.** Read `git status --short` first and deal with every unplanned `??` entry (delete a spike, add a file deliberately if it belongs to the slice, otherwise leave it and name it). Never `git add -A`.
3. `git commit -m "feat(<scope>): <slice title>"` (`feat(S-NNN): …` for one story, `feat(F-NNN): …` for several, `feat(prototype): …` for the prototype), then `git push -u origin feat/<scope>-<slug>`. Never commit on the default branch.
4. **Find out what starts CI** (`grep -l "pull_request" .github/workflows/*.yml`, each workflow's `on:`). When only `pull_request` starts the checks, open the PR as a draft in this step (`gh pr create --draft --fill`) so they run during review; `/story-done` marks it ready and merges it. Otherwise say which run to expect and its id.
5. **Wait for CI** only for a run that exists: one background `gh run watch <run-id> --exit-status`; no polling, no `AskUserQuestion` as a pause.

## Phase 6: Summary
The "fun" criterion from the concept — the user plays and decides (one `AskUserQuestion`: fun as specified · not yet — say what is missing · skip for now); this skill never marks it itself. A summary of numbers (measured vs budget), open findings, the branch, the commit and the PR (or why there is none). The code review runs after the commit, as the hand-off below.

Verdict: `PLAYABLE` | `PARTIAL (over budget: …)` | `PARTIAL (not measured: …)` | `PARTIAL (open: …)` | `BLOCKED`. Next step — one `AskUserQuestion`: `/web-studio:code-review --diff` (copy mode `/code-review --diff`) — then `/story-done` (Recommended on PLAYABLE) · commit first (when Phase 5 was declined) · `/story-done` (when the review already passed) · the next slice · fix the open findings first. Run the next skill only on that answer.
