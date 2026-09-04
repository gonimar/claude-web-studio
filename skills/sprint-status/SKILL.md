---
name: sprint-status
description: "Read-only sprint status from artifacts — story states, tests/CI evidence, blockers, burn, risk to the sprint goal. Use for 'where are we' during a sprint."
argument-hint: "[sprint number]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash
model: haiku
---

# Sprint Status

Read-only. Source: artefacts (story files, git log, CI), not claims.

## Phase 1: Data
The current sprint (latest in `production/sprints/`), stories and statuses, `git log --since` on `feat/S-*` branches, `gh run list` (if `gh` exists), `session-state/active.md`.

## Phase 2: Report
```
Sprint NN — goal: …   days left: N
Done N / In Progress N / Ready N / Blocked N
Blockers: …
Risk to the goal: low | medium | high (why)
In progress now: S-NNN (branch, last commit, tests: ✅/❌)
```
Discrepancies "Done without a test/PR" on a separate line.

Verdict: `ON TRACK` | `AT RISK` | `OFF TRACK`. Next step: `/dev-story` for the next story or `/help`.
