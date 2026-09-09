# Skill Spec: /impact

> **Category**: review · **Priority**: high · **Spec written**: 2026-09-09

## Summary
Triage of a change proposal that arrives in the conversation rather than through an approved story: classification (architecture · security · product · routine) from the artifacts and paths it touches, a short verdict from the owner of each triggered class (`technical-director`, `security-lead`, `product-director`), a hand-off to the commands the verdict requires. Writes only session-state.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path — architecture class
**Fixture**: ADR-0002 pins REST; the user proposes "let's expose the catalogue over GraphQL too". **Expected**: classification table with the evidence row "architecture · contradicts ADR-0002 · docs/architecture/adr-0002-api-style.md"; one `Task` to `technical-director`; a verdict within 15 lines that names the commands (`/architecture-decision`, then `/api-contract`); the hand-off `AskUserQuestion` offers `/architecture-decision` first.
- [ ] evidence cites the ADR path · [ ] only technical-director spawned · [ ] verdict carries commands · [ ] hand-off is the first command
### 2. Refusal / BLOCKED — security veto
**Fixture**: the proposal stores the OAuth refresh token in `localStorage`; `threat-model.md` lists browser storage of credentials as a rejected surface. **Expected**: security class from the threat-model row; `security-lead` returns `BLOCKED (reason)`; surfaced immediately; the hand-off offers revise (Recommended) · record the rejection as an ADR · stop; nothing written except session-state.
- [ ] BLOCKED surfaced with reason · [ ] no document written · [ ] hand-off options as specified
### 3. Mode/argument variant — `--classify-only` and `solo`
**Fixture**: `--classify-only` with a two-class proposal; separately review mode `solo`. **Expected**: with the flag — the table, verdict `CLASSIFIED (architecture, security)`, no `Task`; in `solo` — the table, then one `AskUserQuestion` (verify (Recommended) · skip) before any spawn.
- [ ] flag stops before Phase 3 · [ ] solo asks before spawning
### 4. Edge case — routine inside the active story
**Fixture**: session-state names S-007; the proposal is a rename of a field the story's criteria already cover. **Expected**: `ROUTINE` in one line, no verifier, hand-off to `/dev-story S-007`.
- [ ] no spawn · [ ] names the story · [ ] hand-off to /dev-story
### 5. Gate / protocol — verdict without commands
**Fixture**: the verifier answers "approved" with no commands. **Expected**: the skill sends it back once asking for the commands; a second incomplete reply is reported as incomplete, never padded; the verdict table shows it as such.
- [ ] one retry · [ ] no invented commands · [ ] reported honestly
### 6. Two classes in parallel
**Fixture**: the proposal adds a file-upload endpoint (new dependency for image processing + an upload surface). **Expected**: architecture and security rows; `technical-director` and `security-lead` in one parallel batch; the combined table; commands ordered `/architecture-decision` → `/threat-model` → `/api-contract` → `/create-stories`.
- [ ] one batch of two Tasks · [ ] combined table · [ ] pipeline order kept
### 7. Marker and session state
**Fixture**: any verified proposal. **Expected**: `Notes:` gets a dated `impact:` line, `Next:` the first command, `.claude/.impact-verdict` touched; no other file changes.
- [ ] session-state updated · [ ] marker touched · [ ] no other writes

## Protocol
- [ ] draft (the table) before any spawn · [ ] next step as `AskUserQuestion` · [ ] never advances the stage itself · [ ] artefacts over claims (evidence rows cite files)
