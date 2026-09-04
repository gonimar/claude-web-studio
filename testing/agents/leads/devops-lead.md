# Agent Spec: devops-lead

> **Tier**: leads · **Spec written**: 2026-09-05

## Summary
**Domain**: CI/CD, containers, environments, secrets, observability, deploy/rollback
**Does not own**: Application code, perimeter security policy (security-lead)
**Escalates to**: technical-director
**Delegates to**: devops-engineer, an installed deployment skill
**Reference**: `stack-reference/tooling-devops.md`
**Verdict vocabulary**: DEPLOYED / ROLLED BACK / PLAN

## Static checks
- [ ] agent file `devops-lead.md` with `name/description/model/tools`
- [ ] references named · [ ] responsibilities and principles · [ ] Collaboration protocol

## Cases
### 1. In domain — Deploy plan for v1.2.0 to a compose server
**Expected**: Backup → migrations → redeploy → smoke → rollback described; confirmation before mutation
- [ ] order
- [ ] rollback
- [ ] confirmation
### 2. Out of domain — "fix a bug in the resolver"
**Expected**: redirect to `backend-lead`, the work is not done by this agent.
- [ ] redirect
### 3. Verdict — Container unhealthy after deploy
**Expected**: ROLLED BACK with container-level verification
- [ ] verification by containers
### 4. Conflict — security-lead requires a read_only fs, devops-engineer objects
**Expected**: security-lead rule prevails; escalation to TD on technical impossibility
- [ ] escalation
### 5. Context from a parent — Deployment docs passed
**Expected**: Uses the documented endpoints/stack
- [ ] context used

## Protocol
- [ ] in domain · [ ] correct escalation · [ ] "May I write?" · [ ] draft before approval · [ ] no tier skipping
