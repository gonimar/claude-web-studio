---
updated: 2026-09-17
sources: [https://go.dev/doc/go1.27, https://go.dev/doc/go1.26, https://go.dev/doc/effective_go, https://google.github.io/styleguide/go/, https://go.dev/doc/modules/layout, https://github.com/golang-standards/project-layout, https://golangci-lint.run/docs/linters/configuration/#depguard, https://gqlgen.com/config/, https://pkg.go.dev/testing/synctest]
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
| HTTP router | `chi` v5 (recommended) or `net/http` ServeMux (1.22+) — chosen in `/setup-stack`, recorded as `go_router` | chi is a thin idiomatic layer with middleware groups; the standard library covers a service without them. Request logging through `slog` (a middleware of the project's own or `httplog` on slog) — chi's `middleware.Logger` is plain text, not structured |
| Database | `pgx` v5 (pool) + `sqlc` for type-safe queries | No ORM magic, SQL is the source of truth |
| Migrations | `golang-migrate` or `goose` (SQL files) | Transparent, runs from CI |
| Logging | `log/slog` JSON handler | Standard, structured |
| Config | environment variables (`caarlos0/env` / `koanf`) | 12-factor |
| Validation | manual at the boundary; `go-playground/validator` for many DTOs | |
| WebSocket | `coder/websocket` (formerly nhooyr) or `gorilla/websocket` | context-aware, no leaks |
| Tests | `testing` table-driven, `testify` optional, `testcontainers-go` for Postgres, `synctest` for time, `moq` for ports with more than three methods | See "Tests by layer" below |
| Lint | `gofmt` + `goimports`, `go vet`, `staticcheck`, `golangci-lint` v2 (`version: "2"` config; a v1 `linters-settings:` file is rejected by v2) | Template `docs/templates/go/golangci.yml`; `depguard` enforces the layer rule when `go_architecture: layered` |
| Docker | multi-stage, `CGO_ENABLED=0`, `distroless/static` or `scratch` | minimal image |

## Idioms
- Errors: `fmt.Errorf("op: %w", err)`, `errors.Is/As`; exported sentinel errors; no panics in library code.
- `context.Context` first argument for anything that waits or does I/O; timeouts on every external call.
- Layout: see "Project layout" below — `cmd/<app>/main.go`, `internal/…`; `pkg/` only for genuinely reusable code; no `utils`, no `src/`. The inside of `internal/` follows the architecture style (`go_architecture`, next section).
- Interfaces are declared by the consumer, kept small (1–3 methods); accept interfaces, return structs. Exception under `go_architecture: layered`: repository and gateway **ports** are declared in the domain package (see "Layered architecture"), because the domain is the one that states what it needs from the outside world.
- Concurrency: `errgroup` for fan-out; the sender owns the channel; `sync.Once`, `atomic`; `-race` in CI.
- HTTP server: `ReadHeaderTimeout`, `ReadTimeout`, `IdleTimeout`; graceful shutdown on signal; `http.MaxBytesReader` on bodies.
- JSON: `encoding/json/v2` for new code (strict options, streaming); DTOs separate from domain structs.
- Secrets only from the environment; never as command-line flag values.
- Profiling: `net/http/pprof` on an internal port only; `go test -bench` + `benchstat`.

## Architecture style (`go_architecture` in technical-preferences)
Two styles; the choice is made once in `/setup-stack` (or recorded by `/adopt` from the tree) and changed only
through `/refactor layout` with an ADR — never story by story.

| Style | Inside `internal/` | When |
|---|---|---|
| `modular` | One package per domain, `internal/<domain>/` with handler → service → repository in it; shared code in `internal/platform/` | A single tool, a small service, a brownfield project adopted as it is |
| `layered` | Three layers with a compiler-checked dependency direction: `internal/domain/` → `internal/usecase/` → `internal/infrastructure/` (DDD, ports & adapters) | A service with business rules, several entry points (GraphQL + REST + worker), a team that wants the rules in one place |

`cmd/<app>/main.go` and `internal/app/<app>/` (the composition root) are the same in both styles — see "Project layout".

## Layered architecture (`go_architecture: layered`)
Dependencies point inwards only. Each layer imports the ones below it, never above; the domain imports
nothing of the project and nothing outside the standard library (plus the value libraries listed in
`go_domain_allow`, e.g. `github.com/google/uuid`, `github.com/shopspring/decimal` — never a driver, a
framework, a transport or a logger).

| Layer | Package | Contains | Never |
|---|---|---|---|
| Domain | `internal/domain/<ctx>/` | Entities and aggregates as **rich models** (unexported fields, a validating constructor `New…`, operations as methods that keep the invariants, exported sentinel errors `ErrX`), value objects, domain events, and the **ports**: `Repository`, gateway interfaces the use cases need | Importing `usecase`/`infrastructure`; frameworks; SQL; HTTP; `context` is allowed in port signatures |
| Use cases | `internal/usecase/<ctx>/` (per bounded context, recommended) or one `internal/usecase/` package — the shape the layout ADR's tree shows | **One struct per scenario** with one method `Execute(ctx, Input) (Output, error)`; a constructor taking the ports; orchestration, transactions (through a `TxManager` port), calls into the domain, emitting events | Importing `infrastructure`; business rules (they belong to the entity); knowing SQL, HTTP or GraphQL types |
| Infrastructure | `internal/infrastructure/postgres/`, `…/transport/graphql/`, `…/transport/http/`, `…/mail/`, … | Adapters implementing the ports (sqlc/pgx repositories, `Rehydrate`-style loading of entities), the gqlgen server and resolvers, chi/ServeMux handlers, clients; DTOs and mapping to/from the domain | Business rules; a resolver or handler that calls a repository directly instead of a use case |
| Composition root | `internal/app/<app>/` | `Run`, config, the dependency graph (`newServices`), the HTTP server with timeouts and graceful shutdown, signal handling | Anything the four rows above own |
| Entry | `cmd/<app>/main.go` | ≤ 50 lines: args/env → `Run` → exit code | Everything else (see "Project layout") |

The names are the studio's; the shape is the one the cited sources describe. The go-clean-template repository (evrone) keeps the graph in
`internal/app` and calls the layers `internal/entity`, `internal/usecase`, `internal/repo` (driven adapters) and
`internal/controller` (driving adapters) — `domain` ≙ `entity`, `infrastructure` ≙ `repo` + `controller`; `/adopt` recognises
both spellings as `layered`. The official "Organizing a Go module" page prescribes only `cmd/` + `internal/` for a server and
no exported packages; project-layout adds `/internal/app/<app>` and `/internal/pkg`. The go-structure-examples repository from the 2018 "How do you structure your Go apps" talks is cited
by guides, but its README marks the talks as outdated — history, not a reference.

Directory shape is a recorded choice, not taste: `/setup-stack` shows the tree for the chosen shape and the layout ADR keeps
it (`/refactor` asks again when the tree and the ADR disagree, or in a full pass): one use-case package per bounded context
(recommended — `subscription.Activate` reads and dependencies stay small) or one `usecase` package (simpler while the
service is small). New code follows the tree; there is no separate field to drift from it.
`go_composition_root: internal/app` (the studio contract, checked by numbers) or `main` (the classic guide shape —
the graph and the router assembled in `cmd/<app>/main.go`; the ≤ 50-line rule does not apply, `cmd/<app>` still holds one
non-test file, and the choice is written into the layout ADR as an accepted deviation so the `LAYOUT` check reads it and stays silent).

**Rich model, concretely.** A `Subscription` with `Balance` and `IsActive` as exported fields and an `Activate()` that checks them is
half-way: any package can still set `IsActive = true`. The studio form: unexported fields, `NewSubscription(id, userID, balance)` validating
its arguments and returning `(*Subscription, error)`, `Activate() error` returning `ErrZeroBalance`/`ErrAlreadyActive`, getters for reads,
and a `Rehydrate(...)` constructor (or a `subscription.State` struct) for repositories loading persisted state without re-running the
creation rules. Anemic struct + rules in the use case is a `RICH-MODEL` finding in `/code-review`.

**GraphQL models** (`graphql_models` in technical-preferences, asked in `/setup-stack`): `dto` (recommended) — gqlgen generates its
models into `internal/infrastructure/transport/graphql/model/`, resolvers map them to and from the domain; `bind` — `gqlgen.yml`
`models:` binds schema types to domain types; with unexported fields the binding goes through getter methods, which gqlgen resolves
by name. Either way: **a schema type must not be named `Query`, `Mutation` or `Subscription`** — gqlgen (per the spec) treats those as
the root operation types, and an entity called `Subscription` is generated as a set of channel-returning subscription resolvers.
The SDL lives where `api_contract_path` says (Go default `api/schema.graphqls`); `gqlgen.yml` points at that file, no copies.

**The dependency rule is a linter rule, not a comment.** `docs/templates/go/golangci.yml` carries `depguard` with two lists:
`domain` in `list-mode: strict` (only `$gostd` and the `go_domain_allow` packages pass) and `usecase` in `list-mode: lax`
(everything passes except `internal/infrastructure` and `internal/app`) — depguard's default mode denies every package
absent from `allow`, which would forbid `errgroup` or `uuid` in a use case (source: the depguard README, "ListMode").
`golangci-lint run ./...` in `make ci` and in `/code-review` Phase 3. `make arch-check` is a second, different check: transitive,
over the package graph (`go list -deps -test`), project packages only — it catches `usecase → platform → infrastructure`, which
per-file depguard cannot, and ignores third-party packages, which depguard covers. When they disagree, each is right about its
own question; neither is "fixed" in its config. Verified when the rule was written: a domain file importing `internal/infrastructure/postgres` fails with
`import '…/internal/infrastructure/postgres' is not allowed from list 'domain'`.

### Tests by layer (`go_architecture: layered`)
| Layer | Level | Doubles | Gate |
|---|---|---|---|
| Domain | Unit, table-driven, no doubles at all (nothing to double) | none — a mock in a domain test is a finding | statement coverage ≥ `go_coverage_domain` (default 90 %), every sentinel error has a case |
| Use cases | Unit, table-driven, ports replaced by doubles | hand-written func-field fakes (`GetByIDFunc func(...)`) for ports of ≤ 3 methods; `moq` (`go tool moq`, `tool` directive in `go.mod`) above that | statement coverage ≥ `go_coverage_usecase` (default 80 %); a test importing `pgx`, `testcontainers`, `net/http` or `os` file APIs is a finding |
| Infrastructure | Integration against a real Postgres (testcontainers) or `httptest`; contract tests against the SDL | none | no threshold; every adapter has at least one round-trip test |
| Composition root / CLI | `internal/app/<app>` tests: exit codes, flags, `--help` | none | as in "Project layout" |

Rules that apply to every Go test, whatever the style: **`errors.Is`/`errors.As`** against the sentinel — never
`err.Error() == "..."` (string comparison breaks on the first `%w` wrap and on a message edit); case names in English, as all
identifiers; **no `time.Sleep`** to wait for anything — `testing/synctest` (Go 1.25+) for code that waits on time, a polling helper
with a deadline (`require.Eventually` or a ten-line local one) for external systems; `go test -race ./...` after every change, a
race or a deadlock means the change is invalid and goes back to the engineer, not into a retry loop. The gate script
`docs/templates/go/coverage-gate.sh` (installed as `scripts/coverage-gate.sh`, called by `make coverage-gate` on the profile
`make test` wrote — one test run, not three) fails the build below the thresholds and prints one line per layer — the number goes
into the story result and the review. The thresholds live once for the build, as `GO_COVERAGE_DOMAIN`/`GO_COVERAGE_USECASE` in
the Makefile, written by `/test-setup` from technical-preferences.

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
| `cmd/<app>/main.go` | One directory per binary, named after the executable (`cmd/api`, `cmd/worker`). **`main.go` is the only non-test file there**, ≤ 50 lines including the doc comment: read `os.Args`/`os.Environ`, call `internal/app/<app>.Run(ctx, args, env, stdout, stderr) int`, `os.Exit` with its code — the convention's own wording is "a small `main` function that imports and invokes the code from `/internal` and `/pkg` and nothing else". No `flag.*`, no sub-command bodies, no type or adapter declarations, no output formatting, no dependency construction. Tests: at most one smoke test (`--help`/`version`). |
| `internal/app/<app>/` | The composition root of one binary (the convention's `/internal/app/myapp`): `Run`, sub-command dispatch (`serve`, `update`, `migrate`, …), flag parsing per sub-command, config → dependency graph → server wiring, adapters between internal packages, signal handling, CLI output. One constructor per shared dependency graph (`newServices(cfg, log, …)`) used by every sub-command that needs it — never the same struct literal in two sub-commands. Tests of the CLI contract (exit codes, stdout tokens, flag errors) live here, not in `package main`. |
| `internal/` | All application code; privacy enforced by the compiler. `modular`: domains as `internal/<domain>/` (handler → service → repository/sqlc); `layered`: `internal/domain/`, `internal/usecase/`, `internal/infrastructure/` (see "Layered architecture"). Private shared code (`config`, `logging`) in `internal/platform/` (or `internal/pkg/`) once two or more packages use it. |
| `pkg/` | Only code deliberately importable by other modules (SDK, client library, shared protocol types). Empty by default; the convention notes it is contested in the community — it is not an "everything else" bucket. |
| `api/` | The API contract of a Go module: the GraphQL SDL (`api/schema.graphqls`, the Go default of `api_contract_path` — `gqlgen.yml` reads it in place), OpenAPI, Protobuf, JSON Schema. One source of truth: `docs/architecture/api/` holds the contract document (`api-contract.md`, examples, persisted operations) and links to the file here; never two copies of the schema. |
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
`utils/`, `common/`, `helpers/` packages; anything but `main.go` (+ one smoke test) in `cmd/<app>` —
sub-command bodies, flag parsing, adapters, output formatting and dependency graphs belong to
`internal/app/<app>`; a `pkg/` created before an external consumer exists; several `main` packages
in one directory.

**Layout check — by numbers, never by the comment that calls code "wiring"**: `wc -l cmd/*/*.go` and
`grep -ln 'flag\.\|Fprint' cmd/*/*.go`. A second non-test file in `cmd/<app>`, a `main.go` over 50
lines, or a `flag.`/`Fprint` hit there is a `LAYOUT` finding (WARNING in `/code-review`, drift in
`/architecture-review code`); the fix is a move to `internal/app/<app>`, never a comment. The same
dependency-graph literal in two files is BLOCKING once a field has already been missed in one of them —
that is the bug class it produces.

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
1. Contexts and timeouts on I/O; 2. errors wrapped and checked; 3. no global state beyond config; 4. goroutines have an owner and an exit; 5. table-driven tests, `-race` passes; 6. `go vet`/`staticcheck`/`golangci-lint` clean; 7. structured logs without secrets; 8. (`layered`) `depguard` clean, rules live in entities not in use cases or resolvers, ports in the domain, one struct per use case; 9. (`layered`) coverage gate green, domain tests without doubles, use-case tests without I/O; 10. tests: `errors.Is`, no `time.Sleep`, English case names.
