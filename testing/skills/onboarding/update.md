# Skill Spec: /update

> **Category**: onboarding · **Priority**: high · **Spec written**: 2026-09-05

## Summary
Update the studio in the project (plugin update or copy-mode reinstall); local edits preserved.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path
**Fixture**: plugin v0.3.0 available, project on v0.2.0. **Expected**: CHANGELOG delta, diff of docs/rules, question about local edits, update, summary.
- [ ] phase order followed · [ ] output matches the expectation · [ ] writes only after consent
### 2. Refusal / BLOCKED
**Fixture**: plugin not installed and no kit path. **Expected**: asks for the path.
- [ ] stops or explicitly flags the limitation · [ ] names the command/reason · [ ] writes no files
### 3. Mode/argument variant
**Fixture**: --dry-run → no changes. **Expected**: behaviour differs from case 1 according to the argument.
- [ ] argument parsed · [ ] the difference matches the skill description
### 4. Edge case
**Fixture**: a locally edited rule → copy in local-overrides. **Expected**: handled explicitly, never silently skipped.
- [ ] the case is mentioned in the instructions · [ ] correct message/action
### 5. Gate / protocol
**Fixture**: project data untouched — confirmed. **Expected**: the user decides; stage/statuses never change automatically.
- [ ] no self-advancing · [ ] verdict from the skill's vocabulary

### 6. Plugin updated while the gate was open
**Fixture**: the session's skills come from v0.7.0; the "Update 0.4.3 → 0.7.0?" gate stays open; meanwhile `claude plugin list --json` reports v0.8.0. **Expected**: after "yes" the skill re-reads the installed version before copying, notices the mismatch, prints the one-line restart instruction and ends with `RESTART REQUIRED`; nothing is seeded from the session's cache and `.claude/.web-studio-version` is not written.
- [ ] version re-read after the gate, not only in Phase 1 · [ ] mismatch named with both versions · [ ] no files written, verdict `RESTART REQUIRED`

### 7. Local edit in a seeded doc
**Fixture**: `.claude/docs/agent-roster.md` carries a project-added column. **Expected**: the file is listed as locally edited before the gate; the question offers "keep copies in `.claude/local-overrides/`"; the skill never drops the edit on its own judgement.
- [ ] local edits listed before the question · [ ] local-overrides option present · [ ] edit preserved or copied

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
