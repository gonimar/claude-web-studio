# Technical Preferences

<!-- Filled by /setup-stack (or /adopt for an existing project). -->
<!-- While [TO BE CONFIGURED] remains, skills treat the stack as not chosen. -->

## Project type
- **Type**: [TO BE CONFIGURED] (site | spa | api | fullstack | game | game+backend)
- **Target platforms**: [desktop, mobile-web, PWA…]
- **Rendering**: [SPA | SSR | SSG | hybrid]

## Backend
- **Language/runtime**: [TO BE CONFIGURED] (Go 1.27 | PHP 8.5 — or `PHP 8.4 — <reason>, upgrade story S-NNN` when the hosting cannot run 8.5 yet | Node 24 | none)
- **Framework**: [net/http + chi | Yii3 | Symfony | Laravel | Slim | Hono | NestJS | …]
- **php_framework**: [yii3 (reference yii3.md) | symfony (symfony.md, stub) | laravel (laravel.md, stub) | slim | none — php-engineer works from the official docs where the reference is a stub or missing]
- **php_architecture**: [layered (src/Domain → src/Application → src/Infrastructure, deptrac-enforced) | framework (the framework's own layout) — see stack-reference/php.md "Layered architecture"]
- **php_layers**: [per-context (src/Domain/<Context>, src/Application/<Context> — recommended) | flat (one namespace per layer) | n/a]
- **php_static_analysis**: [phpstan (level 9 new / baseline brownfield) | psalm (level 1)]
- **php_cs_tool**: [ecs (perCs: true) | php-cs-fixer (@PER-CS)]
- **php_domain_allow**: [non-PSR vendor namespaces the domain may use, e.g. Ramsey\Uuid, Brick\Money — mirrored into deptrac.yaml's Vendor layer; `none` = PHP only]
- **Database**: [PostgreSQL 18 | …]  **Cache/queue**: [Redis 8 | …]
- **API style**: [GraphQL (default for the client API; schema-first SDL) | REST/OpenAPI 3.1 (webhooks, files, integrations) | WebSocket/SSE (realtime) | gRPC]
- **api_contract_path**: [api/schema.graphqls (Go module) | docs/architecture/api/schema.graphql | docs/architecture/api/openapi.yaml] — the one SDL/OpenAPI file every skill and the codegen read
- **graphql_models**: [dto (generated models mapped in resolvers — recommended) | bind (domain types bound in gqlgen.yml) | n/a]
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
- **Unit**: [Vitest 4 | PHPUnit 13 (+ Pest 5) | go test]
- **E2E**: [Playwright]
- **Lint/format**: [ESLint 9 flat + Prettier | ecs or php-cs-fixer + phpstan or psalm + deptrac | gofmt + golangci-lint]
- **Coverage threshold**: [an indicator for non-layered stacks, e.g. 80 % for the domain layer; layered Go and PHP use the fields below as a gate]
- **go_coverage_domain**: [90] — statement coverage of `internal/domain/...`; /test-setup writes it into the Makefile (`GO_COVERAGE_DOMAIN`), which is what `make coverage-gate` reads
- **go_coverage_usecase**: [80] — the same for `internal/usecase/...` (`GO_COVERAGE_USECASE`)
- **php_coverage_domain**: [90] — line coverage of `src/Domain/`; /test-setup writes it into the composer `coverage-gate` script, the one place the build reads it
- **php_coverage_application**: [80] — the same for `src/Application/`

## Infrastructure
- **Containers**: [Docker, compose v2]  **CI**: [GitHub Actions]
- **Deploy target**: [compose-ssh | kubernetes | cloud:<name> | portainer | manual]  **Environments**: [dev, staging, prod]
- **Deploy delegate**: [agent <name> | script <path> | none] — see `deploy-target-contract.md`
- **Infra repo**: [path or URL of the repository holding the proxy/host config | none]  **Proxy config**: [file inside it, e.g. caddy/Caddyfile | none]
- **Observability**: [JSON logs, /healthz, Prometheus metrics, OpenTelemetry]

## Layout
- **backend_root**: [./backend | ./ | …]
- **go_layout**: [project-layout (cmd/, internal/, pkg/ only when exported, api/, configs/, scripts/, build/, deployments/, test/) | minimal (main.go + go.mod) | none — see stack-reference/go.md "Project layout"]
- **go_architecture**: [layered (internal/domain → usecase → infrastructure, depguard-enforced) | modular (internal/<domain>/ with handler → service → repository) — see stack-reference/go.md "Architecture style"]
- **go_layers**: [per-context (internal/usecase/<ctx>/ — recommended) | flat-usecase (one internal/usecase package) | n/a]
- **go_composition_root**: [internal/app (studio contract, cmd/<app>/main.go ≤ 50 lines) | main (graph and router assembled in cmd/<app>/main.go; recorded in the layout ADR as an accepted deviation)]
- **go_router**: [chi v5 (recommended) | net/http ServeMux]
- **go_domain_allow**: [non-stdlib packages the domain layer may import, e.g. github.com/google/uuid, github.com/shopspring/decimal; `none` = stdlib only. The list is written into `.golangci.yml` depguard by /test-setup; growing it is a technical-preferences change (one AskUserQuestion, the field, then /test-setup regenerates the allow-list) — never a hand edit of the linter config alone]
- **frontend_root**: [./frontend | ./web | …]
- **game_root**: [./game | none]
- **shared_packages**: [./packages | none]

## Naming conventions
- Go: lowercase packages, exported PascalCase, snake_case files, `_test.go`
- PHP: PER-CS 3.1, PascalCase classes, `declare(strict_types=1)`, `*Test.php`
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
