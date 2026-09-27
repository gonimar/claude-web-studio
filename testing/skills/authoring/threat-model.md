# Skill Spec: /threat-model

> **Category**: authoring · **Priority**: critical · **Spec written**: 2026-09-05

## Summary
STRIDE per surface, DFD, mitigations, priorities.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path
**Fixture**: GraphQL + WebSocket + uploads. **Expected**: surfaces include GraphQL specifics and WS; top 5 unmitigated.
- [ ] phase order followed · [ ] output matches the expectation · [ ] writes only after consent
### 2. Refusal / BLOCKED
**Fixture**: no product spec. **Expected**: continues from code with a note.
- [ ] stops or explicitly flags the limitation · [ ] names the command/reason · [ ] writes no files
### 3. Mode/argument variant
**Fixture**: <surface> → only one. **Expected**: behaviour differs from case 1 according to the argument.
- [ ] argument parsed · [ ] the difference matches the skill description
### 4. Edge case
**Fixture**: multiplayer → anti-cheat. **Expected**: handled explicitly, never silently skipped.
- [ ] the case is mentioned in the instructions · [ ] correct message/action
### 5. Gate / protocol
**Fixture**: written after consent. **Expected**: the user decides; stage/statuses never change automatically.
- [ ] no self-advancing · [ ] verdict from the skill's vocabulary

### 7. Write gate order
**Fixture**: STRIDE analysis complete. **Expected**: the draft appears in the chat message, the consent question follows, and `docs/architecture/threat-model.md` is written only after the "write" answer; asking "the file is already written — keep it?" is a failure even if the content is correct.
- [ ] draft before the question · [ ] no Write/Edit before the answer

### 8. Export / deletion surface
**Fixture**: data model §6 classifies personal data. **Expected**: the surfaces table has a "data export / deletion" row: requester, identity check, what is exported and what is not, propagation to replicas, backups and logs, evidence kept; STRIDE threats for it (spoofed requester, tampering with the export, information disclosure).
- [ ] surface present when PII exists · [ ] STRIDE rows · [ ] absent when no PII

### 9. Commit gate on the documents lane
**Fixture**: the model written while HEAD is `feat/S-001-…` (a story branch). **Expected**: right after the write gate one commit gate offers `docs: threat model` staging exactly the written files (`docs/architecture/threat-model.md` and any feature spec that gained a "Security" section), names the current branch and asks where it belongs (switch to the default branch Recommended for a pipeline-wide document · commit here · leave uncommitted); nothing is committed without the answer.
- [ ] commit gate follows the write · [ ] current branch named · [ ] default-branch option Recommended · [ ] nothing committed without the answer

### 10. LLM / MCP surface
**Fixture**: technical-preferences § LLM features = `yes`, `mcp_role: client`, the code imports `@anthropic-ai/sdk` and `@modelcontextprotocol/client`. **Expected**: `references/llm-surface.md` is read and the surfaces table gains rows for direct and indirect prompt injection (tool results, RAG, MCP responses), tool-call side effects / exfiltration, RAG ingestion, secrets in prompts and the connected MCP servers, each with STRIDE letters, likelihood/impact, a mitigation referencing `llm-integration.md` and a status; the DFD draws the third-party-content and model→tool boundaries; a `none` status on injection or side effects reaches the top 5. Fixture without either signal (LLM features `none`, no SDK import): no LLM rows.
- [ ] rows present when a signal exists · [ ] STRIDE + likelihood/impact + status columns · [ ] absent without a signal · [ ] unmitigated injection in the top 5

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
