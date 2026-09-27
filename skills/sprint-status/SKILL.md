---
name: sprint-status
description: "Read-only sprint status from artifacts — story states, tests/CI evidence, blockers, the dependency-update queue, burn, risk to the sprint goal. Use for 'where are we' during a sprint."
argument-hint: "[sprint number]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, AskUserQuestion
---

# Sprint Status

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

Read-only: no file is written and no status changes. Source: artefacts (story files, git log, CI), not claims.

In the commands below, `<hooks>` is `.claude/hooks/` in copy mode and `${CLAUDE_PLUGIN_ROOT}/hooks/` in plugin mode.

## Phase 1: Data
1. **The sprint.** `production/sprints/sprint-NN.md` for the sprint number in the argument, else the latest file in `production/sprints/`. Its header gives `Status:`, the start and end dates, the goal and the capacity. No sprint file → report `No sprint in production/sprints/ — run /sprint-plan`, give no verdict, and go straight to the next step with `/sprint-plan` as the Recommended option.
2. **Stories**: the sprint's stories and their states **from the roadmap's sprint block** (the single source `/story-done` writes); the sprint file's `## Stories` table compared with it row by row — a differing row is drift, counted, never the source.
3. **Commits**: `git log --since <sprint start>` on the `feat/S-*` branches.
4. **CI and the dependency queue** (only when `gh` exists): `gh run list`, and `gh pr list --state open --author app/dependabot --json number,title,createdAt,statusCheckRollup` (Renovate: `--author app/renovate`).
5. **Session state**: `production/session-state/active.md`.
6. **Findings**: open BLOCKING findings in `production/findings.md`.
7. **Who did the work**: `<hooks>agent-stats.sh --since <sprint start>`, which reads `production/session-logs/agent-audit.log` and includes the `parent-write` count, code the session wrote instead of an engineer (coordination-rules § Subagents). The numbers come from the log the `log-agent` hook keeps, never from memory of what ran.
8. **Burn inputs**: for every story in the sprint's roadmap block (step 2), the estimate (`~Nh` on its `production/roadmap.md` line) and, when it is Done, its close date — the author date of the `docs: close S-NNN` commit, searched across every ref (`git log --all --since <sprint start> --format='%as %s' --grep='^docs: close S-'`): a close commit left on a `feat/S-*` branch after a declined merge is not in HEAD's history, and step 3 already walks those branches. No close commit for a Done story → the date the story's roadmap line was ticked: the roadmap's `Updated:` line when it names `/story-done S-NNN`, else the author date of the commit that ticked the line (`git log --all --format=%as -S'[x] [S-NNN]' -- production/roadmap.md | tail -1`). Never the story card's `Actual:` line — it is a duration, not a date. Estimates missing on any planned story → burn is counted in stories, not hours, and the report says so.

## Phase 2: Report
1. Print the report:
   ```
   Sprint NN — goal: …   status: active | closed YYYY-MM-DD | overdue (end date passed, not closed)   days left: N
   Done N / In Progress N / Ready N / Blocked N   sprint file ≠ roadmap: N rows
   Burn: X h of Y h closed (N of M stories) · day D of T · on a straight line Z h would be closed by now
     day 1: 0 · day 2: 8 h · day 3: 8 h · day 4: 18 h · …   (cumulative, one entry per day since the sprint start)
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
2. **Burn** (Phase 1 step 8): closed against planned, per day since the sprint start. Planned = the sum of `~Nh` over the sprint's stories (or their count); closed = the same sum over the stories Done, each counted on its close date; the per-day line is cumulative from day 1 (the sprint start) to today, `T` is the number of calendar days in the sprint. The straight-line expectation is `planned × D / T`. Closed behind that line by more than one day's share (`planned / T`) → a line under *Risk to the goal* (`burn: X h closed, Z h expected by day D`). No story Done yet on day 1 or 2 is not a risk. Stories without an estimate make it a count (`N of M stories`), never an invented number.
3. **Dependency PRs.** A dependency PR older than the sprint start, or any red one, is a line under *Risk to the goal* with `/sprint-plan` (its Phase 2) as the fix. Without `gh` the line reads `Dependency PRs: n/a (no gh)`.
4. **Agent lines** — the three counts are read differently:
   - The **non-studio count** is a fact: the name is in the line, so routing went around the roster and the specialist's rules, stack reference and memory were not in the room.
   - The **unclosed agents** are a lead, not a verdict: an agent started and never closed was cut off at its turn limit or is still running. The story it was given either came back half-done or was finished by the parent, so check the story results.
   - The **parent-write count** (`P code file(s) written by the session itself`) is a fact from the `parent-write` hook: product code or tests the parent wrote instead of a Tier-3 engineer, each file logged as `ParentWrite` in the audit log — a rule with no observer was broken on a real project, so the count is printed even when the stories are green.
   - Never report starts minus stops. `SubagentStart` fires on every resume of the same agent, so that difference counts resumes, not lost work.
   - Each of these three lines goes under *Risk to the goal* when it is not zero; for parent-write the line reads `parent-write: P file(s) — engineer rule bypassed (coordination-rules § Subagents)`.
5. **Discrepancies** on a separate line: "Done without a test/PR" for every story marked Done with no test or PR behind it. `sprint file ≠ roadmap: N rows` names the rows; the fix is `/retrospective` at close (it reconciles them), never an edit from here.
5a. **Sprint over and not closed**: a sprint that is `overdue`, or whose every roadmap line is `[x]` while its file is not `Status: closed`, is a line under *Risk to the goal*: `sprint NN is over and not closed — /retrospective NN`. A sprint file without a `Status:` line predates 0.13 and counts as closed only when its roadmap block is folded.
6. **Findings**: `Open BLOCKING findings: N (production/findings.md)`, naming the story per finding, or "no story".

Verdict: `ON TRACK` | `AT RISK` | `OFF TRACK` | `OVER (not closed)`.

Next step — one `AskUserQuestion`: `/dev-story <next story>` (Recommended) · `/help` · nothing now; when the sprint is over and not closed, `/retrospective NN` is the Recommended option instead.
