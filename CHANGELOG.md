# Changelog

## Unreleased
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
