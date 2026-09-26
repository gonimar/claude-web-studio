---
name: architecture-review
description: "Cross-checks ADRs, API contracts, data model, threat model and feature specs for consistency and feasibility before build; verifies stack facts against the stack reference; `code` mode checks the repository itself against the ADRs, contract and threat model (module boundaries, dependencies, entry points, surfaces) and records drift as findings. Read-only report with PASS / CONCERNS / FAIL. Run at the architecture→build gate, quarterly, and on an adopted project."
argument-hint: "[full | adrs | contracts | code]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Write, Edit, Task, AskUserQuestion
model: opus
agent: technical-director
---

# Architecture Review

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

Read-only; the report goes to the chat. The one exception is `production/findings.md`: BLOCKING/HIGH
findings are recorded there, and only after the "record" answer of their gate (Phase 3). Bash is for
reading the tree in `code` mode (`go list`, `make arch-check`, `wc -l`), never for changing it.

A studio agent is `web-studio:<name>` in plugin mode and `<name>` in copy mode; a command in a hand-off is
`/web-studio:<command>` in plugin mode and `/<command>` in copy mode (coordination-rules § Subagents).

## Phase 1: Collect
1. **Scope from the argument**: `adrs` → the ADR checks only; `contracts` → the contract and what it must cover; `code` → Phase 2 step 6; `full` or none → Phase 2 steps 1–5.
2. **Read**: all `docs/architecture/adr-*.md`; `docs/architecture/api/*` and the schema file at `api_contract_path` (technical-preferences; default `api/schema.graphqls` for a Go module, `docs/architecture/api/schema.graphql` otherwise); `data-model.md`; `threat-model.md`; `test-strategy.md`; `docs/specs/features/*.md`; `technical-preferences.md`; `stack-reference/index.md` (and `go.md` / `php.md` in `code` mode).

## Phase 2: Checks
1. **Consistency**: ADRs do not contradict each other or technical-preferences; the contract covers the feature-spec operations; the data model covers the contract's data; the threat model covers the contract's surfaces (GraphQL/WS/uploads).
2. **ADR completeness**: Status/Options/Consequences/Verification; accepted ADRs are `Accepted`.
3. **Stack facts**: versions and claims in ADRs match the stack reference (a release the reference marks as RC, a library it says has no SemVer, a directive it says is outside the GraphQL spec). A contradiction is a WARNING.
4. **Feasibility**: performance budgets realistic; basic security measures present; the test strategy covers the levels.
5. **Leads, in parallel via `Task`**: `backend-lead`, `frontend-lead`, `security-lead` (and `game-lead` for games), each for the top 3 risks in their area.
6. **`code` mode (brownfield, quarterly)**: the repository against the documents, from evidence in the tree, never from the documents' claims.
   1. **Module boundaries and dependency direction** (`go list -deps` / import graphs / `composer` autoload / TS project references) against the ADRs that name them.
   2. **Entry points** (routes, resolvers, handlers, WebSocket endpoints, cron/queue consumers, webhooks) against the contract and the threat model's surfaces table. An entry point absent from both is **BLOCKING** drift.
   3. **Runtime dependencies** in the manifests against the ADRs that admit them. A dependency no ADR names → WARNING, with the ADR to write.
   4. **Migrations** against the data model; the **deployment topology** (compose, workflows) against the deployment ADR.
   5. **PHP under `php_architecture: layered`**: the dependency direction by `composer arch-check` (deptrac), or without it `grep -rlE 'use (FRAMEWORK_NAMESPACES|App\\Infrastructure)\\' src/Domain src/Application` with the namespaces of the recorded `php_framework`. A hit is BLOCKING drift, citing the ADR that chose the style. A missing `deptrac.yaml`, or a `php_architecture` the tree does not show, is WARNING drift (fix: `/refactor layout --dry-run`).
   6. **Go under `go_architecture: layered`**: the dependency direction by the graph. `go list -deps ./internal/domain/...` must name no `internal/usecase`, `internal/infrastructure` or `internal/app` package, and `go list -deps ./internal/usecase/...` no `internal/infrastructure`/`internal/app` package (`make arch-check` is the transitive graph check; `golangci-lint run` adds the per-file depguard view with third-party packages). A hit is BLOCKING drift, citing the ADR that chose the style. A `.golangci.yml` without the `depguard` block, or a `go_architecture` in technical-preferences that the tree does not show, is WARNING drift (fix: `/refactor layout --dry-run`).
   7. **Go `cmd/<app>`** against `go.md` "Project layout": `wc -l cmd/*/*.go`; anything but a `main.go` of ≤ 50 lines is WARNING drift, even when the layout ADR lists only directories, because the convention's rule is about how much code, not which folders exist (fix: a story moving it to `internal/app/<app>`).
   8. **Each finding**: `file:line`, the document it contradicts, the fix (`/architecture-decision`, `/api-contract`, `/threat-model <surface>`, or a code story).

## Phase 3: Report
1. **Table** "document → status → findings (BLOCKING/WARNING/INFO)", then the verdict `PASS` / `CONCERNS` / `FAIL` with reasons.
2. **Findings sink** (`code` mode): for every BLOCKING/HIGH finding, one `AskUserQuestion` — record it in `production/findings.md` (template `findings.md`; id `ARCH-NNN`, severity, area, the decision needed) (Recommended) · story stubs now via `/create-stories` · report only. The "record" answer is the "May I write `production/findings.md`?" consent: after it, `touch .claude/.write-consent` (rule 7), then write the row; never before the answer. `/create-stories` and `/sprint-plan` read that file, not this report.
3. Never change `stage.txt`; only recommend.

Next step — one `AskUserQuestion`:
- on PASS: `/create-stories` (Recommended) · re-run the review after fixes · stop here;
- otherwise: the specific `/architecture-decision retrofit …` / `/api-contract` (Recommended) · proceed with the CONCERNS recorded · stop here.
