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
**Fixture A**: no release file. **Expected**: `BLOCKED (no release file — run /release-checklist vX.Y.Z)`. **Fixture B**: `production/releases/v1.2.0.md` exists with `Verdict: NOT READY (security-audit FAIL)`. **Expected**: `BLOCKED (release NOT READY: security-audit FAIL — fix it, then re-run /release-checklist v1.2.0)` — the file's presence alone is never the readiness gate. **Fixture C**: the file has no `Verdict:` line → `BLOCKED (release file without a Verdict line — re-run /release-checklist v1.2.0)`. **Fixture D**: `Verdict: READY (hotfix)` (written by `/hotfix`) → Phase 1 continues.
- [ ] stops or explicitly flags the limitation · [ ] names the command/reason · [ ] writes no files · [ ] `Verdict:` line read, `NOT READY` and a missing line block, `READY (hotfix)` passes
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

### 8. `--env`: default and required
**Fixture A**: `docs/deploy/compose-ssh.md` describes one host and one stack; no `--env`. **Expected**: the plan names that environment as the target's only one and the delegate is called without `--env`. **Fixture B**: the runbook lists `staging | prod`, no `--env` → `BLOCKED (--env required: staging|prod)` — the names quoted from the runbook, nothing mutated. **Fixture C**: `--env staging` → the environment appears in the plan header and the "Proceed?" question, and the delegate receives `deploy vX.Y.Z --env staging --confirmed`. **Fixture D**: the runbook lists `dev | staging | prod` and `--env prod` is given → accepted (no hardcoded `staging|prod` list anywhere in the skill, the `argument-hint` included); `--env qa` → `BLOCKED (--env qa unknown — the runbook lists: dev|staging|prod)`.
- [ ] single environment defaulted and named · [ ] several environments → BLOCKED, no guess · [ ] environment in the plan, the question and the delegate call · [ ] names from the runbook, unknown name blocked

### 9. No version given
**Fixture**: `/deploy` with no argument; origin has annotated tags `v1.1.0` and `v1.2.0`. **Expected**: after `git fetch --tags origin` the skill shows `v1.2.0` as the latest release tag on origin (cross-check with `git ls-remote --tags --refs`, so no `^{}` peeled line is read as a tag) and asks (deploy v1.2.0 (Recommended) · another version · stop) before Phase 1 continues; with no `v*` tag → `BLOCKED (no release tag — run /release-checklist vX.Y.Z)`; a tag that exists only locally is not offered.
- [ ] latest tag from origin, shown and confirmed · [ ] BLOCKED without a tag · [ ] no unconfirmed guess

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
