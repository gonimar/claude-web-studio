# Skill Spec: /team-game

> **Category**: team · **Priority**: high · **Spec written**: 2026-09-05

## Summary
Playable game slice.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path
**Fixture**: prototype three.js. **Expected**: branch `feat/prototype-<slug>` with consent; simulation ‖ rendering ‖ UI; measurements; a11y; commit and push; the user decides "fun"; hand-off to `/code-review --diff`.
- [ ] phase order followed · [ ] output matches the expectation · [ ] writes only after consent
### 2. Refusal / BLOCKED
**Fixture**: no game concept. **Expected**: runs /game-concept through the `Skill` tool (all of its gates), then continues.
- [ ] stops or explicitly flags the limitation · [ ] names the command/reason · [ ] writes no files
### 3. Mode/argument variant
**Fixture**: multiplayer → protocol first. **Expected**: behaviour differs from case 1 according to the argument.
- [ ] argument parsed · [ ] the difference matches the skill description
### 4. Edge case
**Fixture**: frame time 22 ms against a 16.7 ms budget → PARTIAL with numbers. **Expected**: `PARTIAL (over budget: frame 22 ms > 16.7 ms)` naming the measured value, the budget and the measurement file; never `PLAYABLE`; a measurement that could not be taken → `PARTIAL (not measured: …)`, never silently skipped.
- [ ] the case is mentioned in the instructions · [ ] correct message/action · [ ] numbers and budget in the verdict
### 5. Gate / protocol
**Fixture**: the user decides "fun". **Expected**: the user decides; stage/statuses never change automatically.
- [ ] no self-advancing · [ ] verdict from the skill's vocabulary

### 6. Git workflow
**Fixture**: session on a merged story branch; the slice is feature F-004, one story S-021. **Expected**: Phase 2 asks before branching, switches to the default branch, pulls `--ff-only` from `origin/<default>`, creates `feat/S-021-<slug>`; Phase 5 asks before committing, stages by name (never `git add -A`), commits `feat(S-021): …`, pushes, and opens a draft PR when only `pull_request` starts CI; no commit on the default branch.
- [ ] branch with consent, from an up-to-date default branch · [ ] commit scope is the story/feature ID (`prototype` for the prototype) · [ ] draft PR when the PR starts CI · [ ] no commit on the default branch

### 7. Skills run one after another
**Fixture**: the engine ADR is missing in Phase 1. **Expected**: `Skill` is in `allowed-tools`; `/architecture-decision` runs through the `Skill` tool with its own gates; `‖` in the body only ever joins agents of one `Task` batch, never two skills.
- [ ] `Skill` listed · [ ] called skill keeps its gates · [ ] no two skills at once

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
