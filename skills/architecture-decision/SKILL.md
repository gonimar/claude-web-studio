---
name: architecture-decision
description: "Creates an Architecture Decision Record (context, ≥2 options with costs, decision, consequences, verification) or retrofits an existing ADR to the template. Every significant technical choice (stack, API style, auth, data, engine, deployment) gets an ADR before code."
argument-hint: "[title] | retrofit [path] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, WebFetch, AskUserQuestion, Task
model: sonnet
agent: technical-director
---

# Architecture Decision Record

Template `.claude/docs/templates/adr.md`; files `docs/architecture/adr-NNNN-<slug>.md`.

## Phase 0: Mode
`retrofit <path>` — read the existing ADR, find missing sections (Status — BLOCKING; Options/Consequences/Verification — HIGH), propose adding them without changing existing text; "May I write?".

## Phase 1: Context
Read technical-preferences, the product spec, related feature specs, existing ADRs (dependencies, contradictions), the relevant `stack-reference/` file (version facts come from there; when in doubt `WebFetch` the official source).

## Phase 2: Options
≥ 2 options (including "do nothing" where relevant) with pros/cons/cost/risk/maturity. For the studio's typical forks use the known arguments: GraphQL vs REST (see `graphql.md`), Go vs PHP vs Node, Angular vs Vue, three.js vs Pixi vs Phaser, sessions vs JWT, monolith vs services, Caddy vs nginx. Give an explicit recommendation.

## Phase 3: Decision and consequences
Draft Decision/Consequences/Verification (how we will check: metric, spike, test; when we revisit). Review per mode: `full` — `backend-lead`/`frontend-lead`/`security-lead` for affected areas via Task; `lean` — `security-lead` when auth/data/network are affected; `solo` — none.

## Phase 4: Write
"May I write `docs/architecture/adr-NNNN-<slug>.md` and a line in the technical-preferences decision log?" Status is `Proposed` until the user says `Accepted`.

Verdict: `ACCEPTED` | `PROPOSED` | `NEEDS REVISION`. Next step: `/api-contract` / `/data-model` / `/create-stories`.
