# Skill Spec: /game-concept

> **Category**: authoring · **Priority**: critical · **Spec written**: 2026-09-05

## Summary
Game concept: loop, MDA, mechanics, economy, feasibility, accessibility, prototype.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path
**Fixture**: idle game, mobile web. **Expected**: budgets as numbers; Pixi justified; spikes.
- [ ] phase order followed · [ ] output matches the expectation · [ ] writes only after consent
### 2. Refusal / BLOCKED
**Fixture**: no genre. **Expected**: asks.
- [ ] stops or explicitly flags the limitation · [ ] names the command/reason · [ ] writes no files
### 3. Mode/argument variant
**Fixture**: 3D → three.js WebGPU + fallback. **Expected**: behaviour differs from case 1 according to the argument.
- [ ] argument parsed · [ ] the difference matches the skill description
### 4. Edge case
**Fixture**: multiplayer → server-authoritative. **Expected**: handled explicitly, never silently skipped.
- [ ] the case is mentioned in the instructions · [ ] correct message/action
### 5. Gate / protocol
**Fixture**: engine ADR proposed. **Expected**: the user decides; stage/statuses never change automatically.
- [ ] no self-advancing · [ ] verdict from the skill's vocabulary

### 6. Prototype gate
**Fixture**: `/game-concept gate` after the first playable slice; §11 criterion "3 of 4 testers replay". **Expected**: asks for the measured result, records `GO | NO-GO | PIVOT` with evidence in `production/releases/gate-prototype.md` and under §11 after "May I write?"; `NO-GO`/`PIVOT` → concept revision is the next step, not the next feature.
- [ ] measurable criterion required · [ ] artefact written after consent · [ ] NO-GO changes the next step

### 7. GO hands off
**Fixture**: `/game-concept gate` records `GO`; no stories exist yet. **Expected**: after the write and its commit gate one `AskUserQuestion`: `/create-stories` for the vertical slice's feature (Recommended) · `/dev-story S-NNN` (Recommended instead when stories exist, the first Ready one named) · stop here; the turn ends on the question, no feature work starts inline.
- [ ] hand-off after GO · [ ] Recommended option depends on whether stories exist · [ ] turn ends

### Commit gate on the documents lane
**Fixture**: the game concept is written while HEAD is `feat/S-001-…` (a story branch). **Expected**: right after the write one commit gate offers `docs: game concept` staging exactly the written files (`docs/specs/game-concept.md`; after `gate`: `docs: prototype gate GO` with `production/releases/gate-prototype.md` and the concept's §11, nothing else); the current branch is named and the question offers the three options — switch to the default branch and commit there (Recommended) · commit here · leave uncommitted; nothing is committed without the answer.
- [ ] commit gate follows the write · [ ] only the written files staged · [ ] three options, default branch Recommended · [ ] nothing committed without the answer

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
