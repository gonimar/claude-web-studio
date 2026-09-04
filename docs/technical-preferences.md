# Technical Preferences

<!-- Filled by /setup-stack (or /adopt for an existing project). -->
<!-- While [TO BE CONFIGURED] remains, skills treat the stack as not chosen. -->

## Project type
- **Type**: [TO BE CONFIGURED] (site | spa | api | fullstack | game | game+backend)
- **Target platforms**: [desktop, mobile-web, PWA…]
- **Rendering**: [SPA | SSR | SSG | hybrid]

## Backend
- **Language/runtime**: [TO BE CONFIGURED] (Go 1.27 | PHP 8.5 | Node 24 | none)
- **Framework**: [net/http + chi | Yii3 | Hono | NestJS | …]
- **Database**: [PostgreSQL 18 | …]  **Cache/queue**: [Redis 8 | …]
- **API style**: [GraphQL (default for the client API; schema-first SDL) | REST/OpenAPI 3.1 (webhooks, files, integrations) | WebSocket/SSE (realtime) | gRPC]
- **GraphQL server/client**: [gqlgen | graphql-php | Yoga 5] / [Apollo Angular | villus/urql | graphql-request]
- **Authentication**: [sessions | OIDC | JWT+BFF | …]

## Frontend
- **Framework**: [TO BE CONFIGURED] (Angular 22 | Vue 3.5 | Nuxt 4 | vanilla TS)
- **UI kit**: [Angular Material 22 | Taiga UI 5 | token-based custom | …]
- **State**: [signals | Pinia | …]
- **Build**: [Angular CLI (esbuild) | Vite 8]
- **Styles**: [SCSS | Tailwind 4 | CSS modules]
- **i18n**: [yes/no; locales]

## Game (if any)
- **Engine/renderer**: [three.js r185 (WebGPU/WebGL2) | PixiJS 8 | Phaser | Babylon 8]
- **Networking**: [none | WebSocket, server-authoritative on Go]
- **Frame budget**: [16.6 ms @60fps; draw calls ≤ N; memory ≤ N MB]

## Tests and quality
- **Unit**: [Vitest 4 | PHPUnit 12 | go test]
- **E2E**: [Playwright]
- **Lint/format**: [ESLint 9 flat + Prettier | php-cs-fixer + Psalm | gofmt + golangci-lint]
- **Coverage threshold**: [e.g. 80 % for the domain layer]

## Infrastructure
- **Containers**: [Docker, compose v2]  **CI**: [GitHub Actions]
- **Deploy**: [compose on a server | container platform | cloud]  **Environments**: [dev, staging, prod]
- **Observability**: [JSON logs, /healthz, Prometheus metrics, OpenTelemetry]

## Layout
- **backend_root**: [./backend | ./ | …]
- **frontend_root**: [./frontend | ./web | …]
- **game_root**: [./game | none]
- **shared_packages**: [./packages | none]

## Naming conventions
- Go: lowercase packages, exported PascalCase, snake_case files, `_test.go`
- PHP: PSR-12, PascalCase classes, `declare(strict_types=1)`, `*Test.php`
- TS: kebab-case files, PascalCase classes/types, camelCase variables, `*.spec.ts`
- Angular: v20+ style by default — no suffixes (`user-profile.ts`, class `UserProfile`); or classic `feature.component.ts` — the choice is recorded here; selectors `app-*`
- Vue: PascalCase SFCs (`UserCard.vue`), composables `useX.ts`, stores `useXStore`
- CSS: BEM or design-system tokens; variables `--ds-*`
- Git: branches `feat/…`, `fix/…`; Conventional Commits

## Performance budgets
- LCP ≤ 2.5 s, INP ≤ 200 ms, CLS ≤ 0.1 (p75, mobile)
- Initial JS bundle ≤ [N] KB gzip; API p95 ≤ [N] ms

## Architecture decision log
Full ADRs live in `docs/architecture/adr-*.md`. One line per decision here:
- [date] — [decision] — ADR-NNNN
