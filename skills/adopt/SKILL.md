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

Writes only after "May I write?", asked as an `AskUserQuestion`. After the "write" answer: `touch .claude/.write-consent` (rule 7).
A command in a hand-off is `/web-studio:<command>` in plugin mode and `/<command>` in copy mode (coordination-rules § Subagents).

**Mode → phases** (argument; no argument = `full`). "Before Phase 1" runs in every mode.

| Mode | Phase 1 stack | Phase 2 artefacts | Phase 3 settings | Phase 4 plan | Phase 5 commit |
|---|---|---|---|---|---|
| `full` | yes | yes | yes | yes | yes |
| `stack` | yes | — | — | yes (stack findings only; the artefact audit is marked "not run — `/adopt docs`") | yes |
| `docs` | — | yes | — | yes (artefact findings only; the facts table reads from the current `technical-preferences.md`) | yes |
| `settings` | — | — | yes | — (only the settings diff; no plan file) | yes (for `CLAUDE.md`/roster only) |

A phase a mode skips is named as skipped in the result, never silently absent.

## Before Phase 1
1. `.claude/docs/` missing → run `/init` first, and stop.
2. Not a git repository (`git rev-parse --show-toplevel` fails) → one `AskUserQuestion`: initialize git now (Recommended) · stop.
   - "stop" → `BLOCKED (not a git repository — adoption relies on history and branches)`; never re-asked in the same run.
   - "initialize" → plain `git init`, which honours the user's `init.defaultBranch`. Never pass `-b`/`--initial-branch`.

## Phase 1: Stack detection (`stack` / `full`)
Say "Scanning the project…", then:
1. **Read the manifests and configs**: `go.mod` (Go version, router, pgx/sqlc, gqlgen), `composer.json` (PHP, `yiisoft/*`, Symfony/Laravel, graphql-php), `package.json` (Angular/Vue/Nuxt/Vite versions, TS, three, pixi, GraphQL clients), `angular.json`, `nuxt.config.*`, `vite.config.*`, `gqlgen.yml`, `*.graphql`, `*.graphqls`, `openapi*.yaml`, `compose*.yaml`, `Dockerfile*`, `.github/workflows/*`, existing deploy/advisor skills in `.claude/skills`.
2. **Versions**: compare with `.claude/docs/stack-reference/index.md`. Outdated majors → a table "now → current → upgrade path (reference section)".
3. **Go projects.**
   - Layout: compare the tree with `go.md` "Project layout" (golang-standards/project-layout adapted). `src/`, `utils/`/`common/`, logic in `cmd/`, an unused `pkg/` → INFO/MEDIUM findings with a migration note. Record the actual variant as `go_layout`; never restructure during adoption.
   - Architecture style, from the tree and the dependency graph, never from a wish or from folder names alone:
     - `internal/domain/` + `internal/usecase/` present (or the go-clean-template spelling `internal/entity/` + `internal/usecase/` + `internal/repo/`) **and** the graph is clean → `go_architecture: layered`. Clean means `go list -deps ./internal/domain/... | grep '<module>/internal/' | grep -v internal/domain` prints nothing (`internal/entity` in the go-clean-template spelling), and usecase reaches neither infrastructure nor app (the `arch-check` target).
     - A layered tree with cross-layer imports → `modular`, with an INFO "layered by name, N cross-layer imports — /refactor layout".
     - Otherwise `modular`.
   - `go_router` from `go.mod` (chi; none → ServeMux).
   - `graphql_models` from `gqlgen.yml` (`models:` bound to `internal/domain` → bind, else dto).
   - A `.golangci.yml` in v1 format (`linters-settings:`, no `version: "2"`) → MEDIUM finding: golangci-lint v2 rejects it.
   - Moving to `layered` is offered as `/refactor layout` in the adoption plan, never done here.
