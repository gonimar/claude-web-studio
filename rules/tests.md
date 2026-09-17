---
paths: ["**/*_test.go", "**/*Test.php", "**/*.spec.ts", "**/*.test.ts", "tests/**", "e2e/**", "**/playwright.config.*", "**/vitest.config.*"]
---
# Test rules
- Tests are named by behaviour (`it('rejects expired token')`, `TestLogin_ExpiredToken_Returns401`, `testActivationFailsOnZeroBalance`); names and identifiers in English.
- Determinism: time, randomness and network injected or mocked; flaky = bug. No fixed waits (`time.Sleep`, `sleep()`, `setTimeout`): poll with a deadline or use fake time (`testing/synctest`, a clock interface, `vi.useFakeTimers`).
- Errors asserted by identity (`errors.Is`/`errors.As`, `expectException(Class::class)`, `toThrow(ErrorClass)`), never by message string.
- Table-driven cases (`t.Run` slices, PHPUnit data providers, `it.each`); one scenario per case; arrange/act/assert; no logic in tests.
- Layered Go and PHP: domain tests without doubles; use-case/application tests double the ports only and open no DB, file, framework or network; infrastructure tests against real containers; the coverage gate (`make coverage-gate`, `composer coverage-gate`) is a gate, not a report. Details: `go.md` / `php.md` "Tests by layer".
- DB integration uses a real Postgres (container), not an SQLite substitute.
- E2E: selectors by `data-testid`/role, not CSS classes; `trace: on-first-retry`.
- Story acceptance criterion ↔ test (story ID referenced in the test description).
- Reference: `.claude/docs/stack-reference/testing.md`.
