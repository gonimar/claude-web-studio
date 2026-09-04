---
paths: ["**/openapi*.yaml", "**/openapi*.json", "**/asyncapi*.yaml", "docs/architecture/api/**", "**/*.proto", "**/*.graphql", "**/*.graphqls", "**/*.gql", "**/gqlgen.yml", "**/codegen.ts"]
---
# API contract rules
- The contract is the source of truth: client types and server DTOs are generated from it; hand-written copies are forbidden.
- GraphQL (priority): schema-first SDL in `docs/architecture/api/schema.graphql`; `graphql-inspector diff` in CI; Relay connections for lists; payload types with `errors` on mutations; `@deprecated` instead of versions; DataLoader on relations; depth/cost limits; persisted operations in production; field-level authorisation. Reference: `.claude/docs/stack-reference/graphql.md`.
- OpenAPI 3.1: `operationId` on every operation; schemas with `required`, formats, `maxLength`/limits; examples.
- Errors — RFC 9457 `application/problem+json` with a single `Problem` schema.
- Cursor pagination; explicit filters; `Idempotency-Key` for unsafe repeatable operations.
- Versioning per ADR; a breaking change = new version + deprecation period.
- Security: `securitySchemes` described; every operation has explicit `security`; no "open" mutations.
- A contract change notifies `frontend-lead`/`game-lead` and updates contract tests.
