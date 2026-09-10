# Skill Spec: /architecture-decision

> **Category**: authoring · **Priority**: critical · **Spec written**: 2026-09-05

## Summary
ADR with ≥2 options, consequences, verification; retrofit.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path
**Fixture**: "GraphQL vs REST". **Expected**: options with cost, GraphQL recommended per reference, Status Proposed.
- [ ] phase order followed · [ ] output matches the expectation · [ ] writes only after consent
### 2. Refusal / BLOCKED
**Fixture**: retrofit without Status. **Expected**: BLOCKING → add.
- [ ] stops or explicitly flags the limitation · [ ] names the command/reason · [ ] writes no files
### 3. Mode/argument variant
**Fixture**: --review full → area leads. **Expected**: behaviour differs from case 1 according to the argument.
- [ ] argument parsed · [ ] the difference matches the skill description
### 4. Edge case
**Fixture**: conflict with an existing ADR → flagged. **Expected**: handled explicitly, never silently skipped.
- [ ] the case is mentioned in the instructions · [ ] correct message/action
### 5. Gate / protocol
**Fixture**: Accepted only on the user's word. **Expected**: the user decides; stage/statuses never change automatically.
- [ ] no self-advancing · [ ] verdict from the skill's vocabulary

### 6. Review through studio agents
**Fixture**: `--review full`. **Expected**: reviews run before the write gate as parallel `Task`s with `subagent_type: web-studio:backend-lead` / `web-studio:security-lead`, each receiving the full draft; the report names the agents as `agent-audit.log` records them; conditions applied before Phase 4.
- [ ] no general-purpose agent · [ ] full text passed · [ ] review precedes write
### 7. Brownfield status
**Fixture**: the decision is already implemented and deployed. **Expected**: `Status: Proposed · implemented since <date>` until the user says Accepted.
- [ ] no self-assigned Accepted

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
