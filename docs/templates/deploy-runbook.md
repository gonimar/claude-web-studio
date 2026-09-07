# Deploy runbook — [project]

<!-- docs/ops/deploy.md. Created by the "Deploy artefacts" story (/create-stories) and kept current by
     /deploy and /release-checklist. Every box below must be ticked before the first release. -->

## Target
- **Deploy target**: [compose on a server | container platform (id) | cloud] — from `technical-preferences.md`
- **Environments**: [dev | staging | prod] · **Domain(s)**: … · **TLS**: [proxy / ACME]
- **Infra repository / proxy config** (if outside this repo): …

## Artefacts
- [ ] `Dockerfile` per deployable (multi-stage, non-root, healthcheck)
- [ ] `compose.prod.yaml` (images by tag/digest, healthchecks, restart policy, env from secrets, migrate service)
- [ ] release workflow (`.github/workflows/release.yml`: build → test → image push on tag)
- [ ] `/healthz` (and `/readyz` where relevant) answered by every service
- [ ] `.env.example` with every variable documented; secrets never in git

## Procedure
1. Tag: `vX.Y.Z` (Conventional Commits → `/changelog`)
2. Build and push: [workflow / command]
3. Migrations: [order, backward compatibility, who runs them]
4. Deploy: [`/deploy vX.Y.Z` → delegate skill | manual steps]
5. Smoke: [`curl -f https://…/healthz`, key user flow]

## Rollback
- Previous tag: … · Command: … · Data: [migrations reversible? backup before?]

## Checklist (ticked by /release-checklist)
- [ ] artefacts above exist and build in CI
- [ ] stack starts with healthchecks from a clean host
- [ ] secrets and env documented
- [ ] backup verified before the first production deploy
- [ ] rollback rehearsed once
