---
name: sprint-plan
description: "Plans a sprint — goal, capacity, story selection by priority and dependencies, risks, QA plan link; writes production/sprints/sprint-NN.md and roadmap markers. Use at sprint start."
argument-hint: "[sprint number] [--days N]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion
model: sonnet
agent: product-director
---

# Sprint Plan

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

Template `sprint-plan.md`.

## Phase 1: State
Ready stories (`production/stories/**`), the roadmap (priority/blocker markers), the last sprint (unfinished work, retro actions), `production/findings.md` (open BLOCKING findings and their stories), capacity (ask: days, hours per day).

## Phase 2: Selection
The sprint goal as one verifiable statement. Stories by priority and dependencies within capacity (20 % buffer); first the one that removes the biggest risk. Blockers and external dependencies explicit. An open BLOCKING finding is either in the sprint (its story) or deferred with a written reason in the plan — never absent.

## Phase 3: Write
Show the plan; "May I write `production/sprints/sprint-NN.md` and update the roadmap?" (roadmap per `templates/roadmap.md`: move the selected stories under a `## Sprint NN (YYYY-MM-DD → YYYY-MM-DD) — goal` subheading — the sprint is the heading, never a `📅 sprint-NN` marker; `📅` carries ISO dates only; mark the active story ⏳, the first one 🔥; markers inline in the legend's order, IDs as inline links, no prose ordering; refresh the `Updated:` line; when this closes the *previous* sprint — every one of its stories now `[x]` — wrap that sprint's list in `<details><summary>closed · N stories — expand</summary>` (blank line after `<summary>` or GitHub won't render the list inside); add a row to the roadmap's `## Docs` → *production/sprints/* block for the new sprint) — one `AskUserQuestion`: write (Recommended) · show the draft/diff first · not now. Propose `/qa-plan NN`.

Verdict: `READY`. Next step — one `AskUserQuestion`: `/qa-plan` (Recommended) · `/dev-story` directly · revise the sprint.
