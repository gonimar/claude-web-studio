---
name: dependency-audit
description: "Supply-chain audit (OWASP A03) — lockfiles present, npm/pnpm/composer audit, govulncheck, abandoned/unmaintained packages, versions vs the stack reference, licence check, Renovate/Dependabot config, SRI for external scripts, image pinning. Report with upgrade/replace actions."
argument-hint: "[--fix-safe]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Write, Task, AskUserQuestion
model: sonnet
agent: appsec-engineer
---

# Dependency Audit

File writes and any mutation (git, deploy) happen only after an explicit "May I write?" / "Proceed?" → "yes"; delegated agents follow the same protocol.

## Phase 1: Inventory
Manifests and lockfiles (`go.mod/go.sum`, `composer.lock`, `pnpm-lock.yaml`/`package-lock.json`), Dockerfile base images, external `<script src>` in HTML, GitHub Actions (pins).

## Phase 2: Checks (Bash, whatever is available)
`govulncheck ./...`; `composer audit`, `composer outdated --direct`, Packagist abandoned (WebFetch when in doubt); `pnpm audit`/`npm audit`, `pnpm outdated`; versions vs `stack-reference/index.md`; licences (`license-checker`/`composer licenses`/`go-licenses` when available); `renovate.json`/`dependabot.yml`; `trivy image` when available.

## Phase 3: Report
Table "package → version → problem (CVE/abandoned/outdated/licence) → action (upgrade/replace/accept risk) → effort". `--fix-safe`: propose applying only patch/minor updates without breaking changes (after "yes", with a test run).

Verdict: `CLEAN` | `ACTION REQUIRED (N high)`. Next step: stories for replacements/upgrades; `/stack-update` for outdated majors.
