---
name: team-game
description: "Delivers a playable web-game slice: game-concept check → engine ADR → simulation + rendering (three.js/Pixi) + UI overlay (Angular/Vue) + optional multiplayer (Go server) in parallel → frame-budget measurement → accessibility settings → review. Use to build the prototype or a game feature."
argument-hint: "[prototype | feature F-NNN]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, AskUserQuestion
model: opus
agent: game-lead
---

# Team: Game

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

File writes and any mutation (git, deploy) happen only after an explicit "May I write?" / "Proceed?" — each one `AskUserQuestion` (proceed (Recommended) · show the draft/diff first · not now) → "yes". After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker).

**Consent for delegated work is collected by this skill.** A subagent spawned through `Task` cannot ask the user. Before each `Task` batch, the "Proceed?" question names the agents and the files each will create or change; that answer covers those files. A specialist that needs to go beyond its brief (another file, a new dependency, a protocol or schema change) stops and reports it, and the parent asks.

Agents below are spawned with a studio `subagent_type`: `web-studio:<name>` in plugin mode, `<name>` in copy mode. Commands are `/web-studio:<name>` in plugin mode and `/<name>` in copy mode; a bare `/code-review` in plugin mode runs Claude Code's built-in review, not the studio's (coordination-rules § Subagents).

## Phase 1: Readiness
`docs/specs/game-concept.md` (missing → `/game-concept`); the engine ADR (missing → `/architecture-decision`); budgets in technical-preferences.

## Phase 2: Parallel implementation
`web-game-engineer` (simulation, loop, input, audio, saves) ‖ `threejs-engineer` or `web-game-engineer` (rendering) ‖ `angular-engineer`/`vue-engineer` (UI overlay/menus from the UX spec) ‖ `multiplayer-engineer` + `go-engineer` (if networked; protocol via `api-designer` first).

## Phase 3: Measurements and accessibility
`performance-engineer` (frame, draw calls, memory, load on 4G emulation) ‖ `accessibility-specialist` (menus, settings).

## Phase 4: Review and summary
`/web-studio:code-review --diff` (copy mode `/code-review --diff`); the "fun" criterion from the concept — the user plays and decides; a summary of numbers.

Verdict: `PLAYABLE` | `PARTIAL` | `BLOCKED`. Next step — one `AskUserQuestion`: `/story-done` (Recommended) · the next slice · fix the open findings first.
