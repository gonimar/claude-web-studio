---
name: game-concept
description: "Authors a web-game concept — pitch, core loop, MDA, mechanics, progression/economy, content scope, visual/audio direction, technical feasibility (engine, frame/memory/load budgets on mobile web, networking), accessibility, metrics, prototype plan. Produces docs/specs/game-concept.md."
argument-hint: "[game title]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion, Task
model: sonnet
agent: game-lead
---

# Game Concept

Template `.claude/docs/templates/game-concept.md`. Reference `threejs-webgames.md`.

## Phase 1: Pitch and loop
Questions: genre, the player's "verb", session (minutes), platform (mobile web first?), single/multiplayer, references. Three core-loop variants with "why it is fun to repeat".

## Phase 2: Mechanics, progression, content
Rules with parameters (mark: in data); a difficulty-curve table; MVP volume vs full version.

## Phase 3: Feasibility
Engine with justification (3D → three.js r185 WebGPU/WebGL2; 2D → PixiJS 8/Phaser); budget: 16.6 ms frame, draw calls, memory, first load on 4G; networking (multiplayer → server-authoritative on Go, tick rate); saves; **spikes** to test risks (e.g. "1000 instances on a mid-range phone").
`threejs-engineer`/`web-game-engineer` via Task — risk assessment for their part (in parallel).

## Phase 4: Accessibility, metrics, prototype
Accessibility settings; retention metrics; prototype plan: what playability validates first, timeline, the "fun" criterion.

## Phase 5: Write
"May I write `docs/specs/game-concept.md`?" Propose an engine ADR (`/architecture-decision`).

Verdict: `APPROVED` | `NEEDS REVISION`. Next step: `/product-spec` (light) → `/architecture-decision` (engine) → prototype via `/dev-story`.
