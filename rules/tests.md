---
paths: ["**/*_test.go", "**/*Test.php", "**/*.spec.ts", "**/*.test.ts", "tests/**", "e2e/**", "**/playwright.config.*", "**/vitest.config.*"]
---
# Test rules
- Tests are named by behaviour (`it('rejects expired token')`, `TestLogin_ExpiredToken_Returns401`).
- Determinism: time/randomness/network injected or mocked; flaky = bug. No `time.Sleep` to wait for a result: poll with a deadline or use fake time (`testing/synctest`, `vi.useFakeTimers`).
- Errors are asserted by identity (`errors.Is`/`errors.As`, `assertInstanceOf`, `toThrow(ErrorClass)`), never by comparing message strings.
- Case names and test identifiers in English, like the rest of the code.
- PHP: `expectException(Class::class)` never a message comparison; PHPUnit data providers for table-driven cases; `php_architecture: layered` → domain tests without doubles, application tests with mocked ports and no framework/DB/network, infrastructure in `tests/Integration/` against real containers; `scripts/coverage-gate.php` thresholds are a gate.
- Go, `go_architecture: layered`: domain tests use no doubles; use-case tests double the ports only (func-field fakes ≤ 3 methods, `moq` above) and open no DB, file or network; infrastructure tests run against real containers; `scripts/coverage-gate.sh` thresholds are a gate, not a report.
- One scenario per test; AAA (arrange/act/assert); no logic in tests.
- DB integration uses a real Postgres (container), not an SQLite substitute.
- E2E: selectors by `data-testid`/role, not CSS classes; `trace: on-first-retry`.
- Story acceptance criterion ↔ test (story ID referenced in the test description).
- Reference: `.claude/docs/stack-reference/testing.md`.
