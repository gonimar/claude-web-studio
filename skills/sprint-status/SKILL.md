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

Read-only: no file is written and no status changes. Source: artefacts (story files, git log, CI), not claims.

In the commands below, `<hooks>` is `.claude/hooks/` in copy mode and `${CLAUDE_PLUGIN_ROOT}/hooks/` in plugin mode.

## Phase 1: Data
1. **The sprint.** `production/sprints/sprint-NN.md` for the sprint number in the argument, else the latest file in `production/sprints/`. Its header gives the start and end dates. No sprint file → report `No sprint in production/sprints/ — run /sprint-plan`, give no verdict, and go straight to the next step with `/sprint-plan` as the Recommended option.
2. **Stories**: the sprint's stories and their statuses, from the story files.
3. **Commits**: `git log --since <sprint start>` on the `feat/S-*` branches.
4. **CI and the dependency queue** (only when `gh` exists): `gh run list`, and `gh pr list --state open --author app/dependabot --json number,title,createdAt,statusCheckRollup` (Renovate: `--author app/renovate`).
5. **Session state**: `production/session-state/active.md`.
6. **Findings**: open BLOCKING findings in `production/findings.md`.
7. **Who did the work**: `<hooks>agent-stats.sh --since <sprint start>`, which reads `production/session-logs/agent-audit.log` and includes the `parent-write` count, code the session wrote instead of an engineer (coordination-rules § Subagents). The numbers come from the log the `log-agent` hook keeps, never from memory of what ran.

## Phase 2: Report
1. Print the report:
   ```
   Sprint NN — goal: …   days left: N
   Done N / In Progress N / Ready N / Blocked N
   Blockers: …
   Risk to the goal: low | medium | high (why)
   In progress now: S-NNN (branch, last commit, tests: ✅/❌)
   Dependency PRs: N open (green N · red N · majors N · oldest YYYY-MM-DD)
   Agents: N runs all-time · M this sprint
     go-engineer N · vue-engineer N · appsec-engineer N · … (top five, plugin and copy-mode names merged)
     U agent(s) started and never closed — cut off at the turn limit, or still running
     R run(s) predate the agent ids — they cannot be paired, so "never closed" covers only the A agents that can
     ! F run(s) of non-studio agents — routing went around the roster
     ! P code file(s) written by the session itself (parent-write)
   ```
2. **Dependency PRs.** A dependency PR older than the sprint start, or any red one, is a line under *Risk to the goal* with `/sprint-plan` (its Phase 2) as the fix. Without `gh` the line reads `Dependency PRs: n/a (no gh)`.
3. **Agent lines** — the two counts are read differently:
   - The **non-studio count** is a fact: the name is in the line, so routing went around the roster and the specialist's rules, stack reference and memory were not in the room.
   - The **unclosed agents** are a lead, not a verdict: an agent started and never closed was cut off at its turn limit or is still running. The story it was given either came back half-done or was finished by the parent, so check the story results.
   - Never report starts minus stops. `SubagentStart` fires on every resume of the same agent, so that difference counts resumes, not lost work.
   - Each of these two lines goes under *Risk to the goal* when it is not zero.
4. **Discrepancies** on a separate line: "Done without a test/PR" for every story marked Done with no test or PR behind it.
5. **Findings**: `Open BLOCKING findings: N (production/findings.md)`, naming the story per finding, or "no story".

Verdict: `ON TRACK` | `AT RISK` | `OFF TRACK`.

Next step — one `AskUserQuestion`: `/dev-story <next story>` (Recommended) · `/help` · nothing now.
