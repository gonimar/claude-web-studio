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

Template `incident-postmortem.md`. In the commands below, `<hooks>` is `.claude/hooks/` in copy mode and `${CLAUDE_PLUGIN_ROOT}/hooks/` in plugin mode. **Other studio skills run through the `Skill` tool** — `/deploy` (Phase 1 and 3), `/hotfix` (Phase 3) and `/backlog add` (Phase 4) — as `/web-studio:<name>` in plugin mode and `/<name>` in copy mode (coordination-rules § Subagents); each keeps all of its own phases and gates, its verdict comes back as text this skill quotes, and they run one after another, never two at once. `/create-stories` is a hand-off in the closing `AskUserQuestion`, not run from here.

## Phase 1: Containment
Severity; what users see; immediate measures (rollback via `/deploy`/the deployment skill, feature kill switch, rate limit) — with confirmation. Security (leak/breach?) → `security-lead` immediately: isolate, rotate secrets, preserve logs.

## Phase 2: Diagnosis
Logs (delegate verb `logs [service] [--since]` by `.claude/docs/deploy-target-contract.md`, or `docker compose logs`), metrics, recent deploys/migrations, `git log`; hypotheses → verification.
**No logs** (the delegate answers `NOT SUPPORTED` or `FAILED`, no compose access, the retention window has passed, the service never logged) → say so in the diagnosis in one line ("no logs: <reason>"), continue from metrics, recent deploys and `git log`, mark every hypothesis that logs would have confirmed as unverified, and note it in the postmortem under "What did not work" with a `detect` action (log retention, structured logs, the delegate's `logs` verb). Never silently diagnose as if logs had been read.

## Phase 3: Fix
`/hotfix` or `/deploy rollback`, each run through the `Skill` tool with its own confirmations (coordination-rules § Subagents; the incident continues into the postmortem afterwards, so these are runs, not hand-offs); verify by metrics.

## Phase 4: Postmortem
1. Timeline, root cause (system/process, blameless), what worked/did not, actions (fix/prevent/detect) with owners and dates in the postmortem's Actions table — the table is the record of owner and due date. Render the postmortem in the chat (rule 7, readable rendering) and name the actions that step 5 will record.
2. **Actions → backlog, not the roadmap.** The roadmap holds story lines only (`templates/roadmap.md`: `- [ ] [ID](path) · Title` + markers, `🏷` is the layer, no owner marker), and `/create-stories` does not read Backlog lines — so no line is written to `production/roadmap.md` here. Each action becomes one `production/backlog.md` item (`I-NNN`) in step 5; the prevent/detect actions become stories through `/create-stories` from the postmortem (the next step). A `fix` action that is already a hotfix is recorded with its PR link in the Actions table and gets no backlog item.
3. "May I write `docs/ops/incidents/INC-NNN.md`?" — one `AskUserQuestion`: write (Recommended) · show the draft/diff first · not now. After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker), then write it.
4. **Commit gate** (rule 7 (4), `.claude/docs/git-workflow.md` § Documents), recorded before it is asked — `<hooks>session-state.sh set Gate "/incident Phase 4: commit?"` — and cleared after the answer (`<hooks>session-state.sh set Gate "—"`), so an open gate survives the next turn; one `AskUserQuestion`: `docs: postmortem INC-NNN` staging exactly `docs/ops/incidents/INC-NNN.md` — on the default branch when no story or hotfix work is in progress; when HEAD is a story or hotfix branch, name it and offer: switch to the default branch and commit there (Recommended — a pipeline-wide document) · commit here (the postmortem belongs to this hotfix) · leave uncommitted. The fix's code, configs and workflows never ride the `docs:` commit — they belong to the `/hotfix` branch and its PR; name them. Nothing is committed without the answer.
5. **Record the actions**, after the commit gate and before the next step: `/backlog add "<action> 🔗 INC-NNN"` through the `Skill` tool (`/web-studio:backlog add` in plugin mode), one call per action, one after another, each with its own write and commit gate inside `/backlog` (source: `incident INC-NNN`); `/backlog` creates `production/backlog.md` when the project has none. An action that is neither in the Actions table nor recorded as an `I-NNN` is gone at the end of the session — the result lists every `I-NNN` next to its action.

Verdict: `RESOLVED` | `MITIGATED` | `OPEN`. Next step — one `AskUserQuestion`: `/create-stories` for the prevent/detect actions (Recommended) · `/hotfix` · close the incident.
