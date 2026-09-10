---
name: game-concept
description: "Authors a web-game concept — pitch, core loop, MDA, mechanics, progression/economy, content scope, visual/audio direction, technical feasibility (engine, frame/memory/load budgets on mobile web, networking), accessibility, metrics, prototype plan. Produces docs/specs/game-concept.md."
argument-hint: "[game title] | gate"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion, Task
model: sonnet
agent: game-lead
---

# Game Concept

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

Template `.claude/docs/templates/game-concept.md`. Reference `threejs-webgames.md`.

## Phase 1: Pitch and loop
Questions: genre, the player's "verb", session (minutes), platform (mobile web first?), single/multiplayer, references. Three core-loop variants with "why it is fun to repeat".

## Phase 2: Mechanics, progression, content
Rules with parameters (mark: in data); a difficulty-curve table; MVP volume vs full version.

## Phase 3: Feasibility
Engine with justification (3D → three.js r185 WebGPU/WebGL2; 2D → PixiJS 8/Phaser); budget: 16.6 ms frame, draw calls, memory, first load on 4G; networking (multiplayer → server-authoritative on Go, tick rate); saves; **spikes** to test risks (e.g. "1000 instances on a mid-range phone").
`threejs-engineer`/`web-game-engineer` via Task — risk assessment for their part (in parallel).

## Phase 4: Accessibility, metrics, prototype
Accessibility settings; retention metrics; prototype plan: what playability validates first, timeline, the "fun" criterion — measurable (sessions, minutes, a question to N testers), so `gate` can record a result, not an opinion.

## Phase 4b: `gate` — the prototype go/no-go
`/game-concept gate` (after the first playable slice, before backend/multiplayer investment): read §11 of `docs/specs/game-concept.md`, ask for the measured result against the "fun" criterion (playtest notes, numbers), and record `GO | NO-GO | PIVOT (what changes)` with the evidence in `production/releases/gate-prototype.md` and as a "Result" block under §11 — after "May I write?". `NO-GO`/`PIVOT` → the next step is a concept revision, not the next feature. The catalog step `prototype-gate` and `/help` look for this artefact.

## Phase 5: Write
"May I write `docs/specs/game-concept.md`?" — one `AskUserQuestion`: write (Recommended) · show the draft/diff first · not now. Propose an engine ADR (`/architecture-decision`). After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker).

Verdict: `APPROVED` | `NEEDS REVISION` | `GO` | `NO-GO` | `PIVOT`. Next step — one `AskUserQuestion`: `/product-spec` (light) (Recommended) · `/architecture-decision` (engine) · prototype via `/dev-story`.
