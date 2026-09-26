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

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

File writes and any mutation (git, deploy) happen only after an explicit "May I write?" / "Proceed?" — each one `AskUserQuestion` (proceed (Recommended) · show the draft/diff first · not now) → "yes". After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker).

**Consent for delegated work is collected by this skill.** A subagent spawned through `Task` cannot ask the user. Before each `Task` batch, the "Proceed?" question names the agents and the files each will create or change (reports, test files); that answer covers those files. A delegated step that needs to go beyond its brief (another file, a code or configuration change, a production mutation) stops and reports it, and the parent asks.

## Phase 1: Parallel checks
`/perf-audit full` ‖ `/a11y-audit all` ‖ `/security-audit quick` ‖ `/dependency-audit`. Any failing verdict (`FAIL` from `/a11y-audit` or `/security-audit`, `OVER BUDGET` from `/perf-audit`) → stop with a partial report: `ABORTED (stage 1: …)`.

## Phase 2: Documents
`/changelog <version>` → `/release-checklist <version>` (it creates the tag `vX.Y.Z`, with consent, which `/deploy` needs).

## Phase 3: Deploy
`/deploy <version>` (confirmations inside; the delegate by `docs/deploy-target-contract.md`, manual runbook when none is declared) → smoke → monitoring.

## Phase 4: Summary
Version, what shipped, post-deploy metrics, known issues; `production/stage.txt` → `operate` with consent.

Verdict: `RELEASED` | `ABORTED (stage …)`. Next step — one `AskUserQuestion`: `/sprint-plan` for the next cycle (Recommended) · `/incident` if the post-deploy checks fail · stop here.
