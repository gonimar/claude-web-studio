# Skill Spec: /start

> **Category**: onboarding · **Priority**: high · **Spec written**: 2026-09-05

## Summary
Onboarding for a new project: detect → "where are you" → type/review mode → route.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path
**Fixture**: initialised empty repo, technical-preferences TO BE CONFIGURED. **Expected**: A–D question, then type/mode; review-mode/stage written after "May I write?"; next step /setup-stack.
- [ ] phase order followed · [ ] output matches the expectation · [ ] writes only after consent
### 2. Refusal / BLOCKED
**Fixture**: go.mod and docs/specs already exist. **Expected**: suggests /adopt instead — the detection is named (a non-empty `docs/specs/`, or a manifest next to a source tree), verdict `BLOCKED (existing project — run /adopt full)`, the hand-off is one `AskUserQuestion` with `/adopt full` Recommended; the review mode is not asked and no file is written.
- [ ] stops or explicitly flags the limitation · [ ] names the command/reason · [ ] writes no files · [ ] detection rule stated, not a feeling
### 3. Mode/argument variant
**Fixture**: option C (browser game) → route via /game-concept. **Expected**: behaviour differs from case 1 according to the argument.
- [ ] argument parsed · [ ] the difference matches the skill description
### 4. Edge case
**Fixture**: settings.web-studio.json present → merge offered. **Expected**: handled explicitly, never silently skipped.
- [ ] the case is mentioned in the instructions · [ ] correct message/action
### 5. Gate / protocol
**Fixture**: no gates; stage not written without consent. **Expected**: the user decides; stage/statuses never change automatically.
- [ ] no self-advancing · [ ] verdict from the skill's vocabulary

### 6. Review mode already set by /init
**Fixture**: `production/review-mode.txt` = `full` and `production/stage.txt` = `discovery`, written by `/init`; empty project. **Expected**: Phase 3 asks the project type only, prints "review mode: full, set by /init" and does not ask the mode again; neither file is rewritten, so there is no write gate in Phase 3 and `full` survives the run.
- [ ] mode read before asking · [ ] not re-asked · [ ] file not overwritten

### 7. Documents lane (commit after write)
**Fixture**: review mode and stage written, `production/roadmap.md` created in Phase 4, HEAD is `feat/S-001-…`. **Expected**: right after the write one commit gate offers `docs: initialise web studio` staging exactly those files, names the current branch and asks where it belongs (switch to the default branch Recommended · commit here · leave uncommitted); a merged `.claude/settings.json` is named for the chore lane, never staged in the `docs:` commit; nothing is committed without the answer.
- [ ] commit gate follows the write · [ ] exact files staged · [ ] settings.json kept out of the docs commit

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
