---
name: threat-model
description: "Builds or updates the STRIDE threat model — assets, trust boundaries, attack surfaces (auth, GraphQL/REST, WebSocket, uploads, webhooks, admin, CI/CD, dependencies, infra), threats with likelihood/impact/mitigation, verification. Produces docs/architecture/threat-model.md. Required before build and when a new surface appears."
argument-hint: "[full | <surface>]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion, Task
model: opus
agent: security-lead
---

# Threat Model

Template `.claude/docs/templates/threat-model.md`; `security-baseline.md`, `security-standards.md`, `graphql.md` (security).

## Phase 1: System
Read the product spec (data, jurisdiction), technical-preferences (including Deploy target, Infra repo and Proxy config — proxy requirements need an owner and a file), the API contract, compose/infra, the existing threat model. Draw the DFD (mermaid) with trust boundaries; ask about the non-obvious (external integrations, admin access, payments).

## Phase 2: Surfaces and threats
Per surface — STRIDE threats with likelihood/impact; mitigations referencing the baseline; status (exists/planned/none). GraphQL separately: introspection, complexity, batching, field authorisation, persisted ops. Games — anti-cheat, modified clients, chat spam, room DoS.
`appsec-engineer` and `network-security-engineer` via Task in parallel — complete their areas.

## Phase 3: Priorities
Top 5 unmitigated threats → stories/ADRs; residual risks explicitly accepted by the user.

## Phase 4: Write
"May I write `docs/architecture/threat-model.md`?" — one `AskUserQuestion`: write (Recommended) · show the draft/diff first · not now. Add a "Security" section to affected feature specs with consent.

Verdict: `COMPLETE` | `HIGH RISK (N unmitigated)`. Next step — one `AskUserQuestion`: `/create-stories` for the mitigations (Recommended) · `/security-audit` after implementation · revise the model.
