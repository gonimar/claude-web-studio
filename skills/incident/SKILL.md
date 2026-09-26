---
name: incident
description: "Incident response and blameless postmortem — severity, containment steps, diagnosis (logs/metrics/containers via a deployment skill when present), fix/rollback, timeline, root cause, actions; writes docs/ops/incidents/INC-NNN.md."
argument-hint: "[title] [--sev 1-4]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Write, Edit, Task, Skill, AskUserQuestion
model: sonnet
agent: devops-lead
---

# Incident

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

Template `incident-postmortem.md`.

## Phase 1: Containment
Severity; what users see; immediate measures (rollback via `/deploy`/the deployment skill, feature kill switch, rate limit) — with confirmation. Security (leak/breach?) → `security-lead` immediately: isolate, rotate secrets, preserve logs.

## Phase 2: Diagnosis
Logs (delegate verb `logs [service] [--since]` by `.claude/docs/deploy-target-contract.md`, or `docker compose logs`), metrics, recent deploys/migrations, `git log`; hypotheses → verification.
**No logs** (the delegate answers `NOT SUPPORTED` or `FAILED`, no compose access, the retention window has passed, the service never logged) → say so in the diagnosis in one line ("no logs: <reason>"), continue from metrics, recent deploys and `git log`, mark every hypothesis that logs would have confirmed as unverified, and note it in the postmortem under "What did not work" with a `detect` action (log retention, structured logs, the delegate's `logs` verb). Never silently diagnose as if logs had been read.

## Phase 3: Fix
`/hotfix` or `/deploy rollback`, each run through the `Skill` tool with its own confirmations (coordination-rules § Subagents; the incident continues into the postmortem afterwards, so these are runs, not hand-offs); verify by metrics.

## Phase 4: Postmortem
1. Timeline, root cause (system/process, blameless), what worked/did not, actions (fix/prevent/detect) with owners and dates. Render the postmortem and the roadmap lines in the chat (rule 7, readable rendering).
2. **Actions → roadmap.** Each action becomes one line in `production/roadmap.md` under Backlog, tagged `🏷 incident INC-NNN` with its type, owner and due date (a `fix` action that is already a hotfix links the PR instead); the prevent/detect actions become stories through `/create-stories` (the next step), which reads those lines. No `production/roadmap.md` in the project → the actions stay in the postmortem's Actions table and the result says so; nothing else is created.
3. "May I write `docs/ops/incidents/INC-NNN.md` and add the action lines to `production/roadmap.md`?" — one `AskUserQuestion`: write (Recommended) · show the draft/diff first · not now. After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker), then write both.
4. **Commit gate** (rule 7 (4), `.claude/docs/git-workflow.md` § Documents), one `AskUserQuestion`: `docs: postmortem INC-NNN` staging exactly the written files (`docs/ops/incidents/INC-NNN.md`, `production/roadmap.md`) — on the default branch when no story or hotfix work is in progress; when HEAD is a story or hotfix branch, name it and offer: switch to the default branch and commit there (Recommended — a pipeline-wide document) · commit here (the postmortem belongs to this hotfix) · leave uncommitted. The fix's code, configs and workflows never ride the `docs:` commit — they belong to the `/hotfix` branch and its PR; name them. Nothing is committed without the answer.

Verdict: `RESOLVED` | `MITIGATED` | `OPEN`. Next step — one `AskUserQuestion`: `/create-stories` for the prevent/detect actions (Recommended) · `/hotfix` · close the incident.
