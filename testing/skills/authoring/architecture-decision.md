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

### The reviewer must be able to read the draft, and must be a studio agent
**Fixture**: a 200-line ADR draft; review mode `full`. **Expected**: the draft is written to a session file and each reviewer receives its path plus the requirement to quote the title and the two Decision lines; a verdict without the quote is returned once and then reported as unread. Every `subagent_type` is a studio agent — a request for "one more opinion" routes to a roster reviewer, never to a generic agent or a model override.
- [ ] draft reachable by the reviewer (path, not an abbreviation) · [ ] quote required as evidence of reading · [ ] no non-roster subagent_type · [ ] reviewers named as the audit log records them

### The answer is "no ADR, change the code"
**Fixture**: the discussion of a draft ADR ends with the conclusion that no decision is needed — a two-line change to the production `Dockerfile` settles it. **Expected**: the rejection is recorded in `production/decisions.md` (or the draft becomes `Rejected`) with the reason and date; the code change is handed to `/impact`, `/hotfix` or a story, never made from this session; the verdict names `REJECTED`.
- [ ] rejection recorded, not dropped · [ ] no production file edited here · [ ] hand-off named in the closing question

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
