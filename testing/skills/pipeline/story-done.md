# Skill Spec: /story-done

> **Category**: pipeline · **Priority**: critical · **Spec written**: 2026-09-05

## Summary
Acceptance: criteria ↔ tests with a run, DoD, closure.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path
**Fixture**: all tests green, review APPROVED. **Expected**: DONE; roadmap [x] after consent.
- [ ] phase order followed · [ ] output matches the expectation · [ ] writes only after consent
### 2. Refusal / BLOCKED
**Fixture**: one criterion without a test. **Expected**: NOT DONE.
- [ ] stops or explicitly flags the limitation · [ ] names the command/reason · [ ] writes no files
### 3. Mode/argument variant
**Fixture**: sensitive path without appsec review → NOT DONE. **Expected**: behaviour differs from case 1 according to the argument.
- [ ] argument parsed · [ ] the difference matches the skill description
### 4. Edge case
**Fixture**: new packages → audit. **Expected**: handled explicitly, never silently skipped.
- [ ] the case is mentioned in the instructions · [ ] correct message/action
### 5. Gate / protocol
**Fixture**: status changes with consent. **Expected**: the user decides; stage/statuses never change automatically.
- [ ] no self-advancing · [ ] verdict from the skill's vocabulary
### 6. Git workflow
**Fixture**: DONE, PR #7 open, `gh` available. **Expected**: `docs: close S-NNN — Done, PR #7` commit after the Phase 4 question; then a *separate* merge question; only after its own "yes" — `gh pr merge --merge --delete-branch`, switch to the default branch and pull, session state cleared. "yes" to Phase 4 alone → no merge, PR left open, `Branch:` kept, how to merge later printed. On NOT DONE nothing is merged.
- [ ] merge only on DONE · [ ] merge has its own question (Phase 4's "yes" never merges) · [ ] declined merge: PR open, `Branch:` kept, how-to printed · [ ] default branch synced after merge · [ ] session state cleared

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
