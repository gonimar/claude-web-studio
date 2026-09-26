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

File writes and any mutation (git, deploy) happen only after an explicit "May I write?" / "Proceed?" — each one `AskUserQuestion` (proceed (Recommended) · show the draft/diff first · not now) → "yes". After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker). A subagent spawned through `Task` cannot ask the user: the parent's "yes" covers the packages and files it names, and a delegated agent that needs to go beyond that stops and reports back so the parent asks.

## Phase 1: Inventory
Manifests and lockfiles (`go.mod/go.sum`, `composer.lock`, `pnpm-lock.yaml`/`package-lock.json`), Dockerfile base images, external `<script src>` in HTML, GitHub Actions (pins).

## Phase 2: Checks (Bash, whatever is available)
- Go: `govulncheck ./...`.
- PHP: `composer audit`, `composer outdated --direct`, Packagist abandoned (WebFetch when in doubt).
- JS: `pnpm audit`/`npm audit`, `pnpm outdated`.
- Versions vs `stack-reference/index.md`.
- Licences: `license-checker`/`composer licenses`/`go-licenses` when available.
- `renovate.json`/`dependabot.yml`: present, minors grouped per `tooling-devops.md`. The open update PRs themselves are `/sprint-plan`'s queue, not this report's.
- Images: `trivy image` when available.

## Phase 3: Report
Table "package → version → problem (CVE/abandoned/outdated/licence) → action (upgrade/replace/accept risk) → effort". `--fix-safe`: propose applying only patch/minor updates without breaking changes (after "yes", with a test run).

Verdict: `CLEAN` | `ACTION REQUIRED (N high)`. Next step — one `AskUserQuestion`: stories for the replacements/upgrades (Recommended) · `/stack-update` for outdated majors · report only.
