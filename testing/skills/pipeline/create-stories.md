# Skill Spec: /create-stories

> **Category**: pipeline · **Priority**: critical · **Spec written**: 2026-09-05

## Summary
Slice a feature into vertical stories with a criteria matrix.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path
**Fixture**: F-002 with criteria. **Expected**: stories ≤ M, lossless matrix, roadmap lines.
- [ ] phase order followed · [ ] output matches the expectation · [ ] writes only after consent
### 2. Refusal / BLOCKED
**Fixture**: feature spec without criteria. **Expected**: stops → complete it.
- [ ] stops or explicitly flags the limitation · [ ] names the command/reason · [ ] writes no files
### 3. Mode/argument variant
**Fixture**: game → simulation first. **Expected**: behaviour differs from case 1 according to the argument.
- [ ] argument parsed · [ ] the difference matches the skill description
### 4. Edge case
**Fixture**: dependencies between stories. **Expected**: handled explicitly, never silently skipped.
- [ ] the case is mentioned in the instructions · [ ] correct message/action
### 5. Gate / protocol
**Fixture**: written after consent. **Expected**: the user decides; stage/statuses never change automatically.
- [ ] no self-advancing · [ ] verdict from the skill's vocabulary

### 6. Open BLOCKING findings
**Fixture**: `production/findings.md` has SEC-001 (BLOCKING, touches F-002's resolver). **Expected**: it becomes an acceptance criterion of the affected story (or a dedicated story); the matrix shows `finding → story`; after writing, the finding carries `story: S-NNN`.
- [ ] findings read · [ ] criterion or story created · [ ] finding linked to the story
### 7. Deploy artefacts story
**Fixture**: technical-preferences Deploy = compose on a server, no `docs/ops/deploy.md`, first feature. **Expected**: a "Deploy artefacts" story is added (Dockerfile, production compose, release workflow, healthz, runbook from `templates/deploy-runbook.md`) with the three criteria.
- [ ] story added on the first feature · [ ] runbook template referenced · [ ] criteria present

### 8. Observability, restore drill and deletion stories
**Fixture**: Deploy target set; no `/healthz` route, no alert rule; data model with tables and no tested-restore date in §7; §6 classifies e-mail and IP as PII, no deletion code. **Expected**: the first feature gets "Observability" (devops-engineer), "Backup & restore drill" (restore on staging with the date recorded) and "Data deletion" (every §6 field, backups, logs) with the criteria the skill names; none when the evidence already exists.
- [ ] three stories with criteria · [ ] none when evidence exists · [ ] restore date named as a criterion

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
