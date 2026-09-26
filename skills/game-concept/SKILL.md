---
name: game-concept
description: "Authors a web-game concept — pitch, core loop, MDA, mechanics, progression/economy, content scope, visual/audio direction, technical feasibility (engine, frame/memory/load budgets on mobile web, networking), accessibility, metrics, prototype plan. Produces docs/specs/game-concept.md."
argument-hint: "[game title] | gate"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, AskUserQuestion, Task
model: sonnet
agent: game-lead
---

# Game Concept

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

Template `.claude/docs/templates/game-concept.md`. Reference `threejs-webgames.md`. In the commands below, `<hooks>` is `.claude/hooks/` in copy mode and `${CLAUDE_PLUGIN_ROOT}/hooks/` in plugin mode.

## Phase 1: Pitch and loop
Questions: genre, the player's "verb", session (minutes), platform (mobile web first?), single/multiplayer, references. Three core-loop variants with "why it is fun to repeat".

## Phase 2: Mechanics, progression, content
Rules with parameters (mark which live in data, not code); a difficulty-curve table; MVP volume vs full version.

## Phase 3: Feasibility
Engine with justification (3D → three.js, WebGPU with WebGL2 fallback; 2D → PixiJS/Phaser; versions from `threejs-webgames.md`); budget: 16.6 ms frame, draw calls, memory, first load on 4G; networking (multiplayer → server-authoritative on Go, tick rate); saves; **spikes** to test risks (e.g. "1000 instances on a mid-range phone").
`threejs-engineer`/`web-game-engineer` via Task — risk assessment for their part (in parallel).

## Phase 4: Accessibility, metrics, prototype
Accessibility settings; retention metrics; prototype plan: what playability validates first, timeline, the "fun" criterion — measurable (sessions, minutes, a question to N testers), so `gate` can record a result, not an opinion.

## Phase 4b: `gate` — the prototype go/no-go
`/game-concept gate` runs only this phase, after the first playable slice and before backend/multiplayer investment. The catalog step `prototype-gate` and `/help` look for its artefact.
1. Read §11 of `docs/specs/game-concept.md` (the measurable "fun" criterion).
2. Ask for the measured result against it (playtest notes, numbers).
3. Record `GO | NO-GO | PIVOT (what changes)` with the evidence in `production/releases/gate-prototype.md` and as a "Result" block under §11, after "May I write?" — one `AskUserQuestion`: write (Recommended) · show the draft/diff first · not now. After the "write" answer: `touch .claude/.write-consent`.
4. After the write, the Phase 6 commit gate (`docs: prototype gate <GO|NO-GO|PIVOT>`, staging `production/releases/gate-prototype.md` and `docs/specs/game-concept.md`).
5. **Hand-off** — one `AskUserQuestion`. `GO` → `/create-stories` for the vertical slice's feature (Recommended when no stories exist) · `/dev-story S-NNN` (Recommended when the stories exist — name the first Ready one) · stop here. `NO-GO`/`PIVOT` → the next step is a concept revision, not the next feature: `/game-concept` again for the sections the result names (Recommended) · `/brainstorm` when the loop itself failed · stop here.

## Phase 5: Write
"May I write `docs/specs/game-concept.md`?" — one `AskUserQuestion`: write (Recommended) · show the draft/diff first · not now. Propose an engine ADR (`/architecture-decision`). After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker).

## Phase 6: Commit (documents lane)
Right after the write, one commit gate (rule 7 (4), `.claude/docs/git-workflow.md` § Documents): one `AskUserQuestion` offering `docs: game concept`, staging exactly the written files — `docs/specs/game-concept.md` (for `gate`: the message and files Phase 4b step 4 names). Record the gate before asking — `<hooks>session-state.sh set Gate "/game-concept Phase 6: commit?"` — and clear it after the answer (`<hooks>session-state.sh set Gate "—"`).
- On the default branch when no story work is in progress.
- When HEAD is a story branch, name it and offer: switch to the default branch and commit there (Recommended — a pipeline-wide document) · commit here (the document belongs to this story) · leave uncommitted.
- Code, configs, workflows and scripts never ride the `docs:` commit.

Nothing is committed without the answer.

Verdict: `APPROVED` | `NEEDS REVISION` | `GO` | `NO-GO` | `PIVOT`. Next step — one `AskUserQuestion`: `/product-spec` (light) (Recommended) · `/architecture-decision` (engine) · prototype via `/dev-story`. After `gate`, the hand-off of Phase 4b step 5 instead.
