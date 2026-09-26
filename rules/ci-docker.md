---
paths: [".github/**", "**/Dockerfile*", "**/compose*.y*ml", "**/docker-compose*.y*ml", "**/docker/**"]
---
# CI and container rules
- Dockerfile: multi-stage, non-root `USER`, base image pinned by tag (+digest in production), `.dockerignore`, `HEALTHCHECK`.
- compose: `depends_on` with `condition: service_healthy`; DB/Redis ports not published; secrets via an env file outside git; a migrate service before the app.
- Actions: minimal `permissions:` (explicit `contents: read` at the top), `concurrency`, `timeout-minutes`, `uses:` pinned by full commit SHA with a `# vX.Y.Z` comment (the update bot bumps them); secrets only via `secrets.*`.
- Release image: SBOM from the pushed digest, `cosign sign --yes <image>@<digest>` keyless, provenance via `actions/attest`; CI installs are frozen (`npm ci` / `pnpm install --frozen-lockfile` / `composer install`, never `-mod=mod`). Reference: `.claude/docs/stack-reference/supply-chain.md`.
- Pipeline: lint → typecheck → unit → build → integration → e2e → security (audit/govulncheck/gitleaks/trivy) → image.
- Any deployment change updates the runbook in `docs/ops/`; rollback is described.
- Reference: `.claude/docs/stack-reference/tooling-devops.md`.
