---
name: hotfix
description: "Fast path for an urgent production fix — reproduce with a failing test, minimal fix on a hotfix branch from the release tag, mandatory security review for sensitive paths, expedited checklist, deploy and backport to main. Use for P1 production bugs."
argument-hint: "[issue description or bug id]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, AskUserQuestion
model: sonnet
---

# Hotfix

File writes and any mutation (git, deploy) happen only after an explicit "May I write?" / "Proceed?" → "yes"; delegated agents follow the same protocol.

## Phase 1: Reproduce
Branch `hotfix/<slug>` from the production tag; a failing test reproducing the bug (mandatory); impact assessment (data? security? → `security-lead` via Task).

## Phase 2: Minimal fix
Through the relevant engineer; only what is needed; test green; lint/typecheck; for sensitive paths — `appsec-engineer` review.

## Phase 3: Expedited gate
Package tests + e2e smoke; `/changelog` patch version; `/deploy` with confirmation; backport to the default branch (`master`/`main`, PR).

## Phase 4: Postmortem note
A short entry in `docs/ops/incidents/` (or `/incident` if there was an incident).

Verdict: `FIXED` | `BLOCKED`. Next step: `/incident` for root-cause analysis.
