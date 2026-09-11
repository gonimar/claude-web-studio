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
- Table-driven tests, `t.Parallel()` where safe, `-race` in CI; `testcontainers` for the DB.
- `log/slog` structured logs without secrets; `govulncheck`, `go vet`, `staticcheck` clean.
- Reference: `.claude/docs/stack-reference/go.md`.
