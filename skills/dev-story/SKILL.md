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

File writes and any mutation (git, deploy) happen only after an explicit "May I write?" / "Proceed?" → "yes", asked as an `AskUserQuestion` with the recommended action first and the real alternatives (coordination-rules, rule 7). After the "write" answer: `touch .claude/.write-consent` (rule 7).

```
/create-stories → /dev-story (this) → /code-review → /story-done
```

In the commands below, `<hooks>` is `.claude/hooks/` in copy mode and `${CLAUDE_PLUGIN_ROOT}/hooks/` in plugin mode; a studio agent is `web-studio:<name>` in plugin mode and `<name>` in copy mode.

## Phase 1: Story
1. **Context gate (rule 13).** When the statusline `ctx:` share is above 50 %, or this session has already closed a story, the story does not start here. Ask one `AskUserQuestion`: `/clear`, then `/web-studio:dev-story S-NNN` again (copy mode `/dev-story`) (Recommended) · continue in this session (the answer names why). Every subagent hand-back lands on top of the context the story starts with, so a story started at 450 k costs as much as three fresh ones.
2. **Pick the story.** The argument, else `Task:` in `production/session-state/active.md`, else ask. Its status must be Ready or In Progress.
3. **Sprint layer.** When no `production/sprints/sprint-*.md` covers this story and the backlog holds more than three Ready stories, say so in one line and add `/sprint-plan` to the options of the Phase 3 plan question (Recommended for the first story of a fresh backlog). Otherwise the sprint layer is reachable only by the owner's memory. With a covering sprint file, say nothing.

## Phase 2: Context (read everything before planning)
1. **Architecture prerequisites.** `docs/architecture/threat-model.md` and `docs/architecture/test-strategy.md` must exist. The catalog marks both `required`, and brownfield projects enter `build` with the architecture phase unwalked, so check them however the project got here. Either missing → verdict `BLOCKED (architecture prerequisites unmet — run /threat-model | /test-setup first)`, naming only the missing ones. Do not plan, branch or write anything, and do not loop a question about it.
2. **Read**: the story; the relevant sections of the feature spec; the contract (`schema.graphql` / openapi); ADRs; the data model; applicable `.claude/rules/*.md`; the stack reference for the story's languages; the test strategy. Note line ranges as you read, because the Phase 4 briefs need them.
3. **Missing inputs.** A story that changes the contract → run `/api-contract` first. A story that needs an ADR or a contract that does not exist → `BLOCKED`, naming the command to run.
4. **Scope creep goes to `/impact`.** When the user asks for something the story's acceptance criteria do not cover, or the implementation needs an unplanned dependency, contract, schema or security surface, do not absorb it into the story. Detour to `/impact <the request>` (rule 11), then return to the story (rule 7, hand-off after a detour).

## Phase 3: Plan and branch
1. **Mark the story's scope as reviewed.** `touch .claude/.impact-verdict`. The story already passed its spec and ADR gates, and this keeps the impact-guard hook quiet on the story's own architecture/security paths (rule 11).
2. **Build the plan table**, then render it in the chat message as a table (rule 7, readable rendering, on updates too). Columns: step · agent · files to create/change · criterion and test it serves. Rules for the steps:
   - A step is something one specialist can finish inside a subagent's turn budget (≤ 40 turns: read the brief's files, write, one test run). One specialist, one file cluster per step. A one-step plan called "implement the story" is how the parent ends up writing the story itself.
   - Every step names its agent, and the table says how many steps there are.
   - **Spikes.** When the plan needs a throwaway script to answer a question about a library, a timing or a format, the table gives it a home: `tools/spike-<slug>/` (gitignored) or the session scratchpad, and says Phase 6 deletes it. An unnamed spike lands in the repository root and rides into the commit.
3. **Ask one `AskUserQuestion`**: continue — branch `feat/S-NNN-slug` and start (Recommended) · change the plan (say what) · stop. Include `/sprint-plan` when Phase 1 step 3 flagged it. The "continue" answer is the consent for the branch, the state update, the story-card edit and the files named in the plan.
4. **Branch** per `.claude/docs/git-workflow.md`:
   1. `git fetch origin`.
   2. If the current branch is the default branch, or is already merged into `origin/<default>` (session-start prints "no commits beyond"; check with `git merge-base --is-ancestor HEAD origin/<default>`): `git switch <default> && git pull --ff-only origin <default>`. Never continue on a merged branch.
   3. `git switch -c feat/S-NNN-slug`.
5. **Record the start.**
   - Session state goes through the studio's writer, never a hand-built `sed` / `python3 -c` one-liner: `<hooks>session-state.sh set Task "S-NNN …" Branch feat/S-NNN-slug Next "/code-review"`. It keeps every template field, fills untouched ones with `—` and prints the result, so a failed write is visible instead of silent. If it refuses because it cannot round-trip the file, the project's `active.md` has grown into a working document. Leave it alone and suggest moving its durable parts into their own documents. Never force the writer.
   - On the story card's metadata line, write `Started: YYYY-MM-DDTHH:MM` with the actual time. `/story-done` measures the story's actual duration from it.

## Phase 4: Implementation (Task to the right engineers, by layer)
**The parent does not write product code.** Every file of the story is written by a specialist through `Task` with an explicit studio `subagent_type` (for example `web-studio:go-engineer`), not by the session running this skill. The specialists carry the stack reference, the layout contract and their own memory, and the audit log records who wrote what. (Observed: across four stories the implementing agent was spawned once, cut off without writing a line, and the parent wrote 687 lines itself. The stories passed; the rule did not.)

