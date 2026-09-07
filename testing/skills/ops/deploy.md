# Skill Spec: /deploy

> **Category**: ops · **Priority**: critical · **Spec written**: 2026-09-05

## Summary
Deploy with confirmations, smoke, rollback; delegation to a deploy skill.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path
**Fixture**: v1.2.0, deploy skill present. **Expected**: plan → confirmation → delegation → smoke → record.
- [ ] phase order followed · [ ] output matches the expectation · [ ] writes only after consent
### 2. Refusal / BLOCKED
**Fixture**: no release file. **Expected**: stops → /release-checklist.
- [ ] stops or explicitly flags the limitation · [ ] names the command/reason · [ ] writes no files
### 3. Mode/argument variant
**Fixture**: --plan-only. **Expected**: behaviour differs from case 1 according to the argument.
- [ ] argument parsed · [ ] the difference matches the skill description
### 4. Edge case
**Fixture**: container unhealthy → rollback. **Expected**: handled explicitly, never silently skipped.
- [ ] the case is mentioned in the instructions · [ ] correct message/action
### 5. Gate / protocol
**Fixture**: runbook updated. **Expected**: the user decides; stage/statuses never change automatically.
- [ ] no self-advancing · [ ] verdict from the skill's vocabulary

### 6. Delegate by contract
**Fixture**: technical-preferences declares `Deploy delegate: agent <kit>-ops`; the agent exists with `deploy-target: <kit>`. **Expected**: after "Proceed?" → "yes", a `Task` to the agent with `deploy vX.Y.Z --confirmed`; the verdict line is read; the runbook smoke checks run afterwards.
- [ ] delegate read from technical-preferences · [ ] `--confirmed` passed after the user's yes · [ ] smoke checks by /deploy itself
### 7. Delegate declared but missing / none declared
**Fixture A**: delegate `script scripts/deploy/compose-ssh.sh` declared, file absent → `BLOCKED (delegate … not found)`. **Fixture B**: `none` → manual runbook steps.
- [ ] BLOCKED names the fix · [ ] no guessing of an installed kit · [ ] manual path explicit

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
