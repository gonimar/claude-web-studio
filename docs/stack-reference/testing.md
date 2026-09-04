---
updated: 2026-09-05
sources: [https://vitest.dev/llms.txt, https://playwright.dev/docs/intro, https://phpunit.de, https://go.dev/doc/tutorial/add-a-test, https://testing-library.com, https://k6.io/docs]
---
# Testing — tools and pyramid

| Level | Go | PHP | TS / frontend |
|---|---|---|---|
| Unit | `testing` table-driven, `testify`, `synctest` for time | PHPUnit 12, data providers, minimal mocking | Vitest 4 (`describe/it`, `vi.fn`), Testing Library (Angular/Vue) |
| Integration | `testcontainers-go` (Postgres/Redis), `httptest` | PHPUnit + a real Postgres in compose | Vitest + MSW (mock HTTP) or a real API in compose |
| Contract | GraphQL: codegen validation + N+1 test; REST: `oapi-codegen` schema checks; Pact with several consumers | `league/openapi-psr7-validator` middleware in tests; GraphQL schema snapshot | `graphql-codegen` fails on incompatibility; `openapi-typescript` types + Schemathesis (fuzz) |
| E2E | — | — | **Playwright** (Chromium/WebKit/Firefox), fixtures, `trace on-first-retry`, test-id selectors |
| Load | `k6` (JS scenarios), `vegeta` | k6 | k6, Lighthouse CI |
| Security | `govulncheck`, `gosec` | `composer audit`, Psalm taint analysis | `npm audit`, `eslint-plugin-security`, ZAP baseline in CI |
| Accessibility | — | — | `axe-core` (`@axe-core/playwright`), Lighthouse a11y |
| Visual | — | — | Playwright screenshots / Storybook + Chromatic when needed |

## Principles
- A test proves an acceptance criterion; a criterion without a test is not closed.
- Pyramid: many unit tests on the domain, a medium number of integration tests at boundaries (DB, HTTP), few e2e tests on key journeys (login, purchase, game save).
- Deterministic tests: time/randomness injected; network mocked or containerised; a flaky test is a priority bug.
- CI: lint → unit → integration → build → e2e (on the built artefact) → security scan; artefacts (traces, coverage) are kept.
- Coverage is an indicator, not a goal; a threshold for the domain layer (e.g. 80 %), not for everything.
- Naming: `TestX_Scenario_Expected` (Go), `testItDoesXWhenY` (PHP), `it('does X when Y')` (TS).
- Game code: unit tests on the simulation (deterministic step), golden tests for balance, a perf test "N frames ≤ budget".
