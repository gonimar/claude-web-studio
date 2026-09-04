# Test Strategy: [Project]

> Date: · Owner: qa-lead

## Tools per level
| Level | Backend | Frontend | Game | Command |
|---|---|---|---|---|

## Environments
Compose profile `test` (Postgres/Redis), seeds, test accounts; CI stages and artefacts.

## Thresholds and rules
Domain-layer coverage ≥ N %; flaky = P1; criterion ↔ test; release e2e set.

## Data
Factories/fixtures; production data anonymisation policy.

## Security, accessibility, performance in tests
What is automated (audit, axe, Lighthouse CI, k6) and at which stage.
