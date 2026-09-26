---
name: dependency-audit
description: "Supply-chain audit (OWASP A03) — lockfiles present, npm/pnpm/composer audit, govulncheck, abandoned/unmaintained packages, versions vs the stack reference, licence check, Renovate/Dependabot config, SRI for external scripts, image pinning. Report with upgrade/replace actions."
argument-hint: "[--fix-safe]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Write, WebFetch, Task, AskUserQuestion
model: sonnet
agent: appsec-engineer
---

# Dependency Audit

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

Reference `stack-reference/index.md`, `tooling-devops.md`. The report is `docs/ops/dependency-audit-<date>.md` (Phase 4) — the one record of this audit; its high findings reach planning through the next-step stories, not through `production/findings.md` rows.

File writes and any mutation (git, deploy) happen only after an explicit "May I write?" / "Proceed?" — each one `AskUserQuestion` (proceed (Recommended) · show the draft/diff first · not now) → "yes". After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker). A subagent spawned through `Task` cannot ask the user: the parent's "yes" covers the packages and files it names, and a delegated agent that needs to go beyond that stops and reports back so the parent asks.

## Phase 1: Inventory
Manifests and lockfiles (`go.mod/go.sum`, `composer.lock`, `pnpm-lock.yaml`/`package-lock.json`), Dockerfile base images, external `<script src>` in HTML, GitHub Actions (pins).

## Phase 2: Checks (Bash, whatever is available)
- Go: `govulncheck ./...`.
- PHP: `composer audit`, `composer outdated --direct`, Packagist abandoned (`WebFetch` of the package's Packagist page when in doubt — the fetched status is quoted in the report, never assumed).
- JS: `pnpm audit`/`npm audit`, `pnpm outdated`.
- Versions vs `stack-reference/index.md`.
- Licences: `license-checker`/`composer licenses`/`go-licenses` when available.
- `renovate.json`/`dependabot.yml`: present, minors grouped per `tooling-devops.md`. The open update PRs themselves are `/sprint-plan`'s queue, not this report's.
- Images: `trivy image` when available.

## Phase 3: Report
Table "package → version → problem (CVE/abandoned/outdated/licence) → action (upgrade/replace/accept risk) → effort", shown in the chat.

`--fix-safe`: propose applying only patch/minor updates without breaking changes (after "yes", with a test run). Dependency updates are toolchain work on the chore lane (git-workflow § Chore / infra): after the "yes", switch to a `chore/deps-<date>` branch from an up-to-date default branch, apply the updates, run the tests (output in the result), commit `chore(deps): safe updates <date>` and open the PR; `/code-review --diff` before the merge. The manifest and lockfile changes never land on the default branch and never ride the `docs:` commit of Phase 4. A failing test run reverts the update that broke it and lists it under "not applied".

## Phase 4: Write
1. "May I write `docs/ops/dependency-audit-<date>.md`?" — one `AskUserQuestion`: write (Recommended) · show the draft/diff first · not now. After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker).
2. **Commit gate** (rule 7 (4), `.claude/docs/git-workflow.md` § Documents), right after the write: `docs: dependency audit <date>`, staging exactly `docs/ops/dependency-audit-<date>.md`.
   - On the default branch when no story work is in progress: one `AskUserQuestion` — commit (Recommended) · leave uncommitted.
   - When HEAD is a story branch (or the `chore/deps-<date>` branch of `--fix-safe`), name it and ask one `AskUserQuestion`: switch to the default branch and commit there (Recommended — a pipeline-wide document) · commit here (the document belongs to this branch) · leave uncommitted.
   - Lockfile and manifest changes, a `renovate.json`/`dependabot.yml` added on request, image pins: not documents — they stay on the chore lane and never ride the `docs:` commit; name them in the result.

   Nothing is committed without the answer.

Verdict: `CLEAN` | `ACTION REQUIRED (N high)`. Next step — one `AskUserQuestion`: stories for the replacements/upgrades (Recommended) · `/stack-update` for outdated majors · report only.
