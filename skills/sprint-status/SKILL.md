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

Read-only. Source: artefacts (story files, git log, CI), not claims.

## Phase 1: Data
Who did the work: `hooks/agent-stats.sh --since <sprint start>` (`.claude/hooks/` in copy mode, `${CLAUDE_PLUGIN_ROOT}/hooks/` in plugin mode) over `production/session-logs/agent-audit.log` — the numbers come from the log the `log-agent` hook keeps, never from memory of what ran.
The current sprint (latest in `production/sprints/`), stories and statuses, `git log --since` on `feat/S-*` branches, `gh run list` and `gh pr list --state open --author app/dependabot --json number,title,createdAt,statusCheckRollup` (if `gh` exists; Renovate: `--author app/renovate`), `session-state/active.md`.

## Phase 2: Report
```
Sprint NN — goal: …   days left: N
Done N / In Progress N / Ready N / Blocked N
Blockers: …
Risk to the goal: low | medium | high (why)
In progress now: S-NNN (branch, last commit, tests: ✅/❌)
Dependency PRs: N open (green N · red N · majors N · oldest YYYY-MM-DD)
Agents: N runs all-time · M this sprint
  go-engineer N · vue-engineer N · appsec-engineer N · … (top five, plugin and copy-mode names merged)
  K start(s) without a stop — cut off at the turn limit, or still running
  ! F run(s) of non-studio agents — routing went around the roster
```
A dependency PR older than the sprint start, or any red one, is a line under *Risk to the goal* with `/sprint-plan` (its Phase 2) as the fix; without `gh` the line says `Dependency PRs: n/a (no gh)`.
The last two agent lines are the ones to read. A start with no stop is an agent cut off at its turn limit: the work it was given either came back half-done or was finished by the parent, and neither shows anywhere else — four stories in a row were written by the parent this way before anyone looked at the log. A run of a non-studio agent (`general-purpose`, `Explore`) is routing that went around the roster: the specialist's rules, stack reference and memory were not in the room. Both belong under *Risk to the goal* when they are not zero, with the count.
Discrepancies "Done without a test/PR" on a separate line. `Open BLOCKING findings: N (production/findings.md)` — with the story or "no story" per finding.

Verdict: `ON TRACK` | `AT RISK` | `OFF TRACK`. Next step — one `AskUserQuestion`: `/dev-story <next story>` (Recommended) · `/help` · nothing now.
