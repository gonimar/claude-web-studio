---
name: stack-update
description: "Refreshes the stack knowledge base — checks the latest versions of every technology in stack-reference (official llms.txt, release pages, endoflife.date, npm/packagist/pkg.go.dev), rewrites the reference files with dated facts and sources, compares with the project's lockfiles, and proposes an upgrade plan. Run when references are older than 60 days or before planning upgrades."
argument-hint: "[all | <tech: go|php|yii3|typescript|angular|vue|graphql|threejs|database|testing|security|web-platform|tooling>] [--check-only]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, WebFetch, WebSearch, AskUserQuestion, Task
model: sonnet
---

# Stack Update

Web technology moves fast; the reference is a dated snapshot. This skill refreshes it on request:
facts only from official sources, with a date and a link.

## Phase 1: Scope and current state
Argument: `all` (default) or one technology. Read `stack-reference/index.md` and the target files;
list current versions and `updated:`. Read the project lockfiles (`go.mod`, `composer.lock`,
`pnpm-lock.yaml`/`package-lock.json`) — actual project versions.

## Phase 2: Collect current data (in parallel, independent sources)
| Technology | Source |
|---|---|
| Angular / Material / Taiga | `https://angular.dev/llms.txt`, `https://angular.dev/roadmap`, npm `@angular/core`, `@angular/material`, `taiga-ui.dev/llms.txt` |
| Vue / Nuxt / Vite / Vitest | `vuejs.org/llms.txt`, `nuxt.com/llms.txt`, `vite.dev/llms.txt`, `vitest.dev/llms.txt`, GitHub releases |
| Go | `go.dev/doc/devel/release`, `go.dev/doc/go1.NN` |
| PHP / Yii3 | `php.watch/versions`, `yiiframework.com/news`, packagist `yiisoft/*` |
| TypeScript / Node | `devblogs.microsoft.com/typescript`, `nodejs.org/en/about/previous-releases`, `endoflife.date/nodejs` |
| GraphQL | `spec.graphql.org`, GraphQL.js releases, gqlgen/Yoga/graphql-php releases |
| three.js / Pixi / Babylon | GitHub releases + Migration Guide wiki, `pixijs.com/llms.txt`, `doc.babylonjs.com/llms.txt` |
| PostgreSQL / Redis | `postgresql.org/docs`, `endoflife.date/postgresql`, `redis.io` |
| Security | `owasp.org/Top10`, ASVS releases, Mozilla guidelines |
| Web platform | `web-features` Baseline, `web.dev` CWV, W3C WCAG |
For each: latest stable version and date, next expected, EOL, key changes (breaking!), new best practices.
`WebSearch` only to clarify, never as the primary source.

## Phase 3: Diff and proposal
Table "technology → in the reference → now (date, source) → in the project → action (update reference / propose upgrade / none)".
For upgrades: path (e.g. `ng update`, three.js Migration Guide rNNN→rMMM, Go toolchain), risks, order.
`--check-only` — stop here.

## Phase 4: Write
Show the reference changes (updated lines, `updated:` and `sources:` in the header, new practices in the right section).
"May I write [files]?" After "yes" also update `index.md` (table and date). Outdated statements are removed, not left beside new ones.

## Phase 5: Project upgrade plan (optional)
If upgrades exist — propose stories (`/create-stories`) or ADRs for majors; for each — how to verify (tests, build). Do not perform upgrades in this skill.

Verdict: `UPDATED (N files)` | `UP TO DATE` | `CHECK ONLY`. Next step: `/help`.
