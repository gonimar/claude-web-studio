---
name: incident
description: "Incident response and blameless postmortem — severity, containment steps, diagnosis (logs/metrics/containers via a deployment skill when present), fix/rollback, timeline, root cause, actions; writes docs/ops/incidents/INC-NNN.md."
argument-hint: "[title] [--sev 1-4]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Write, Edit, Task, AskUserQuestion
model: sonnet
agent: devops-lead
---

# Incident

Template `incident-postmortem.md`.

## Phase 1: Containment
Severity; what users see; immediate measures (rollback via `/deploy`/the deployment skill, feature kill switch, rate limit) — with confirmation. Security (leak/breach?) → `security-lead` immediately: isolate, rotate secrets, preserve logs.

## Phase 2: Diagnosis
Logs (deployment skill / `docker compose logs`), metrics, recent deploys/migrations, `git log`; hypotheses → verification.

## Phase 3: Fix
`/hotfix` or rollback; verify by metrics.

## Phase 4: Postmortem
Timeline, root cause (system/process, blameless), what worked/did not, actions (fix/prevent/detect) with owners and dates. "May I write `docs/ops/incidents/INC-NNN.md`?" Actions → roadmap.

Verdict: `RESOLVED` | `MITIGATED` | `OPEN`. Next step: stories for prevent/detect actions.
