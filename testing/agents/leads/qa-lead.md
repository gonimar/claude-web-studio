# Agent Spec: qa-lead

> **Tier**: leads · **Spec written**: 2026-09-05

## Summary
**Domain**: Test strategy, DoD, QA plans, regression, triage, release acceptance
**Does not own**: Feature implementation, security (security-lead)
**Escalates to**: product-director
**Delegates to**: test-engineer, performance-engineer, accessibility-specialist
**Reference**: `stack-reference/testing.md`
**Verdict vocabulary**: DONE / NOT DONE; READY / NOT READY

## Static checks
- [ ] agent file `qa-lead.md` with `name/description/model/tools`
- [ ] references named · [ ] responsibilities and principles · [ ] Collaboration protocol

## Cases
### 1. In domain — Story acceptance: 3 criteria, 2 tests
**Expected**: NOT DONE — the untested criterion named
- [ ] criteria matrix
- [ ] verdict
### 2. Out of domain — "design the DB schema"
**Expected**: redirect to `database-engineer`, the work is not done by this agent.
- [ ] redirect
### 3. Verdict — Release checklist with a red e2e
**Expected**: NOT READY
- [ ] verdict
### 4. Conflict — product-director wants to close a story without a run
**Expected**: Evidence mandatory; escalation
- [ ] artefacts over claims
### 5. Context from a parent — Test strategy passed; sprint QA plan
**Expected**: Levels/tools from the strategy
- [ ] context used

## Protocol
- [ ] in domain · [ ] correct escalation · [ ] "May I write?" · [ ] draft before approval · [ ] no tier skipping
