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
**Fixture**: no game concept; `/game-concept` ends `NO-GO`. **Expected**: runs /game-concept through the `Skill` tool (all of its gates) and reads its verdict line: continues only on `APPROVED` or `GO`; `NEEDS REVISION`, `NO-GO` or `PIVOT` → `BLOCKED (stage 1: game-concept NO-GO)` with a partial report — no branch, no `Task` batch.
- [ ] stops or explicitly flags the limitation · [ ] names the command/reason · [ ] writes no files · [ ] continues only on `APPROVED`/`GO`
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
- [ ] branch with consent, from an up-to-date default branch · [ ] commit scope is the story/feature ID (`prototype` for the prototype) · [ ] draft PR when the PR starts CI · [ ] no commit on the default branch · [ ] `Gate "/team-game Phase 5: commit?"` recorded through `session-state.sh` before the commit question and cleared to `—` after the answer

### 7. Skills run one after another
**Fixture**: the engine ADR is missing in Phase 1; `/architecture-decision` ends `PROPOSED`. **Expected**: `Skill` is in `allowed-tools`; `/architecture-decision` runs through the `Skill` tool with its own gates; the slice continues only on `ACCEPTED` — `PROPOSED`, `NEEDS REVISION` or `REJECTED` → `BLOCKED (stage 1: architecture-decision PROPOSED)`; `‖` in the body only ever joins agents of one `Task` batch, never two skills.
- [ ] `Skill` listed · [ ] called skill keeps its gates · [ ] no two skills at once · [ ] continues only on `ACCEPTED`

### 8. Story cards reach `Review` with a `Started:` line
**Fixture**: `feature F-004`, one story S-021. **Expected**: at branch time (Phase 2) the card's metadata line gets `Status: In Progress` and `Started: YYYY-MM-DDTHH:MM` (actual time), covered by the "start" answer; before the commit gate (Phase 5 step 1) it is set to `Status: Review`; the card is staged by name in the `feat(S-021)` commit; a later `/story-done S-021` finds `Review` and a `Started:` line. `prototype` has no card and no stamp.
- [ ] `In Progress` + `Started:` at branch time · [ ] `Review` before the commit · [ ] card rides the feat commit · [ ] no stamp for the prototype

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
