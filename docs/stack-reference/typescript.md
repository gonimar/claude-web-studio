---
updated: 2026-09-05
sources: [https://devblogs.microsoft.com/typescript/, https://vite.dev/llms.txt, https://vitest.dev/llms.txt, https://hono.dev/llms.txt, https://docs.nestjs.com/llms.txt, https://typescript-eslint.io/]
---
# TypeScript 7, tooling, Node backends

## TypeScript
- **7.0 (2026-07-08)** — first stable release on the native compiler (Go port): 8–12× faster full builds, multithreading. Installed as usual (`npm i -D typescript`); the programmatic API lands in 7.1. **6.0** was the last JS bridge release: strict defaults (`strict`, `module: nodenext`/`esnext`, `target: es2025`), old options deprecated.
- Recommended tsconfig: `strict`, `noUncheckedIndexedAccess`, `exactOptionalPropertyTypes`, `verbatimModuleSyntax`, `isolatedModules`, `erasableSyntaxOnly` (compatible with native TS execution in Node), `moduleResolution: bundler` (frontend) / `nodenext` (Node), `skipLibCheck`.
- Node 22.18+/24 run `.ts` directly (type stripping) — no enums/namespaces/parameter properties (hence `erasableSyntaxOnly`).
- Types from runtime schemas: **zod 4** / valibot (Standard Schema) — one schema for validation and type; API DTOs generated from the contract (`graphql-codegen`, `openapi-typescript`, `orval`).

## Build and tooling
| Tool | Version | Notes |
|---|---|---|
| Vite | 8 (2026-03) | **Rolldown** (Rust) is the default bundler, 5–10× faster; `vite.config.ts`; `import.meta.env` |
| Vitest | 4 | browser mode stable; `vitest --coverage` (v8); compatible with Vite 8 |
| pnpm | 10 | workspaces for monorepos; `pnpm audit`; `minimumReleaseAge` against fresh malicious versions |
| ESLint | 9/10 flat config (`eslint.config.js`) | `typescript-eslint` 8 (`strictTypeChecked`), `eslint-plugin-vue`, `angular-eslint` |
| Prettier | 3 | or **Biome** 2 (lint + format in one, faster) |
| tsdown / tsup | — | library builds; `exports` map, ESM-only by default |
| Node | 24 LTS (26 → LTS 2026-10) | `node --watch`, `node:test`, built-in `fetch`, `--env-file` |

Rules: ESM everywhere (`"type": "module"`); lockfile in git; exact dependency versions for
applications (`save-exact`); `npm audit`/`pnpm audit` + Renovate/Dependabot; avoid installing
packages younger than 3–7 days without need (supply chain).

## Node/TS backend (when not Go or PHP)
| Choice | When |
|---|---|
| **Hono** 4 | Light APIs, BFF, edge/Workers, WebSocket; Web-standard Request/Response; zod validation |
| **NestJS** 11 | Large team monoliths with DI and modules; many integrations |
| **Fastify** 5 | High-throughput HTTP with JSON schemas |
| Nuxt server routes (Nitro) / Angular SSR server | When the backend is a thin BFF next to an SSR app |
Layers: controller (DTO validation) → service → repository (Drizzle ORM / Kysely / pg). Errors as RFC 9457 problem+json.

## Monorepo
`pnpm-workspace.yaml` + `packages/contracts` (types from GraphQL SDL / OpenAPI), `packages/ui`,
`apps/web`, `apps/api`; a shared `tsconfig.base.json`; Turborepo/Nx as needed (Nx fits Angular naturally).

## TS review checklist
1. `strict`, no `any`/`as unknown as`; 2. boundary validation (zod), types from schemas; 3. async errors handled, no floating promises (`@typescript-eslint/no-floating-promises`); 4. ESM only, no cycles (`madge`); 5. Vitest tests next to code; 6. bundle analysis when it grows.
