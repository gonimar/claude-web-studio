---
name: adopt
description: "Brownfield onboarding — detects the real stack of an existing project (Go/PHP/Node, Angular/Vue/Nuxt, GraphQL/REST, three.js), fills technical-preferences from the facts, audits existing artifacts against studio formats, merges settings/CLAUDE.md, and produces a numbered adoption plan. Run when installing the studio into an existing project."
argument-hint: "[full | stack | docs | settings]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, AskUserQuestion, Task
model: sonnet
---

# Adopt — attach the studio to an existing project

Answers not "what exists?" but "will what exists work with the studio's skills?".
Writes only after "May I write?". If `.claude/docs/` is missing, run `/init` first.

## Phase 1: Stack detection (`stack` / `full`)
Say "Scanning the project…", then read:
- `go.mod` (Go version, router, pgx/sqlc, gqlgen), `composer.json` (PHP, `yiisoft/*`, Symfony/Laravel, graphql-php), `package.json` (Angular/Vue/Nuxt/Vite versions, TS, three, pixi, GraphQL clients), `angular.json`, `nuxt.config.*`, `vite.config.*`, `gqlgen.yml`, `*.graphql`, `openapi*.yaml`, `compose*.yaml`, `Dockerfile*`, `.github/workflows/*`, existing deploy/advisor skills in `.claude/skills`.
- Compare versions with `.claude/docs/stack-reference/index.md`: outdated majors → a table "now → current → upgrade path (reference section)".
- Go projects: compare the tree with `go.md` "Project layout" (golang-standards/project-layout adapted) — `src/`, `utils/`/`common/`, logic in `cmd/`, an unused `pkg/` → INFO/MEDIUM findings with a migration note; record the actual variant as `go_layout` in technical-preferences (never restructure during adoption).

**Fill `technical-preferences.md` in this run.** Every field the files answer is written from the facts:
Project type and Rendering (from the framework and routes), Backend (language/runtime, framework,
database and cache from compose, API style from schema/openapi/routes, authentication if visible),
Frontend (framework, build, styles; `vanilla` or `none` when there is none), Tests and quality (from
`phpunit.xml`, `vitest.config`, `go test`, lint configs), Infrastructure (containers, CI, deploy from
compose/workflows/deploy skills — **Deploy target and delegate** by `docs/deploy-target-contract.md`: an agent `.claude/agents/*-ops.md` with `deploy-target:` in its frontmatter or a `scripts/deploy/*.sh`; a kit that only ships a slash command is noted as `none` with the reason; **Infra repo / Proxy config** asked when the host is shared), Layout (`backend_root`, `frontend_root`, `go_layout`). `[TO BE CONFIGURED]`
may remain only for fields no file answers; ask those in one `AskUserQuestion` (project type, API style,
layout — whatever is still unknown), then write the file under "May I write?". Do not defer to
`/setup-stack`: after `/adopt` the stack counts as chosen, and the template's note "while
[TO BE CONFIGURED] remains, skills treat the stack as not chosen" is exactly why.

## Phase 2: Artefact audit (`docs` / `full`)
| Artefact | Where | Format check |
|---|---|---|
| product spec | `docs/specs/product-spec.md`, README | template sections |
| feature specs | `docs/specs/features/*.md` | Given/When/Then criteria, "Security" section |
| ADRs | `docs/architecture/adr-*.md`, `docs/adr/` | Status/Context/Options/Decision/Consequences |
| contract | `docs/architecture/api/`, `schema.graphql`, `openapi*.yaml` | present, diff check in CI |
| threat model | `docs/architecture/threat-model.md` | STRIDE table |
| test strategy | `docs/architecture/test-strategy.md` | tools per level |
| roadmap/stories | `production/roadmap.md`, `production/stories/` | checkbox format |
| CLAUDE.md | root | studio block (`web-studio`), Language section, @-includes |
Classify: BLOCKING (a skill would fail or lie), HIGH (traceability lost), MEDIUM, INFO. A roadmap kept
by a companion advisor skill in its own format is INFO ("not migrated"), never a migration item.

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

Verdict: `COMPLIANT` | `NEEDS MIGRATION (N blocking)`. Next step — one `AskUserQuestion`: the plan's first
open item (Recommended) · `/help` · stop here.
