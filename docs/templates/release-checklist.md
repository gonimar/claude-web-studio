# Release vX.Y.Z — YYYY-MM-DD

## Gates
- [ ] All release stories Done with tests (link to the CI run)
- [ ] `/security-audit` without BLOCKING (report: ) · `/dependency-audit` clean · `/harden` checklist closed
- [ ] `/perf-audit` within budget (LCP/INP/CLS, API p95) · `/a11y-audit` without critical findings
- [ ] Migrations backward-compatible; rollback plan written
- [ ] CHANGELOG.md updated; tag created
- [ ] Production secrets/env in place, new variables documented
- [ ] DB backup taken before deploy; restore last tested: [date] (first release: the restore drill on staging is a gate — story "Backup & restore drill")
- [ ] Observability in place: `/healthz` with dependency checks, structured logs, an alert on error rate (first release gate when a Deploy target is set)

## Deploy
Steps (`/deploy`), who, when; smoke checks afterwards (URL, healthz, key journey).

## Rollback
Previous tag/command; rollback conditions.

## Post-release
24 h monitoring (error rate, latency), known issues.
