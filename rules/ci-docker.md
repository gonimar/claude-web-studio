---
paths: [".github/**", "**/Dockerfile*", "**/compose*.y*ml", "**/docker-compose*.y*ml", "**/docker/**"]
---
# CI and container rules
- Dockerfile: multi-stage, non-root `USER`, base image pinned by tag (+digest in production), `.dockerignore`, `HEALTHCHECK`.
- compose: `depends_on` with `condition: service_healthy`; DB/Redis ports not published; secrets via an env file outside git; a migrate service before the app.
- Actions: minimal `permissions:`, `concurrency`, `timeout-minutes`, actions pinned by major; secrets only via `secrets.*`.
- Pipeline: lint → typecheck → unit → build → integration → e2e → security (audit/govulncheck/gitleaks/trivy) → image.
- Any deployment change updates the runbook in `docs/ops/`; rollback is described.
- Reference: `.claude/docs/stack-reference/tooling-devops.md`.
