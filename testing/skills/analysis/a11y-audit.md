# Skill Spec: /a11y-audit

> **Category**: analysis · **Priority**: critical · **Spec written**: 2026-09-05

## Summary
WCAG 2.2 AA: axe + manual checklist.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path
**Fixture**: all routes. **Expected**: findings with WCAG criteria.
- [ ] phase order followed · [ ] output matches the expectation · [ ] writes only after consent
### 2. Refusal / BLOCKED
**Fixture**: dev server not running. **Expected**: offers to start it.
- [ ] stops or explicitly flags the limitation · [ ] names the command/reason · [ ] writes no files
### 3. Mode/argument variant
**Fixture**: game → accessibility settings. **Expected**: behaviour differs from case 1 according to the argument.
- [ ] argument parsed · [ ] the difference matches the skill description
### 4. Edge case
**Fixture**: canvas menu without a DOM overlay → critical. **Expected**: handled explicitly, never silently skipped.
- [ ] the case is mentioned in the instructions · [ ] correct message/action
### 5. Gate / protocol
**Fixture**: axe regression test with consent. **Expected**: the user decides; stage/statuses never change automatically; the regression test is the Phase 2 spec `<e2e dir>/a11y/axe.spec.ts` in its final form, one file, its path named in the Phase 4 question; `<e2e dir>` is the `testDir` of `playwright.config.{ts,js,mjs}` when the config exists, then the directory `test-strategy.md` names, else `e2e/` with a note that the path was assumed.
- [ ] no self-advancing · [ ] verdict from the skill's vocabulary · [ ] one axe file, path named · [ ] `<e2e dir>` from `playwright.config.*` first

### 6. Commit gate on the documents lane
**Fixture**: report written and one `A11Y-NNN` row recorded while HEAD is `feat/S-001-…` (a story branch); the axe spec was written too. **Expected**: right after the write one commit gate offers `docs: a11y audit <date>` staging exactly `docs/ops/a11y-audit-<date>.md` and `production/findings.md`, names the current branch and asks where it belongs (switch to the default branch Recommended for a pipeline-wide document · commit here · leave uncommitted); the axe spec is named and offered the chore lane or the fix story, never staged; nothing is committed without the answer.
- [ ] commit gate follows the write · [ ] current branch named · [ ] default-branch option Recommended · [ ] the axe spec never rides the `docs:` commit

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
