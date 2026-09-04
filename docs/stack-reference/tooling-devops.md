---
updated: 2026-09-05
sources: [https://nodejs.org/en/about/previous-releases, https://docs.docker.com/compose/, https://docs.github.com/actions, https://www.conventionalcommits.org, https://semver.org, https://docs.renovatebot.com, https://opentelemetry.io/docs/]
---
# Tooling, CI/CD, operations

## Runtimes and versions
- Node.js **24 LTS** (until 2028-04); 22 LTS until 2027-04; **26** enters LTS 2026-10; from Node 27 (2026-10) one major per year, all LTS. `.nvmrc`/`engines` in package.json; `corepack` for pnpm.
- Docker Engine 28+, **Compose v2** (`compose.yaml`, `docker compose`), BuildKit, `--platform`; images `-alpine`/`distroless`, digest-pinned in production.
- nginx 1.28 stable / Caddy 2.10 (automatic TLS, HTTP/3) — Caddy is preferred for small servers and projects, nginx for complex rules or an existing stack.

## Git and releases
- Trunk-based: `main` protected; branches `feat/…`, `fix/…`, `chore/…`; a PR per feature; squash or linear history.
- **Conventional Commits 1.0**: `feat:`, `fix:`, `perf:`, `refactor:`, `docs:`, `test:`, `build:`, `ci:`, `chore:`; `!` for breaking; scope per subsystem. They drive `CHANGELOG.md` (`/changelog`) and SemVer 2.0 versions; tags `vX.Y.Z`.
- Repo hooks: `lefthook`/`husky` with lint-staged optional; in the studio linting runs through Claude Code hooks and CI.

## CI (GitHub Actions — reference pipeline)
```
lint → typecheck → unit → build → integration (services: postgres, redis) → e2e (Playwright on the artefact) → security (audit, govulncheck, gitleaks, trivy) → docker build/push (main) → deploy (by tag / manual)
```
- `actions/checkout@v5`, `actions/setup-node@v5` (pnpm cache), `actions/setup-go@v6`, `shivammathur/setup-php@v2`; dependency caches; `concurrency` to cancel stale runs; minimal `permissions:`; secrets only via `secrets.*`, OIDC for clouds.
- Matrices only where needed (PHP/Node versions); `timeout-minutes` on jobs.
- Renovate/Dependabot: group minors, `minimumReleaseAge` 3–7 days, auto-merge patches after green CI.

## Deployment
- Small servers: compose stacks from the repository (optionally through a container-platform deploy skill), an env file outside git, a migrate service before the app, health-check dependencies (`depends_on: condition: service_healthy`).
- Strategy: a built image tagged `sha`/`vX.Y.Z`; rollback = redeploy the previous tag; backward-compatible migrations (expand/contract).
- Zero-downtime when needed: two replicas behind the proxy or Caddy graceful reload.

## Observability
- Logs: JSON to stdout, collected by Loki/Vector (or a simple log viewer on small servers); `request_id` end to end.
- Metrics: `/metrics` for Prometheus (Go `prometheus/client_golang`, PHP via `promphp`), Grafana dashboards; RED metrics (rate, errors, duration) per service.
- Tracing: OpenTelemetry SDK with more than two services; export to Tempo/Jaeger.
- Health: `/healthz` (liveness) and `/readyz` (dependencies), no secrets in the response.
- Alerts: error rate, p95 latency, disk, certificate expiry, queue lag.

## Local environment
`compose.yaml` with profiles (`dev`, `test`), `.env.example`, `Makefile`/`justfile` with `up/test/lint/migrate`; devcontainer optional; on WSL2 keep projects on the Linux filesystem, not `/mnt/c`.
