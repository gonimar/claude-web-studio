---
name: team-release
description: "Release pipeline end-to-end: perf-audit + a11y-audit + security quick check in parallel → changelog → release-checklist → deploy (via an installed deployment skill when present) → post-deploy verification. Use to ship a version."
argument-hint: "[version]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Write, Task, AskUserQuestion
model: opus
agent: qa-lead
---

# Team: Release

File writes and any mutation (git, deploy) happen only after an explicit "May I write?" / "Proceed?" → "yes"; delegated agents follow the same protocol.

## Phase 1: Parallel checks
`/perf-audit full` ‖ `/a11y-audit all` ‖ `/security-audit quick` ‖ `/dependency-audit`. Any FAIL → stop with a partial report.

## Phase 2: Documents
`/changelog <version>` → `/release-checklist <version>`.

## Phase 3: Deploy
`/deploy <version>` (confirmations inside) → smoke → monitoring.

## Phase 4: Summary
Version, what shipped, post-deploy metrics, known issues; `production/stage.txt` → `operate` with consent.

Verdict: `RELEASED` | `ABORTED (stage …)`. Next step: `/sprint-plan` for the next cycle.
