---
paths: ["**/*_test.go", "**/*Test.php", "**/*.spec.ts", "**/*.test.ts", "tests/**", "e2e/**", "**/playwright.config.*", "**/vitest.config.*"]
---
# Test rules
- Tests are named by behaviour (`it('rejects expired token')`, `TestLogin_ExpiredToken_Returns401`).
- Determinism: time/randomness/network injected or mocked; flaky = bug.
- One scenario per test; AAA (arrange/act/assert); no logic in tests.
- DB integration uses a real Postgres (container), not an SQLite substitute.
- E2E: selectors by `data-testid`/role, not CSS classes; `trace: on-first-retry`.
- Story acceptance criterion ↔ test (story ID referenced in the test description).
- Reference: `.claude/docs/stack-reference/testing.md`.
