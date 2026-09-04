# Feature Spec: [Feature name] (F-NNN)

> Status: Draft | Review | Approved · Product spec: `docs/specs/product-spec.md` · ADR: · Date:

## 1. Overview
What the feature does, for which persona, which product-spec goal it serves.

## 2. User scenarios
Main flow and alternatives (numbered steps; screens/states).

## 3. Rules and logic
Business rules, formulas (variables, ranges, worked example), permissions (who can do what).

## 4. Data
Entities/fields (type, required, constraints), source of truth, migrations; impact on `data-model.md`.

## 5. API / contract
GraphQL operations (queries/mutations/subscriptions) or REST endpoints, inputs/outputs, errors (codes / payload errors); link to `docs/architecture/api/`.

## 6. UI and states
Screens and their states: empty / loading / error / success / offline; copy; link to the UX spec.

## 7. Edge cases
Table "situation → concrete behaviour" (never "handle gracefully").

## 8. Security
Authorisation (object/field), input validation, limits/quotas, what is logged, new attack surfaces → update the threat model.

## 9. Accessibility and performance
Keyboard/screen reader for new elements; budget (size, requests, latency).

## 10. Dependencies
Other features, external services, packages (health check).

## 11. Acceptance criteria
```
Given … When … Then …
```
Every criterion → a test (level assigned by `/create-stories`).

## 12. Open questions
