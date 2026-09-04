# Agent Roster

Each agent is a file in `agents/` (plugin) or `.claude/agents/` (copy mode). Work that spans
domains goes through a coordinating agent (director or lead) who delegates to specialists.
The stack-reference file an agent reads first is listed in its description
(`.claude/docs/stack-reference/…`). All agents reply in the project's conversation language
(CLAUDE.md → Language) and keep code, identifiers and commits in English.

## Tier 0 — companion skills (optional, not part of this plugin)
| Role | When |
|---|---|
| External strategic advisor skill (if installed) | Whole-project audits, scope arbitration, roadmap curation. Sits outside the hierarchy: advises, never owns a domain. |
| Deployment operator skill (container platform / Kubernetes / cloud, if installed) | `/deploy` delegates the actual stack mutation to it. |

## Tier 1 — directors (Opus)
| Agent | Domain | When |
|---|---|---|
| `technical-director` | Technical vision | Stack choice, ADRs, system boundaries, performance and security strategy, arbitration of technical conflicts |
| `product-director` | Product and production | Scope, priorities, product spec, epics/stories, sprints, risks, phase gates |

## Tier 2 — leads (Sonnet)
| Agent | Domain | When |
|---|---|---|
| `backend-lead` | Server architecture | Domains/modules, API contracts, DB, queues, backend code review, Go vs PHP vs Node per service |
| `frontend-lead` | Client architecture | SPA/SSR structure, state, components, build, frontend review, Angular vs Vue |
| `design-lead` | UX/UI and design system | Flows, screens and states, tokens, component library, accessibility as a requirement |
| `security-lead` | Application and network security | Threat model, security requirements, audits, OWASP acceptance, incidents; veto on blocking findings |
| `qa-lead` | Quality | Test strategy, pyramid, definition of done, regression, release acceptance |
| `devops-lead` | Delivery infrastructure | CI/CD, Docker, environments, observability, deploy/rollback (delegating mutations to a deploy skill) |
| `game-lead` | Browser games | Game loop, client architecture, frame budget, three.js / Babylon / Pixi / Phaser choice, backend integration |

## Tier 3 — specialists (Sonnet unless noted)
| Agent | Domain | When |
|---|---|---|
| `go-engineer` | Go 1.27 | HTTP services, `net/http` routing, `pgx`/`sqlc`, contexts, concurrency, `go test`, `govulncheck` |
| `php-engineer` | PHP 8.5 / Yii3 | `yiisoft/*` packages, DI/config, middleware, Psalm, PHPUnit; Symfony/Laravel for comparison |
| `node-engineer` | Node 24 / TS backend | Hono / NestJS / Fastify, BFF, SSR servers, WebSocket servers on Node |
| `database-engineer` | PostgreSQL 18, Redis | Schema, migrations, indexes, query plans, transactions, backups |
| `graphql-engineer` | GraphQL (priority API style) | SDL schema, resolvers (gqlgen / graphql-php / Yoga), DataLoader, cost limits, persisted operations, subscriptions, typed clients (Apollo Angular / villus), codegen |
| `api-designer` | Contracts | GraphQL SDL (priority), OpenAPI 3.1, AsyncAPI, versioning, RFC 9457 errors, pagination, idempotency, gRPC/WebSocket protocols |
| `angular-engineer` | Angular 22 | Signals, Signal Forms, standalone, zoneless, Angular Material 22, Taiga UI 5, CDK, SSR/hydration |
| `vue-engineer` | Vue 3.5/3.6, Nuxt 4 | Composition API, Pinia, Vapor mode, Nuxt layers, Vite 8 |
| `typescript-engineer` | TS 7, tooling | tsconfig, ESLint flat config, Prettier/Biome, Vite/Rolldown, pnpm monorepos, shared packages |
| `css-engineer` | CSS | Modern CSS (container queries, `:has`, layers, nesting), design tokens, Tailwind 4, responsive, dark theme |
| `accessibility-specialist` (Haiku) | WCAG 2.2 AA | Semantics, keyboard, ARIA, contrast, focus, screen readers, a11y audits |
| `threejs-engineer` | three.js r185 | Scenes, materials, WebGPU/TSL, post-processing, glTF loading, draw-call optimisation |
| `web-game-engineer` | 2D / game systems | Game loop, fixed timestep, input, Web Audio, assets/atlases, PixiJS 8 / Phaser, saves |
| `multiplayer-engineer` | Networked games | WebSocket/WebRTC, server-authoritative simulation (Go), ticks, interpolation, anti-cheat basics, matchmaking |
| `appsec-engineer` | Code security | OWASP Top 10:2025 review, auth/sessions/JWT, injection, SSRF, uploads, SAST, security tests, dynamic testing of the project's own app |
| `network-security-engineer` | Network and perimeter | TLS 1.3/HSTS, nginx/Caddy hardening, security headers/CSP, rate limiting, WAF, DNS, firewall/Docker networks |
| `test-engineer` | Tests | Vitest 4, Playwright, PHPUnit 12, `go test`/testify, contract tests, fixtures, coverage |
| `performance-engineer` | Performance | Core Web Vitals, Lighthouse, bundle analysis, Go/PHP profiling, caching, N+1 |
| `devops-engineer` | Infra code | Multi-stage Dockerfiles, compose, GitHub Actions, secrets, health checks, logs/metrics |
| `seo-specialist` (Haiku) | SEO/sharing | Meta tags, OG, structured data, sitemap, SSR/prerender, SPA indexing |
| `tech-writer` (Haiku) | Documentation | README, API docs from contracts, runbooks, changelog, ADR formatting |
