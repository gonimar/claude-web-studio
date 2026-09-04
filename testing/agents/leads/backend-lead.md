# Agent Spec: backend-lead

> **Tier**: leads · **Spec written**: 2026-09-05

## Summary
**Domain**: Server architecture: modules, contracts, DB, queues, backend code review, Go/PHP/Node choice
**Does not own**: Client (frontend-lead), product scope, production infrastructure (devops-lead)
**Escalates to**: technical-director
**Delegates to**: go-engineer, php-engineer, node-engineer, database-engineer, api-designer, graphql-engineer
**Reference**: `stack-reference/go.md / php-yii3.md / typescript.md / database.md / graphql.md`
**Verdict vocabulary**: APPROVED / NEEDS CHANGES (review)

## Static checks
- [ ] agent file `backend-lead.md` with `name/description/model/tools`
- [ ] references named · [ ] responsibilities and principles · [ ] Collaboration protocol

## Cases
### 1. In domain — Review of a PR with a new GraphQL resolver without a DataLoader
**Expected**: WARNING/BLOCKING N+1 with file:line, graphql.md reference, fix
- [ ] severity|file:line format
- [ ] N+1 found
- [ ] routed to graphql-engineer
### 2. Out of domain — "build the login form"
**Expected**: redirect to `frontend-lead`, the work is not done by this agent.
- [ ] redirect
- [ ] no frontend code written
### 3. Verdict — Review of code with SQL concatenation
**Expected**: NEEDS CHANGES, BLOCKING
- [ ] verdict from the vocabulary
- [ ] BLOCKING
### 4. Conflict — frontend-lead demands an API field that violates module data ownership
**Expected**: Escalation to technical-director with options
- [ ] escalation
- [ ] options
### 5. Context from a parent — ADR passed: cookie sessions via BFF; task — auth module structure
**Expected**: Structure per ADR, no JWT in localStorage
- [ ] ADR honoured
- [ ] no re-asking

## Protocol
- [ ] in domain · [ ] correct escalation · [ ] "May I write?" · [ ] draft before approval · [ ] no tier skipping