4. **PHP projects.**
   - PHP version from `composer.json` `require.php` and `composer show --locked`, recorded in **Language/runtime**. Below the floor in `php.md` → HIGH finding; on the floor → INFO with an upgrade story to the target.
   - `php_framework` from `composer.json`: `yiisoft/*` → yii3; `symfony/framework-bundle` → symfony; `laravel/framework` → laravel; `slim/slim` → slim; none of them → none. A framework whose reference is a stub is recorded with the line "php-engineer works from the official documentation".
   - `php_architecture` from the tree **and** the dependency direction. `src/Domain` + `src/Application` present and `grep -rlE 'use (FRAMEWORK_NAMESPACES|App\\Infrastructure)' src/Domain src/Application` empty (FRAMEWORK_NAMESPACES = the namespaces of the detected `php_framework`) → layered. A layered tree with framework imports inside → framework, with an INFO "layered by name — /refactor layout".
   - `php_static_analysis` from `phpstan.neon*`/`psalm.xml`; `php_cs_tool` from `ecs.php`/`.php-cs-fixer*.php`; deptrac config present or not.
   - PHPUnit major from `composer show --locked phpunit/phpunit`; below the major `php.md` names → MEDIUM finding.
   - DDL in PHP classes outside a migrations directory → MEDIUM finding.
   - Moving to `layered` or to another framework is offered as `/refactor layout` / `/refactor framework --dry-run` in the adoption plan, never done here.
5. **Contract**: `api_contract_path` from the `schema:` entry of `gqlgen.yml`, or the OpenAPI file's real location; never from the studio default.

**Fill `technical-preferences.md` in this run.** Every field the files answer is written from the facts:
- Project type and Rendering: from the framework and routes.
- Backend: language/runtime, framework, database and cache from compose, API style from schema/openapi/routes, authentication if visible.
- Frontend: framework, build, styles; `vanilla` or `none` when there is none.
- Tests and quality: from `phpunit.xml`, `vitest.config`, `go test`, lint configs. Go: coverage thresholds only when a gate script or CI step enforces them, else `indicator`.
- Infrastructure: containers, CI, deploy from compose/workflows/deploy skills.
  - **Deploy target and delegate** by `.claude/docs/deploy-target-contract.md`: an agent `.claude/agents/*-ops.md` with `deploy-target:` in its frontmatter, or a `scripts/deploy/*.sh`. A kit that only ships a slash command is noted as `none` with the reason "kit ships only a slash command — add `deploy-target:` to its agent or a `scripts/deploy/<target>.sh`".
  - **Infra repo / Proxy config**: asked when the host is shared.
- Layout: `backend_root`, `frontend_root`, `go_layout`, `go_architecture` and its companions, `php_framework`, `php_architecture` and its companions.

`[TO BE CONFIGURED]` may remain only for fields no file answers. Ask those in one `AskUserQuestion`
(project type, API style, layout — whatever is still unknown) before the write gate.

**The write is gated, in this exact order:**
1. Show the filled draft **in the chat message**, rendered readably (rule 7): the fields as a table field · value · source fact. Showing the draft never means creating the file; at this point `technical-preferences.md` is still the untouched init placeholder version.
2. Ask "May I write `.claude/docs/technical-preferences.md`?" as one `AskUserQuestion`: write (Recommended) · adjust first · not now.
3. Only after the "write" answer call Write/Edit. Calling Write/Edit on this file before the answer is a protocol violation even if you revert afterwards; "the file is already written as a draft, confirm?" is exactly the failure this order prevents.

Do not defer to `/setup-stack`: after `/adopt` the stack counts as chosen, which is why the template says
"while [TO BE CONFIGURED] remains, skills treat the stack as not chosen".

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

1. **Classify**: BLOCKING (a skill would fail or lie), HIGH (traceability lost), MEDIUM, INFO. A roadmap kept by a companion advisor skill in its own format is INFO ("not migrated"), never a migration item.
2. **Format gaps.** A HIGH that is a **format** gap (a roadmap in a foreign format, story cards without a criteria table, ADRs without options) gets the plan item `/migrate <type> --dry-run`, never "rewrite by hand".
3. **Every BLOCKING and HIGH gets a sink**, not only a row in the plan: one `AskUserQuestion` per item — record it in `production/findings.md` (template `findings.md`; id `ADOPT-NNN`, severity, area, the decision needed) (Recommended) · story stubs now via `/create-stories` · plan only. The row is written only after the "record" answer. "Story stubs" is a hand-off, not a call: this skill does not list `Skill`, so the item becomes the plan's first open item with `/create-stories` as its command and the closing question offers it first (coordination-rules § Subagents). `/help`, `/create-stories` and `/sprint-plan` read `production/findings.md`; the adoption plan is read only by `/help`, and only for its first open item.
4. A BLOCKING or HIGH item that is neither recorded nor turned into a story is named as unrecorded in the verdict line.

