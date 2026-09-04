---
updated: 2026-09-05
sources: [https://spec.graphql.org/September2025/, https://graphql.org/learn/best-practices/, https://github.com/graphql/graphql-js/releases, https://gqlgen.com, https://the-guild.dev/graphql/yoga-server, https://www.apollographql.com/docs/apollo-server, https://webonyx.github.io/graphql-php/, https://the-guild.dev/graphql/codegen, https://cheatsheetseries.owasp.org/cheatsheets/GraphQL_Cheat_Sheet.html]
---
# GraphQL — the studio's priority API style

## Specification and status
- **GraphQL Spec September 2025** — first stable edition since October 2021: validation clarifications, `@oneOf` input objects, schema descriptions, groundwork for semantic nullability. **`@defer`/`@stream` (incremental delivery) are not in the spec** — RFC Stage 2, implemented experimentally (GraphQL.js 17, Yoga, Hive Gateway) — production use only via an ADR.
- **GraphQL over HTTP** spec: `POST /graphql`, `application/graphql-response+json`, GET only for persisted/idempotent queries.
- Subscriptions transport: **`graphql-ws`** (WebSocket, `graphql-transport-ws` protocol) or **SSE** (`graphql-sse`) — SSE is simpler for one-way events.

## When GraphQL, when REST (recorded in an ADR)
GraphQL is the default for client-facing APIs with rich data relationships (SPA/mobile clients,
dashboards, game profiles/inventories), multiple clients with different needs, or aggregation of
several sources (BFF/federation). REST/OpenAPI for simple CRUD resources, webhooks, file
uploads/downloads, third-party public integrations and CDN-cacheable responses. Mixing is fine:
GraphQL for the client API plus REST for uploads/webhooks/health.

## Stack per language
| Layer | Go | PHP | Node/TS |
|---|---|---|---|
| Server | **gqlgen** (schema-first, resolver codegen, dataloaders via `vikstrous/dataloadgen` / `graph-gophers/dataloader`); alternative graphql-go | **webonyx/graphql-php** (+ `thecodingmachine/graphqlite` code-first; in Yii3 a PSR-15 endpoint over graphql-php; DataLoader — `overblog/dataloader-php`) | **GraphQL Yoga** 5 (edge-ready, Envelop plugins) by default; Apollo Server 5 with GraphOS/federation; Pothos or gql.tada for types |
| Gateway/federation | — | — | Apollo Federation 2 (Router/GraphOS) or Hive Gateway; in the studio only with ≥ 3 subgraphs via an ADR |
| Angular client | **Apollo Angular** 11 (Apollo Client 4) or urql; types via graphql-codegen (`typed-document-node`) | | |
| Vue client | **villus** / urql-vue / Apollo Client 4 with `@vue/apollo-composable`; Nuxt — `nuxt-graphql-client` / `@nuxtjs/apollo` | | |
| Game client (TS) | urql core / `graphql-request` for simple queries; subscriptions via `graphql-ws` | | |
| Codegen | `@graphql-codegen/cli` (typed documents, client hooks), `gql.tada` (types from schema without a generation step) | gqlgen generates Go types from SDL | |
| Tooling | GraphiQL/Altair, `graphql-inspector` (schema diff, breaking changes), `graphql-eslint`, Hive/Apollo schema registry | | |

## Schema design
- **Schema-first, SDL in the repository** (`docs/architecture/api/schema.graphql`) is the source of truth; changes pass `graphql-inspector diff` in CI (breaking → new field/deprecation).
- Naming: `PascalCase` types, `camelCase` fields, `SCREAMING_SNAKE` enums, verb mutations `createOrder`, inputs `CreateOrderInput`, mutation results as payload types with `errors` (user errors as data, not exceptions).
- **Relay style**: `Node` interface with a global `id`, connections (`edges/node/pageInfo`, cursor pagination) for lists; `@oneOf` for polymorphic inputs.
- Nullable only where a field can genuinely be absent; semantic nullability (`@semanticNonNull`) as support lands.
- Evolution without versions: add fields, `@deprecated(reason:)`, remove after usage metrics; no `v2` types.
- Errors: transport-level in the standard `errors[]` with `extensions.code`; domain errors in mutation payloads.

## Performance
- **A DataLoader on every relation** (batching + per-request cache) — N+1 is forbidden; test the SQL query count.
- Limits: depth (≤ 10), complexity/cost (per-field and connection sizes), `first` ≤ 100, request timeout, body size.
- **Persisted operations** (trusted documents) are mandatory in production for first-party clients: the server executes only registered hashes; APQ saves bandwidth only, it is not a security control.
- Cache: `@cacheControl`/response cache per field (Yoga plugin), HTTP cache for persisted GET; normalised client cache (Apollo/urql).
- `@defer`/`@stream` only behind a flag and an ADR.

## Security (OWASP GraphQL Cheat Sheet)
- Introspection off in production (except internal tools behind auth); the schema comes from the registry.
- Authorisation **per resolver/field** (`@auth` directive/middleware), not only at the endpoint; object-ownership checks by `id` (BOLA).
- Input validation by schema plus domain validation; limits on query batching (array batching ≤ 5) and aliases.
- Rate limiting by query cost, not only request count; resolver timeouts; log `operationName` without secret variables.
- CSRF: only `POST` with `Content-Type: application/json` and CORS checks (GET only for persisted); mask internal errors (`maskedErrors`).
- File uploads not through GraphQL multipart (REST endpoint + reference) unless an ADR says otherwise.

## Tests
Schema snapshot + `graphql-inspector`; resolvers unit-tested with mocked loaders; integration via real requests against a server with a containerised DB; contract — client documents validated against the schema in CI (`graphql-codegen` fails on incompatibility); load — k6 with persisted operations.

## Review checklist
1. SDL in the repo, diff in CI; 2. DataLoader on relations, N+1 test; 3. depth/cost/`first` limits; 4. persisted operations in prod, introspection off; 5. field-level authorisation; 6. errors: payload for domain, `extensions.code` for transport; 7. client types from codegen, never hand-written.
