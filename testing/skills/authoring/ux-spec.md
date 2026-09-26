# Skill Spec: /ux-spec

> **Category**: authoring · **Priority**: high · **Spec written**: 2026-09-05

## Summary
UX spec for a flow: screens, 6 states, copy, a11y, responsive.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path
**Fixture**: F-002 with a design system. **Expected**: all states; Haiku a11y check.
- [ ] phase order followed · [ ] output matches the expectation · [ ] writes only after consent
### 2. Refusal / BLOCKED
**Fixture**: no feature spec. **Expected**: stops with `BLOCKED (no feature spec — run /feature-spec F-NNN first)`, writes nothing, offers `/feature-spec F-NNN`.
- [ ] stops or explicitly flags the limitation · [ ] names the command/reason · [ ] writes no files
### 3. Mode/argument variant
**Fixture**: no design system → base kit components, /design-system suggested. **Expected**: behaviour differs from case 1 according to the argument.
- [ ] argument parsed · [ ] the difference matches the skill description
### 4. Edge case
**Fixture**: mobile-only flow. **Expected**: handled explicitly, never silently skipped.
- [ ] the case is mentioned in the instructions · [ ] correct message/action
### 5. Gate / protocol
**Fixture**: written after consent. **Expected**: the user decides; stage/statuses never change automatically.
- [ ] no self-advancing · [ ] verdict from the skill's vocabulary

### Commit gate on the documents lane
**Fixture**: UX-003 is written while HEAD is `feat/S-001-…` (a story branch). **Expected**: right after the write one commit gate offers `docs: UX spec UX-003` staging exactly the written files (`docs/specs/ux/UX-003-<slug>.md`, nothing else); the current branch is named and the question offers the three options — switch to the default branch and commit there (Recommended) · commit here · leave uncommitted; nothing is committed without the answer.
- [ ] commit gate follows the write · [ ] only the written files staged · [ ] three options, default branch Recommended · [ ] nothing committed without the answer

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
