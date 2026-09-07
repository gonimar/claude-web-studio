# Changelog

## Unreleased
- Brownfield onboarding: `/init` detects existing code, proposes the stage from the facts (`build` / `operate`) instead of writing `discovery` over a running project, and hands off with an `AskUserQuestion` (`/adopt full` Recommended for brownfield); its statusline smoke check feeds a `cwd` JSON.
- `/adopt` fills `technical-preferences.md` from the detected facts in the same run (only unanswerable fields stay `[TO BE CONFIGURED]` and are asked in one question — never deferred to `/setup-stack`), classifies a companion advisor's roadmap as INFO, writes the plan from the new `templates/adoption-plan.md` with checkbox items and hands off to the first open item.
- `/help` reads the newest `docs/adoption-plan-*.md` (open items, first one is NEXT when the phase has no unmet required step) and sends an initialised-but-not-adopted project to `/adopt full`.
- Specs: init case 6, adopt cases 1/6, help cases 6–7.
- Findings reach planning: `/security-audit`, `/perf-audit`, `/a11y-audit` offer to record BLOCKING / over-budget / critical findings in `production/findings.md` (new template `findings.md`); `/create-stories` turns open BLOCKING findings into acceptance criteria or stories and links them; `/sprint-plan` keeps them in the sprint or defers them with a reason; `/sprint-status` and `/help` show the open count.
- Deploy artefacts story: with a Deploy target set, `/create-stories` adds a "Deploy artefacts" story to the first feature (Dockerfile, production compose, release workflow, `/healthz`, `docs/ops/deploy.md` from the new `templates/deploy-runbook.md`); catalog step `deploy-artefacts`; `/help` flags the missing runbook.
- `/test-setup` creates the compose profile/services its generated CI references (or stops with `BLOCKED` naming the story) and self-checks with `docker compose --profile test config`.
- Prototype gate for games: `/game-concept gate` records `GO | NO-GO | PIVOT` with evidence in `production/releases/gate-prototype.md` and under §11 (the template asks for a measurable fun criterion); catalog step `prototype-gate` (games only); `/help` makes it NEXT when the first feature is done and the gate is missing.
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
