# Skill Spec: /qa-plan

> **Category**: sprint · **Priority**: high · **Spec written**: 2026-09-05

## Summary
Criteria → tests matrix for a sprint.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path
**Fixture**: sprint 3. **Expected**: levels/tools/files table.
- [ ] phase order followed · [ ] output matches the expectation · [ ] writes only after consent
### 2. Refusal / BLOCKED
**Fixture**: no test strategy. **Expected**: stops → /test-setup.
- [ ] stops or explicitly flags the limitation · [ ] names the command/reason · [ ] writes no files
### 3. Mode/argument variant
**Fixture**: F-NNN instead of a sprint. **Expected**: behaviour differs from case 1 according to the argument.
- [ ] argument parsed · [ ] the difference matches the skill description
### 4. Edge case
**Fixture**: criterion without a possible automated test → manual, flagged. **Expected**: handled explicitly, never silently skipped: level `manual` (a value of the template's Level column) with steps, tester and evidence in the row's `Manual (steps · tester · evidence)` column, `—` on automated rows, counted in the risks section.
- [ ] the case is mentioned in the instructions · [ ] correct message/action
### 5. Gate / protocol
**Fixture**: written after consent. **Expected**: the user decides; stage/statuses never change automatically.
- [ ] no self-advancing · [ ] verdict from the skill's vocabulary

### 6. Commit gate on the documents lane
**Fixture**: plan written while HEAD is `feat/S-001-…` (a story branch). **Expected**: right after the write gate one commit gate offers `docs: qa plan NN` staging exactly `production/sprints/qa-plan-NN.md`, names the current branch and asks where it belongs (switch to the default branch Recommended for a pipeline-wide document · commit here · leave uncommitted); nothing is committed without the answer.
- [ ] commit gate follows the write · [ ] current branch named · [ ] default-branch option Recommended · [ ] nothing committed without the answer

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
