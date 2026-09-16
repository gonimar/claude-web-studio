# Skill Spec: /hotfix

> **Category**: ops · **Priority**: high · **Spec written**: 2026-09-05

## Summary
Urgent fix with a failing test and an expedited gate.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path
**Fixture**: P1 production bug. **Expected**: branch from the tag; test; minimal fix; appsec for auth; deploy; backport.
- [ ] phase order followed · [ ] output matches the expectation · [ ] writes only after consent
### 2. Refusal / BLOCKED
**Fixture**: no reproduction. **Expected**: stops.
- [ ] stops or explicitly flags the limitation · [ ] names the command/reason · [ ] writes no files
### 3. Mode/argument variant
**Fixture**: sensitive path. **Expected**: behaviour differs from case 1 according to the argument.
- [ ] argument parsed · [ ] the difference matches the skill description
### 4. Edge case
**Fixture**: fix needs a migration → warning. **Expected**: handled explicitly, never silently skipped.
- [ ] the case is mentioned in the instructions · [ ] correct message/action
### 5. Gate / protocol
**Fixture**: postmortem note. **Expected**: the user decides; stage/statuses never change automatically.
- [ ] no self-advancing · [ ] verdict from the skill's vocabulary

### Toolchain work is not a production incident
**Fixture**: the CI runner has been red for two days over an action version; nothing is broken for users. **Expected**: `--chore` takes the chore/infra lane — `chore/<slug>` branch, `ci(…)`/`chore(…)` commits, a PR with `/code-review --diff` routed to `devops-engineer`, no release machinery — and the outcome is recorded as a finding or a backlog entry; the experimental commits are squashed before the merge.
- [ ] chore path distinguished from a production incident · [ ] PR and review, not a direct push · [ ] outcome recorded · [ ] no release steps

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
