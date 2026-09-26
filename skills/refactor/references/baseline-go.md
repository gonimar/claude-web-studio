# /refactor — Go: baseline commands (Phase 2) and choices (Phase 3)

Read from `SKILL.md` Phase 2 step 1 and Phase 3 step 3.

## Baseline — from the Go root
Run every command and tabulate its output (metric · value · rule it is measured against).
1. `go build ./...`; `go vet ./...`.
2. `golangci-lint run ./...`: issue count by linter. A v1-format `.golangci.yml` is itself a finding.
3. `go test -race -count=1 ./...`: packages, tests, failures.
4. Coverage: `scripts/coverage-gate.sh` when present, else `go test -cover` per `internal/<layer>`.
5. Layout numbers: `wc -l cmd/*/*.go`, `grep -ln 'flag\.\|Fprint' cmd/*/*.go`.
6. Dependency direction: `go list -deps ./internal/domain/...` and `go list -deps ./internal/usecase/...`, filtered to the module's `internal/`.
7. Package sizes: `find internal -name '*.go' ! -name '*_test.go' | xargs wc -l`, grouped by directory, and files per package.
8. Public API of `pkg/`, when it exists: `go list ./pkg/... | xargs -n1 go doc -all > "$TMPDIR/refactor-<scope>-pkgapi.txt"` — saved outside the repository as the baseline Phase 6 diffs against.
9. Test smells: `grep -rn 'time\.Sleep(' --include='*_test.go'`, `grep -rnE '\.Error\(\) *[!=]=' --include='*_test.go'`, test functions without `t.Run`, non-English case names, a mock type in a domain test, `pgx`/`testcontainers`/`net/http` imports in a use-case test.

## Choices — the fields Phase 3 asks (current value first, "keep", Recommended)
- `go_architecture`: layered | modular. Keeping `modular` ends the `layout` mode with `PLANNED (no migration — modular confirmed)`.
- Use-case shape: one package per context | one `usecase` package (the layout ADR's tree; a change is an ADR step).
- `go_composition_root`: internal/app | main.
- Ports in the domain (the layered rule): shown, not asked.
- `go_router`: chi | ServeMux. `graphql_models`: dto | bind. `go_domain_allow`. Coverage thresholds.
