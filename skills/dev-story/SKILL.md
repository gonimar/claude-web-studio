---
name: dev-story
description: "Implements a story end-to-end: loads spec/contract/ADR/rules, routes to the right engineers (Go/PHP/Node/GraphQL/Angular/Vue/three.js/DB), drives code + tests, runs checks, confirms each acceptance criterion. The core implementation skill — run after stories exist, before /code-review and /story-done."
argument-hint: "[story-path or S-NNN]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, SendMessage, Skill, AskUserQuestion
---

# Dev Story

Conventions: coordination-rules § Skill conventions (language, paths, gates, commit gate, Skill tool, subagents, CI wait, next step). Through the `Skill` tool this skill runs `/impact` (Phase 2 step 4, Phase 4 step 5) and `/backlog add` (Phase 6 step 5); every other command is a closing hand-off. The parent writes no product code (Phase 4).

Writes and mutations (git, deploy) happen only after the "May I write `<path>`?" / "Proceed?" gate (§ Gates).

```
/create-stories → /dev-story (this) → /code-review → /story-done
```

## Phase 1: Story
1. **Context gate (rule 13).** Statusline `ctx:` above 50 %, or a story already closed in this session → the story does not start here. One `AskUserQuestion`: `/clear`, then `/web-studio:dev-story S-NNN` again (copy mode `/dev-story`) (Recommended) · continue here (the answer names why). Every subagent hand-back lands on top of the context the story starts with.
2. **Pick the story.** The argument, else `Task:` in `production/session-state/active.md`, else ask. Status Ready or In Progress; anything else → `BLOCKED (story S-NNN is <status> — Draft: run /create-stories | /sprint-plan; Review or Done: run /code-review | /story-done)`.
3. **Sprint layer.** No `production/sprints/sprint-*.md` covers the story and the backlog holds more than three Ready stories → say so in one line and add `/sprint-plan` to the Phase 3 plan question (Recommended for the first story of a fresh backlog); otherwise the sprint layer lives only in the owner's memory. With a covering sprint file, say nothing.

## Phase 2: Context (read everything before planning)
1. **Architecture prerequisites.** `docs/architecture/threat-model.md` and `docs/architecture/test-strategy.md` must exist (a brownfield project enters `build` with the architecture phase unwalked). Either missing → `BLOCKED (architecture prerequisites unmet — run /threat-model | /test-setup first)`, naming only the missing ones; plan, branch or write nothing, and do not loop a question about it.
2. **Read**: the story; the relevant sections of the feature spec; the contract (`schema.graphql` / openapi); ADRs; the data model; applicable `.claude/rules/*.md`; the stack reference for the story's languages; the test strategy. Note line ranges: the Phase 4 briefs need them.
3. **Missing inputs.** A story that changes the contract → `BLOCKED (contract change — run /api-contract first)`: a pipeline document with its own gates is not written mid-story; the story restarts once the contract is in. A story whose ADR or contract does not exist → `BLOCKED`, naming the command (`/architecture-decision` · `/api-contract`). In both cases nothing is planned, branched or written; the verdict names the command, not a question.
4. **Scope creep goes to `/impact`.** A request the acceptance criteria do not cover, or an unplanned dependency, contract, schema or security surface, is not absorbed into the story: detour to `/impact <the request>` through the `Skill` tool (`/web-studio:impact` in plugin mode; rule 11), quote its verdict and the commands it names in the story's chat, then return to the story (rule 7, hand-off after a detour: the pending `Next:` is never overwritten).
5. **CI on the default branch.** With `gh`: `gh run list --branch <default> --limit 1`. A red latest run is named now — job and run id, from the output — and the Phase 3 plan question gains `/hotfix --chore` (the toolchain lane). Not blocking: the fix is chore work, not story work. A green run adds nothing. Without `gh`, say in one line that the check was not possible.

