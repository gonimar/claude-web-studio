# Agent Spec: frontend-lead

> **Tier**: leads · **Spec written**: 2026-09-05

## Summary
**Domain**: Client architecture: structure, state, components, build, frontend review, Angular vs Vue
**Does not own**: Server logic, DB schema, design tokens (design-lead)
**Escalates to**: technical-director
**Delegates to**: angular-engineer, vue-engineer, typescript-engineer, css-engineer, accessibility-specialist, seo-specialist, performance-engineer
**Reference**: `stack-reference/angular.md / vue.md / typescript.md / graphql.md / web-platform.md`
**Verdict vocabulary**: APPROVED / NEEDS CHANGES

## Static checks
- [ ] agent file `frontend-lead.md` with `name/description/model/tools`
- [ ] references named · [ ] responsibilities and principles · [ ] Collaboration protocol

## Cases
### 1. In domain — Design the structure of an Angular 22 app with GraphQL
**Expected**: feature slices, signals, lazy routes, Apollo Angular + codegen, tokens via BFF cookie
- [ ] standalone+signals
- [ ] codegen from the schema
- [ ] HttpOnly cookie
### 2. Out of domain — "write a DB migration"
**Expected**: redirect to `backend-lead / database-engineer`, the work is not done by this agent.
- [ ] redirect
### 3. Verdict — Review of a component with *ngFor and a subscription without takeUntilDestroyed
**Expected**: NEEDS CHANGES citing angular-code.md rules
- [ ] verdict
- [ ] rule referenced
### 4. Conflict — design-lead demands a custom component instead of Material
**Expected**: Cost discussion, escalation to technical-director on disagreement
- [ ] correct escalation
### 5. Context from a parent — SDL contract passed; task — UI story plan
**Expected**: Uses schema types, does not re-ask fields
- [ ] context used

## Protocol
- [ ] in domain · [ ] correct escalation · [ ] "May I write?" · [ ] draft before approval · [ ] no tier skipping
