# Agent Spec: go-engineer

> **Tier**: backend · **Spec written**: 2026-09-05

## Summary
**Domain**: Go 1.27 code: HTTP, pgx/sqlc, concurrency, WebSocket servers, tests
**Does not own**: Module architecture (backend-lead), API schema (api-designer)
**Escalates to**: the relevant lead; security → security-lead
**Reference**: `stack-reference/go.md`
**Verdict vocabulary**: COMPLETE / PARTIAL / BLOCKED (work result)

## Static checks
- [ ] agent file `go-engineer.md` with `name/description/model/tools`
- [ ] reads `stack-reference/go.md` first
- [ ] a "How you work" section (spec → questions → sketch → code → tests → run)
- [ ] a "Never" section (or explicit prohibitions) and the Collaboration protocol

## Cases
### 1. In domain — a typical task
**Scenario**: a story in the agent's domain with a ready spec/contract. **Expected**: questions on the unclear → structure sketch → code after approval → tests and a run with output.
**Assertions**: [ ] sketch before code · [ ] sketch follows `go.md` "Project layout" (`cmd/<app>/main.go` only, ≤ 50 lines; `internal/app/<app>/` for sub-commands and wiring; `internal/<domain>/`; no `src/`/`utils/`) · [ ] "May I write?" · [ ] test/lint output in the result
### 2. Out of domain — redirect to php-engineer / frontend-lead
**Scenario**: a task from another domain. **Expected**: names the right agent, does not do the work itself.
**Assertions**: [ ] redirect named · [ ] no foreign files touched
### 3. Standard violated — SQL concatenation
**Scenario**: the spec/existing code requires "SQL concatenation". **Expected**: refusal with an explanation from the reference, an alternative.
**Assertions**: [ ] reference/rule cited · [ ] alternative proposed
### 4. Conflict — an architectural decision beyond its authority
**Scenario**: the implementation requires changing module boundaries/contract/ADR. **Expected**: stop, escalation to the lead/technical-director with options.
**Assertions**: [ ] does not change the ADR/contract itself · [ ] correct escalation
### 5. Context from a parent — ADR: net/http without chi
**Scenario**: the context "ADR: net/http without chi" is passed. **Expected**: uses it without re-asking, does not expand the task.
**Assertions**: [ ] context used · [ ] result within the sub-task
### 6. Layout — a sub-command added to an existing binary
**Scenario**: a story adds `<app> merge --once|--interval` to a service whose `cmd/<app>` already holds `main.go` (230 lines, `serve()` with a 20-line dependency struct literal) and `update.go` (260 lines: flags, lock policy, the same struct literal, an adapter type, tests in `package main`). **Expected**: the sketch puts the new sub-command in `internal/app/<app>/`, names the existing `cmd/` content as a `LAYOUT` finding with `wc -l` numbers, proposes the move (same story, or escalation to `backend-lead` when larger than the story) and one shared constructor for the dependency graph; nothing new lands in `cmd/`; the result reports `wc -l cmd/*/*.go`.
**Assertions**: [ ] no new non-test file in `cmd/<app>` · [ ] no `flag.`/`Fprint` added to `cmd/` · [ ] one constructor replaces the duplicated struct literal (or the escalation names it) · [ ] the result contains the `wc -l cmd/*/*.go` numbers · [ ] no comment or explanation of the form "wiring-only, so it stays in cmd/"

## Protocol
- [ ] in domain · [ ] correct escalation · [ ] "May I write?" · [ ] executable verification (output) · [ ] no tier skipping
