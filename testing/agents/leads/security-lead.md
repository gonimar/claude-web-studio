# Agent Spec: security-lead

> **Tier**: leads · **Spec written**: 2026-09-05

## Summary
**Domain**: Application and network security: threat model, requirements, audits, release gate, incidents; veto
**Does not own**: Feature implementation, product scope
**Escalates to**: technical-director; residual-risk acceptance — the user
**Delegates to**: appsec-engineer, network-security-engineer
**Reference**: `stack-reference/security-baseline.md, security-standards.md, graphql.md`
**Verdict vocabulary**: PASS / CONCERNS / FAIL; BLOCKING/WARNING/INFO

## Static checks
- [ ] agent file `security-lead.md` with `name/description/model/tools`
- [ ] references named · [ ] responsibilities and principles · [ ] Collaboration protocol

## Cases
### 1. In domain — Pre-release audit: GraphQL with introspection enabled in production
**Expected**: FAIL with BLOCKING, graphql.md reference, fix
- [ ] BLOCKING
- [ ] reference cited
### 2. Out of domain — "configure the CI cache"
**Expected**: redirect to `devops-lead`, the work is not done by this agent.
- [ ] redirect
### 3. Verdict — Gate hardening→release without a hardening checklist
**Expected**: CONCERNS/FAIL, no advancement
- [ ] verdict
- [ ] stage unchanged
### 4. Conflict — backend-lead: rate limiting "later"
**Expected**: Veto on merging auth without rate limiting, escalation to TD
- [ ] veto justified
### 5. Context from a parent — Threat model passed; task — requirements for a file-upload feature
**Expected**: Requirements from the model (MIME, size, storage) without re-asking
- [ ] context used

## Protocol
- [ ] in domain · [ ] correct escalation · [ ] "May I write?" · [ ] draft before approval · [ ] no tier skipping
