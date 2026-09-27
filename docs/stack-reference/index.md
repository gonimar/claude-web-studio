---
updated: 2026-09-26
refresh: /stack-update
---
# Stack Reference — index

A dated snapshot of current versions and practices. **The `Verified` column** carries each file's own `updated:`
date — when that technology was last checked against its sources; a row older than 60 days → run `/stack-update <tech>`,
which refreshes the file and its row. The header `updated:` of this index is the date of the last edit to the table itself,
not a claim about every row. Agents read the relevant file before working. "Latest on the date" is filled by `/stack-update` from the registries (`npm view … dist-tags`, packagist, `go list -m -versions`); a recommended version a major behind latest carries a reason in its file.

| Technology | Recommended on the date | Latest on the date (registry) | File | Verified | Official llms.txt |
|---|---|---|---|---|---|
| **GraphQL** (priority API style) | Spec September 2025; GraphQL.js 17; gqlgen / Yoga 5 / graphql-php | — | [graphql.md](graphql.md) | 2026-09-17 | none — spec.graphql.org, the-guild.dev |
| Go | 1.27 (2026-08-19) | — | [go.md](go.md) | 2026-09-17 | none — go.dev/doc/go1.27, pkg.go.dev |
| PHP | 8.5 (2025-11-20); 8.6 due 2026-11; PHPUnit 13, PHPStan 2.2 / Psalm 6, deptrac 4, ECS 13 / php-cs-fixer 3, PER-CS 3.1 | 8.5.9 (2026-07-30, php.net); phpunit 13.3.4, pest 5.2.0, phpstan 2.2.14, psalm 6.17.2, deptrac 4.7.2, ecs 13.3.2, php-cs-fixer 3.95 (2026-09-17, packagist) | [php.md](php.md) | 2026-09-17 | none — php.watch, php.net, php-fig.org |
| Yii3 | stable (2025-12-31), packages on SemVer | `yiisoft/queue`/`queue-redis` still `dev-master`, unabandoned (2026-09-10, packagist) | [yii3.md](yii3.md) | 2026-09-17 | none — yiiframework.com, github.com/yiisoft |
| Symfony | 8.1 (2026-09); 7.4 LTS until 2028-11 — stub, no idioms yet | symfony/framework-bundle 8.1.7 (2026-09-14, packagist) | [symfony.md](symfony.md) | 2026-09-17 | none — symfony.com/releases |
| Laravel | 13 (2026-02) — stub, no idioms yet | laravel/framework 13.32.0 (2026-09-15, packagist) | [laravel.md](laravel.md) | 2026-09-17 | none — laravel.com/docs/releases |
| TypeScript | 7.0 (2026-07-08, native Go compiler) | — | [typescript.md](typescript.md) | 2026-09-05 | none — typescriptlang.org |
| Node.js | 24 LTS; 26 → LTS 2026-10; one major per year from 27 | — | [tooling-devops.md](tooling-devops.md) | 2026-09-10 | none — nodejs.org |
| Angular | 22 (2026-06-03) | — | [angular.md](angular.md) | 2026-09-05 | https://angular.dev/llms.txt, /llms-full.txt |
| Angular Material / CDK | 22.1.x | — | [angular.md](angular.md) | 2026-09-05 | none — material.angular.dev |
| Taiga UI | 5.21 (Angular ≥ 19) | — | [angular.md](angular.md) | 2026-09-05 | https://taiga-ui.dev/llms.txt, /llms-full.txt |
| Vue | 3.5.42; 3.6 RC (Vapor) | — | [vue.md](vue.md) | 2026-09-05 | https://vuejs.org/llms.txt |
| Nuxt | 4.5 (2026-07-18); Nuxt 3 EOL 2026-07-31 | — | [vue.md](vue.md) | 2026-09-05 | https://nuxt.com/llms.txt |
| Vite | 8 (Rolldown by default) | — | [typescript.md](typescript.md) | 2026-09-05 | https://vite.dev/llms.txt |
| Vitest | 4 | — | [testing.md](testing.md) | 2026-09-17 | https://vitest.dev/llms.txt |
| Playwright | 1.5x | — | [testing.md](testing.md) | 2026-09-17 | none — playwright.dev |
| three.js | r185 (2026-07-01), ~monthly releases | — | [threejs-webgames.md](threejs-webgames.md) | 2026-09-05 | https://threejs.org/llms.txt (index) |
| PixiJS / Babylon.js | 8.x / 8.x | — | [threejs-webgames.md](threejs-webgames.md) | 2026-09-05 | https://pixijs.com/llms.txt, https://doc.babylonjs.com/llms.txt |
| PostgreSQL / Redis | 18 / 8 | PG 18.6, **19 Beta 3** (2026-08-13, GA ~Sep/Oct 2026); Redis **8.10** (2026-07-29), Valkey **9.1** (2026-09-01) | [database.md](database.md) | 2026-09-10 | none — postgresql.org/docs |
| Hono / NestJS | 4.x / 11.x | — | [typescript.md](typescript.md) | 2026-09-05 | https://hono.dev/llms.txt, https://docs.nestjs.com/llms.txt |
| Kubernetes / Helm | 1.37 (2026-08-26); 1.34–1.37 supported, 1.34 EOL 2026-10-27; **Helm 4.3** (Helm 3: final feature release 3.22, security fixes end 2027-02-10); Gateway API 1.6 (`HTTPRoute`), External Secrets 2.11 / Sealed Secrets 0.40 | v1.37.1 / 1.36.5 / 1.35.9 / 1.34.12 (2026-09-23, dl.k8s.io + tags); helm v4.3.0, v3.22.0 (2026-09-09, tags) | [kubernetes.md](kubernetes.md) | 2026-09-26 | not checked — kubernetes.io, helm.sh unreachable on the date; facts from kubernetes/website, helm/helm-www |
| Observability (OpenTelemetry / Prometheus) | OTel Go SDK 1.46 (logs RC 1.47), JS api 1.9 / SDK 2.11 (experimental 0.222), PHP SDK 1.15; semconv 1.44; Collector 0.161; Prometheus 3.15 (LTS 3.13); client_golang 1.24, `@prometheus-io/client` 0.16, promphp 2.15; slog / monolog 3.12 / pino 10 | otel v1.46.0 (2026-08-25, proxy.golang.org); `@opentelemetry/sdk-node` 0.222.0 (2026-08-31, npm); `open-telemetry/sdk` 1.15.0 (2026-07-14, packagist); prometheus v3.15.0 (2026-09-25, tag) | [observability.md](observability.md) | 2026-09-26 | not checked — opentelemetry.io, prometheus.io unreachable on the date; facts from the source repositories |
| OWASP Top 10 | 2025 (final 2026-01) | confirmed current, categories unchanged (2026-09-10, owasp.org/Top10/2025) | [security-standards.md](security-standards.md) | 2026-09-10 | none — owasp.org/Top10/2025 |
| WCAG | 2.2 AA | no newer AA revision (2026-09-10) | [web-platform.md](web-platform.md) | 2026-09-10 | none — w3.org/TR/WCAG22 |
| Supply chain (cosign / syft / grype / trivy / SLSA / Renovate) | cosign 3.1, syft 1.52, grype 0.119, trivy 0.74, SLSA v1.1, `actions/attest` v4 | cosign v3.1.3 (2026-08-06), syft v1.52.0 (2026-09-17), grype v0.119.0 (2026-09-17), trivy v0.74.0 (2026-08-14) (GitHub releases) | [supply-chain.md](supply-chain.md) | 2026-09-26 | none — github.com/sigstore, slsa.dev, docs.renovatebot.com |
| Claude Code | docs | — | — | — | https://code.claude.com/docs/llms.txt |

Rule: **project versions are pinned exactly** (lockfile in git); upgrades go through
`/stack-update`, which compares the lockfile with current releases and proposes a plan.
