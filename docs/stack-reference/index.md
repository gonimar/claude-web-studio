---
updated: 2026-09-05
refresh: /stack-update
---
# Stack Reference — index

A dated snapshot of current versions and practices. **The `updated:` date in each file** says when
it was last verified; older than 60 days → run `/stack-update`. Agents read the relevant file before working.

| Technology | Version on the date | File | Official llms.txt |
|---|---|---|---|
| **GraphQL** (priority API style) | Spec September 2025; GraphQL.js 17; gqlgen / Yoga 5 / graphql-php | [graphql.md](graphql.md) | none — spec.graphql.org, the-guild.dev |
| Go | 1.27 (2026-08-19) | [go.md](go.md) | none — go.dev/doc/go1.27, pkg.go.dev |
| PHP | 8.5 (2025-11-20); 8.6 due 2026-11 | [php-yii3.md](php-yii3.md) | none — php.watch, php.net |
| Yii3 | stable (2025-12-31), packages on SemVer | [php-yii3.md](php-yii3.md) | none — yiiframework.com, github.com/yiisoft |
| TypeScript | 7.0 (2026-07-08, native Go compiler) | [typescript.md](typescript.md) | none — typescriptlang.org |
| Node.js | 24 LTS; 26 → LTS 2026-10; one major per year from 27 | [tooling-devops.md](tooling-devops.md) | none — nodejs.org |
| Angular | 22 (2026-06-03) | [angular.md](angular.md) | https://angular.dev/llms.txt, /llms-full.txt |
| Angular Material / CDK | 22.1.x | [angular.md](angular.md) | none — material.angular.dev |
| Taiga UI | 5.21 (Angular ≥ 19) | [angular.md](angular.md) | https://taiga-ui.dev/llms.txt, /llms-full.txt |
| Vue | 3.5.42; 3.6 RC (Vapor) | [vue.md](vue.md) | https://vuejs.org/llms.txt |
| Nuxt | 4.5 (2026-07-18); Nuxt 3 EOL 2026-07-31 | [vue.md](vue.md) | https://nuxt.com/llms.txt |
| Vite | 8 (Rolldown by default) | [typescript.md](typescript.md) | https://vite.dev/llms.txt |
| Vitest | 4 | [testing.md](testing.md) | https://vitest.dev/llms.txt |
| Playwright | 1.5x | [testing.md](testing.md) | none — playwright.dev |
| three.js | r185 (2026-07-01), ~monthly releases | [threejs-webgames.md](threejs-webgames.md) | https://threejs.org/llms.txt (index) |
| PixiJS / Babylon.js | 8.x / 8.x | [threejs-webgames.md](threejs-webgames.md) | https://pixijs.com/llms.txt, https://doc.babylonjs.com/llms.txt |
| PostgreSQL / Redis | 18 / 8 | [database.md](database.md) | none — postgresql.org/docs |
| Hono / NestJS | 4.x / 11.x | [typescript.md](typescript.md) | https://hono.dev/llms.txt, https://docs.nestjs.com/llms.txt |
| OWASP Top 10 | 2025 (final 2026-01) | [security-standards.md](security-standards.md) | none — owasp.org/Top10/2025 |
| WCAG | 2.2 AA | [web-platform.md](web-platform.md) | none — w3.org/TR/WCAG22 |
| Claude Code | docs | — | https://code.claude.com/docs/llms.txt |

Rule: **project versions are pinned exactly** (lockfile in git); upgrades go through
`/stack-update`, which compares the lockfile with current releases and proposes a plan.
