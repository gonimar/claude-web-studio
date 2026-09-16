---
paths: ["**/*.go"]
---
# Go code rules
- `context.Context` first parameter; timeouts on any I/O; graceful shutdown.
- Errors wrapped with `%w`, checked with `errors.Is/As`; `panic` only for impossible states.
- No global mutable state; dependencies via constructors `NewX(deps)`.
- `net/http` routing (1.22+ patterns) or chi; thin handlers, logic in `internal/` services.
- Layout per golang-standards/project-layout (adapted, see the reference): `cmd/<app>/main.go` is the only non-test file of a binary (≤ 50 lines: args/env → `internal/app/<app>.Run` → exit code); sub-commands, flags, dependency wiring, adapters and CLI output in `internal/app/<app>/`; domain code in `internal/<domain>/`; `pkg/` only for external consumers; no `src/`, `utils/`, `common/`; a one-file tool stays `main.go` + `go.mod`. Check with `wc -l cmd/*/*.go`, not by eye.
- Parameterised SQL only (pgx/sqlc); `html/template` for HTML.
- GraphQL (gqlgen): the SDL at `api_contract_path` (default `api/schema.graphqls`); no schema type named `Query`/`Mutation`/`Subscription` unless it is the root.
- Architecture style per `go_architecture` in technical-preferences. `layered`: `internal/domain/` → `internal/usecase/` → `internal/infrastructure/`, dependencies inwards only (`depguard` in `.golangci.yml`); ports declared in the domain; one struct per use case with `Execute`; rich models (unexported fields, validating `New…`, invariants in methods, sentinel errors); resolvers/handlers call use cases, never repositories. Directory shape and DTO/bind per `go_layers`, `go_composition_root`, `graphql_models`. Reference: `go.md` "Layered architecture".
- Table-driven tests, `t.Parallel()` where safe, `-race` in CI; `testcontainers` for the DB. Tests by layer (`layered`): domain without doubles, use cases with func-field fakes or `moq`, infrastructure against real containers; coverage gate `scripts/coverage-gate.sh` (domain ≥ 90 %, usecase ≥ 80 % unless technical-preferences says otherwise).
- Formatting after every write: `gofmt` and `goimports` (or `golangci-lint fmt`). A linter finding or a `-race` failure is fixed in the same story, not deferred; the clean run's output goes into the result.
- `log/slog` structured logs without secrets; `govulncheck`, `go vet`, `staticcheck` clean.
- Reference: `.claude/docs/stack-reference/go.md`.
