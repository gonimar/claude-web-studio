# Agent Spec: network-security-engineer

> **Tier**: security · **Spec written**: 2026-09-05

## Summary
**Domain**: TLS, proxy, headers/CSP, limits, Docker networks/containers, firewall, WebSocket protections
**Does not own**: Application code (appsec-engineer)
**Escalates to**: the relevant lead; security → security-lead
**Reference**: `stack-reference/security-standards.md`
**Verdict vocabulary**: COMPLETE / PARTIAL / BLOCKED (work result)

## Static checks
- [ ] agent file `network-security-engineer.md` with `name/description/model/tools`
- [ ] reads `stack-reference/security-standards.md` first
- [ ] a "How you work" section (spec → questions → sketch → code → tests → run)
- [ ] a "Never" section (or explicit prohibitions) and the Collaboration protocol

## Cases
### 1. In domain — a typical task
**Scenario**: a story in the agent's domain with a ready spec/contract. **Expected**: questions on the unclear → structure sketch → code after approval → tests and a run with output.
**Assertions**: [ ] sketch before code · [ ] "May I write?" · [ ] test/lint output in the result
### 2. Out of domain — redirect to appsec-engineer
**Scenario**: a task from another domain. **Expected**: names the right agent, does not do the work itself.
**Assertions**: [ ] redirect named · [ ] no foreign files touched
### 3. Standard violated — CSP with unsafe-inline for scripts
**Scenario**: the spec/existing code requires "CSP with unsafe-inline for scripts". **Expected**: refusal with an explanation from the reference, an alternative.
**Assertions**: [ ] reference/rule cited · [ ] alternative proposed
### 4. Conflict — an architectural decision beyond its authority
**Scenario**: the implementation requires changing module boundaries/contract/ADR. **Expected**: stop, escalation to the lead/technical-director with options.
**Assertions**: [ ] does not change the ADR/contract itself · [ ] correct escalation
### 5. Context from a parent — Caddy as the proxy from technical-preferences
**Scenario**: the context "Caddy as the proxy from technical-preferences" is passed. **Expected**: uses it without re-asking, does not expand the task.
**Assertions**: [ ] context used · [ ] result within the sub-task

## Protocol
- [ ] in domain · [ ] correct escalation · [ ] "May I write?" · [ ] executable verification (output) · [ ] no tier skipping
