---
paths: ["**/*.go"]
---
# Go code rules
- `context.Context` first; timeouts on every I/O; graceful shutdown.
- Errors wrapped with `%w`, checked with `errors.Is/As`; `panic` only for impossible states.
- No global mutable state; dependencies through constructors `NewX(deps)`; one constructor per shared dependency graph.
- Router per `go_router` (chi or `net/http` 1.22+); thin handlers, logic below them.
- Layout is a contract, checked by numbers (`make layout-check`, or `wc -l cmd/*/*.go` + `grep -ln 'flag\.\|Fprint' cmd/*/*.go`): `cmd/<app>/main.go` is the only non-test file of a binary, ≤ 50 lines, args/env → `internal/app/<app>.Run` → exit code; sub-commands, flags, wiring, adapters and CLI output in `internal/app/<app>/`; `pkg/` only for external consumers; no `src/`, `utils/`, `common/`; a one-file tool stays `main.go` + `go.mod`. A story that touches `cmd/` reports those numbers. Details: `go.md` "Project layout".
- Architecture per `go_architecture`: `modular` (`internal/<domain>/`) or `layered` (`internal/domain` → `usecase` → `infrastructure`, inwards only, `depguard` + `make arch-check`; ports in the domain; one struct per use case with `Execute`; rich models; handlers and resolvers call use cases). The directory shape is the tree the layout ADR shows. A `layered` story reports the `coverage-gate` lines and the `golangci-lint` issue count. Details: `go.md` "Layered architecture".
- A value library the domain needs goes into `go_domain_allow` through technical-preferences and `/test-setup`, never into `.golangci.yml` by hand.
- Parameterised SQL only (pgx/sqlc); `html/template` for HTML; `log/slog` without secrets.
- GraphQL (gqlgen): the SDL at `api_contract_path`; no schema type named `Query`/`Mutation`/`Subscription` unless it is the root.
- Tests per `rules/tests.md` and `go.md` "Tests by layer"; `go test -race` on the packages touched after each change, the full suite and `make coverage-gate` once before the result.
- `golangci-lint fmt` after every write; `golangci-lint run` and `make arch-check` clean before the result — a finding is fixed in the same story; `govulncheck` in `make ci-full`.
- Reference: `.claude/docs/stack-reference/go.md`.
