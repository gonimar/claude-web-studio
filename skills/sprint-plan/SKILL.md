---
name: sprint-plan
description: "Plans a sprint — goal, capacity, story selection by priority and dependencies, risks, QA plan link; triages the dependency-update queue (Dependabot/Renovate PRs: green patch/minor merged at sprint start, majors become stories); writes production/sprints/sprint-NN.md and roadmap markers. Use at sprint start."
argument-hint: "[sprint number] [--days N]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Write, Edit, AskUserQuestion
model: sonnet
agent: product-director
---

# Sprint Plan

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

Template `sprint-plan.md`.

## Phase 1: State
Ready stories (`production/stories/**`), the roadmap (priority/blocker markers), the last sprint (unfinished work, retro actions), `production/findings.md` (open BLOCKING findings and their stories), the dependency-update queue (Phase 2), capacity (ask: days, hours per day).

## Phase 2: Dependency queue
Only when `gh` exists and the repository has `.github/dependabot.yml` or `renovate.json`; otherwise one line ("no update bot configured — `/dependency-audit` sets one up") and on to Phase 3. `gh pr list --state open --author app/dependabot --json number,title,createdAt,mergeable,statusCheckRollup` (Renovate: `--author app/renovate`). Classify every PR from the command output, never from memory or the title alone:
- **green and safe** — `mergeable: MERGEABLE`, every check `SUCCESS` or `SKIPPED`, and the bump is a patch/minor of a library or any CI-action bump — a merge candidate at sprint start, not a story;
- **major** — the first version component changes in the title (`from 4.2.2 to 7.0.1`) or the PR body names a breaking change — a story (`chore(deps)`, size S/M, layer from the manifest's directory) or deferred with a written reason in the plan; never merged here;
- **red or conflicting** — a failing check or `CONFLICTING` — stays open, named under risks, never merged.
Show the queue as a table (number · package · bump · checks · class · action). One `AskUserQuestion`: merge the green safe PRs now (Recommended) · turn them into one story · leave them. On "merge": `gh pr merge <n> --squash` one PR at a time with the output in the message; after the batch the default branch's CI run is the gate — `gh run list --branch <default> --limit 1` must be green before the first story branch starts. An empty queue is one line. A major bump is either a story in the sprint or deferred with a written reason — never left open unmentioned (`tooling-devops.md` §Renovate/Dependabot).

## Phase 3: Selection
The sprint goal as one verifiable statement. Stories by priority and dependencies within capacity (20 % buffer); first the one that removes the biggest risk. Blockers and external dependencies explicit. An open BLOCKING finding is either in the sprint (its story) or deferred with a written reason in the plan — never absent. Stories born from major bumps compete on priority like any other; one that unblocks the toolchain or the runner (a Node 24 action, a new Go toolchain) goes before the stories that need it.

## Phase 4: Write
Show the plan; "May I write `production/sprints/sprint-NN.md` and update the roadmap?" (roadmap per `templates/roadmap.md`: move the selected stories under a `## Sprint NN (YYYY-MM-DD → YYYY-MM-DD) — goal` subheading — the sprint is the heading, never a `📅 sprint-NN` marker; `📅` carries ISO dates only; mark the active story ⏳, the first one 🔥; markers inline in the legend's order, IDs as inline links, no prose ordering; refresh the `Updated:` line; when this closes the *previous* sprint — every one of its stories now `[x]` — wrap that sprint's list in `<details><summary>closed · N stories — expand</summary>` (blank line after `<summary>` or GitHub won't render the list inside); add a row to the roadmap's `## Docs` → *production/sprints/* block for the new sprint; the plan's `## Dependency updates` section lists what was merged, which majors became stories, what was deferred and why, what stays open red) — one `AskUserQuestion`: write (Recommended) · show the draft/diff first · not now. Propose `/qa-plan NN`.

Verdict: `READY`. Next step — one `AskUserQuestion`: `/qa-plan` (Recommended) · `/dev-story` directly · revise the sprint.
