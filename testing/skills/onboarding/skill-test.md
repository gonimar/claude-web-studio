# Skill Spec: /skill-test

> **Category**: onboarding · **Priority**: high · **Spec written**: 2026-09-05

## Summary
Linter/specs/rubric/audit of skills and agents.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path
**Fixture**: static all. **Expected**: 8-check table for every skill, summary.
- [ ] phase order followed · [ ] output matches the expectation · [ ] writes only after consent
### 2. Refusal / BLOCKED
**Fixture**: no framework. **Expected**: only static available.
- [ ] stops or explicitly flags the limitation · [ ] names the command/reason · [ ] writes no files
### 3. Mode/argument variant
**Fixture**: spec <name> → quoted lines per assertion. **Expected**: behaviour differs from case 1 according to the argument.
- [ ] argument parsed · [ ] the difference matches the skill description
### 4. Edge case
**Fixture**: agent all. **Expected**: handled explicitly, never silently skipped.
- [ ] the case is mentioned in the instructions · [ ] correct message/action
### 5. Gate / protocol
**Fixture**: results written after "May I write?". **Expected**: the user decides; stage/statuses never change automatically; the results gate and the hand-off are `AskUserQuestion`s with a Recommended option and alternatives.
- [ ] no self-advancing · [ ] verdict from the skill's vocabulary · [ ] gate and hand-off are `AskUserQuestion`s, not text

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
