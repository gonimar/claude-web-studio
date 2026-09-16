---
name: dev-story
description: "Implements a story end-to-end: loads spec/contract/ADR/rules, routes to the right engineers (Go/PHP/Node/GraphQL/Angular/Vue/three.js/DB), drives code + tests, runs checks, confirms each acceptance criterion. The core implementation skill — run after stories exist, before /code-review and /story-done."
argument-hint: "[story-path or S-NNN]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, AskUserQuestion
model: sonnet
---

# Dev Story

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

File writes and any mutation (git, deploy) happen only after an explicit "May I write?" / "Proceed?" → "yes", asked as an `AskUserQuestion` with the recommended action first and the real alternatives (coordination-rules, rule 7); delegated agents follow the same protocol. After the "write" answer: `touch .claude/.write-consent` (rule 7).

```
/create-stories → /dev-story (this) → /code-review → /story-done
```

## Phase 1: Story
Argument or `production/session-state/active.md` (`Task:`); none — ask. Status must be Ready/In Progress.
No `production/sprints/sprint-*.md` covers this story while the backlog holds more than three Ready
stories → say so before the plan question and include `/sprint-plan` in its options (Recommended for
the first story of a fresh backlog): the sprint layer must not be reachable only by the owner's memory.

## Phase 2: Context (read everything before starting)
**Architecture prerequisites first** — regardless of how the project entered `build` (brownfield
projects start there with the architecture phase unwalked): `docs/architecture/threat-model.md` and
`docs/architecture/test-strategy.md` must exist — the catalog marks both `required`. Either missing →
`BLOCKED (architecture prerequisites unmet — run /threat-model | /test-setup first)`; name only the
missing ones, never loop a question about it. Then read: the story; the feature spec (relevant
sections); the contract (`schema.graphql`/openapi) — if the story changes the contract, run
`/api-contract` first; ADRs; the data model; applicable `.claude/rules/*.md`; the stack reference for
the story's languages; the test strategy. A missing ADR/contract for a story that needs one →
`BLOCKED` naming what to run. A request that leaves the story's acceptance criteria — the user asks
for something the story does not cover, or the implementation needs an unplanned dependency,
contract, schema or security surface — is not absorbed into the story: detour to `/impact <the
request>` (rule 11) and return to the story afterwards (rule 7, hand-off after a detour).

## Phase 3: Plan and branch
The story's scope passed its spec and ADR gates: `touch .claude/.impact-verdict` at story start, so the impact-guard hook stays silent on the story's own architecture/security paths (rule 11).
Files to create/change, order, tests per criterion — **the table rendered in the chat message** before the plan question. The plan is divided into steps an agent can finish inside its turn budget — one specialist, one file cluster per step — and the table says how many steps and which agent takes each; a plan of one step called "implement the story" is how a story ends up written by the parent. When the plan needs a spike — a throwaway script that answers a question about a library, a timing, a format — the table says where it lives: `tools/spike-<slug>/` (gitignored) or the session's scratchpad, and that Phase 6 deletes it. A spike has no other home: unnamed, it lands in the repository root and rides into the commit (rule 7: readable rendering, on updates too). Branch per `.claude/docs/git-workflow.md`: `git fetch origin`; if the current branch is the default branch or is already merged into `origin/<default>` (session-start prints "no commits beyond"), `git switch <default> && git pull --ff-only`; then `git switch -c feat/S-NNN-slug` — with consent. Never continue on a merged branch. Update the session state with the studio's writer, never with a hand-built `sed`/`python3 -c` one-liner — `hooks/session-state.sh set Task "S-NNN …" Branch feat/S-NNN-slug Next "/code-review"` (`.claude/hooks/` in copy mode, `${CLAUDE_PLUGIN_ROOT}/hooks/` in plugin mode). It refuses to touch a state file it cannot round-trip — a project whose `active.md` grew into a working document keeps it, and the answer is to move its durable parts to their own documents, never to force the writer through. It keeps every field of the template, fills the untouched ones with `—` and prints the result, so a failed write is visible instead of silent — quoting one-liners inside double quotes is how the file used to be updated, and a broken quote left it unchanged with nobody the wiser and write `Started: YYYY-MM-DDTHH:MM` into the story card's metadata line (the actual time `/story-done` records is measured from it). Show the plan, then one `AskUserQuestion`: continue (Recommended) · change the plan (say what) · stop.

