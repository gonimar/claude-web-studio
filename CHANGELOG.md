# Changelog

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
