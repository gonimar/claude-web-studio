# Skill Spec: /skill-test

> **Category**: onboarding · **Priority**: high · **Spec written**: 2026-09-05

## Summary
Linter/specs/rubric/audit of skills and agents.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path
**Fixture**: static all. **Expected**: 9-check table for every skill, summary.
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

### 6. Language line
**Fixture**: a skill without "Reply in the project conversation language". **Expected**: static check 9 WARN naming the skill.
- [ ] check 9 present · [ ] WARN, not FAIL

### 7. Static and category results reach the catalog
**Fixture**: `static all` in the kit repository (framework present), then `category onboarding`. **Expected**: after each table one `AskUserQuestion` ("May I update `catalog.yaml` (`last_static`/`last_static_result` …)?" — update Recommended · do not write); on "update" the consent marker is touched and only those two fields of the tested rows change (`last_category`/`last_category_result` for the category run); each question is preceded by `Gate: /skill-test Phase 2A: update catalog?` (2C for the category run, 2B for the spec results) in session-state and the field is cleared after the answer; `audit` then shows the dates; `static` without a framework offers no catalog write.
- [ ] gate before the catalog edit · [ ] gate recorded and cleared · [ ] only the two fields per row · [ ] no write without a framework

### 8. Check 4 sees the consent touch
**Fixture**: a skill with `Write` in `allowed-tools`, a "May I write" `AskUserQuestion`, and no `touch .claude/.write-consent` after it. **Expected**: check 4 WARN naming the missing consent touch (the gate itself passes); a skill with the touch after its gate is silent on this point.
- [ ] consent touch checked · [ ] WARN, not FAIL

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
