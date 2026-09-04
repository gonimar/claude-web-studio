# API Contract: [Area]

> Style: GraphQL (SDL) | REST (OpenAPI 3.1) | AsyncAPI · File: `docs/architecture/api/…` · ADR: · Date:

## 1. Purpose and consumers
Who calls it (web, game client, integrations), permissions.

## 2. Operations
| Operation | Kind (query/mutation/subscription or method+path) | Permissions | Errors | Idempotency |
|---|---|---|---|---|

## 3. Schema
Link to the SDL/OpenAPI; key types; connections/pagination; payload errors.

## 4. Security
Auth scheme, field/object authorisation, limits (depth/cost/`first`/size), persisted operations, CORS/CSRF.

## 5. Evolution
Deprecation policy, breaking-change check in CI (`graphql-inspector` / `oasdiff`).

## 6. Examples
Requests/responses (persisted documents for clients).

## 7. Tests
Contract/integration tests, N+1 test.
