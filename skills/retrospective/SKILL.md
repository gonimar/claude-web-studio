---
name: retrospective
description: "Sprint retrospective from artefacts — planned vs shipped, estimate vs actual per story (the calibration ratio /sprint-plan applies to the next sprint), blockers and their causes, incidents and findings of the period, process actions with owners; writes the Retrospective section of the sprint file and carries the actions into the roadmap. Use at sprint end, before /sprint-plan for the next sprint."
argument-hint: "[sprint NN]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Write, Edit, AskUserQuestion
model: sonnet
---

# Retrospective

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

Template `sprint-plan.md` (`## Retrospective` section); roadmap markers `~Nh` (estimate) and `⏱ Nh` (actual, written
by `/story-done`) per `templates/roadmap.md`. Blameless: causes are in the system and the process, never in a person
or an agent by name. Writes only after "May I write?".

## Phase 1: Data
The sprint file (`production/sprints/sprint-NN.md`: goal, selected stories, capacity, dependency updates, actions
from the last retrospective), the roadmap lines of those stories (status, `~Nh`, `⏱ Nh`, `🔗 PR`), `gh pr list
--state merged` for the period, `production/findings.md` (findings opened/closed in the period), incidents and
hotfixes dated inside the sprint (`docs/ops/incidents/`, `hotfix/*` branches), `production/session-logs/compaction.log`
(how often context was lost), and the `Blocked:`/`Notes:` lines that stories or session-state recorded. Missing
`⏱` on a Done story → counted as "no actual" and named (it is `/story-done`'s job to record it).

## Phase 2: Analysis
Rendered in the chat as tables (rule 7):
1. **Planned vs shipped** — per story: planned · Done/carried over/cancelled · PR · `~Nh` · `⏱ Nh` · ratio.
   Sprint totals: Σ estimate, Σ actual, **calibration ratio** = Σ⏱ / Σ~ over the stories that have both (fewer than
   three such stories → "insufficient data, ratio not applied"). The ratio is what `/sprint-plan` uses to scale the
   next sprint's capacity; write it exactly as computed, never rounded to a nicer story.
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
(Recommended) · edit them · drop the retrospective.

## Phase 4: Write
"May I write the `## Retrospective` section into `production/sprints/sprint-NN.md` (ratio, tables, actions) and add
the accepted actions to `production/roadmap.md` (as stories or lines under Backlog with `🏷 process`)?" — one
`AskUserQuestion`: write (Recommended) · show the draft/diff first · not now. After the "write" answer: `touch
.claude/.write-consent` (rule 7 — the consent-guard hook checks the marker). Then one commit gate: `docs: retrospective
sprint NN` staging exactly the written files, on the default branch (documents lane of git-workflow).

Verdict: `COMPLETE (ratio R over N stories, M actions)` | `COMPLETE (insufficient data for the ratio)` | `BLOCKED (no
sprint file — run /sprint-plan NN first)`. Next step — one `AskUserQuestion`: `/sprint-plan NN+1` (Recommended) ·
`/sprint-status` · stop here.