**One call per plan step**, independent steps in parallel, dependent ones in order (contract → backend → frontend). The result reports decisions, surprises and numbers, never the full diff; the parent reads the diff with `git diff`.

**The brief carries what the parent already knows.** Every `Task` prompt has these six lines, filled from Phase 2 and 3:
```
Story:  <story path> — criterion <n> (<one-line criterion>)
Read:   <file>:<start>-<end>, … (the files this step touches or depends on, with line ranges)
Write:  <files to create or change>
Check:  <exact commands to run before reporting>
Skip:   <what not to read or run: the full suite, the whole reference, unrelated packages>
Report: decisions, surprises, numbers, and a final `Checkpoint:` line (done · next · unverified)
```
Do not send a brief without line ranges in `Read:`. An agent that has to find its files spends half its budget on `grep`.

**Consent inside a step.** The Phase 3 answer covers the files the plan names. A specialist that needs to go beyond its brief (another file, a new dependency, a contract or schema change) stops and reports it. The parent then asks the user, or detours to `/impact` when it leaves the story (Phase 2 step 4). Subagents cannot ask the user themselves.

**When an agent is cut off** (`stopped at its N-turn limit`, a result that ends mid-sentence, a `SubagentStart` with no `Stop`):
1. Resume *that* agent. Do not spawn a second one on the same task. The resume message is one line: "continue from your `Checkpoint:`; run `git status` and the step's `Check:` yourself and report". Before sending it the parent runs **no** `git status`, build or test of its own. Each such check adds 5–20 k tokens to the parent's context (on one real day, 50 of 64 cut-offs were answered that way). The parent verifies once, after the `SubagentStop`.
2. Cut off twice: split what is left into smaller steps and spawn again.
3. Only after both have failed may the parent write the code itself. The story result then says so in one line, "written by the parent: <agent> cut off twice on <task>", because a rule broken silently gets broken again next story.

**Routing**
- Backend: `go-engineer` / `php-engineer` / `node-engineer`; GraphQL `graphql-engineer`; DB `database-engineer`.
  - Go under `go_architecture: layered`: the plan names the layer of every step, in the order domain → use case → infrastructure → composition root → transport for a vertical slice. A domain or use-case step includes its tests. The story result quotes the `coverage-gate` lines and the `golangci-lint` count. A story that would restructure existing packages is not a story: detour to `/refactor` (rule 11).
  - PHP under `php_architecture: layered`: the same step order by layer (domain → application → infrastructure → composition root → transport). Domain and application steps include their tests. The story result quotes the `coverage-gate:` lines and the deptrac violation count. A schema change is a migration file in the story, never DDL in a class.
- Frontend: `angular-engineer` / `vue-engineer`; styles `css-engineer`. On public pages of a content site (`Type: site`, SSR/SSG), `seo-specialist` reviews title/meta/canonical, structured data, sitemap and hreflang before the story closes; internal SPAs get no SEO review. User-facing copy with i18n keys: `accessibility-specialist` reviews the states and copy.
- Game: `threejs-engineer` / `web-game-engineer` / `multiplayer-engineer`.
- Tests: the engineers write their own; `test-engineer` handles e2e.

## Phase 5: Criteria check
1. **Who wrote the story.** Run `grep "SubagentStart" production/session-logs/agent-audit.log | tail -n <steps>` and compare the agents that ran against the agents the plan named. Name any step whose agent never started, or started and never stopped. Silence here is what let four stories in a row be written by the parent without anyone noticing.
2. **Criteria table**: criterion → test → result, with the command output. Name unmet criteria explicitly.
3. **Checks**: lint, typecheck, and a dependency audit when packages were added (health verified).

## Phase 6: Wrap-up, commit and CI
1. **Status.** Set the story status to `Review` and the session state to `Next: /code-review` (through `<hooks>session-state.sh`).
2. **Commit gate**, one `AskUserQuestion`: commit and push (Recommended) · commit only · not now (`git-workflow.md`, step "Implement").
3. **Stage by name.** Read `git status --short` first and deal with every unplanned `??` entry: delete the spike (its `tools/spike-<slug>/` or scratchpad files), add a file deliberately if it belongs to the story, otherwise leave it alone and name it. Then stage the story's files **by name**. Never use `git add -A`; that is how a spike, a scratch log or a stray `.bak` reaches the history.
4. `git commit -m "feat(S-NNN): <story title>"`, then `git push -u origin feat/S-NNN-slug`. Never commit on the default branch.
5. **Find out what starts CI** before waiting for anything. Read the triggers (`grep -l "pull_request" .github/workflows/*.yml` and each workflow's `on:`). A workflow with `on: pull_request` and no `push` trigger for this branch starts **nothing** on a bare push. When the PR is what starts the checks, open it as a draft in this step (`gh pr create --draft --fill`) so they run during review; `/story-done` marks it ready and merges it. Without `gh`, or with a push-triggered workflow, say which run to expect and its id.
6. **Wait for CI** only for a run that exists: one background `gh run watch <run-id> --exit-status`, as in `/story-done`. No polling `Monitor`, and no `AskUserQuestion` used as a pause. If the queue is slow, end the turn with a one-line status.

**Verdict**: `COMPLETE` | `PARTIAL (open: …)` | `BLOCKED`.

**Next step**, one `AskUserQuestion`, never a bare "run /code-review?": `/web-studio:code-review --diff <story-path>` (copy mode `/code-review --diff <story-path>`; in plugin mode the bare name is Claude Code's built-in review, see coordination-rules § Subagents) (Recommended on COMPLETE) · commit first (when step 2 was declined) · show the diff · stop here. Run the next skill only on that answer.
