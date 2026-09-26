---
name: retrospective
description: "Sprint retrospective from artefacts — planned vs shipped, estimate vs actual per story (the calibration ratio /sprint-plan applies to the next sprint), blockers and their causes, incidents and findings of the period, process actions with owners; writes the Retrospective section of the sprint file, carries the actions into the roadmap and closes the sprint (unfinished stories back to the Backlog, the block folded, Status: closed). The only command that closes a sprint. Use at sprint end, before /sprint-plan for the next sprint."
argument-hint: "[sprint NN]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Write, Edit, AskUserQuestion
model: sonnet
---

# Retrospective

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

Template `.claude/docs/templates/sprint-plan.md` (`## Retrospective` section); roadmap markers `~Nh` (estimate) and
`⏱ Nh` (actual, written by `/story-done`) per `.claude/docs/templates/roadmap.md`. Blameless: causes are in the system
and the process, never in a person or an agent by name. Writes only after "May I write?". In the commands below, `<hooks>` is `.claude/hooks/` in copy mode and `${CLAUDE_PLUGIN_ROOT}/hooks/` in plugin mode.

**This command closes the sprint.** Nothing else does: `/sprint-plan` refuses to plan the next sprint while this one is
open, `/story-done` hands off here after the last story, `/help` prints an `Attention:` for an overdue sprint. A sprint
with a retrospective section and no `Status: closed` stayed open for weeks on two projects, and the folding of its block
happened by hand or as a side effect of the next plan. A story still `⏳` is carried over like any other unfinished one —
the retrospective is the end of the sprint by definition; when the user means a mid-sprint check, say so in one line and
name `/sprint-status` instead of running Phase 2.

## Phase 1: Data
1. **Pick the sprint**: `sprint NN` from the argument, else the latest `production/sprints/sprint-*.md`. No sprint file
   → `BLOCKED (no sprint file — run /sprint-plan NN first)`, nothing written.
2. **Read**:
   - the sprint file (`production/sprints/sprint-NN.md`): goal, selected stories, capacity, dependency updates,
     actions from the last retrospective;
   - the roadmap lines of those stories (status, `~Nh`, `⏱ Nh`, `🔗 PR`);
   - `gh pr list --state merged` for the period;
   - `production/findings.md` (findings opened/closed in the period);
   - incidents and hotfixes dated inside the sprint (`docs/ops/incidents/`, `hotfix/*` branches);
   - `production/session-logs/compaction.log` (how often context was lost);
   - the `Blocked:`/`Notes:` lines that stories or session-state recorded.
3. **Missing actuals.** A Done story without `⏱` is counted as "no actual" and named: recording it is `/story-done`'s
   job.
4. **Sprint file vs roadmap.** The sprint file's `## Stories` table against the roadmap's sprint block, row by row: a row
   whose status differs is drift — counted, printed as `sprint file ≠ roadmap: N rows` and reconciled from the roadmap
   in Phase 4 (the roadmap is the source; `/story-done` keeps the two in step since 0.13, older sprints drifted on every
   project).

## Phase 2: Analysis
Rendered in the chat as tables (rule 7):
1. **Planned vs shipped** — per story: planned · Done/carried over/cancelled · PR · `~Nh` · `⏱ Nh` · ratio.
   Sprint totals: Σ estimate, Σ actual, and **two ratios that are never merged into one number**: this sprint's
   (Σ⏱ / Σ~ over its own stories, labelled "this sprint") and the **rolling calibration ratio** over the last six
   closed stories of the roadmap carrying both numbers, labelled "rolling, used by /sprint-plan" — the same sample
   `/sprint-plan` reads, so the two skills never quote different numbers under the same name (fewer than three
   stories in the rolling sample → "insufficient data, ratio not applied"). Write both exactly as computed, never
   rounded to a nicer story.
2. **Goal** — met / partially / not, with the evidence (the verifiable statement from the plan against what exists).
3. **What slowed us** — carried-over stories with the recorded cause (blocked by …, spec gap, red CI, dependency,
   context lost N times), findings and incidents of the period, actions from the previous retrospective that were
   not done.
4. **What worked** — one line each, only with evidence.

## Phase 3: Actions
Each action: what · owner (the user, or the command that will do it: `/feature-spec`, `/test-setup`, a rule in
`CLAUDE.md`, a story) · where it lands (roadmap line, story card, sprint file, `CLAUDE.md`, a studio issue when the
cause is a skill or hook — with the evidence a `/skill-test spec` could check) · due date. At most five; an action
without an owner and a place is not an action. Show the list, then one `AskUserQuestion`: accept the actions
(Recommended) · edit them · drop the retrospective. This question is its own message, before the write gate.

## Phase 4: Write and close
1. Render the `## Retrospective` section (ratios, tables, accepted actions), the roadmap lines and **what the close will
   do** (rule 7): the carried-over stories by ID and where each goes, the cancelled ones, the folded block's summary
   line, the drift rows being reconciled.
2. "May I write the `## Retrospective` section into `production/sprints/sprint-NN.md` (ratio, tables, actions), add
   the accepted actions to `production/roadmap.md` (as stories or lines under Backlog with `🏷 process`) and **close
   sprint NN**?" — one `AskUserQuestion`: write and close (Recommended) · show the draft/diff first · not now.
3. After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker), then
   write the section and the actions.
4. **Close the sprint**, per `templates/roadmap.md` and `templates/sprint-plan.md`:
   - every unfinished story under the sprint heading (`- [ ]`, with or without `⏳`) **moves** to the Backlog block with
     its line unchanged (markers, `🔥`, `⛔` kept — `/sprint-plan` reads them there), and is removed from the sprint block
     in the same edit; a cancelled story stays in the block as `[x] … ❌` (done lines are never deleted); no new marker is
     invented for "carried over" — the format is v3.1 and stays v3.1;
   - the sprint block is wrapped in `<details><summary>closed · N stories · K carried over · ~Σh → ⏱ Σh — expand</summary>`
     (blank line after `<summary>` or GitHub won't render the list; `K carried over` omitted when zero);
   - the sprint file: header `Status: closed YYYY-MM-DD`; every `## Stories` row set from the roadmap — `Done · ⏱ Nh · PR #N`,
     `carried over → Backlog`, `cancelled`;
   - the roadmap's `## Docs` → *production/sprints/* row of the sprint reads `✅ … N Done · K carried over · [qa-plan-NN]`
     and the block's `<summary>` count (`sprints: N closed`) is recalculated; the `Updated:` line refreshed.
5. **Close the write with the numbers**, re-read from the files, not from the plan: `Sprint NN: S stories → N done,
   K carried over, C cancelled; Backlog: M → M+K; sprint file rows reconciled: R`.
6. One commit gate: `docs: retrospective sprint NN — closed` staging exactly the written files, on the default branch
   (documents lane of git-workflow; when HEAD is a story branch, say so and ask as that lane prescribes). Record the gate
   before asking — `<hooks>session-state.sh set Gate "/retrospective Phase 4: commit?"` — and clear it after the answer
   (`<hooks>session-state.sh set Gate "—"`).

Verdict: `COMPLETE (sprint NN closed · ratio R over N stories · M actions · K carried over)` | `COMPLETE (sprint NN
closed · insufficient data for the ratio)` | `BLOCKED (no sprint file — run /sprint-plan NN first)`. Next step — one `AskUserQuestion`: `/sprint-plan NN+1` (Recommended) ·
`/sprint-status` · stop here.
