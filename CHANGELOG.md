# Changelog

## Unreleased
- Change proposals from the conversation get an owner: `/impact <proposal>` classifies a change (architecture · security · product · routine) from the ADRs, threat-model surfaces, contracts and path globs it touches — evidence, not wording — spawns only the triggered classes' owners in parallel (`technical-director`, `security-lead`, `product-director`), requires a ≤ 15-line verdict that names the commands to run next, and hands off to the first of them; `--classify-only` stops at the table. Coordination-rules rule 11, review-workflow § Change classes (with the review-mode scoping), CLAUDE.md principle 2, a responsibility line in the three verifying agents, `/dev-story` detours to `/impact` when a request leaves the story's criteria and touches `.claude/.impact-verdict` at story start; new warn-only hook `impact-guard` (Write/Edit on security-sensitive globs, migrations, workflows, Dockerfile/compose, manifests, contracts without a fresh marker), registered in both modes, hook tests, spec with 7 cases.
- Copy mode gets the hooks it was missing: `consent-guard` and `validate-deps` were registered in `hooks/hooks.json` only, so `install.sh`/copy-mode projects never ran the consent sentinel or the dependency dry-run; both are in `templates/settings.json` now, and the structure linter fails when the two registrations diverge.

## 0.6.0 — 2026-09-09
- Roadmap format v3.1 (`templates/roadmap.md`): a three-line header that names who manages the file, the source of truth and the last update; every ID is an **inline** link (`[ID](path)`, file-relative to `production/roadmap.md`) — reference-style `## Links` definitions are gone (they stop resolving once other sections fold into `<details>`, and the format's first draft also wrote repo-root-relative paths that never resolved); `⛔` accepts story, ADR and owner-decision IDs; sprints carry ISO dates in the heading (`📅 sprint-NN` is gone); a closed sprint, the Backlog and the Legend fold into `<details>` with an aggregate in `<summary>` once there's history to fold, an active sprint never does; a new `## Docs` section is a maintained-by-the-tools status board over `production/stories/`, `backlog.md`, `decisions.md`, `sprints/`, `docs/architecture/`, `docs/specs/`, `docs/ops/` (each a collapsed table, owner decisions live here now — the old numbered "Owner decisions" section is gone); `[x]` needs evidence (⏱ and/or 🔗). Proven on a real project (argus) before landing here. `create-stories`, `sprint-plan`, `story-done` and `architecture-decision` updated to the format and to keeping the Docs blocks current.

## 0.5.9 — 2026-09-10
- Greenfield `/init` never writes product code inline — it hands off to `/start`; a trivial-looking goal is `/start`'s call, not init's (e2e branch B1b).
- Review mode scopes **reviews only**: no mode (solo included) skips `/start`/`/adopt`, the specs or the catalog's required steps; persona runs confirmed solo now walks the pipeline.
- Agent audit log carries `session_id`/`agent_id`/`tool_use_id` — Start/Stop pair up, per-session agent stats become measurable.
- Persona-driven e2e testing: five character profiles (agreeable, hasty, refusenik, inventor, clueless), a driver, and the result-storage/report convention under `testing/e2e/personas/`.
- Drafts render readably in chat — tables as tables, on updates too (rule 7); dev-story renders its plan table, story-done its criteria table.
- Deploy contract gains **Prerequisites & secrets**: registry access, exact image names and the stack method verified before the first mutation; secrets never through the chat; a refused path stays refused.
- Hand-offs return to the interrupted intent after a detour; a detour never overwrites session-state `Next:`.
- New hooks: `validate-deps` (dry-run resolver after a manifest edit — invented versions surface immediately) and `consent-guard` (warn-only sentinel for pipeline-document writes without a fresh consent marker; rule 7 adds the marker step).

## 0.5.8 — 2026-09-09
- Executable e2e layer (`testing/e2e/` + `tests/e2e.sh`): synthetic brownfield fixture, multi-turn headless driver, tool-event checker, branched pipeline scenario B1–B15 — one branch per closed behavioural defect class; deliberately outside `run-all.sh` (each branch spends real model turns). Smoke: B9 PASS.
- Structured roadmap format (`templates/roadmap.md`): one line per story with inline markers — ⛔ dependencies, ~estimate, ⏱ actual, 📅 sprint, 🏷 layer; sprints as dated subheadings, backlog below; prose ordering paragraphs are banned (the order derives from dependencies). `create-stories`, `sprint-plan` and `story-done` reference it.

## 0.5.7 — 2026-09-09
- A documents lane in the git workflow: every authoring skill ends with a commit gate (`docs:` staging exactly the written files); pipeline-wide documents go to the default branch, and on a story branch the skill names it and asks where the document belongs; `validate-commit` exempts `docs:`-scoped commits touching only document paths. Hook test, test-setup spec case 7.
- `/dev-story` offers `/sprint-plan` when no sprint covers the story (>3 Ready stories) — the sprint layer was reachable only by the owner's memory. Spec case 8.
- Catalog artifacts are produced by their commands, never inline: CLAUDE.md template principle 7 and coordination-rules rule 9 — a session that authors ADRs/specs/stories in the main conversation bypasses the steps' gates, templates and hand-offs.

## 0.5.6 — 2026-09-08
- `/help` flags plugin version drift: when `.claude/.web-studio-version` (what seeded the project) is older than the running plugin, one line names both versions and `/update` joins the closing question's options; silent when they match and in copy mode. Spec case 11.

## 0.5.5 — 2026-09-08
- Development never starts before architecture prerequisites: `/dev-story` blocks (naming the missing command) while `docs/architecture/threat-model.md` or `test-strategy.md` is absent — brownfield projects enter `build` with the architecture phase unwalked and nothing enforced the catalog's required steps; `/create-stories` stops recommending `/dev-story` while a prerequisite is missing; `/help` checks the required steps of every earlier phase. Dev-story spec case 7.
- The write gate's exact order (draft in the chat message → the "May I write?" question → Write only after the answer) lives in coordination-rules rule 7 for every artifact-producing skill — write-then-ask recurred across skills; `/threat-model` references it. Threat-model spec case 7.

## 0.5.4 — 2026-09-08
- `/init` carries the conversation-language line (it was the only skill without one) and binds the chosen language from the moment the answer arrives — a non-English choice no longer leaves the session English-toned; spec case 8.
- `/init` never proposes stage `operate` from a README-claimed live URL alone: `operate` needs deploy artefacts in the repository; a detached copy of a deployed service is still `build`.
- `/adopt` hand-off solicits the owner's goal in their own words and reorders the adoption plan around it; spec case 10.

## 0.5.3 — 2026-09-08
- `/adopt` wrote `technical-preferences.md` before asking, again ("the file is already written as a draft — confirm?") — the 0.5.1 gate sentence was buried at the end of a long paragraph. The gate is now a numbered three-step protocol: draft in the chat message → `AskUserQuestion` → only then Write/Edit, with the write-then-ask anti-pattern named explicitly.

## 0.5.2 — 2026-09-08
- `/init` asked the conversation language with a single "English" option when invoked as a bare command (no user prose to infer from) — the question now always carries at least two named options, inferring the second from project or user docs; spec case 7.
- `/adopt` on a project without git looped its "initialize git now?" question until "yes" and ran `git init -b main`, overriding the user's `init.defaultBranch` — now one question, a decline ends in `BLOCKED`, and a plain `git init` honours the configured default branch; spec case 9.

## 0.5.1 — 2026-09-08
- Every skill carries "Reply in the project conversation language (CLAUDE.md → Language)" — on a Russian-language project `/adopt` answered in English while `/help` (which had the line) answered in Russian; `/skill-test static` check 9 warns when the line is missing.
- `/adopt` shows the filled `technical-preferences.md` draft and writes it only after the `AskUserQuestion` answer (it wrote first and asked afterwards once).
- `/help` keeps to one pipeline step: a red CI, a failed deploy, a billing problem or a tech-debt CRITICAL become one `Attention:` line each with where to fix, never the closing question and never investigated inside help.

## 0.5.0 — 2026-09-08
- Brownfield onboarding: `/init` detects existing code, proposes the stage from the facts (`build` / `operate`) instead of writing `discovery` over a running project, and hands off with an `AskUserQuestion` (`/adopt full` Recommended for brownfield); its statusline smoke check feeds a `cwd` JSON.
- `/adopt` fills `technical-preferences.md` from the detected facts in the same run (only unanswerable fields stay `[TO BE CONFIGURED]` and are asked in one question — never deferred to `/setup-stack`), classifies a companion advisor's roadmap as INFO, writes the plan from the new `templates/adoption-plan.md` with checkbox items and hands off to the first open item.
- `/help` reads the newest `docs/adoption-plan-*.md` (open items, first one is NEXT when the phase has no unmet required step) and sends an initialised-but-not-adopted project to `/adopt full`.
- Specs: init case 6, adopt cases 1/6, help cases 6–7.
- Findings reach planning: `/security-audit`, `/perf-audit`, `/a11y-audit` offer to record BLOCKING / over-budget / critical findings in `production/findings.md` (new template `findings.md`); `/create-stories` turns open BLOCKING findings into acceptance criteria or stories and links them; `/sprint-plan` keeps them in the sprint or defers them with a reason; `/sprint-status` and `/help` show the open count.
- Deploy artefacts story: with a Deploy target set, `/create-stories` adds a "Deploy artefacts" story to the first feature (Dockerfile, production compose, release workflow, `/healthz`, `docs/ops/deploy.md` from the new `templates/deploy-runbook.md`); catalog step `deploy-artefacts`; `/help` flags the missing runbook.
- `/test-setup` creates the compose profile/services its generated CI references (or stops with `BLOCKED` naming the story) and self-checks with `docker compose --profile test config`.
- Prototype gate for games: `/game-concept gate` records `GO | NO-GO | PIVOT` with evidence in `production/releases/gate-prototype.md` and under §11 (the template asks for a measurable fun criterion); catalog step `prototype-gate` (games only); `/help` makes it NEXT when the first feature is done and the gate is missing.
- Deploy target contract (`docs/deploy-target-contract.md`): `technical-preferences.md` declares `Deploy target` / `Deploy delegate` (agent `<target>-ops` with `deploy-target:` or `scripts/deploy/<target>.sh`), verbs `status · create · deploy · rollback · logs` with verdict words and `--confirmed`; `/deploy` calls the delegate via `Task`/`Bash` (a kit's slash command alone is not a delegate), `BLOCKED` when a declared delegate is missing, manual runbook when none; `/setup-stack` asks for the target, `/adopt` detects it; reference delegate `docs/templates/deploy/compose-ssh.sh`; `team-release`, `hotfix`, `incident`, roster and devops-lead reference the contract.
- `Infra repo` / `Proxy config` fields: `/harden` edits the proxy config in the infra repository (with consent) or hands the snippet to its owner, verifying live headers either way; `/threat-model` reads the fields; `/setup-stack`/`/adopt` ask for them on shared hosts.
- `/stack-update` queries the registries (`npm view … dist-tags`, packagist, `go list -m -versions`) and records "latest on the date" next to the recommendation with a reason when behind a major; `stack-reference/index.md` gets the column; `/architecture-decision` states why an older major is chosen.
- Degraded-input behaviour spelled out where `/skill-test spec` found gaps: `/adopt` stops outside a git repository; `/security-audit` defines `quick`, continues without a threat model (and proposes it) and lists missing tools as "not run"; `/help` maps "just finished X" through the catalog; `/deploy` offers rollback after a failed smoke check.
- Write gates are `AskUserQuestion` choices too (write (Recommended) · show the draft/diff first · not now) in every skill with a "May I write?" gate — rubric A3 / static check 4; five more hand-offs converted (`product-spec`, `start`, `story-done`, `pentest`, `brainstorm`); `brainstorm` anchors its brief to the stack reference and the spec templates.
- Every skill hands off with one `AskUserQuestion` (recommended action first, then real alternatives) — the 28 skills that still ended with a text "Next step: …" line (audits, authoring, team, ops, sprint, setup) now follow the dialogue protocol of 0.4.2; `/skill-test static` check 5 reports them as compliant.

## 0.4.3 — 2026-09-06
- Hooks `log-agent`, `pre-compact`, `session-stop`, `session-start` work from the project root (`$CLAUDE_PROJECT_DIR`, git top-level fallback) instead of the session cwd — no more `backend/production/session-logs/` after `cd backend && …`; hook tests for the subdirectory case (#8).

## 0.4.2 — 2026-09-06
- Dialogue protocol: consent gates and hand-offs are `AskUserQuestion` choices (recommended action first, then real alternatives), not text yes/no prompts — coordination-rules rule 7, CLAUDE.md template principle 2, `/dev-story`, `/code-review`, `/story-done`, `/help` (tool added to `code-review` and `help`), spec case 5 of the four (#4).
- Rubric (O2, A3, R1, P5, T4, D1) and `/skill-test` static checks 4–5 name the `AskUserQuestion` form; the tool and choice-form gates/hand-offs for `architecture-review`, `changelog`, `skill-improve`, `skill-test`, `sprint-status`, `tech-debt` and their spec case 5 (closes #4).

## 0.4.1 — 2026-09-06
- `/story-done`: the merge gets its own question in Phase 5 — the Phase 4 "close" answer never merges; declining leaves the PR open and keeps `Branch:` in the session state, re-running `/story-done S-NNN` merges later. `docs/git-workflow.md`, the story template and spec case 6 updated (#2).

## 0.4.0 — 2026-09-06
- Git workflow for stories (`docs/git-workflow.md`, seeded into `.claude/docs/`): one story = one branch = one PR. `/dev-story` starts from a fresh default branch (never on a merged branch) and commits `feat(S-NNN): …`; `/code-review` commits its fixes as `fix(S-NNN): apply /code-review findings`; `/story-done` commits the close, opens the PR if missing, merges it on DONE, syncs the default branch and clears the session state. CLAUDE.md template principle 5, story and session-state templates and review-workflow updated.
- Hooks: `validate-commit.sh` warns when committing on the default branch or on a branch already merged into origin's default branch; `session-start.sh` fetches origin and prints ahead/behind, merged-branch and unpushed-branch warnings plus a CLAUDE.md placeholder reminder; `validate-push.sh` inspects only real `git push` command segments (heredoc text and `rm -f` in the same command no longer trigger the force-push block).
- Testing framework: rubric metrics P6 (git workflow) and R6 (fix commit); case 6 in the dev-story, story-done and code-review specs; hook smoke tests for the new warnings and the heredoc false positive.

## 0.3.0 — 2026-09-05
- Go project layout: golang-standards/project-layout adopted as an adapted convention — "Project layout" section in `docs/stack-reference/go.md` (directory table, size rule, never-list, monorepo mapping), `go_layout` field in technical-preferences, `/setup-stack` proposes it for Go backends, `/adopt` reports deviations, `go-engineer` / `backend-lead` / `rules/go-code.md` follow it.

## 0.2.0 — 2026-09-05
- Restructured as a Claude Code plugin (`.claude-plugin/plugin.json` + marketplace); copy-mode `install.sh` kept as an alternative.
- All content in English; `/init` asks for the conversation language and writes it to the project's CLAUDE.md.
- New skills: `/init` (project scaffolding), `/update` (plugin or copy-mode update).
- README in English, Russian, Spanish, German and Chinese with usage, session-return guidance, one-line command reference and three walkthroughs.
- CONTRIBUTING guide (local development, adding agents/skills/technologies, PRs, releases), NOTICE with attributions, tests/ suite and GitHub Actions CI.
- No project-specific or personal references; generic "companion skills" (external advisor, deployment) hooks instead.

## 0.1.0 — 2026-09-05
- Initial kit: 30 agents in three tiers, 43 pipeline skills, hooks, path-scoped rules, document templates, dated stack reference (Go, PHP/Yii3, TypeScript, Angular, Vue, GraphQL, three.js, PostgreSQL, testing, security, web platform, tooling), agent testing framework.
