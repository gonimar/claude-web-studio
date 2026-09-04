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

File writes and any mutation (git, deploy) happen only after an explicit "May I write?" / "Proceed?" → "yes"; delegated agents follow the same protocol.

## Phase 1: Readiness
`docs/specs/game-concept.md` (missing → `/game-concept`); the engine ADR (missing → `/architecture-decision`); budgets in technical-preferences.

## Phase 2: Parallel implementation
`web-game-engineer` (simulation, loop, input, audio, saves) ‖ `threejs-engineer` or `web-game-engineer` (rendering) ‖ `angular-engineer`/`vue-engineer` (UI overlay/menus from the UX spec) ‖ `multiplayer-engineer` + `go-engineer` (if networked; protocol via `api-designer` first).

## Phase 3: Measurements and accessibility
`performance-engineer` (frame, draw calls, memory, load on 4G emulation) ‖ `accessibility-specialist` (menus, settings).

## Phase 4: Review and summary
`/code-review --diff`; the "fun" criterion from the concept — the user plays and decides; a summary of numbers.

Verdict: `PLAYABLE` | `PARTIAL` | `BLOCKED`. Next step: `/story-done` / the next slice.
