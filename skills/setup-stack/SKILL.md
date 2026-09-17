---
name: setup-stack
description: "Selects and pins the technology stack — project type, backend (Go/PHP-Yii3/Node), frontend (Angular/Vue/Nuxt), UI kit (Material/Taiga), API style (GraphQL default), game engine (three.js/Pixi/Phaser), database, tests, CI, layout — and writes technical-preferences.md with exact versions from the stack reference. Run once at project start or when the stack changes."
argument-hint: "[type: site|spa|api|fullstack|game|game+backend] [--quick]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, AskUserQuestion, Task
model: sonnet
---

# Setup Stack

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

Result: `.claude/docs/technical-preferences.md` without `[TO BE CONFIGURED]` plus a decision-log line.
Big forks are recorded as ADRs via `/architecture-decision`.

## Phase 1: Context
Read `technical-preferences.md`, `docs/specs/product-spec.md` (if any), `stack-reference/index.md`
(current versions; older than 60 days → suggest `/stack-update` first).
Check the environment: `go version`, `php -v`, `node -v`, `pnpm -v`, `docker --version` — report what is missing.

## Phase 2: Interview (one `AskUserQuestion` at a time, recommendation first)
1. Project type (argument or question), platforms (desktop/mobile-web/PWA), rendering (SPA/SSR/SSG).
2. Backend: **Go 1.27** (services, realtime, games) | **PHP 8.5** (content systems, existing PHP ecosystem) | **Node 24** (BFF/SSR) | none. Recommendation by type. PHP → the version, one `AskUserQuestion`: **8.5** (Recommended — the studio target per `php.md`) | 8.4 (the floor per `php.md`; only when the hosting cannot run 8.5 yet — recorded in **Language/runtime** with the reason and an upgrade story); then `php_framework`, one `AskUserQuestion`: **Yii3** (Recommended — the only framework with a full studio reference, `yii3.md`) | Symfony (`symfony.md`, stub) | Laravel (`laravel.md`, stub) | Slim | none (PSR-15 pipeline only); any choice but Yii3 is recorded with the line "php-engineer works from the official documentation; the studio reference is a stub".
3. API style: **GraphQL (SDL, default for the client API)** | REST/OpenAPI | both (GraphQL + REST for files/webhooks). Then `api_contract_path` — for a Go module `api/schema.graphqls` (Recommended; gqlgen reads it in place), otherwise `docs/architecture/api/schema.graphql`; and, with gqlgen, `graphql_models`: **dto** (generated models mapped in resolvers — Recommended) | bind (domain types in `gqlgen.yml`).
4. Frontend: **Angular 22** (+ Material 22 | Taiga UI 5) | **Vue 3.5 / Nuxt 4** (+ UI kit) | vanilla TS (a game without a UI framework).
5. Game (type game): three.js r185 (3D) | PixiJS 8 (2D) | Phaser | Babylon 8; networking: none | server-authoritative.
6. Data: PostgreSQL 18 (+ Redis 8) — confirm; auth: sessions | OIDC | JWT+BFF.
7. Infra: Docker + compose, GitHub Actions — confirm. **Deploy target** (one `AskUserQuestion`): `compose-ssh` (reference script shipped — recommended for a single server) · `kubernetes` · `cloud:<name>` · a container-platform kit if one is installed (e.g. `portainer`) · `manual`; the delegate follows (`agent <name>` from `.claude/agents/*-ops.md` with `deploy-target:`, `script scripts/deploy/<target>.sh`, or `none`) — contract `docs/deploy-target-contract.md`; `compose-ssh` copies `.claude/docs/templates/deploy/compose-ssh.sh` to `scripts/deploy/compose-ssh.sh` and creates `docs/deploy/compose-ssh.md`. Shared host with its own proxy repository → also `Infra repo` and `Proxy config`.
8. Layout: monorepo (`apps/`, `packages/`) | current structure — show a proposal. For a Go backend also `go_layout`: **project-layout** (golang-standards/project-layout adapted in `go.md`: `cmd/`, `internal/`, `pkg/` only when exported, `api/`, `configs/`, `scripts/`, `build/`, `deployments/`, `test/`) — recommended for services | **minimal** (`main.go` + `go.mod`) for a single tool/PoC; show the directory tree.
9a. PHP architecture (`php.md`), one `AskUserQuestion` each, recommendation first: `php_architecture` — **layered** (`src/Domain` → `src/Application` → `src/Infrastructure`, deptrac-enforced, the framework only in Infrastructure — Recommended for a service with business rules or one that may change framework) | framework (the framework's own layout); when layered, the directory shape — **use cases per context** (Recommended) | flat — is shown as the tree and recorded in the layout ADR, not as a field; `php_static_analysis` — **PHPStan level 9** (Recommended) | Psalm level 1 (the yiisoft ecosystem's own tool); `php_cs_tool` — **ECS** (`perCs: true`, Recommended) | php-cs-fixer (`@PER-CS`); `php_domain_allow` — vendor namespaces the domain may use (default `none`); coverage gate — **Domain 90 % / Application 80 %** (Recommended) | other numbers. Show the resulting tree. The `deptrac.yaml`, analyser config, coding-standard config, `phpunit.xml`, `scripts/coverage-gate.php` and composer scripts come from `docs/templates/php/` in `/test-setup`.
9b. Go architecture (`go.md` "Architecture style"), one `AskUserQuestion` each, recommendation first: `go_architecture` — **layered** (`internal/domain` → `usecase` → `infrastructure`, depguard-enforced — Recommended for a service with business rules or several entry points) | modular (`internal/<domain>/`, handler → service → repository — a tool or a small service); when layered, the directory shape — **one use-case package per context** (Recommended) | one `usecase` package — is shown as the tree and recorded in the layout ADR, not as a field; `go_composition_root` — **internal/app** (Recommended, the `cmd/` contract by numbers) | main (the classic shape, recorded as an accepted deviation in the layout ADR); `go_router` — **chi v5** (Recommended) | net/http ServeMux; `go_domain_allow` — value libraries the domain may import (default `none`, stdlib only; e.g. `github.com/google/uuid`); coverage gate — **domain 90 % / usecase 80 %** (Recommended) | other numbers. Show the resulting tree for the chosen shape. The `.golangci.yml`, `scripts/coverage-gate.sh` and Makefile targets come from `docs/templates/go/` in `/test-setup`.
`--quick` — accept all recommendations without questions, show the summary.

## Phase 3: Draft
The full `technical-preferences.md` with exact versions from the reference, naming conventions for the chosen languages
(Angular file style v20+ without suffixes or classic — ask), performance budgets. Show it whole. "May I write `.claude/docs/technical-preferences.md`?" — one `AskUserQuestion`: write (Recommended) · show the draft/diff first · not now After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker).

## Phase 4: Consequences
- Propose ADRs for non-trivial forks (GraphQL vs REST, Angular vs Vue, game engine) — `/architecture-decision`.
- Propose `/test-setup` and `/threat-model` as the next mandatory architecture steps.
- Update `production/stage.txt` → `specification` if the product spec exists.

Verdict: `COMPLETE` | `BLOCKED (missing tools: …)`. Next step — one `AskUserQuestion`: `/product-spec` (Recommended) · `/game-concept` · revise the stack.
