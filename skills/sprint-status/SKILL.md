---
name: sprint-status
description: "Read-only sprint status from artifacts — story states, tests/CI evidence, blockers, the dependency-update queue, burn, risk to the sprint goal. Use for 'where are we' during a sprint."
argument-hint: "[sprint number]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, AskUserQuestion
model: haiku
---

# Sprint Status

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

Read-only. Source: artefacts (story files, git log, CI), not claims.

## Phase 1: Data
The current sprint (latest in `production/sprints/`), stories and statuses, `git log --since` on `feat/S-*` branches, `gh run list` and `gh pr list --state open --author app/dependabot --json number,title,createdAt,statusCheckRollup` (if `gh` exists; Renovate: `--author app/renovate`), `session-state/active.md`.

## Phase 2: Report
```
Sprint NN — goal: …   days left: N
Done N / In Progress N / Ready N / Blocked N
Blockers: …
Risk to the goal: low | medium | high (why)
In progress now: S-NNN (branch, last commit, tests: ✅/❌)
Dependency PRs: N open (green N · red N · majors N · oldest YYYY-MM-DD)
```
A dependency PR older than the sprint start, or any red one, is a line under *Risk to the goal* with `/sprint-plan` (its Phase 2) as the fix; without `gh` the line says `Dependency PRs: n/a (no gh)`.
Discrepancies "Done without a test/PR" on a separate line. `Open BLOCKING findings: N (production/findings.md)` — with the story or "no story" per finding.

Verdict: `ON TRACK` | `AT RISK` | `OFF TRACK`. Next step — one `AskUserQuestion`: `/dev-story <next story>` (Recommended) · `/help` · nothing now.