## Phase 3: Plan and branch
1. **Mark the story's scope as reviewed.** `touch .claude/.impact-verdict`: the story passed its spec and ADR gates, so the impact-guard hook stays quiet on its architecture/security paths (rule 11).
2. **Build the plan table**, rendered in the chat as a table (rule 7, on updates too). Columns: step · agent · files to create/change · criterion and test it serves.
   - A step is what one specialist finishes inside a subagent's turn budget (≤ 40 turns: read the brief's files, write, one test run): one specialist, one file cluster. A one-step plan "implement the story" is how the parent ends up writing it.
   - Every step names its agent, and the table says how many steps there are. Agent per stack and layer, layered Go/PHP step order, the lines the story result quotes, the SEO/a11y review step and the `/refactor` hand-off: read `references/routing.md`.
   - **Spikes.** A throwaway script (a library, timing or format question) gets a home in the table — `tools/spike-<slug>/` (gitignored) or the session scratchpad — and Phase 6 deletes it; an unnamed spike lands in the repository root and rides into the commit.
3. **Ask one `AskUserQuestion`**: continue — branch `feat/S-NNN-slug` and start (Recommended) · change the plan (say what) · stop; plus `/sprint-plan` when Phase 1 step 3 flagged it, and `/web-studio:hotfix --chore` (copy mode `/hotfix --chore`) when Phase 2 step 5 named a red run. "Continue" is the consent for the branch, the state update, the story-card edit and the files the plan names (rule 7, delegated steps): `touch .claude/.write-consent` after it and again before each `Task` batch in Phase 4.
4. **Branch** per `.claude/docs/git-workflow.md`:
   1. `git fetch origin`.
   2. On the default branch, or on a branch already merged into `origin/<default>` (session-start prints "no commits beyond"; check with `git merge-base --is-ancestor HEAD origin/<default>`): `git switch <default> && git pull --ff-only origin <default>`. Never continue on a merged branch.
   3. `git switch -c feat/S-NNN-slug`.
5. **Record the start.**
   1. Session state only through the studio's writer, never a hand-built `sed` / `python3 -c` one-liner: `<hooks>session-state.sh set Task "S-NNN …" Branch feat/S-NNN-slug Next "/web-studio:code-review --diff <story-path>"` (copy mode `Next "/code-review --diff <story-path>"`). It keeps every template field, fills untouched ones with `—` and prints the result, so a failed write is visible.
   2. If it refuses because it cannot round-trip the file, `active.md` has grown into a working document: leave it alone, suggest moving its durable parts into their own documents, never force the writer.
   3. Story card metadata line: `Status: In Progress` and `Started: YYYY-MM-DDTHH:MM±HHMM` from `date +%FT%H:%M%z`, never typed from memory (`/story-done` subtracts it; a stamp without an offset cannot be subtracted).
   4. The card rides the story's `feat(S-NNN)` commit in Phase 6 (staged by name), so the stamp never lands on the default branch by itself.
   5. A story under a sprint's roadmap heading: its row in the `## Stories` table of `production/sprints/sprint-NN.md` → `In Progress`, one Edit; the sprint file rides the same commit. A Backlog story has no sprint row (sprints are optional).

## Phase 4: Implementation (Task to the right engineers, by layer)
1. **The parent does not write product code.** Every file of the story is written by a specialist through `Task` with an explicit studio `subagent_type` (e.g. `web-studio:go-engineer`), never by the session running this skill: specialists carry the stack reference, layout contract and memory, and the audit log records who wrote what.
2. **One call per plan step**, to the agent the plan named: independent steps in parallel, dependent ones in order (contract → backend → frontend). The result reports decisions, surprises and numbers, never the full diff — the parent reads it with `git diff`.
3. **The brief carries what the parent already knows** — six lines in every `Task` prompt, filled from Phase 2 and 3:
```
Story:  <story path> — criterion <n> (<one-line criterion>)
Read:   <file>:<start>-<end>, … (the files this step touches or depends on, with line ranges)
Write:  <files to create or change>
Check:  <exact commands to run before reporting>
Skip:   <what not to read or run: the full suite, the whole reference, unrelated packages>
Report: decisions, surprises, numbers, what you noticed "Outside the brief" (reported, not fixed), and a final `Checkpoint:` line (done · next · unverified)
```
4. No brief without line ranges in `Read:`: an agent that has to find its files spends half its budget on `grep`.
5. **Consent inside a step.** The Phase 3 answer covers the files the plan names. A specialist that needs more (another file, a new dependency, a contract or schema change) stops and reports; it cannot ask the user itself. The parent asks, or detours to `/impact` (Phase 2 step 4) — after the running `Task` batch has returned, never alongside it.
6. **When an agent is cut off** (`stopped at its N-turn limit`, a result that ends mid-sentence, a `SubagentStart` with no `Stop`): resume *that* agent, never a second one (§ Subagents) — one line with `SendMessage` to its id from the `Task` result: "continue from your `Checkpoint:`; run `git status` and the step's `Check:` yourself and report".
7. Before sending it, no `git status`, build or test by the parent — each adds 5–20 k tokens to its context. The parent verifies once, after the `SubagentStop`.
8. Cut off twice: split what is left into smaller steps and spawn again.
9. Only after both have failed may the parent write the code itself, and the story result says so in one line, "written by the parent: <agent> cut off twice on <task>" — a rule broken silently gets broken again next story.

