# Skill Spec: /dependency-audit

> **Category**: analysis · **Priority**: high · **Spec written**: 2026-09-05

## Summary
Supply chain: audit tools, abandoned, versions, licences.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path
**Fixture**: pnpm + composer + go. **Expected**: package→problem→action table.
- [ ] phase order followed · [ ] output matches the expectation · [ ] writes only after consent
### 2. Refusal / BLOCKED
**Fixture**: no lockfile. **Expected**: ACTION REQUIRED.
- [ ] stops or explicitly flags the limitation · [ ] names the command/reason · [ ] writes no files
### 3. Mode/argument variant
**Fixture**: --fix-safe → patches with tests. **Expected**: behaviour differs from case 1 according to the argument: after "yes" the updates are applied on a `chore/deps-<date>` branch with a test run and a `chore(deps): …` commit and PR, never on the default branch.
- [ ] argument parsed · [ ] the difference matches the skill description · [ ] chore branch, test output in the result
### 4. Edge case
**Fixture**: dev-master package → replacement. **Expected**: handled explicitly, never silently skipped.
- [ ] the case is mentioned in the instructions · [ ] correct message/action
### 5. Gate / protocol
**Fixture**: report with consent. **Expected**: the user decides; stage/statuses never change automatically; the write question names `docs/ops/dependency-audit-<date>.md`.
- [ ] no self-advancing · [ ] verdict from the skill's vocabulary · [ ] report path named

### 6. Commit gate on the documents lane
**Fixture**: `--fix-safe` applied two patch updates on `chore/deps-<date>`, then the report was written. **Expected**: right after the write one commit gate offers `docs: dependency audit <date>` staging exactly `docs/ops/dependency-audit-<date>.md`, names the current branch and asks where it belongs (switch to the default branch Recommended for a pipeline-wide document · commit here · leave uncommitted); the lockfile changes stay in the `chore(deps)` commit and are never staged with the document; nothing is committed without the answer.
- [ ] commit gate follows the write · [ ] current branch named · [ ] default-branch option Recommended · [ ] lockfile never rides the `docs:` commit

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
