# /code-review — Go checks (Phase 3)

Read when the diff contains `*.go`. Every check's output goes into the report; the finding strings are the
contract (`severity | file:line | what | risk | fix`) and are used as written.

**Go tests**, on every `_test.go` in the diff (files importing `testing/synctest` and comment lines excluded):
- `grep -n 'time\.Sleep(' <files>` → WARNING `TEST-SLEEP | file:line | fixed wait in a test | flaky under load | poll with a deadline or testing/synctest`.
- `grep -nE '\.Error\(\) *[!=]=' <files>` → WARNING `TEST-ERRSTR | file:line | error compared as a string | breaks on the first %w wrap | errors.Is/As against the sentinel`.
- A Go test function with no `t.Run` and more than one scenario → INFO `TEST-TABLE`.

**Go layered** (`go_architecture: layered` in technical-preferences). The numbers (lint issues, gate lines) go into the report even when clean.
- `golangci-lint run --new-from-rev=<base> ./...` — only the issues the diff introduces; the whole-module run belongs to `make ci` and the engineer's own result. A `depguard` line is BLOCKING `LAYER | file:line | <layer> imports <outer layer> | the rule the architecture rests on | move the code; a value library the domain genuinely needs goes into go_domain_allow through technical-preferences and /test-setup, never into the linter config by hand`.
- When the diff touches `internal/domain/` or `internal/usecase/`, run the tests with coverage first (`make test` writes the profile `make coverage-gate` reads); other packages run their tests without it.
- `make coverage-gate` on the profile of the tests already run (`make test` writes it), only when the diff touches `internal/domain/` or `internal/usecase/`: a layer below its threshold is BLOCKING `COVERAGE | internal/<layer> | N % < M % | untested rules | tests in the same story`.
- A file changed under `internal/domain` or `internal/usecase` with no `_test.go` change in the diff → WARNING `TEST-LAYER`.
- A `_test.go` under `internal/domain` that declares a mock/fake type, or one under `internal/usecase` importing `pgx`, `testcontainers`, `net/http` or `database/sql` → WARNING `TEST-LAYER`.
- An entity with exported mutable state and its rules in a use case or resolver → WARNING `RICH-MODEL`.
- A resolver/handler that imports `internal/infrastructure/postgres` (or any repository) instead of a use case → WARNING `LAYER`.

**Go layout** (`go.md` "Project layout"), whenever the diff touches `cmd/` or the project has one. The numbers go into the report even when clean; a code comment calling the code "wiring" changes nothing.
- `wc -l cmd/*/*.go` and `grep -ln 'flag\.\|Fprint' cmd/*/*.go`: a second non-test file in `cmd/<app>`, a `main.go` over 50 lines or a `flag.`/`Fprint` hit there is a WARNING `LAYOUT | cmd/<app>/<file>:1 | application code in cmd/ | grows with every story, untestable without package main | move to internal/app/<app>`.
- The same dependency-graph struct literal in two files is BLOCKING when a field is already missing in one of them (that difference is the bug), WARNING otherwise (fix: one constructor).
