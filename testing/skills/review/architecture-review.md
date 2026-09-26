# Skill Spec: /architecture-review

> **Category**: review · **Priority**: critical · **Spec written**: 2026-09-05

## Summary
Cross-check of ADRs/contracts/data/threats; read-only.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path
**Fixture**: all documents exist. **Expected**: status table, PASS.
- [ ] phase order followed · [ ] output matches the expectation · [ ] writes only after consent
### 2. Refusal / BLOCKED
**Fixture**: ADR Proposed > 30 days. **Expected**: a WARNING naming the ADR and its age; verdict at least CONCERNS; fix `/architecture-decision`.
- [ ] stops or explicitly flags the limitation · [ ] names the command/reason · [ ] writes no files
### 3. Mode/argument variant
**Fixture**: adrs → only ADRs. **Expected**: behaviour differs from case 1 according to the argument.
- [ ] argument parsed · [ ] the difference matches the skill description
### 4. Edge case
**Fixture**: a stack fact contradicts the reference → WARNING. **Expected**: handled explicitly, never silently skipped.
- [ ] the case is mentioned in the instructions · [ ] correct message/action
### 5. Gate / protocol
**Fixture**: stage unchanged. **Expected**: the user decides; stage/statuses never change automatically; the hand-off is an `AskUserQuestion` with a Recommended option and alternatives.
- [ ] no self-advancing · [ ] verdict from the skill's vocabulary · [ ] hand-off is an `AskUserQuestion`, not text

### 6. `code` mode drift findings
**Fixture**: `/architecture-review code` on an adopted Go project: a WebSocket endpoint absent from the contract and the threat model; a runtime dependency no ADR names; import direction violating ADR-0003. **Expected**: findings with `file:line` and the contradicted document — the endpoint BLOCKING, the dependency WARNING with the ADR to write, the import direction BLOCKING; BLOCKING go to `production/findings.md` (`ARCH-NNN`) behind the record-or-story gate; nothing else is written.
- [ ] evidence from the tree, not the docs · [ ] findings sink · [ ] read-only otherwise

### 7. Commit gate on the documents lane
**Fixture**: two `ARCH-NNN` rows recorded after case 6 while HEAD is `feat/S-001-…` (a story branch). **Expected**: right after the rows are written one commit gate offers `docs: architecture review findings <date>` staging exactly `production/findings.md`, names the current branch and asks where it belongs (switch to the default branch Recommended for a pipeline-wide document · commit here · leave uncommitted); no gate when no row was recorded; nothing is committed without the answer.
- [ ] commit gate follows the rows · [ ] current branch named · [ ] default-branch option Recommended · [ ] only `production/findings.md` staged

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
