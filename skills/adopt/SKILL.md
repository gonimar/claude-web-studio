---
name: adopt
description: "Brownfield onboarding — detects the real stack of an existing project (Go/PHP/Node, Angular/Vue/Nuxt, GraphQL/REST, three.js), fills technical-preferences from the facts, audits existing artifacts against studio formats, merges settings/CLAUDE.md, and produces a numbered adoption plan. Run when installing the studio into an existing project."
argument-hint: "[full | stack | docs | settings]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, AskUserQuestion, Task
model: sonnet
---

# Adopt — attach the studio to an existing project

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

Answers not "what exists?" but "will what exists work with the studio's skills?".
Writes only after "May I write?". If `.claude/docs/` is missing, run `/init` first. Not a git repository (`git rev-parse --show-toplevel` fails) → one `AskUserQuestion`: initialize git now (Recommended) · stop. On "stop" — `BLOCKED (not a git repository — adoption relies on history and branches)`, never re-asked in the same run. On "yes" — plain `git init` (it honours the user's `init.defaultBranch`); never pass `-b`/`--initial-branch`. After the "write" answer: `touch .claude/.write-consent` (rule 7).

## Phase 1: Stack detection (`stack` / `full`)
Say "Scanning the project…", then read:
- `go.mod` (Go version, router, pgx/sqlc, gqlgen), `composer.json` (PHP, `yiisoft/*`, Symfony/Laravel, graphql-php), `package.json` (Angular/Vue/Nuxt/Vite versions, TS, three, pixi, GraphQL clients), `angular.json`, `nuxt.config.*`, `vite.config.*`, `gqlgen.yml` (its `schema:` entry names `api_contract_path`), `*.graphql`, `*.graphqls`, `openapi*.yaml`, `compose*.yaml`, `Dockerfile*`, `.github/workflows/*`, existing deploy/advisor skills in `.claude/skills`.
- Compare versions with `.claude/docs/stack-reference/index.md`: outdated majors → a table "now → current → upgrade path (reference section)".
- Go projects: compare the tree with `go.md` "Project layout" (golang-standards/project-layout adapted) — `src/`, `utils/`/`common/`, logic in `cmd/`, an unused `pkg/` → INFO/MEDIUM findings with a migration note; record the actual variant as `go_layout` in technical-preferences (never restructure during adoption). Record the architecture style from the tree, never from a wish: `internal/domain/` + `internal/usecase/` present (or the go-clean-template spelling `internal/entity/` + `internal/usecase/` + `internal/repo/`) **and** the graph is clean — `go list -deps ./internal/domain/... | grep '<module>/internal/' | grep -v internal/domain` prints nothing, and usecase reaches neither infrastructure nor app (the `arch-check` target) → `go_architecture: layered`; a layered tree with cross-layer imports is recorded as `modular` with an INFO "layered by name, N cross-layer imports — /refactor layout"; otherwise `modular`. Detection by the mechanism that will enforce it, never by folder names alone.
- PHP projects: the PHP version from `composer.json` `require.php` and `composer show --locked` (below the floor in `php.md` → HIGH finding, on the floor → INFO with an upgrade story to the target), recorded in **Language/runtime**; `php_framework` from `composer.json` (`yiisoft/*` → yii3; `symfony/framework-bundle` → symfony; `laravel/framework` → laravel; `slim/slim` → slim; none of them → none); `php_architecture` from the tree **and** the dependency direction — `src/Domain` + `src/Application` present and `grep -rlE 'use (FRAMEWORK_NAMESPACES|App\\Infrastructure)' src/Domain src/Application` empty → layered, a layered tree with framework imports inside → framework with an INFO "layered by name — /refactor layout"; `php_static_analysis` from `phpstan.neon*`/`psalm.xml`; `php_cs_tool` from `ecs.php`/`.php-cs-fixer*.php`; deptrac config present or not; the PHPUnit major from `composer show --locked phpunit/phpunit` (below the major `php.md` names → MEDIUM finding); DDL in PHP classes outside a migrations directory → MEDIUM finding. A framework whose reference is a stub is recorded with the line "php-engineer works from the official documentation". Moving to `layered` or to another framework is offered as `/refactor layout` / `/refactor framework --dry-run` in the adoption plan, never done here. `go_router` from `go.mod` (chi / none → ServeMux); `graphql_models` from `gqlgen.yml` (`models:` bound to `internal/domain` → bind, else dto); `api_contract_path` from `gqlgen.yml` `schema:` (or the OpenAPI file's real location) — never from the studio default. A `.golangci.yml` in v1 format (`linters-settings:`, no `version: "2"`) is a MEDIUM finding — golangci-lint v2 rejects it. Moving to `layered` is offered as `/refactor layout` in the adoption plan, not done here.

**Fill `technical-preferences.md` in this run.** Every field the files answer is written from the facts:
Project type and Rendering (from the framework and routes), Backend (language/runtime, framework,
database and cache from compose, API style from schema/openapi/routes, authentication if visible),
Frontend (framework, build, styles; `vanilla` or `none` when there is none), Tests and quality (from
`phpunit.xml`, `vitest.config`, `go test`, lint configs; Go: coverage thresholds only when a gate script or CI step enforces them, else `indicator`), Infrastructure (containers, CI, deploy from
compose/workflows/deploy skills — **Deploy target and delegate** by `docs/deploy-target-contract.md`: an agent `.claude/agents/*-ops.md` with `deploy-target:` in its frontmatter or a `scripts/deploy/*.sh`; a kit that only ships a slash command is noted as `none` with the reason "kit ships only a slash command — add `deploy-target:` to its agent or a `scripts/deploy/<target>.sh`"; **Infra repo / Proxy config** asked when the host is shared), Layout (`backend_root`, `frontend_root`, `go_layout`, `go_architecture` and its companions, `php_framework`, `php_architecture` and its companions). `[TO BE CONFIGURED]`
may remain only for fields no file answers; ask those in one `AskUserQuestion` (project type, API style,
layout — whatever is still unknown).

The write is gated, in this exact order:
1. Show the filled draft **in the chat message** (fenced block). Showing the draft never means
   creating the file — at this point `technical-preferences.md` is still the untouched init
   placeholder version.
2. Ask "May I write `.claude/docs/technical-preferences.md`?" — one `AskUserQuestion`:
   write (Recommended) · adjust first · not now.
3. Only after the "write" answer call Write/Edit. Calling Write/Edit on this file before the
   answer is a protocol violation even if you revert afterwards (spec case 8) — asking
   "the file is already written as a draft, confirm?" is exactly the failure this order exists
   to prevent.

Do not defer to `/setup-stack`: after `/adopt` the stack counts as chosen, and the template's note
"while [TO BE CONFIGURED] remains, skills treat the stack as not chosen" is exactly why.

## Phase 2: Artefact audit (`docs` / `full`)
| Artefact | Where | Format check |
|---|---|---|
| product spec | `docs/specs/product-spec.md`, README | template sections |
| feature specs | `docs/specs/features/*.md` | Given/When/Then criteria, "Security" section |
| ADRs | `docs/architecture/adr-*.md`, `docs/adr/` | Status/Context/Options/Decision/Consequences |
| contract | `docs/architecture/api/api-contract.md` + the file at `api_contract_path` (`api/schema.graphqls`, `schema.graphql`, `openapi*.yaml`) | present, one copy, diff check in CI |
| threat model | `docs/architecture/threat-model.md` | STRIDE table |
| test strategy | `docs/architecture/test-strategy.md` | tools per level |
| roadmap/stories | `production/roadmap.md`, `production/stories/` | checkbox format |
| CLAUDE.md | root | studio block (`web-studio`), Language section, @-includes |
Classify: BLOCKING (a skill would fail or lie), HIGH (traceability lost), MEDIUM, INFO. A roadmap kept
by a companion advisor skill in its own format is INFO ("not migrated"), never a migration item.
Every BLOCKING and HIGH gets a sink, not only a row in the plan: one `AskUserQuestion` per item — record it in
`production/findings.md` (template `findings.md`; id `ADOPT-NNN`, severity, area, the decision needed) (Recommended) ·
story stubs now via `/create-stories` · plan only. A BLOCKING that is neither recorded nor turned into a story is
named as such in the verdict line (`/help`, `/create-stories` and `/sprint-plan` read `production/findings.md`;
the adoption plan is read only by `/help` and only for its first open item). A HIGH that is a **format** gap (a roadmap in a foreign format, story cards without a criteria table, ADRs without options) gets the plan item `/migrate <type> --dry-run` — never "rewrite by hand".

## Phase 3: Settings (`settings` / `full`)
- `.claude/settings.web-studio.json` present → show a diff with `settings.json` for `hooks`, `permissions`, `statusLine`; propose a merge (never drop foreign hooks; merge arrays).
- `CLAUDE.md` without the studio block → propose inserting the Language/Studio/Stack/Principles sections from the template (generated from `technical-preferences.md` if the template is unavailable).
- `.gitignore`: `production/session-state/`, `session-logs/`, `settings.local.json`.
- Companion skills detected (advisor, deploy) → note them in the roster's Tier 0 row.

## Phase 4: Adoption plan
Write `docs/adoption-plan-<date>.md` from `.claude/docs/templates/adoption-plan.md`: verdict, the facts
table, the artefact audit and a numbered plan where every item is a checkbox `- [ ] N. <priority> — <command> → <artefact>`
(`/help` reads the open items and offers the first one; tick items `[x]` when done). Propose `production/stage.txt`
from the facts (`build` / `operate`) if `/init` has not already set it.

Verdict: `COMPLIANT` | `NEEDS MIGRATION (N blocking)`.

The plan so far reflects only the artefact gaps — nobody has asked the owner what they actually want.
Next step — one `AskUserQuestion` asking exactly that: the plan's first open item (Recommended) ·
"describe your goal for this project in your own words" (free text; reorder the plan around the
answer — goal items first — and only then recommend a command) · `/help` · stop here. An owner who
installs the studio on a working project always has an intent (tidy it up, a new feature, security,
an upgrade); the plan must not pretend the artefact audit is that intent.
