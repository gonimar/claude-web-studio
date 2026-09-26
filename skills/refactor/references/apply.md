# /refactor — Phases 5–7 step 1 (`--apply S-NNN` only)

Read from `SKILL.md` Phase 5. `<engineer>`, `<hooks>`, `<default>` and the namespaces are the ones SKILL.md
and `docs/coordination-rules.md` § Skill conventions define; gates, the `Skill` tool, subagents and the
CI wait follow that section. Phase 2's table is the "before" column of Phase 6.

## Phase 5: Apply
1. **Story check.**
   1. The story must be `Ready` or `In Progress` (a re-run after step 4 stamped the card finds it `In Progress` and is accepted the same way) and reference a plan document; otherwise `BLOCKED (no plan — run /refactor --dry-run first)`.
   2. For a `framework` plan, the step-1 ADR must be `Accepted`; otherwise `BLOCKED (ADR not Accepted — /architecture-decision)`.
2. **Consent** — the gate for every commit of the apply.
   1. Record it: `<hooks>session-state.sh set Gate "/refactor Phase 5: start S-NNN?"`.
   2. One `AskUserQuestion`: start — branch `refactor/S-NNN-<slug>`, update the session state, stamp the story card, then run the plan's steps with one commit per green step (Recommended) · show the plan first · stop.
   3. Clear the gate after the answer (`<hooks>session-state.sh set Gate "—"`).
   4. The "start" answer is the "May I write?" consent for the branch, the session state, the story card's two status stamps and their `docs:` commits (step 4 and Phase 7 step 1), the step commits and the files the plan names; anything beyond those files comes back to the parent, which asks (step 5.3).
   5. `touch .claude/.write-consent` after the answer, and again before each step's `Task` call.
3. **Branch** per `git-workflow.md` ("Refactor" lane), from an up-to-date default branch:
   1. `git fetch origin`.
   2. `git switch <default> && git pull --ff-only origin <default>`.
   3. `git switch -c refactor/S-NNN-<slug>`.
4. **Record the start** — before the first `Task` to an engineer.
   1. Session state through the studio's writer, never a hand-built one-liner: `<hooks>session-state.sh set Task "S-NNN …" Branch refactor/S-NNN-<slug> Next "/web-studio:code-review --diff <story-path>"` (copy mode `Next "/code-review --diff <story-path>"`).
   2. On the story card's metadata line, set `Status: In Progress` and write `Started: <date +%FT%H:%M%z>` (the offset included: `/story-done` measures the actual duration from it in the same clock instead of `git reflog`).
   3. When a sprint's roadmap heading holds the story, its row in that sprint file's `## Stories` table (`production/sprints/sprint-NN.md`) → `In Progress`, one Edit of the row. A story taken from the Backlog has no sprint row (sprints are optional).
   4. Commit the card (and the sprint file when its row changed) at once, on the refactor branch: `git commit -m "docs: refactor S-NNN — In Progress"` staging exactly those files. Step commits stage their files by name, so the card never rides a `refactor(S-NNN)` commit and never lingers uncommitted through a `git restore` of a red step.
5. **Run the plan step by step.** For each step:
   1. `Task` to `<engineer>` with the step's row and the rule "move, do not improve — the diff of a refactoring step contains no new behaviour".
   2. The engineer cannot ask the user: a step that needs a file outside its row, or would change behaviour, stops and reports.
   3. A file outside the row → the parent asks the user, one `AskUserQuestion`.
   4. A behaviour change → once that `Task` has returned, `/impact <the change>` through the `Skill` tool (`/web-studio:impact` in plugin mode, `/impact` in copy mode); quote its verdict; continue or amend the step (rule 7, hand-off after a detour; `Next:` stays the code-review line of step 4.1).
   5. After the step, the parent runs the check: Go `go build ./... && go test -race -count=1 ./...` (and the gate/`arch-check` once installed); PHP `composer ci` (the local chain, no network).
   6. Green → `git commit -m "refactor(S-NNN): <step>"`, staging the step's files by name plus `.claude/agent-memory/` (the engineer's notes ride the step that produced them, git-workflow § Agent memory).
   7. Red → the same agent fixes it in the same step, or the step is reverted (`git restore` of its changed files, the files it created removed) and the plan is amended. Never a red commit, and never a second agent on the same step.
   8. A cut-off agent is resumed with its `Checkpoint:`, never replaced by a second one (§ Subagents).
6. **Who wrote it.** The parent writes no code; the story result says who wrote each step, from `production/session-logs/agent-audit.log`.

## Phase 6: Verification by numbers (`--apply` only)
The Phase 2 table again, side by side: before · after · rule. Required for `COMPLETE`:
- build, vet and lint clean;
- every test that existed still exists and passes (count not lower);
- coverage per layer not lower, and at or above the thresholds where a gate exists;
- `depguard`/`arch-check` (Go) or `deptrac` (PHP) clean;
- layout numbers within the contract;
- public API of `pkg/` unchanged: `go list ./pkg/... | xargs -n1 go doc -all` diffed against `$TMPDIR/refactor-<scope>-pkgapi.txt` (the Phase 2 baseline);
- no new dependency in `go.mod` / `composer.json` beyond the tooling the plan named.

A metric that moved the wrong way is a `PARTIAL (…)` with the metric named.

## Phase 7 step 1: after an apply, in this order
1. **Story status → `Review`.**
   1. Set `Status: Review` on the story card and session state `Next: /web-studio:code-review --diff <story-path>` (copy mode `/code-review --diff <story-path>`) through `<hooks>session-state.sh`.
   2. One more `docs:` commit on the refactor branch: `git commit -m "docs: refactor S-NNN — Review"` staging exactly the story card. This commit carries the status change — never the last step commit, whose diff stays the move and the engineer's memory notes.
   3. It comes before the push so the PR carries it. The Phase 5 "start" answer covers it.
2. **Push** with consent.
   1. Record `Gate "/refactor Phase 7: push?"`.
   2. One `AskUserQuestion`: push (Recommended) · not now. Clear the gate after the answer.
   3. `git push -u origin refactor/S-NNN-<slug>`. "Not now" → the report says the branch is local and the status commit is on it.
3. **Find out what starts CI** before waiting for anything: `grep -l "pull_request" .github/workflows/*.yml` and each workflow's `on:`. When the PR is what starts the checks, open it as a draft now (`gh pr create --draft --fill`); `/story-done` marks it ready and merges it. Without `gh`, or with a push-triggered workflow, say which run to expect and its id.
4. **Wait for CI** only for a run that exists: one background `gh run watch <run-id> --exit-status` (§ Skill conventions → CI wait: no polling, no `AskUserQuestion` as a pause, a slow queue ends the turn with one status line). A red run is named in the report and the verdict is `PARTIAL (open: CI red on <commit>)`.

Continue with SKILL.md Phase 7 step 2 (verdict) and step 3 (next step).
