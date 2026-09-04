---
name: deploy
description: "Plans and executes a deployment — verifies release readiness, build/tag, migration order, delegates the stack mutation to an installed deployment skill (container platform / Kubernetes / cloud) or produces manual runbook steps, runs post-deploy smoke checks, documents rollback. Every production mutation needs confirmation."
argument-hint: "[version | --env staging|prod] [--plan-only]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Write, Task, AskUserQuestion
model: sonnet
agent: devops-lead
---

# Deploy

File writes and any mutation (git, deploy) happen only after an explicit "May I write?" / "Proceed?" → "yes"; delegated agents follow the same protocol.

## Phase 1: Readiness
`production/releases/vX.Y.Z.md` (missing → `/release-checklist`); the tag exists; CI green on the tag (`gh run`); the image is built/available; runbook `docs/ops/deploy.md`.

## Phase 2: Plan
Steps: DB backup → migrations (migrate service/command) → stack redeploy → smoke (healthz, key journey, GraphQL `{ __typename }`/REST ping) → 30 min monitoring; rollback: previous tag + migration reversibility. `--plan-only` — stop.

## Phase 3: Execute
If a deployment skill/agent is installed in the project (check `.claude/skills`, `.claude/agents`, installed plugins) — invoke it with the version; otherwise commands for the user/`devops-engineer` from the runbook. **Every production mutation after an explicit "yes".** Verify by containers and smoke requests, not by response codes.

## Phase 4: Record
Update `production/releases/vX.Y.Z.md` (time, result, who); `docs/ops/deploy.md` when the procedure changed.

Verdict: `DEPLOYED` | `ROLLED BACK` | `PLAN`. Next step: monitoring; `/incident` on problems.
