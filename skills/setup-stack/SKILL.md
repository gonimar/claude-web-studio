---
name: setup-stack
description: "Selects and pins the technology stack — project type, backend (Go/PHP-Yii3/Node), frontend (Angular/Vue/Nuxt), UI kit (Material/Taiga), API style (GraphQL default), game engine (three.js/Pixi/Phaser), database, tests, CI, layout — and writes technical-preferences.md with exact versions from the stack reference. Run once at project start or when the stack changes."
argument-hint: "[type: site|spa|api|fullstack|game|game+backend] [--quick]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, AskUserQuestion, Task
model: sonnet
---

# Setup Stack

Result: `.claude/docs/technical-preferences.md` without `[TO BE CONFIGURED]` plus a decision-log line.
Big forks are recorded as ADRs via `/architecture-decision`.

## Phase 1: Context
Read `technical-preferences.md`, `docs/specs/product-spec.md` (if any), `stack-reference/index.md`
(current versions; older than 60 days → suggest `/stack-update` first).
Check the environment: `go version`, `php -v`, `node -v`, `pnpm -v`, `docker --version` — report what is missing.

## Phase 2: Interview (one `AskUserQuestion` at a time, recommendation first)
1. Project type (argument or question), platforms (desktop/mobile-web/PWA), rendering (SPA/SSR/SSG).
2. Backend: **Go 1.27** (services, realtime, games) | **PHP 8.5 + Yii3** (content systems, existing PHP ecosystem) | **Node 24** (BFF/SSR) | none. Recommendation by type.
3. API style: **GraphQL (SDL, default for the client API)** | REST/OpenAPI | both (GraphQL + REST for files/webhooks).
4. Frontend: **Angular 22** (+ Material 22 | Taiga UI 5) | **Vue 3.5 / Nuxt 4** (+ UI kit) | vanilla TS (a game without a UI framework).
5. Game (type game): three.js r185 (3D) | PixiJS 8 (2D) | Phaser | Babylon 8; networking: none | server-authoritative.
6. Data: PostgreSQL 18 (+ Redis 8) — confirm; auth: sessions | OIDC | JWT+BFF.
7. Infra: Docker + compose, GitHub Actions, deployment (compose on a server / container platform / cloud; a deploy skill if installed) — confirm.
8. Layout: monorepo (`apps/`, `packages/`) | current structure — show a proposal.
`--quick` — accept all recommendations without questions, show the summary.

## Phase 3: Draft
The full `technical-preferences.md` with exact versions from the reference, naming conventions for the chosen languages
(Angular file style v20+ without suffixes or classic — ask), performance budgets. Show it whole. "May I write `.claude/docs/technical-preferences.md`?"

## Phase 4: Consequences
- Propose ADRs for non-trivial forks (GraphQL vs REST, Angular vs Vue, game engine) — `/architecture-decision`.
- Propose `/test-setup` and `/threat-model` as the next mandatory architecture steps.
- Update `production/stage.txt` → `specification` if the product spec exists.

Verdict: `COMPLETE` | `BLOCKED (missing tools: …)`. Next step: `/product-spec` or `/game-concept`.
