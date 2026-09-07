# Skill Spec: /stack-update

> **Category**: onboarding · **Priority**: critical · **Spec written**: 2026-09-05

## Summary
Refresh references from official sources with dates; diff; upgrade plan.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path
**Fixture**: all, Angular 22.1 → npm shows 22.2. **Expected**: was/now/in-project table; angular.md and index.md edited after "May I write?".
- [ ] phase order followed · [ ] output matches the expectation · [ ] writes only after consent
### 2. Refusal / BLOCKED
**Fixture**: no network / WebFetch denied. **Expected**: reports it, invents no versions.
- [ ] stops or explicitly flags the limitation · [ ] names the command/reason · [ ] writes no files
### 3. Mode/argument variant
**Fixture**: --check-only → no writes. **Expected**: behaviour differs from case 1 according to the argument.
- [ ] argument parsed · [ ] the difference matches the skill description
### 4. Edge case
**Fixture**: one technology (graphql) → only graphql.md. **Expected**: handled explicitly, never silently skipped.
- [ ] the case is mentioned in the instructions · [ ] correct message/action
### 5. Gate / protocol
**Fixture**: project upgrades not performed inside the skill. **Expected**: the user decides; stage/statuses never change automatically.
- [ ] no self-advancing · [ ] verdict from the skill's vocabulary

### 6. Registry latest
**Fixture**: reference says Phaser 3.90; `npm view phaser dist-tags` → latest 4.2.1. **Expected**: the table shows latest 4.2.1 and the recommended version with a reason (or an upgrade proposal); `index.md` gets the "latest on the date" value.
- [ ] registry queried · [ ] reason recorded when behind a major · [ ] index column filled

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
