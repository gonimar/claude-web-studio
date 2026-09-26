# Release vX.Y.Z — YYYY-MM-DD

Verdict: READY | NOT READY (the ❌ gates, in one line) | READY (hotfix)

<!-- Written by /release-checklist (READY | NOT READY) or /hotfix (READY (hotfix)); /deploy reads this line — a file present without `Verdict: READY…` blocks the deploy. -->

## Gates
- [ ] All release stories Done with tests (link to the CI run)
- [ ] `/security-audit` without BLOCKING (report: ) · `/dependency-audit` clean · `/harden` checklist closed
- [ ] `/perf-audit` within budget (LCP/INP/CLS, API p95) · `/a11y-audit` without critical findings
- [ ] Migrations backward-compatible; rollback plan written
- [ ] CHANGELOG.md updated; tag created
- [ ] Production secrets/env in place, new variables documented
- [ ] DB backup taken before deploy; restore last tested: [date] (first release: the restore drill on staging is a gate — story "Backup & restore drill")
- [ ] Observability in place: `/healthz` with dependency checks, structured logs, an alert on error rate (first release gate when a Deploy target is set)
- [ ] SBOM attached to the release (`gh release view vX.Y.Z --json assets`) — SC-06
- [ ] Image signed and verified by digest (`verify-image.sh <image>@sha256:<digest> <owner>/<repo>` output: ) — SC-08/SC-09
- [ ] Provenance attestation present (`gh attestation verify oci://<image>:vX.Y.Z -R <owner>/<repo>`) or the reason recorded — SC-10

## Deploy
Steps (`/deploy`), who, when; smoke checks afterwards (URL, healthz, key journey).

## Rollback
Previous tag/command; rollback conditions.

## Post-release
24 h monitoring (error rate, latency), known issues.
