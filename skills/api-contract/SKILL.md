---
name: api-contract
description: "Designs the API contract before implementation — GraphQL SDL by default (types, Node/connections, inputs, mutations with payload errors, subscriptions, @auth, persisted operations) or OpenAPI 3.1 / AsyncAPI for REST/events; validates with graphql-inspector / spectral, generates types, documents in docs/architecture/api/. Also game WebSocket protocols."
argument-hint: "[feature F-NNN or area] [--style graphql|rest|events|ws] | --deprecate <operation or field> [--remove-after YYYY-MM-DD]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, AskUserQuestion, Task
model: sonnet
agent: api-designer
---

# API Contract

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

Template `.claude/docs/templates/api-contract.md`; references `graphql.md`, `web-platform.md` (REST conventions), rules `api-contracts.md`.

## Phase 1: Scope and style
Style from technical-preferences (GraphQL by default) or `--style`. Read the feature spec (sections 3–5), the current schema (`docs/architecture/api/schema.graphql` / `openapi.yaml`), the threat model (permissions).

## Phase 2: Draft
GraphQL: an SDL fragment — types, `Node`, connections, inputs (`@oneOf`), mutations with `…Payload { …, errors: [UserError!]! }`, subscriptions; field authorisation directives; limits (`first` ≤ 100). Then `graphql-inspector diff` against the current schema (Bash, if installed) — highlight breaking changes.
REST: operations with `operationId`, schemas with limits, `Problem`, cursor pagination, `Idempotency-Key`; `spectral lint`.
WS/games: message types `type/v/seq`, limits, auth at handshake.
Example operations + persisted documents.
**`--deprecate <operation|field>`** (a breaking change with external consumers): the replacement is named first (or written in the same run); GraphQL — `@deprecated(reason: "use X; removed after YYYY-MM-DD")` on the field/argument, the schema keeps both until the date; REST — the operation marked `deprecated: true` with `Sunset`/`Deprecation` headers in the description and a `/v{n+1}` path when the shape changes; a CI check that fails after `--remove-after` while the deprecated element still exists (`graphql-inspector`/`spectral` rule with the date); a `BREAKING` entry for `/changelog` (the release becomes a major); a removal story (`chore(api): remove …`, `📅 <date>`) proposed to `/create-stories`; consumers named in the ADR or contract are listed for notification. Removing without a deprecation period is `BREAKING (N)` and needs the owner's explicit answer.

## Phase 3: Agreement
Show the table operations → permissions → errors; ask about contentious points (nullability, naming, permissions). When changing an existing contract — `frontend-lead`/`game-lead` via Task to confirm compatibility.

## Phase 4: Write
"May I write `docs/architecture/api/…` and update the api-contract document?" — one `AskUserQuestion`: write (Recommended) · show the draft/diff first · not now. Propose the codegen task (`graphql-codegen`/`gqlgen generate`/`openapi-typescript`) as part of the first story. After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker).

Verdict: `APPROVED` | `BREAKING (N)` | `NEEDS REVISION`. Next step — one `AskUserQuestion`: `/data-model` (Recommended) · `/create-stories` · revise the contract.
