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
In the commands below, `<hooks>` is `.claude/hooks/` in copy mode and `${CLAUDE_PLUGIN_ROOT}/hooks/` in plugin mode.

## Phase 1: Scope and style
1. **Style**: `--style`, else technical-preferences (GraphQL by default).
2. **Schema path**: `api_contract_path` from technical-preferences (`api/schema.graphqls` in a Go module, `docs/architecture/api/schema.graphql` / `openapi.yaml` otherwise). The field is set by `/setup-stack`; unset → ask once, and record it in technical-preferences together with the Phase 4 write.
3. **Read** the feature spec (sections 3–5), the current schema at `api_contract_path`, and the threat model (permissions). A feature named in the argument with no spec → `BLOCKED (no feature spec — run /feature-spec F-NNN first)`; write nothing. (`--deprecate` needs no feature spec.)

## Phase 2: Draft
- **GraphQL**: an SDL fragment — types, `Node`, connections, inputs (`@oneOf`), mutations with `…Payload { …, errors: [UserError!]! }`, subscriptions; field authorisation directives; limits (`first` ≤ 100).
  - No object type named `Query`, `Mutation` or `Subscription` other than the roots: gqlgen generates such an entity as a root, and graphql-php's `BuildSchema` takes it as the root. Rename it or declare `schema { … }`.
  - Then run `graphql-inspector diff` against the current schema (Bash, if installed) and highlight breaking changes.
- **REST**: operations with `operationId`, schemas with limits, `Problem`, cursor pagination, `Idempotency-Key`; `spectral lint`.
- **WS/games**: message types `type/v/seq`, limits, auth at handshake.
- **All styles**: example operations + persisted documents.

**`--deprecate <operation|field>`** (a breaking change with external consumers):
1. Name the replacement first (or write it in the same run).
2. Mark the element:
   - GraphQL — `@deprecated(reason: "use X; removed after YYYY-MM-DD")` on the field/argument; the schema keeps both until the date;
   - REST — the operation marked `deprecated: true` with `Sunset`/`Deprecation` headers in the description, and a `/v{n+1}` path when the shape changes.
3. Add a CI check that fails after `--remove-after` while the deprecated element still exists (a `graphql-inspector`/`spectral` rule with the date).
4. Add a `BREAKING` entry for `/changelog` (the release becomes a major).
5. Propose a removal story (`chore(api): remove …`, `📅 <date>`) to `/create-stories`.
6. List the consumers named in the ADR or contract for notification.

Removing without a deprecation period is `BREAKING (N)` and needs the owner's explicit answer.

## Phase 3: Agreement
1. Show the table operations → permissions → errors.
2. Ask about contentious points (nullability, naming, permissions).
3. When changing an existing contract: `frontend-lead`/`game-lead` via Task to confirm compatibility. They report back; any question for the user is asked by this session.

## Phase 4: Write
1. "May I write the schema at `api_contract_path` and update `docs/architecture/api/api-contract.md` (which links to it)?" (plus `api_contract_path` in technical-preferences when Phase 1 asked for it) — one `AskUserQuestion`: write (Recommended) · show the draft/diff first · not now.
2. After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker). Then write.
3. Propose the codegen task (`graphql-codegen`/`gqlgen generate`/`openapi-typescript`) as part of the first story.

## Phase 5: Commit (documents lane)
Right after the write, one commit gate (rule 7, `.claude/docs/git-workflow.md` § Documents): `docs: api contract <F-NNN or area>` (`docs: deprecate <element>` for `--deprecate`), staging exactly the written documents — the schema at `api_contract_path` when the hooks' documents lane lists that path (`api/schema.graphqls`, `graph/schema.graphqls`, `api/openapi.yaml`, anything under `docs/`; `hooks/docs-lane.sh` is the source of truth), `docs/architecture/api/api-contract.md`, and `.claude/docs/technical-preferences.md` when Phase 1 set `api_contract_path`. Before asking, record the gate — `<hooks>session-state.sh set Gate "/api-contract Phase 5: commit?"` — and clear it after the answer (`<hooks>session-state.sh set Gate "—"`).
- **A contract path outside the documents lane** — any `api_contract_path` the hook does not list, e.g. a schema `/adopt` read from `gqlgen.yml` at `internal/graph/schema.graphqls` — never goes into a `docs:` commit on the default branch: the commit hook would warn and the lane would carry code-side files. Say so in the gate question and commit that file as `chore(contract): <F-NNN or area>` on a `chore/<slug>` branch with a PR (git-workflow.md § Chore / infra); the `docs:` commit then carries `api-contract.md` (and technical-preferences) only.
- On the default branch when no story work is in progress.
- When HEAD is a story branch, name it and ask one `AskUserQuestion`: switch to the default branch and commit there (Recommended — a pipeline-wide document) · commit here (the document belongs to this story) · leave uncommitted.
- The CI date rule of `--deprecate` (a workflow or inspector/spectral config), generated types and codegen output are toolchain work, not documents: they do not ride the `docs:` commit. Name them in the result and offer the chore lane for them (git-workflow.md § Chore / infra), or the first story when Phase 4 step 3 put codegen there.

Nothing is committed without the answer.

Verdict: `APPROVED` | `BREAKING (N)` | `NEEDS REVISION` | `BLOCKED (no feature spec)`. Next step — one `AskUserQuestion`: `/data-model` (Recommended) · `/create-stories` · revise the contract.
