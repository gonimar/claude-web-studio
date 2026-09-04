---
name: api-contract
description: "Designs the API contract before implementation — GraphQL SDL by default (types, Node/connections, inputs, mutations with payload errors, subscriptions, @auth, persisted operations) or OpenAPI 3.1 / AsyncAPI for REST/events; validates with graphql-inspector / spectral, generates types, documents in docs/architecture/api/. Also game WebSocket protocols."
argument-hint: "[feature F-NNN or area] [--style graphql|rest|events|ws]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, AskUserQuestion, Task
model: sonnet
agent: api-designer
---

# API Contract

Template `.claude/docs/templates/api-contract.md`; references `graphql.md`, `web-platform.md` (REST conventions), rules `api-contracts.md`.

## Phase 1: Scope and style
Style from technical-preferences (GraphQL by default) or `--style`. Read the feature spec (sections 3–5), the current schema (`docs/architecture/api/schema.graphql` / `openapi.yaml`), the threat model (permissions).

## Phase 2: Draft
GraphQL: an SDL fragment — types, `Node`, connections, inputs (`@oneOf`), mutations with `…Payload { …, errors: [UserError!]! }`, subscriptions; field authorisation directives; limits (`first` ≤ 100). Then `graphql-inspector diff` against the current schema (Bash, if installed) — highlight breaking changes.
REST: operations with `operationId`, schemas with limits, `Problem`, cursor pagination, `Idempotency-Key`; `spectral lint`.
WS/games: message types `type/v/seq`, limits, auth at handshake.
Example operations + persisted documents.

## Phase 3: Agreement
Show the table operations → permissions → errors; ask about contentious points (nullability, naming, permissions). When changing an existing contract — `frontend-lead`/`game-lead` via Task to confirm compatibility.

## Phase 4: Write
"May I write `docs/architecture/api/…` and update the api-contract document?" Propose the codegen task (`graphql-codegen`/`gqlgen generate`/`openapi-typescript`) as part of the first story.

Verdict: `APPROVED` | `BREAKING (N)` | `NEEDS REVISION`. Next step: `/data-model` or `/create-stories`.
