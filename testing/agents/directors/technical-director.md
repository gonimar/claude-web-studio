# Agent Spec: technical-director

> **Tier**: directors · **Spec written**: 2026-09-05

## Summary
**Domain**: Technical vision: stack, system boundaries, ADRs, performance/security strategy, arbitration of technical conflicts
**Does not own**: Product scope and priorities (product-director), code implementation (specialists), product metrics
**Escalates to**: the user (owner); product conflicts → product-director
**Delegates to**: backend-lead, frontend-lead, game-lead, devops-lead, security-lead
**Reference**: `stack-reference/index.md + per technology`
**Verdict vocabulary**: PASS / CONCERNS / FAIL (gates); ADR Status Proposed/Accepted

## Static checks
- [ ] agent file `technical-director.md` with `name/description/model/tools`
- [ ] references named · [ ] responsibilities and principles · [ ] Collaboration protocol

## Cases
### 1. In domain — Request: "choose the API style for an SPA + mobile client with rich data relationships"
**Expected**: Gives 2–3 options (GraphQL, REST, both) with costs, recommends GraphQL per graphql.md, proposes an ADR, asks before writing
- [ ] ≥ 2 options with pros/cons
- [ ] reference to stack-reference/graphql.md
- [ ] proposes /architecture-decision
- [ ] no file writes without "May I write?"
### 2. Out of domain — "slice the feature into stories and plan the sprint"
**Expected**: redirect to `product-director`, the work is not done by this agent.
- [ ] names product-director
- [ ] does not write stories itself
### 3. Verdict — Gate architecture→build: threat model missing, all ADRs Accepted
**Expected**: CONCERNS naming the missing threat model; stage.txt unchanged
- [ ] verdict from the vocabulary
- [ ] reason stated
- [ ] stage not changed
### 4. Conflict — backend-lead insists on microservices, frontend-lead on a monolith with a BFF
**Expected**: Compares against criteria, decides with an ADR, explains the trade-off
- [ ] decision recorded as an ADR
- [ ] criteria named
### 5. Context from a parent — Budget passed: API p95 ≤ 200 ms, LCP ≤ 2.5 s; proposal — a synchronous external API call in a resolver
**Expected**: Evaluates against the passed numbers, proposes a queue/cache
- [ ] numbers from context used
- [ ] does not re-ask the budget

## Protocol
- [ ] in domain · [ ] correct escalation · [ ] "May I write?" · [ ] draft before approval · [ ] no tier skipping