## Phase 3: Settings (`settings` / `full`)
1. `.claude/settings.web-studio.json` present → show a diff with `settings.json` for `hooks`, `permissions`, `statusLine` and propose a merge: never drop foreign hooks; merge arrays.
2. `CLAUDE.md` without the studio block → propose inserting the Language/Studio/Stack/Principles sections from the kit's `templates/CLAUDE.md.template` (generated from `technical-preferences.md` if the template is unavailable). Insert; never overwrite the existing file.
3. `.gitignore` must list `production/session-state/`, `production/session-logs/`, `.claude/settings.local.json` and `.claude/agent-memory-local/` (the same four lines `/init` and `install.sh` add); propose the missing lines.
4. Companion skills detected (advisor, deploy) → propose noting them in the Tier 0 row of `.claude/docs/agent-roster.md`.
5. Show the proposals, then one `AskUserQuestion`: "May I write the changes above?" — write (Recommended) · show the draft/diff first · not now.

## Phase 4: Adoption plan
1. **Draft** `docs/adoption-plan-<date>.md` from `.claude/docs/templates/adoption-plan.md`: verdict, the facts table, the artefact audit and a numbered plan where every item is a checkbox `- [ ] N. <priority> — <command> → <artefact>`. `/help` reads the open items and offers the first one; items are ticked `[x]` when done.
2. **Stage**: propose `production/stage.txt` from the facts (`build` / `operate`) if `/init` has not already set it. It is written only with the plan's consent, never automatically.
3. **Write gate**: show the plan in the chat, then "May I write `docs/adoption-plan-<date>.md` (and `production/stage.txt`)?" as one `AskUserQuestion`: write (Recommended) · show the draft/diff first · not now.

## Phase 5: Commit (documents lane)
Right after the last write of the run, one commit gate (rule 7, `.claude/docs/git-workflow.md` § Documents): `docs: adopt web studio (<mode>)`, staging exactly the documents this run wrote — `.claude/docs/technical-preferences.md`, `production/findings.md`, `CLAUDE.md`, `.claude/docs/agent-roster.md`, `docs/adoption-plan-<date>.md`, `production/stage.txt` — whichever of them the earlier gates covered.
- On the default branch when no story work is in progress.
- When HEAD is a story branch, name it and ask one `AskUserQuestion`: switch to the default branch and commit there (Recommended — a pipeline-wide document) · commit here (the document belongs to this story) · leave uncommitted.
- `.claude/settings.json` and `.gitignore` (Phase 3) are toolchain work, not documents: they do not ride the `docs:` commit. Name them in the result and offer the chore lane for them (git-workflow.md § Chore / infra).
- Before asking, record the gate — `<hooks>session-state.sh set Gate "/adopt Phase 5: commit?"` (`<hooks>` is `.claude/hooks/` in copy mode and `${CLAUDE_PLUGIN_ROOT}/hooks/` in plugin mode) — and clear it after the answer (`<hooks>session-state.sh set Gate "—"`).

Nothing is committed without the answer; a run that wrote no document has no commit gate.

Verdict: `COMPLIANT` | `NEEDS MIGRATION (N blocking)`, followed by the unrecorded BLOCKING/HIGH items when there are any.

Next step — one `AskUserQuestion`. The plan so far reflects only the artefact gaps; nobody has asked the owner
what they actually want, and an owner who installs the studio on a working project always has an intent
(tidy it up, a new feature, security, an upgrade). Options:
- the plan's first open item (Recommended);
- "describe your goal for this project in your own words" (free text): reorder the plan around the answer, goal items first, and only then recommend a command;
- `/help`;
- stop here.
