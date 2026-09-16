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

### 8. Template drift after an update
**Fixture**: the update changes `templates/story.md` and `templates/sprint-plan.md`; the project has six story cards without a criteria table and two sprint files. **Expected**: a "document → template → drift" table before the gate; verdict `UPDATED (8 documents need /migrate)`; the closing question recommends `/migrate all --dry-run`; no project document is edited by `/update`.
- [ ] drift table · [ ] verdict names the count · [ ] /migrate recommended · [ ] documents untouched

### 9. Configured technical-preferences.md survives the seeding
**Fixture**: a project whose `.claude/docs/technical-preferences.md` is filled (`**Type**: game+backend`, pinned versions, rationale for rejected upgrades) and still carries the template's header comment mentioning `[TO BE CONFIGURED]`; `/update` across two versions, seeding agreed at the gate. **Expected**: the file is byte-identical after the run; the seeding step is `install.sh <project> --seed-only` (no hand-written `cp -r` of `docs/`); the summary contains `technical-preferences.md: kept (configured)` and the claim "project data untouched" appears only after `git diff --quiet` on that file has run.
- [ ] file unchanged · [ ] seeding through the installer, not `cp -r` · [ ] "kept (configured)" line · [ ] the untouched claim is backed by the check

### 10. The plugin is installed at a non-user scope
**Fixture**: `claude plugin list --json` reports `web-studio` at scope `local`. **Expected**: Phase 2 shows and runs `claude plugin update web-studio --scope local` (with `-y` when non-interactive), not the bare command; if the scope is unreadable, the skill prints the candidates and asks instead of guessing.
- [ ] scope taken from Phase 1 output · [ ] command carries `--scope` · [ ] no silent assumption of `user`

### 11. A copy-mode install left under the plugin
**Fixture**: the plugin is installed at `local` scope and `.claude/agents` / `.claude/skills` hold a byte-identical copy of an older version, plus one agent and one skill belonging to the project; `.claude/.web-studio-version` names a version that matches neither. **Expected**: Phase 1 reports `HYBRID INSTALL`, names the copy's real version from the cache comparison rather than from the stamp, and lists the project's own files separately; Phase 3 offers the removal as its own gate, moves agent memory to the `web-studio-<agent>` directories (appending `MEMORY.md` pointers, not overwriting), checks `.claude/settings.json` for hooks pointing at the copies, deletes the stamp with the copy and ends with "restart the session".
- [ ] hybrid named, not silently treated as plugin mode · [ ] version from `cmp`, not from the stamp · [ ] project-owned files kept · [ ] memory moved before deletion · [ ] restart line present

### 12. Several projects in one plugin listing
**Fixture**: `claude plugin list --json` returns rows for five projects — four neighbours on 0.10.1 and 0.10.2, this project on 0.10.0. **Expected**: Phase 1 selects the row whose `projectPath` is this project's root and reports 0.10.0, so the update proceeds; the version and the scope never come from a neighbour's row, and a listing with no row for this project is reported as "not installed here" rather than silently read from someone else's.
- [ ] row selected by projectPath · [ ] neighbours' versions never used · [ ] missing row named, not substituted

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
