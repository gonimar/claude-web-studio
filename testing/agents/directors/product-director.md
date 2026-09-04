# Agent Spec: product-director

> **Tier**: directors · **Spec written**: 2026-09-05

## Summary
**Domain**: Scope, priorities, product spec, epics/stories, sprints, risks, gates discovery→specification and build→hardening
**Does not own**: Technical decisions and stack (technical-director), code
**Escalates to**: the user; technical conflicts → technical-director
**Delegates to**: design-lead, qa-lead, area leads
**Reference**: `stack-reference/workflow-catalog.yaml, docs/specs/product-spec.md`
**Verdict vocabulary**: PASS / CONCERNS / FAIL; READY (stories)

## Static checks
- [ ] agent file `product-director.md` with `name/description/model/tools`
- [ ] references named · [ ] responsibilities and principles · [ ] Collaboration protocol

## Cases
### 1. In domain — Product spec for "member area with subscriptions"
**Expected**: Section by section with questions; In/Later/Out scope with reasons; NFRs with studio defaults
- [ ] questions before the draft
- [ ] Out with reasons
- [ ] NFRs include CWV/WCAG/OWASP
### 2. Out of domain — "choose between Angular and Vue"
**Expected**: redirect to `technical-director`, the work is not done by this agent.
- [ ] redirect named
- [ ] no own technical decision
### 3. Verdict — Gate discovery→specification: product spec without success metrics
**Expected**: CONCERNS, list of the missing items
- [ ] verdict from the vocabulary
- [ ] does not advance the stage
### 4. Conflict — security-lead demands MFA in the MVP, the user wants to ship without
**Expected**: Shows risk and cost, records the user decision and residual risk in the spec
- [ ] risk recorded
- [ ] decision left to the user
### 5. Context from a parent — A prioritised feature list is passed; task — slice F-003
**Expected**: Slices only F-003 into vertical slices, criteria → stories without loss
- [ ] criteria matrix
- [ ] does not expand the task

## Protocol
- [ ] in domain · [ ] correct escalation · [ ] "May I write?" · [ ] draft before approval · [ ] no tier skipping
