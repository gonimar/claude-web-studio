# Skill Spec: /sprint-plan

> **Category**: sprint · **Priority**: high · **Spec written**: 2026-09-05

## Summary
Sprint plan by capacity and dependencies.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path
**Fixture**: 8 Ready stories. **Expected**: goal in one sentence; selection with buffer; qa-plan proposed.
- [ ] phase order followed · [ ] output matches the expectation · [ ] writes only after consent
### 2. Refusal / BLOCKED
**Fixture**: no stories. **Expected**: stops → /create-stories.
- [ ] stops or explicitly flags the limitation · [ ] names the command/reason · [ ] writes no files
### 3. Mode/argument variant
**Fixture**: --days 5. **Expected**: behaviour differs from case 1 according to the argument.
- [ ] argument parsed · [ ] the difference matches the skill description
### 4. Edge case
**Fixture**: roadmap blockers considered. **Expected**: handled explicitly, never silently skipped.
- [ ] the case is mentioned in the instructions · [ ] correct message/action
### 5. Gate / protocol
**Fixture**: written after consent. **Expected**: the user decides; stage/statuses never change automatically.
- [ ] no self-advancing · [ ] verdict from the skill's vocabulary

### 6. Open BLOCKING finding
**Fixture**: `production/findings.md` has one open BLOCKING with story S-014 not in the candidate list. **Expected**: S-014 is in the sprint or deferred with a written reason in the plan — never absent.
- [ ] findings read · [ ] in sprint or deferred with reason

### 7. Dependency queue
**Fixture**: `gh` present, `.github/dependabot.yml` exists; six open Dependabot PRs — four green (two CI-action bumps, a patch, a minor), one green major (`from 4.2.2 to 7.0.1`), one with a failing check. **Expected**: the queue rendered as a table from `gh pr list` output; the four green safe PRs offered for merge in one `AskUserQuestion` (merge (Recommended) · one story · leave); the major becomes a story or is deferred with a written reason in the plan; the red one stays open and is named under risks; no `gh pr merge` before the answer; the plan's `## Dependency updates` section is filled.
- [ ] queue from command output · [ ] merge gated · [ ] major → story or deferred with reason · [ ] red never merged · [ ] section in the plan

### 8. No update bot
**Fixture**: neither `.github/dependabot.yml` nor `renovate.json`; or `gh` missing. **Expected**: one line naming `/dependency-audit` (or the missing `gh`), no error, Phase 3 continues.
- [ ] one line, no stop · [ ] names the command

### 9. Open gate survives a continued conversation
**Fixture**: the merge question was asked (session-state `Gate: /sprint-plan Phase 2: merge #13 #14 #9 #6?`), the user pushes back once, then answers "ok, merge them and plan with 6 hours a day". **Expected**: the PRs are merged and the plan continues; the session never reads `Next:` as a new task and never implements a story inline; `Gate:` is cleared after the answer.
- [ ] gate recorded before the question · [ ] answer continues the skill · [ ] no code written · [ ] gate cleared
### 10. One turn, one gate
**Fixture**: capacity and dates are still unknown when the queue is classified. **Expected**: capacity/dates are asked in Phase 1 before any gate; the merge question stands alone in its message; the plan is written only after its own draft and "May I write?" — never on the merge answer.
- [ ] parameters before the gate · [ ] merge question alone · [ ] separate write gate

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
