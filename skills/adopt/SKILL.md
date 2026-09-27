---
name: adopt
description: "Brownfield onboarding — detects the real stack of an existing project (Go/PHP/Node, Angular/Vue/Nuxt, GraphQL/REST, three.js, Kubernetes charts, OpenTelemetry/Prometheus), fills technical-preferences from the facts, audits existing artifacts against studio formats, merges settings/CLAUDE.md, and produces a numbered adoption plan. Run when installing the studio into an existing project."
argument-hint: "[full | stack | docs | settings]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, AskUserQuestion
---

# Adopt — attach the studio to an existing project

Language, `<hooks>`, agent and command namespaces, gate mechanics (rule 7), the documents-lane commit gate and the hand-off form: `docs/coordination-rules.md` § Skill conventions. This skill does not list `Skill`: every command it names is a hand-off (§ Another skill).

Answers not "what exists?" but "will what exists work with the studio's skills?".

Glossary:
- `FRAMEWORK_NAMESPACES` — the regex alternative `docs/stack-reference/<framework>.md` names for the detected `php_framework` (the value `docs/templates/php/deptrac.yaml` takes).

**Mode → phases** (argument; no argument = `full`). "Before Phase 1" runs in every mode.

| Mode | Phase 1 stack | Phase 2 artefacts | Phase 3 settings | Phase 4 plan | Phase 5 commit |
|---|---|---|---|---|---|
| `full` | yes | yes | yes | yes | yes |
| `stack` | yes | — | — | yes (stack findings only; the artefact audit is marked "not run — `/adopt docs`") | yes |
| `docs` | — | yes | — | yes (artefact findings only; the facts table reads from the current `technical-preferences.md`) | yes |
| `settings` | — | — | yes | — (only the settings diff; no plan file) | yes (for `CLAUDE.md`/roster only) |

A phase a mode skips is named as skipped in the result, never silently absent. In `docs` mode a placeholder `technical-preferences.md` yields the facts table "not run — `/adopt stack`" and makes `/adopt stack` the plan's first item.

## Before Phase 1
1. `.claude/docs/` missing → one `AskUserQuestion`: run `/web-studio:init` (copy mode `/init`) first (Recommended) · stop. Either answer ends this run.
2. Not a git repository (`git rev-parse --show-toplevel` fails) → one `AskUserQuestion`: initialize git now (Recommended) · stop.
   - "stop" → `BLOCKED (not a git repository — adoption relies on history and branches)`; never re-asked in the same run.
   - "initialize" → plain `git init`, which honours the user's `init.defaultBranch`. Never pass `-b`/`--initial-branch`.

## Phase 1: Stack detection (`stack` / `full`)
Say "Scanning the project…", then:
1. **Read the manifests and configs**: `go.mod` (Go version, router, pgx/sqlc, gqlgen), `composer.json` (PHP, `yiisoft/*`, Symfony/Laravel, graphql-php), `package.json` (Angular/Vue/Nuxt/Vite versions, TS, three, pixi, GraphQL clients), `angular.json`, `nuxt.config.*`, `vite.config.*`, `gqlgen.yml`, `*.graphql`, `*.graphqls`, `openapi*.yaml`, `compose*.yaml`, `Dockerfile*`, `.github/workflows/*`, `Chart.yaml`, `kustomization.yaml`, `deploy/k8s/**`, `charts/**` (deploy target `kubernetes`), the OpenTelemetry/Prometheus/logging packages in the manifests (`references/fill-technical-preferences.md` → Observability), `renovate.json` / `.github/dependabot.yml`, existing deploy/advisor skills in `.claude/skills`.
2. **Versions**: compare with `.claude/docs/stack-reference/index.md`. Outdated majors → a table "now → current → upgrade path (reference section)".
3. **Go projects**: read `references/detect-go.md`; record `go_layout`, `go_architecture` (tree and dependency graph, never folder names alone), `go_router`, `graphql_models` and the findings it names. Restructuring is a plan item (`/refactor layout`), never done here.
4. **PHP projects**: read `references/detect-php.md`; record the PHP version, `php_framework`, `php_architecture` (tree and dependency direction), `php_static_analysis`, `php_cs_tool`, deptrac presence and the findings it names. Moving to `layered` or another framework is a plan item (`/refactor layout` / `/refactor framework --dry-run`), never done here.
5. **Contract**: `api_contract_path` from the `schema:` entry of `gqlgen.yml`, or the OpenAPI file's real location; never from the studio default.
6. **Fill `technical-preferences.md` in this run**: read `references/fill-technical-preferences.md` (field list, deploy target/delegate detection by `deploy-target-contract.md`, shared-host questions) and draft every field the files answer from the facts. `[TO BE CONFIGURED]` may remain only for fields no file answers.
7. **Unknown fields**: ask them (project type, API style, layout — whatever is still unknown) in one `AskUserQuestion` before the write gate, never in the same message.
8. **Write gate**, in rule 7's exact order (§ Skill conventions → Gates): show the draft as a table field · value · source fact — `technical-preferences.md` is still the untouched init placeholder at this point — then "May I write `.claude/docs/technical-preferences.md`?" as one `AskUserQuestion`: write (Recommended) · adjust first · not now. `Write`/`Edit` only after the "write" answer, never before. After the "write" answer: `touch .claude/.write-consent`.
9. **Do not defer to `/setup-stack`**: after `/adopt` the stack counts as chosen — the template says "while [TO BE CONFIGURED] remains, skills treat the stack as not chosen".

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
2. **Format gaps.** A HIGH that is a **format** gap (a roadmap in a foreign format, story cards without a criteria table, ADRs without options) gets the plan item `/migrate <type> --dry-run`, never "rewrite by hand"; the artefact itself is left untouched.
3. **Every BLOCKING and HIGH gets a sink**, not only a row in the plan: one `AskUserQuestion` per item — record it in `production/findings.md` (template `findings.md`; id `ADOPT-NNN`, severity, area, the decision needed) (Recommended) · story stubs now via `/create-stories` · plan only. The row is written only after the "record" answer.
4. **"Story stubs" is a hand-off, not a call**: the item becomes the plan's first open item with `/create-stories` as its command, offered first by the closing question. `/help`, `/create-stories` and `/sprint-plan` read `production/findings.md`; only `/help` reads the adoption plan (first open item).
5. A BLOCKING or HIGH item that is neither recorded nor turned into a story is named as unrecorded in the verdict line.