## Phase 5: Criteria check
1. **Who wrote the story.** `grep "SubagentStart" production/session-logs/agent-audit.log | tail -n <steps>`, compared against the agents the plan named; name any step whose agent never started, or started and never stopped — silence here is how a parent-written story goes unnoticed.
2. **Criteria table**: criterion → test → result, with the command output. Name unmet criteria explicitly.
3. **Checks**: lint, typecheck, and a dependency audit when packages were added (health verified).
4. **Outside the brief.** Collect the items the specialists reported under that heading and list them in the story result under *Outside the brief*. Nothing is fixed here; Phase 6 step 5 records each — an item neither listed nor recorded is gone at `SubagentStop`.

## Phase 6: Wrap-up, commit and CI
1. **Status.** Story status `Review`; session state `Next "/web-studio:code-review --diff <story-path>"` (copy mode `Next "/code-review --diff <story-path>"`) through `<hooks>session-state.sh set`.
2. **Commit gate**, one `AskUserQuestion`, recorded first as `Gate "/dev-story Phase 6: commit and push?"` and cleared after the answer (§ Gates): commit and push (Recommended) · commit only (step 4 without the push; no steps 6–7) · not now (no steps 3–4, 6–7) (`git-workflow.md`, step "Implement").
3. **Stage by name.**
   1. `git status --short` first; deal with every unplanned `??` entry: delete the spike (its `tools/spike-<slug>/` or scratchpad files), add a file deliberately if it belongs to the story, otherwise leave it alone and name it.
   2. Stage the story's files **by name**, and `.claude/agent-memory/` as one deliberate entry (`git add .claude/agent-memory`): the agents' notes change with every run and belong to the commit that produced them (git-workflow § Agent memory).
   3. Never `git add -A`: that is how a spike, a scratch log or a stray `.bak` reaches the history.
4. `git commit -m "feat(S-NNN): <story title>"`, then `git push -u origin feat/S-NNN-slug`. Never commit on the default branch.
5. **Record what was outside the brief** (Phase 5 step 4) right after step 4 and before any CI wait — a slow queue ends the turn at step 7, and an item not yet recorded is gone. Per plain item `/backlog add "<item>"` through the `Skill` tool (`/web-studio:backlog add` in plugin mode), one after another, each behind `/backlog`'s own gates. A security-relevant item: read `references/findings-mid-story.md` and follow it — a `production/findings.md` row behind "May I write `production/findings.md`?" and its `docs: findings <ID>` commit gate.
6. **Find out what starts CI** (§ CI wait): `grep -l "pull_request" .github/workflows/*.yml` and each workflow's `on:`. When the PR is what starts the checks, open it as a draft now (`gh pr create --draft --fill`); `/story-done` marks it ready and merges it. Without `gh`, or with a push-triggered workflow, say which run to expect and its id.
7. **Wait for CI** only for a run that exists: one background `gh run watch <run-id> --exit-status` (§ CI wait).

**Verdict**: `COMPLETE` | `PARTIAL (open: …)` | `BLOCKED`.

**Next step**, one `AskUserQuestion`, never a bare "run /code-review?" (§ Verdict and next step): `/web-studio:code-review --diff <story-path>` (copy mode `/code-review --diff <story-path>`) (Recommended on COMPLETE) · commit first (when step 2 was declined) · show the diff · stop here. Run the next skill only on that answer.
