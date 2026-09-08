# Skill Spec: /test-setup

> **Category**: authoring · **Priority**: critical · **Spec written**: 2026-09-05

## Summary
Test strategy and configs per stack.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path
**Fixture**: Go + Angular. **Expected**: levels table; compose test; Vitest+Playwright; CI stages.
- [ ] phase order followed · [ ] output matches the expectation · [ ] writes only after consent
### 2. Refusal / BLOCKED
**Fixture**: stack not configured. **Expected**: stops → /setup-stack.
- [ ] stops or explicitly flags the limitation · [ ] names the command/reason · [ ] writes no files
### 3. Mode/argument variant
**Fixture**: --apply → configs via test-engineer. **Expected**: behaviour differs from case 1 according to the argument.
- [ ] argument parsed · [ ] the difference matches the skill description
### 4. Edge case
**Fixture**: no docker → testcontainers impossible, flagged. **Expected**: handled explicitly, never silently skipped.
- [ ] the case is mentioned in the instructions · [ ] correct message/action
### 5. Gate / protocol
**Fixture**: written after consent. **Expected**: the user decides; stage/statuses never change automatically.
- [ ] no self-advancing · [ ] verdict from the skill's vocabulary

### 6. CI references a compose profile
**Fixture**: the generated ci.yml runs `docker compose --profile test up -d --wait`; compose.yaml has no such profile. **Expected**: the compose fragment (profile + services with healthchecks) is created in the same run, or the skill stops with `BLOCKED` naming the story; `docker compose --profile test config` is run when docker exists; every service in test-strategy exists in compose.
- [ ] fragment created or BLOCKED · [ ] self-check named · [ ] no CI that cannot pass

### 7. Documents lane (commit after write)
**Fixture**: strategy written while HEAD is `feat/S-001-…` (a story branch). **Expected**: right after the write gate one commit gate offers `docs: test strategy` staging exactly the written files, names the current branch and asks where it belongs (switch to the default branch Recommended for a pipeline-wide document · commit here · leave uncommitted); nothing is committed without the answer.
- [ ] commit gate follows the write · [ ] current branch named · [ ] default-branch option Recommended

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
