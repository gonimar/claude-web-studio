---
updated: 2026-09-05
sources: [https://go.dev/doc/go1.27, https://go.dev/doc/go1.26, https://go.dev/doc/effective_go, https://google.github.io/styleguide/go/]
---
# Go 1.27 — versions, idioms, practices

## Language by version (so we do not write old-style code)
- **1.27 (2026-08)**: generic methods (methods with their own type parameters); `encoding/json/v2` stable; goroutine-leak profiling; post-quantum crypto in `crypto/*`; faster small allocations; `go doc pkg@version`.
- **1.26 (2026-02)**: `new(expr)` with an initial value; self-referential generic types; Green Tea GC by default (10–40 % less GC overhead); ~30 % cheaper cgo; more stack-allocated slices.
- **1.25**: `testing/synctest` stable; container-aware `GOMAXPROCS`; `go.mod ignore`.
- **1.24**: generic type aliases; `tool` directive in go.mod (`go tool`); Swiss-table maps; `os.Root`; `testing.B.Loop`; `weak`; `crypto/mlkem`.
- **1.23**: `range over func` iterators, `iter`, `slices.Collect`, `maps.Keys`; `unique`.
- **1.22**: per-iteration loop variables; **`net/http.ServeMux` with methods and wildcard patterns** (`GET /users/{id}`); `math/rand/v2`.

The two latest majors are supported (1.27, 1.26). `go.mod`: `go 1.27` → toolchain follows.
Always `go mod tidy`, `go vet`, `govulncheck ./...`.

## Studio default set
| Task | Choice | Why |
|---|---|---|
| HTTP router | `net/http` ServeMux (1.22+); `chi` v5 when middleware groups are needed | The standard library covers 90 %; chi is a thin idiomatic layer |
| Database | `pgx` v5 (pool) + `sqlc` for type-safe queries | No ORM magic, SQL is the source of truth |
| Migrations | `golang-migrate` or `goose` (SQL files) | Transparent, runs from CI |
| Logging | `log/slog` JSON handler | Standard, structured |
| Config | environment variables (`caarlos0/env` / `koanf`) | 12-factor |
| Validation | manual at the boundary; `go-playground/validator` for many DTOs | |
| WebSocket | `coder/websocket` (formerly nhooyr) or `gorilla/websocket` | context-aware, no leaks |
| Tests | `testing` table-driven, `testify` optional, `testcontainers-go` for Postgres | |
| Lint | `gofmt`, `go vet`, `staticcheck`, `golangci-lint` v2 | |
| Docker | multi-stage, `CGO_ENABLED=0`, `distroless/static` or `scratch` | minimal image |

## Idioms
- Errors: `fmt.Errorf("op: %w", err)`, `errors.Is/As`; exported sentinel errors; no panics in library code.
- `context.Context` first argument for anything that waits or does I/O; timeouts on every external call.
- Layout: `cmd/<app>/main.go`, `internal/<domain>/…`; `pkg/` only for genuinely reusable code; no `utils`.
- Interfaces are declared by the consumer, kept small (1–3 methods); accept interfaces, return structs.
- Concurrency: `errgroup` for fan-out; the sender owns the channel; `sync.Once`, `atomic`; `-race` in CI.
- HTTP server: `ReadHeaderTimeout`, `ReadTimeout`, `IdleTimeout`; graceful shutdown on signal; `http.MaxBytesReader` on bodies.
- JSON: `encoding/json/v2` for new code (strict options, streaming); DTOs separate from domain structs.
- Secrets only from the environment; never as command-line flag values.
- Profiling: `net/http/pprof` on an internal port only; `go test -bench` + `benchstat`.

## Security (Go-specific)
- `html/template` (auto-escaping), never `text/template` for HTML.
- Parameterised SQL only (`pgx` `$1`); `sqlc` rules out concatenation.
- `crypto/rand` for tokens; `golang.org/x/crypto/argon2` for passwords; `subtle.ConstantTimeCompare` for comparisons.
- `net/http` follows redirects by default — with SSRF risk, validate URLs (host allow-list, block private IPs after DNS resolution).
- `govulncheck` in CI is mandatory.

## Go review checklist
1. Contexts and timeouts on I/O; 2. errors wrapped and checked; 3. no global state beyond config; 4. goroutines have an owner and an exit; 5. table-driven tests, `-race` passes; 6. `go vet`/`staticcheck` clean; 7. structured logs without secrets.
