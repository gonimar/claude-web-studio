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

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
