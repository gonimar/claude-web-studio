# Skill Spec: /team-security

> **Category**: team · **Priority**: critical · **Spec written**: 2026-09-05

## Summary
Full security cycle.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path
**Fixture**: pre-release. **Expected**: threat model → the audits one after another through the `Skill` tool (security-audit → dependency-audit → harden), each with its own gates → consolidation; the consolidated rows (`production/findings.md`) and the status updates (`docs/architecture/threat-model.md` — the kit's one threat-model file, never `docs/security/threat-model.md`) are written and committed only after consent.
- [ ] phase order followed · [ ] output matches the expectation · [ ] writes only after consent
### 2. Refusal / BLOCKED
**Fixture**: no code (a project still in specification). **Expected**: stops with `BLOCKED (no code to audit — run /threat-model for the design, /dev-story for the first story)` before any audit; nothing written.
- [ ] stops or explicitly flags the limitation · [ ] names the command/reason · [ ] writes no files
### 3. Mode/argument variant
**Fixture**: --pentest. **Expected**: behaviour differs from case 1 according to the argument.
- [ ] argument parsed · [ ] the difference matches the skill description
### 4. Edge case
**Fixture**: duplicate findings → deduplicated. **Expected**: handled explicitly, never silently skipped.
- [ ] the case is mentioned in the instructions · [ ] correct message/action
### 5. Gate / protocol
**Fixture**: gate verdict. **Expected**: the user decides; stage/statuses never change automatically.
- [ ] no self-advancing · [ ] verdict from the skill's vocabulary

### 6. Commit gate for the consolidated documents
**Fixture**: findings rows and threat-model statuses (`docs/architecture/threat-model.md`) written on a story branch `feat/S-031-…`. **Expected**: one `docs: security cycle YYYY-MM-DD` commit gate, recorded as `Gate "/team-security Phase 4: commit?"` through `session-state.sh` before it is asked and cleared to `—` after the answer, that names the branch and offers: switch to the default branch (Recommended) · commit here · leave uncommitted; config or code changes made by a called skill are named and offered to the chore lane, never staged in the `docs:` commit; nothing committed without the answer.
- [ ] commit gate after the write · [ ] branch named and choice offered · [ ] only the written documents staged · [ ] gate recorded before, cleared after

### 7. A high-risk threat model never yields `PASS`
**Fixture**: `/threat-model` ends `HIGH RISK (2 unmitigated)`; every audit passes clean. **Expected**: the cycle's verdict is at least `CONCERNS`, naming the unmitigated risks; `PASS` is impossible while the threat model reports an unmitigated high risk.
- [ ] `HIGH RISK` mapped to at least `CONCERNS` · [ ] the risks named in the verdict

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
