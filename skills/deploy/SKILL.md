---
name: deploy
description: "Plans and executes a deployment — verifies release readiness, build/tag, migration order, delegates the stack mutation to the declared deploy delegate (container platform / Kubernetes per stack-reference/kubernetes.md / cloud) or produces manual runbook steps, runs post-deploy smoke checks, documents rollback. Every production mutation needs confirmation."
argument-hint: "[version | rollback [tag]] [--env <name>] [--plan-only]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Write, Task, AskUserQuestion
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

**Deploy target `kubernetes`**: the rollout, verification and rollback commands are those of `.claude/docs/stack-reference/kubernetes.md` § Rollout and rollback — the delegate script `scripts/deploy/kubernetes.sh` runs them, and the runbook steps for a `none` delegate quote that section; this skill never restates them. The plan names the namespace of `--env` and the image digest the release workflow wrote.

**Arguments**:
- `vX.Y.Z` — the version to deploy. **No version given** → the latest release tag on origin: `git fetch --tags origin`, then `git tag --list 'v*' --sort=-v:refname | head -1` (cross-checked against `git ls-remote --tags --refs origin 'refs/tags/v*'` — `--refs` drops the `^{}` peeled lines of annotated tags; a tag that exists only locally is not released). Show it and confirm in one `AskUserQuestion`: deploy `vX.Y.Z` (Recommended) · another version (say which) · stop. No `v*` tag at all → `BLOCKED (no release tag — run /release-checklist vX.Y.Z)`, nothing written. Never deploy an unconfirmed guess.
- `rollback [tag]` — roll back to `tag`, default the previous release in `production/releases/`.
- `--env <name>` — the environment to deploy to. **The names come from the project, never from a fixed list**: the runbook `docs/ops/deploy.md` → Environments (the template lists `dev | staging | prod` as examples) and the target file `docs/deploy/<target>.md`; a name neither lists → `BLOCKED (--env <name> unknown — the runbook lists: <names>)`. **Default**: the one environment `docs/deploy/<target>.md` describes (one endpoint, one stack) — named in the plan as "environment: <name> (the target's only one)". When the target file or the runbook lists several environments and `--env` is missing → `BLOCKED (--env required: <the names the runbook lists, e.g. staging|prod>)`, never a guess. The environment selects the runbook section, the smoke URLs and the target facts; it is named in the "Proceed?" question and passed to the delegate after the verb's arguments (`deploy <tag> --env <name> --confirmed`; a delegate whose `docs/deploy/<target>.md` documents one environment only is called without it).
- `--plan-only` — stop after the plan.

## Phase 1: Readiness
1. **Release file and its verdict**: `production/releases/vX.Y.Z.md` (written by `/release-checklist` on `READY` and `NOT READY` alike, so its presence proves nothing by itself). Missing → stop: `BLOCKED (no release file — run /release-checklist vX.Y.Z)`, nothing written. Read its `Verdict:` line: `READY` or `READY (hotfix)` → continue; `NOT READY (…)` → stop: `BLOCKED (release NOT READY: <the reason from the file> — fix it, then re-run /release-checklist vX.Y.Z)`; no `Verdict:` line → stop: `BLOCKED (release file without a Verdict line — re-run /release-checklist vX.Y.Z)`. Nothing is deployed on a guessed readiness.
2. **Artefacts**: the tag exists; CI is green on the tag (`gh run`); the image is built and available — note its **digest** (the release workflow summary or `docker buildx imagetools inspect <image>:<tag>`).
3. **Signature**, when signing is configured (technical-preferences → Supply chain → `signing:` not `none`, or a `cosign sign` step in the release workflow): before any rollout run `bash docs/templates/supply-chain/verify-image.sh <image>@sha256:<digest> <owner>/<repo>` (or the runbook's equivalent `cosign verify` with identity and issuer; `stack-reference/supply-chain.md` § Artifact signing). The output is part of the plan's evidence; a failed verify → `BLOCKED (image signature not verified for <digest> — <cosign output>)`, nothing deployed. Signing not configured → one line in the plan ("unsigned image — `/harden supply-chain`"), not a block. The delegate receives the digest it must roll out.
4. **Runbook**: `docs/ops/deploy.md`.
5. **Delegate**: the deploy target and delegate from `technical-preferences.md` (Infrastructure) and `docs/deploy/<target>.md` — contract: `.claude/docs/deploy-target-contract.md`. A delegate declared but not found (no agent file, no script) → `BLOCKED (delegate <name> not found — fix technical-preferences or run /setup-stack)`, never a guess. A companion slash command alone (`/<kit> deploy`) is not a delegate: the contract's delegate is an agent or a script (§ 4), and `/deploy` does not list `Skill` in its `allowed-tools`, so it cannot run another skill (coordination-rules § Subagents).
With `rollback`, steps 1–3 apply to the target tag, which is already released (the previous image is verified the same way).

## Phase 2: Plan
1. **Steps** (headed by the version and the environment: `vX.Y.Z → <env>`): DB backup → migrations (migrate service/command) → stack redeploy → smoke (healthz, key journey, GraphQL `{ __typename }` / REST ping) → 30 min monitoring. With `rollback`: the delegate's `rollback [tag]` → smoke → monitoring; it rolls back the image, not the data, so the plan states whether the migrations since that tag are reversible (the runbook's Rollback § Data).
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
2. After the "write" answer: `touch .claude/.write-consent`, then update the release file (time, `Result: DEPLOYED` | `Result: ROLLED BACK`, who) and, when the procedure changed, the runbook.

Verdict: `DEPLOYED` | `ROLLED BACK` | `PLAN` | `BLOCKED (…)` (including `BLOCKED (image signature not verified …)`). Next step — one `AskUserQuestion`: monitor the release (`/incident` on problems) (Recommended) · `/deploy rollback` · `/sprint-plan` for the next cycle.
