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

Result: `.claude/docs/technical-preferences.md` without `[TO BE CONFIGURED]` plus a decision-log line — one decided entry `D-NN` in `production/decisions.md` (template `decisions.md`; created from it when the file does not exist) that names the stack chosen, the date and "applied: technical-preferences.md". The line is a pointer, not a second copy of the preferences.
Big forks are recorded as ADRs via `/architecture-decision`.

## Phase 1: Context
1. **Read** `technical-preferences.md`, `docs/specs/product-spec.md` (if any) and `stack-reference/index.md` (current versions).
2. **Reference age.** A reference older than 60 days → say so and suggest `/stack-update` first. It does not block the interview.
3. **Environment.** Run `go version`, `php -v`, `node -v`, `pnpm -v`, `docker --version` and report what is missing. A missing tool the chosen stack needs ends in the verdict `BLOCKED (missing tools: …)`.

## Phase 2: Interview
One `AskUserQuestion` at a time, recommendation first. `--quick` accepts all recommendations without questions and shows the summary; the Phase 3 write gate still applies.

1. **Project type** (argument or question), platforms (desktop/mobile-web/PWA), rendering (SPA/SSR/SSG).
2. **Backend**: **Go** (services, realtime, games) | **PHP** (content systems, existing PHP ecosystem) | **Node** (BFF/SSR) | none — the version of each is the one `stack-reference/index.md` names today (the question quotes it; the skill carries no version of its own). Recommendation by type. For PHP, two more questions:
   - The version: the studio target per `php.md` (Recommended) | the floor per `php.md` (only when the hosting cannot run the target yet — recorded in **Language/runtime** with the reason and an upgrade story). Both numbers are read from `php.md` at question time.
   - `php_framework`: **Yii3** (Recommended — the only framework with a full studio reference, `yii3.md`) | Symfony (`symfony.md`, stub) | Laravel (`laravel.md`, stub) | Slim | none (PSR-15 pipeline only). Any choice but Yii3 is recorded with the line "php-engineer works from the official documentation; the studio reference is a stub".
3. **API style**: **GraphQL (SDL, default for the client API)** | REST/OpenAPI | both (GraphQL + REST for files/webhooks). Then:
   - `api_contract_path`: for a Go module `api/schema.graphqls` (Recommended; gqlgen reads it in place), otherwise `docs/architecture/api/schema.graphql`.
   - With gqlgen, `graphql_models`: **dto** (generated models mapped in resolvers — Recommended) | bind (domain types in `gqlgen.yml`).
4. **Frontend**: **Angular** (+ Material | Taiga UI) | **Vue / Nuxt** (+ UI kit) | vanilla TS (a game without a UI framework). For Angular, also the file naming style: v20+ without suffixes | classic.
5. **Game** (type game): three.js (3D) | PixiJS (2D) | Phaser | Babylon; networking: none | server-authoritative.
6. **Data**: PostgreSQL (+ Redis) — confirm; auth: sessions | OIDC | JWT+BFF.
7. **Infra**: Docker + compose, GitHub Actions — confirm. Then the deploy target (contract `.claude/docs/deploy-target-contract.md`):
   - **Deploy target**, one `AskUserQuestion`: `compose-ssh` (reference script shipped — recommended for a single server) · `kubernetes` · `cloud:<name>` · a container-platform kit if one is installed (e.g. `portainer`) · `manual`.
   - **Deploy delegate** follows from the target: `agent <name>` (from `.claude/agents/*-ops.md` with `deploy-target:`), `script scripts/deploy/<target>.sh`, or `none`.
   - `compose-ssh` adds two files to the Phase 3 write: `.claude/docs/templates/deploy/compose-ssh.sh` copied to `scripts/deploy/compose-ssh.sh`, and a new `docs/deploy/compose-ssh.md`.
   - A shared host with its own proxy repository → also ask `Infra repo` and `Proxy config`.
8. **Layout**: monorepo (`apps/`, `packages/`) | current structure — show a proposal. For a Go backend also `go_layout`, with the directory tree shown:
   - **project-layout** (golang-standards/project-layout adapted in `go.md`: `cmd/`, `internal/`, `pkg/` only when exported, `api/`, `configs/`, `scripts/`, `build/`, `deployments/`, `test/`) — recommended for services;
   - **minimal** (`main.go` + `go.mod`) for a single tool/PoC.
