---
name: deploy
description: "Plans and executes a deployment — verifies release readiness, build/tag, migration order, delegates the stack mutation to an installed deployment skill (container platform / Kubernetes / cloud) or produces manual runbook steps, runs post-deploy smoke checks, documents rollback. Every production mutation needs confirmation."
argument-hint: "[version | rollback [tag]] [--env staging|prod] [--plan-only]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Write, Task, AskUserQuestion
model: sonnet
agent: devops-lead
---

# Deploy

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

File writes and any mutation (git, deploy) happen only after an explicit "May I write?" / "Proceed?" — each one `AskUserQuestion` (proceed (Recommended) · show the draft/diff first · not now) → "yes". After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker). A delegate never asks the user itself: the consent is collected here and passed on as `--confirmed` (`.claude/docs/deploy-target-contract.md` § 5).

Prerequisites & secrets per `.claude/docs/deploy-target-contract.md`: verify registry access, exact image names and the stack method before the first mutation; secrets never through the chat — offer the env/file channel yourself; a refused path stays refused.

**Calling the delegate** (`.claude/docs/deploy-target-contract.md` § 4), for any verb below (`deploy <tag>`, `rollback [tag]`, `logs`):
- `agent <name>` → `Task` to that agent with the prompt `<verb> <args> --confirmed`;
- `script <path>` → `Bash` `<path> <verb> <args> --confirmed`;
- `none` / `manual` → the runbook steps for the user / `devops-engineer`.
`--confirmed` goes only on a mutating verb (`deploy`, `rollback`), and only after the user's "Proceed?" → "yes" in this skill; `logs` is called without it.

**Arguments**: `vX.Y.Z` — the version to deploy; `rollback [tag]` — roll back to `tag`, default the previous release in `production/releases/`; `--env staging|prod` — the runbook environment; `--plan-only` — stop after the plan.

## Phase 1: Readiness
1. **Release file**: `production/releases/vX.Y.Z.md`. Missing → stop: `BLOCKED (no release file — run /release-checklist vX.Y.Z)`, nothing written.
2. **Artefacts**: the tag exists; CI is green on the tag (`gh run`); the image is built and available.
3. **Runbook**: `docs/ops/deploy.md`.
4. **Delegate**: the deploy target and delegate from `technical-preferences.md` (Infrastructure) and `docs/deploy/<target>.md` — contract: `.claude/docs/deploy-target-contract.md`. A delegate declared but not found (no agent file, no script) → `BLOCKED (delegate <name> not found — fix technical-preferences or run /setup-stack)`, never a guess. A companion slash command alone (`/<kit> deploy`) is not a delegate: skills cannot call skills.
With `rollback`, steps 1–2 apply to the target tag, which is already released.

## Phase 2: Plan
1. **Steps**: DB backup → migrations (migrate service/command) → stack redeploy → smoke (healthz, key journey, GraphQL `{ __typename }` / REST ping) → 30 min monitoring. With `rollback`: the delegate's `rollback [tag]` → smoke → monitoring; it rolls back the image, not the data, so the plan states whether the migrations since that tag are reversible (the runbook's Rollback § Data).
2. **Rollback plan**: previous tag + migration reversibility.
3. **Prerequisites**: name each item of the contract's Prerequisites & secrets.
4. `--plan-only` → verdict `PLAN`, stop.
5. **"Proceed?"** — one `AskUserQuestion`: proceed (Recommended) · show the plan again · not now. **Every production mutation after an explicit "yes".**

## Phase 3: Execute
1. **Run** the mutation through the delegate: `deploy <tag>` (or `rollback [tag]`), as defined above.
2. **Read the verdict line** (`DEPLOYED <tag>` | `ROLLED BACK <tag>` | `FAILED (…)`) and the evidence.
3. **Smoke checks yourself**: run the runbook smoke checks (`/healthz`, key journey) — the delegate's verdict is necessary, not sufficient. Verify by containers and smoke requests, not by response codes.
4. **Red deploy.** A failed smoke check or an unhealthy container → one `AskUserQuestion`: `rollback` to the previous tag via the delegate (Recommended) · investigate first (`logs`) · keep. Never leave a red deploy without that question.

## Phase 4: Record
1. Render the changes, then "May I write `production/releases/vX.Y.Z.md`?" (and `docs/ops/deploy.md` when the procedure changed) — one `AskUserQuestion`: write (Recommended) · show the draft/diff first · not now.
2. After the "write" answer: `touch .claude/.write-consent`, then update the release file (time, result, who) and, when the procedure changed, the runbook.

Verdict: `DEPLOYED` | `ROLLED BACK` | `PLAN` | `BLOCKED (…)`. Next step — one `AskUserQuestion`: monitor the release (`/incident` on problems) (Recommended) · `/deploy rollback` · `/sprint-plan` for the next cycle.
