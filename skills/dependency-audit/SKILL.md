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

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

File writes and any mutation (git, deploy) happen only after an explicit "May I write?" / "Proceed?" — each one `AskUserQuestion` (proceed (Recommended) · show the draft/diff first · not now) → "yes"; delegated agents follow the same protocol. After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker).

## Phase 1: Inventory
Manifests and lockfiles (`go.mod/go.sum`, `composer.lock`, `pnpm-lock.yaml`/`package-lock.json`), Dockerfile base images, external `<script src>` in HTML, GitHub Actions (pins).

## Phase 2: Checks (Bash, whatever is available)
`govulncheck ./...`; `composer audit`, `composer outdated --direct`, Packagist abandoned (WebFetch when in doubt); `pnpm audit`/`npm audit`, `pnpm outdated`; versions vs `stack-reference/index.md`; licences (`license-checker`/`composer licenses`/`go-licenses` when available); `renovate.json`/`dependabot.yml` (present, minors grouped per `tooling-devops.md`; the open update PRs themselves are `/sprint-plan`'s queue, not this report's); `trivy image` when available.

## Phase 3: Report
Table "package → version → problem (CVE/abandoned/outdated/licence) → action (upgrade/replace/accept risk) → effort". `--fix-safe`: propose applying only patch/minor updates without breaking changes (after "yes", with a test run).

Verdict: `CLEAN` | `ACTION REQUIRED (N high)`. Next step — one `AskUserQuestion`: stories for the replacements/upgrades (Recommended) · `/stack-update` for outdated majors · report only.