9. **PHP architecture** (`php.md`), one `AskUserQuestion` each, recommendation first:
   - `php_architecture`: **layered** (`src/Domain` → `src/Application` → `src/Infrastructure`, deptrac-enforced, the framework only in Infrastructure — Recommended for a service with business rules or one that may change framework) | framework (the framework's own layout).
   - When layered, the directory shape: **use cases per context** (Recommended) | flat. It is shown as the tree and recorded in the layout ADR, not as a field.
   - `php_static_analysis`: **PHPStan level 9** (Recommended) | Psalm level 1 (the yiisoft ecosystem's own tool).
   - `php_cs_tool`: **ECS** (`perCs: true`, Recommended) | php-cs-fixer (`@PER-CS`).
   - `php_domain_allow`: vendor namespaces the domain may use (default `none`).
   - Coverage gate: **Domain 90 % / Application 80 %** (Recommended) | other numbers.
   - Show the resulting tree. The `deptrac.yaml`, analyser config, coding-standard config, `phpunit.xml`, `scripts/coverage-gate.php` and composer scripts come from `.claude/docs/templates/php/` in `/test-setup`.
10. **Go architecture** (`go.md` "Architecture style"), one `AskUserQuestion` each, recommendation first:
    - `go_architecture`: **layered** (`internal/domain` → `usecase` → `infrastructure`, depguard-enforced — Recommended for a service with business rules or several entry points) | modular (`internal/<domain>/`, handler → service → repository — a tool or a small service).
    - When layered, the directory shape: **one use-case package per context** (Recommended) | one `usecase` package. It is shown as the tree and recorded in the layout ADR, not as a field.
    - `go_composition_root`: **internal/app** (Recommended, the `cmd/` contract by numbers) | main (the classic shape, recorded as an accepted deviation in the layout ADR).
    - `go_router`: **chi v5** (Recommended) | net/http ServeMux.
    - `go_domain_allow`: value libraries the domain may import (default `none`, stdlib only; e.g. `github.com/google/uuid`).
    - Coverage gate: **domain 90 % / usecase 80 %** (Recommended) | other numbers.
    - Show the resulting tree for the chosen shape. The `.golangci.yml`, `scripts/coverage-gate.sh` and Makefile targets come from `.claude/docs/templates/go/` in `/test-setup`.

## Phase 3: Draft and write
1. **Draft** the full `technical-preferences.md`: exact versions from the reference, naming conventions for the chosen languages (the Angular file style from Phase 2), performance budgets, and the `Deploy target` / `Deploy delegate` (plus `Infra repo` / `Proxy config`) fields. Show it whole.
2. **Ask** "May I write `.claude/docs/technical-preferences.md` and the `D-NN` line in `production/decisions.md`?" as one `AskUserQuestion`: write (Recommended) · show the draft/diff first · not now. The question also names the `compose-ssh` files from Phase 2 step 7 when that target was chosen, and `production/stage.txt` → `specification` when the product spec exists.
3. After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker).
4. **Write** the files the answer covered: `technical-preferences.md`; for `compose-ssh`, copy the script with `cp` and create `docs/deploy/compose-ssh.md`; update `production/stage.txt`. Add the decision-log line: the next free `D-NN` under **Decided** in `production/decisions.md` (`### D-NN · Stack chosen: <backend> + <frontend> + <API style> ✅`, opened and decided today by `/setup-stack`, applied: `technical-preferences.md`).

## Phase 4: Commit (documents lane)
Right after the write, one commit gate (rule 7, `.claude/docs/git-workflow.md` § Documents): `docs: stack decision`, staging exactly the written documents — `.claude/docs/technical-preferences.md`, `production/decisions.md`, `production/stage.txt`, `docs/deploy/compose-ssh.md` when created.
- On the default branch when no story work is in progress.
- When HEAD is a story branch, name it and ask one `AskUserQuestion`: switch to the default branch and commit there (Recommended — a pipeline-wide document) · commit here (the document belongs to this story) · leave uncommitted.
- `scripts/deploy/compose-ssh.sh` is toolchain work, not a document: it does not ride the `docs:` commit. Name it in the result and offer the chore lane for it (git-workflow.md § Chore / infra).

Nothing is committed without the answer.

## Phase 5: Consequences
- Propose ADRs for non-trivial forks (GraphQL vs REST, Angular vs Vue, game engine) — `/architecture-decision`. The user decides; no ADR is written here.
- Propose `/test-setup` and `/threat-model` as the next mandatory architecture steps.

Verdict: `COMPLETE` | `BLOCKED (missing tools: …)`. Next step — one `AskUserQuestion`, the Recommended option decided by what Phase 1 found, never by a default:
- no `docs/specs/product-spec.md` → `/product-spec` (Recommended) · `/game-concept` (type game / game+backend) · revise the stack;
- the product spec exists → `/feature-spec` (Recommended; `/create-stories` Recommended instead when `docs/specs/features/*.md` already exist) · `/test-setup` · `/product-spec` (revise it) · revise the stack.
`/product-spec` is never Recommended over a spec that already exists.