## Phase 4: Implementation (via Task to the right engineers, by layer)
**The parent does not write product code.** Every file of the story is written by a specialist through `Task` with an explicit `subagent_type` (`web-studio:go-engineer` in plugin mode, `go-engineer` in copy mode) — not by the session running this skill. This is the rule the pipeline rests on: the specialists carry the stack reference, the layout contract and their own memory, and the audit log records who wrote what. Observed failure: across four stories the implementing agent was spawned **once**, was cut off at its turn limit without writing a line, and the parent wrote 687 lines itself — the story passed, the rule did not.
One call = one layer or one file cluster, sized to a subagent's turn budget; the result reports decisions, surprises and numbers, never the full diff (the parent reads it with `git diff`).
**When an agent is cut off** (`stopped at its N-turn limit`, a result that ends mid-sentence, a `SubagentStart` with no `Stop`): resume *that* agent with the point it stopped at, never spawn a second one on the same task. Cut off twice: split what is left into smaller calls and spawn again. Only after both have failed may the parent write the code itself — and then the story result says so in one line ("written by the parent: <agent> cut off twice on <task>"), because a rule broken silently is a rule that will be broken again next story.
- Backend: `go-engineer` / `php-engineer` / `node-engineer`; GraphQL — `graphql-engineer`; DB — `database-engineer`.
- Frontend: `angular-engineer` / `vue-engineer`; styles — `css-engineer`; public pages of a content site (`Type: site`, SSR/SSG) — `seo-specialist` reviews title/meta/canonical, structured data, sitemap and hreflang before the story closes; user-facing copy with i18n keys — `accessibility-specialist` for the states and copy.
- Game: `threejs-engineer` / `web-game-engineer` / `multiplayer-engineer`.
- Tests: the engineers themselves plus `test-engineer` for e2e.
Each gets the story context and the rule: show code before writing (the user approves), then run tests/lint with output.
Independent layers in parallel; dependent ones sequentially (contract → backend → frontend).

## Phase 5: Criteria check
Who wrote this story is part of the report: `grep "SubagentStart" production/session-logs/agent-audit.log | tail -n <steps>` — the agents that ran, against the agents the plan named. A step whose agent never started, or started and never stopped, is named in the result; silence there is what let four stories in a row be written by the parent without anyone noticing.
Table "criterion → test → result (output)". Unmet ones explicitly. Lint/typecheck/dependency audit (if packages were added — health verified).

**Waiting for CI** after the push: as in `/story-done` — one background `gh run watch <run-id> --exit-status`, no polling `Monitor`, no `AskUserQuestion` as a pause; end the turn with a one-line status if the queue is slow.

## Phase 6: Wrap-up and commit
Update the story status (`Review`), session state (`Next: /code-review`). Then, with consent as one `AskUserQuestion` — commit and push (Recommended) · commit only · not now (`git-workflow.md`, step "Implement"): stage the story's files **by name** — never `git add -A`, which is how a spike, a scratch log and a stray `.bak` reach the history — after reading `git status --short` and naming any unplanned `??` entry (deleted if it is the spike, added deliberately if it belongs to the story, left alone otherwise), `git commit -m "feat(S-NNN): <story title>"`, `git push -u origin feat/S-NNN-slug`. Never commit on the default branch.
Then check what actually triggers CI before waiting for it: a workflow with `on: pull_request` and no `push` trigger for this branch starts **nothing** on a bare push, and a session that waits for that run waits for something that was never queued. Read the triggers (`grep -l "pull_request" .github/workflows/*.yml`) and, when the PR is what starts them, open it as a draft in the same step — `gh pr create --draft --fill` — so the checks run while the review happens; `/story-done` turns the draft ready and merges it. With no `gh`, or with a push-triggered workflow, say which run to expect and its id.

Verdict: `COMPLETE` | `PARTIAL (open: …)` | `BLOCKED`. Next step — one `AskUserQuestion`, never a bare "run /code-review?": `/code-review --diff <story-path>` (Recommended on COMPLETE) · commit first (when Phase 6 was declined) · show the diff · stop here. Run the next skill only on that answer.
