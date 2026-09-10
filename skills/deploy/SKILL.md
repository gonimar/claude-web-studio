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

Prerequisites & secrets per `docs/deploy-target-contract.md`: verify registry access, exact image names and the stack method before the first mutation; secrets never through the chat — offer the env/file channel yourself; a refused path stays refused.


Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

File writes and any mutation (git, deploy) happen only after an explicit "May I write?" / "Proceed?" — each one `AskUserQuestion` (proceed (Recommended) · show the draft/diff first · not now) → "yes"; delegated agents follow the same protocol. After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker).

## Phase 1: Readiness
`production/releases/vX.Y.Z.md` (missing → `/release-checklist`); the tag exists; CI green on the tag (`gh run`); the image is built/available; runbook `docs/ops/deploy.md`; the deploy target and delegate from `technical-preferences.md` (Infrastructure) and `docs/deploy/<target>.md` — contract: `docs/deploy-target-contract.md`.

## Phase 2: Plan
Steps: DB backup → migrations (migrate service/command) → stack redeploy → smoke (healthz, key journey, GraphQL `{ __typename }`/REST ping) → 30 min monitoring; rollback: previous tag + migration reversibility. `--plan-only` — stop.

## Phase 3: Execute
By the declared delegate (`docs/deploy-target-contract.md`): `agent <name>` → `Task` to that agent with the prompt `deploy <tag> --confirmed` (after the user's "Proceed?" → "yes" here — the delegate never asks itself); `script <path>` → `Bash` `<path> deploy <tag> --confirmed`; `none`/`manual` → the runbook steps for the user/`devops-engineer`. A delegate declared but not found (no agent file, no script) → `BLOCKED (delegate <name> not found — fix technical-preferences or run /setup-stack)`, never a guess. A companion slash command alone (`/<kit> deploy`) is not a delegate: skills cannot call skills. Read the verdict line (`DEPLOYED <tag>` | `FAILED (…)`) and the evidence; then run the runbook smoke checks yourself (`/healthz`, key journey) — the delegate's verdict is necessary, not sufficient. A failed smoke check or an unhealthy container → one `AskUserQuestion`: `rollback` to the previous tag via the delegate (Recommended) · investigate first (`logs`) · keep — never leave a red deploy without that question. **Every production mutation after an explicit "yes".** Verify by containers and smoke requests, not by response codes.

## Phase 4: Record
Update `production/releases/vX.Y.Z.md` (time, result, who); `docs/ops/deploy.md` when the procedure changed.

Verdict: `DEPLOYED` | `ROLLED BACK` | `PLAN` | `BLOCKED (delegate …)`. Next step — one `AskUserQuestion`: monitor the release (`/incident` on problems) (Recommended) · `/deploy rollback` · `/sprint-plan` for the next cycle.
