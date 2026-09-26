# Skill Spec: /perf-audit

> **Category**: analysis · **Priority**: critical · **Spec written**: 2026-09-05

## Summary
Measurements against budgets; ranking; before/after.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path
**Fixture**: web, Lighthouse available. **Expected**: metric/budget table; top 3.
- [ ] phase order followed · [ ] output matches the expectation · [ ] writes only after consent
### 2. Refusal / BLOCKED
**Fixture**: no budgets (`technical-preferences.md` § Performance budgets missing or `[N]` placeholders). **Expected**: CWV defaults from `web-platform.md` with a note in the table; metrics with no default reported as `NO BUDGET`; the report proposes recording the budgets.
- [ ] stops or explicitly flags the limitation · [ ] names the command/reason · [ ] writes no files
### 3. Mode/argument variant
**Fixture**: game → frame/draw calls. **Expected**: behaviour differs from case 1 according to the argument.
- [ ] argument parsed · [ ] the difference matches the skill description
### 4. Edge case
**Fixture**: tool missing → installation offered. **Expected**: handled explicitly, never silently skipped.
- [ ] the case is mentioned in the instructions · [ ] correct message/action
### 5. Gate / protocol
**Fixture**: written after consent. **Expected**: the user decides; stage/statuses never change automatically.
- [ ] no self-advancing · [ ] verdict from the skill's vocabulary

### 6. Commit gate on the documents lane
**Fixture**: report written and one `PERF-NNN` row recorded while HEAD is `feat/S-001-…` (a story branch); a k6 scenario was created in Phase 1. **Expected**: right after the write one commit gate offers `docs: perf audit <date>` staging exactly `docs/ops/perf-audit-<date>.md`, `production/findings.md` and the measurement file, names the current branch and asks where it belongs (switch to the default branch Recommended for a pipeline-wide document · commit here · leave uncommitted); the k6 scenario and any fix are named and offered a story or the chore lane, never staged; nothing is committed without the answer.
- [ ] commit gate follows the write · [ ] current branch named · [ ] default-branch option Recommended · [ ] code never rides the `docs:` commit

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