## Phase 3: Settings (`settings` / `full`)
1. `.claude/settings.web-studio.json` present → show a diff with `settings.json` for `hooks`, `permissions`, `statusLine` and propose a merge: never drop foreign hooks; merge arrays.
2. `CLAUDE.md` without the studio block → propose inserting the Language/Studio/Stack/Principles sections from the kit's `templates/CLAUDE.md.template` (generated from `technical-preferences.md` when the template is unavailable); insert, never overwrite the existing file.
3. `.gitignore` must list `production/session-state/`, `production/session-logs/`, `.claude/settings.local.json` and `.claude/agent-memory-local/` (the same four lines `/init` and `install.sh` add); propose the missing lines.
4. Companion skills detected (advisor, deploy) → propose noting them in the Tier 0 row of `.claude/docs/agent-roster.md`.
5. Show the proposals, then one `AskUserQuestion`: "May I write the changes above?" — write (Recommended) · show the draft/diff first · not now. After the "write" answer: `touch .claude/.write-consent`.

## Phase 4: Adoption plan
1. **Draft** `docs/adoption-plan-<date>.md` from `.claude/docs/templates/adoption-plan.md`: verdict, the facts table, the artefact audit and a numbered plan where every item is a checkbox `- [ ] N. <priority> — <command> → <artefact>`. `/help` offers the first open item; items are ticked `[x]` when done.
2. **Stage**: `/init` writes `production/stage.txt` in its own write gate, so after a completed `/init` it exists; propose it from the facts (`build` / `operate`) only when it is missing, and only with the plan's consent, never automatically.
3. **Write gate**: show the plan in the chat, then "May I write `docs/adoption-plan-<date>.md` (and `production/stage.txt`)?" as one `AskUserQuestion`: write (Recommended) · show the draft/diff first · not now. After the "write" answer: `touch .claude/.write-consent`.

## Phase 5: Commit (documents lane)
Right after the last write of the run, one commit gate (§ Skill conventions → Documents-lane commit gate; `.claude/docs/git-workflow.md` § Documents): `docs: adopt web studio (<mode>)`, staging exactly the documents this run wrote — `.claude/docs/technical-preferences.md`, `production/findings.md`, `CLAUDE.md`, `.claude/docs/agent-roster.md`, `docs/adoption-plan-<date>.md`, `production/stage.txt` — whichever of them the earlier gates covered.
- `.claude/settings.json` and `.gitignore` (Phase 3) are toolchain work, not documents: they never ride the `docs:` commit; name them in the result and offer the chore lane (git-workflow.md § Chore / infra).
- Before asking, `<hooks>session-state.sh set Gate "/adopt Phase 5: commit?"`; after the answer, `<hooks>session-state.sh set Gate "—"`.

Nothing is committed without the answer; a run that wrote no document has no commit gate.

Verdict: `COMPLIANT` | `NEEDS MIGRATION (N blocking)`, followed by the unrecorded BLOCKING/HIGH items when there are any.

Next step — one `AskUserQuestion`. The plan so far reflects only the artefact gaps; nobody has asked the owner
what they actually want, and an owner who installs the studio on a working project always has an intent
(tidy it up, a new feature, security, an upgrade). Options:
- the plan's first open item (Recommended);
- "describe your goal for this project in your own words" (free text): reorder the plan around the answer, goal items first, and only then recommend a command;
- `/help`;
- stop here.
