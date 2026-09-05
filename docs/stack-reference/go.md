---
updated: 2026-09-05
sources: [https://go.dev/doc/go1.27, https://go.dev/doc/go1.26, https://go.dev/doc/effective_go, https://google.github.io/styleguide/go/, https://go.dev/doc/modules/layout, https://github.com/golang-standards/project-layout]
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
- Layout: see "Project layout" below — `cmd/<app>/main.go`, `internal/<domain>/…`; `pkg/` only for genuinely reusable code; no `utils`, no `src/`.
- Interfaces are declared by the consumer, kept small (1–3 methods); accept interfaces, return structs.
- Concurrency: `errgroup` for fan-out; the sender owns the channel; `sync.Once`, `atomic`; `-race` in CI.
- HTTP server: `ReadHeaderTimeout`, `ReadTimeout`, `IdleTimeout`; graceful shutdown on signal; `http.MaxBytesReader` on bodies.
- JSON: `encoding/json/v2` for new code (strict options, streaming); DTOs separate from domain structs.
- Secrets only from the environment; never as command-line flag values.
- Profiling: `net/http/pprof` on an internal port only; `go test -bench` + `benchstat`.

## Project layout (golang-standards/project-layout, adapted)
Source: [golang-standards/project-layout](https://github.com/golang-standards/project-layout) — a
community convention, **not an official standard of the Go team**; the official baseline is
[Organizing a Go module](https://go.dev/doc/modules/layout) (`cmd/`, `internal/`). The studio uses the
subset below inside the Go root (`backend_root` in technical-preferences; `./` for a Go-only repo).

**Size rule (from the convention itself)**: a PoC, a single tool or a learning project is `main.go` +
`go.mod` — the full layout is overkill. Introduce `cmd/` + `internal/` with the second binary or the
second package; every other directory only when something real goes into it. Never create empty
directories "for later".

| Directory | Studio usage |
|---|---|
| `cmd/<app>/main.go` | One directory per binary, named after the executable (`cmd/api`, `cmd/worker`). `main` wires config, dependencies, server and graceful shutdown — no business logic. |
| `internal/` | All application code; privacy enforced by the compiler. Domains as `internal/<domain>/` (handler → service → repository/sqlc); private shared code (`config`, `db`, `logging`, `auth`) in `internal/platform/` (or `internal/pkg/`) once two or more domains use it. |
| `pkg/` | Only code deliberately importable by other modules (SDK, client library, shared protocol types). Empty by default; the convention notes it is contested in the community — it is not an "everything else" bucket. |
| `api/` | Protobuf, JSON Schema, generated stubs that ship with the module. The contract source of truth stays `docs/architecture/api/` (GraphQL SDL / OpenAPI); embed or copy it in CI, never fork it. |
| `configs/` | Config templates and defaults (`config.example.yaml`, `.env.example`); never secrets. |
| `scripts/` | Build, migrate, lint, release helpers called from `Makefile` / CI so the Makefile stays small. |
| `build/` | Packaging: Dockerfiles and package specs in `build/package/`. CI stays in `.github/workflows/` (GitHub requires the path), so `build/ci/` is unused. |
| `deployments/` | Compose files, Helm charts, Terraform for this service. In a monorepo the cross-app compose stack stays at the repo root. |
| `test/` | External test apps, fixtures, load scripts (k6), `test/testdata/` (ignored by the toolchain). Unit tests stay next to the code as `_test.go`. |
| `tools/` | Supporting tools that may import `internal/` and `pkg/`; tool dependencies via the `tool` directive in `go.mod` (1.24+), not `tools.go`. |
| `web/` | Templates and static assets served by Go itself (`embed`). The SPA lives in `frontend_root`, not here. |
| `docs/`, `examples/`, `third_party/`, `githooks/`, `assets/`, `website/` | As in the convention when needed. `docs/` in a studio project already holds specs, ADRs and contracts (see `directory-structure.md`). |
| `vendor/` | Not committed: the module proxy and `go.sum` suffice. Commit only for air-gapped builds. |
| `init/` | systemd / supervisor units — only for non-container deployments. |

**Never**: `src/` (a Java habit; the convention lists it under "directories you shouldn't have");
`utils/`, `common/`, `helpers/` packages; business logic in `cmd/`; a `pkg/` created before an external
consumer exists; several `main` packages in one directory.

Monorepo mapping: `backend/` is the Go root with `go.mod`; `cmd/`, `internal/` and the rest live under it.
`go.work` only when there are several modules. The chosen variant is recorded as `go_layout` in
`technical-preferences.md` ("Layout").

## Security (Go-specific)
- `html/template` (auto-escaping), never `text/template` for HTML.
- Parameterised SQL only (`pgx` `$1`); `sqlc` rules out concatenation.
- `crypto/rand` for tokens; `golang.org/x/crypto/argon2` for passwords; `subtle.ConstantTimeCompare` for comparisons.
- `net/http` follows redirects by default — with SSRF risk, validate URLs (host allow-list, block private IPs after DNS resolution).
- `govulncheck` in CI is mandatory.

## Go review checklist
1. Contexts and timeouts on I/O; 2. errors wrapped and checked; 3. no global state beyond config; 4. goroutines have an owner and an exit; 5. table-driven tests, `-race` passes; 6. `go vet`/`staticcheck` clean; 7. structured logs without secrets.
