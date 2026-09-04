---
name: adopt
description: "Brownfield onboarding — detects the real stack of an existing project (Go/PHP/Node, Angular/Vue/Nuxt, GraphQL/REST, three.js), audits existing artifacts against studio formats, merges settings/CLAUDE.md, and produces a numbered adoption plan. Run when installing the studio into an existing project."
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
Draft `technical-preferences.md` from facts; ask the unknowns in one `AskUserQuestion` (project type, API style, layout).

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
Classify: BLOCKING (a skill would fail or lie), HIGH (traceability lost), MEDIUM, INFO.

## Phase 3: Settings (`settings` / `full`)
- `.claude/settings.web-studio.json` present → show a diff with `settings.json` for `hooks`, `permissions`, `statusLine`; propose a merge (never drop foreign hooks; merge arrays).
- `CLAUDE.md` without the studio block → propose inserting the Language/Studio/Stack/Principles sections from the template (generated from `technical-preferences.md` if the template is unavailable).
- `.gitignore`: `production/session-state/`, `session-logs/`, `settings.local.json`.
- Companion skills detected (advisor, deploy) → note them in the roster's Tier 0 row.

## Phase 4: Adoption plan
Write `docs/adoption-plan-<date>.md`: numbered steps with priority, command (`/architecture-decision retrofit …`, `/threat-model`, `/test-setup`, `/stack-update`) and resulting artefact. Propose `production/stage.txt` from the facts.

Verdict: `COMPLIANT` | `NEEDS MIGRATION (N blocking)`. Next step: the plan's first item; usually `/help`.
