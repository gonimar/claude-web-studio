---
name: story-done
description: "Verifies a story is truly done: every acceptance criterion has a passing test (with output), lint/typecheck/security checks pass, review is APPROVED, docs updated; then closes it and updates roadmap/session state. Run after /code-review."
argument-hint: "[story-path or S-NNN]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Edit, Write, Task, AskUserQuestion
model: sonnet
agent: qa-lead
---

# Story Done

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

File writes and any mutation (git, deploy) happen only after an explicit "May I write?" / "Proceed?" → "yes", asked as an `AskUserQuestion` with the recommended action first and the real alternatives (coordination-rules, rule 7). Consent is collected by this session, never by a subagent. After the "write" answer: `touch .claude/.write-consent` (rule 7).

In the commands below, `<hooks>` is `.claude/hooks/` in copy mode and `${CLAUDE_PLUGIN_ROOT}/hooks/` in plugin mode. **An open gate survives the next turn** (rule 7): before the close gate and the merge gate the skill records them — `<hooks>session-state.sh set Gate "/story-done Phase N: <question>"` — and clears the gate after the answer (`<hooks>session-state.sh set Gate "—"`), so a resumed session continues at that question instead of reading a new task from `Next:`.

**Waiting for CI** (Phases 3–5): one background command with a single completion notification — `gh run watch <run-id> --exit-status` (or `gh pr checks <n> --watch`) via Bash `run_in_background`. Never a polling `Monitor`, never `ScheduleWakeup`, and never an `AskUserQuestion` as a pause (rule 7: a question is a decision for the user, not a wait). If the runner queue exceeds ~10 minutes, say so in one line and end the turn; the notification resumes the skill. Wait only for a run that exists.

## Phase 1: Story and evidence
1. **Pick the story** (as `/dev-story` Phase 1): the argument (a story path or `S-NNN`), else `Task:` in `production/session-state/active.md`, else ask — one `AskUserQuestion` listing the stories in `Review` (the most recently started first, Recommended) · another story (say which) · stop. A story resolved from the session state is named in the first line of the report, so a stale `Task:` closes no wrong story. Its status must be `Review`, or `Done` with an open PR (the merge re-run of Phase 5); a `Ready` or `In Progress` story → `NOT DONE (story not in Review — run /dev-story S-NNN, then /code-review)`. One exception in the wording only: a `Ready`/`In Progress` story whose branch already carries a `feat(S-NNN)` commit (`git log origin/<default>..<branch> --oneline | grep 'S-NNN'`) and a PR (`gh pr list --head <branch>`) was implemented and never stamped — it is named as such, `NOT DONE (implemented but never set to Review — set it and re-run)`, and the status is not changed here.
2. **Read** the story, the feature-spec criteria, and the latest `/code-review` report (chat history, or `production/reviews/` if kept).

## Phase 2: Run
1. Run the tests from the criteria matrix and the whole affected package.
2. Run lint/typecheck; `govulncheck` / `audit` when dependencies changed.
3. For UI: axe on new pages (if e2e exists).
4. Put the output in the report. Anything red → `NOT DONE`.

## Phase 3: DoD checklist
Each item is ✅ or an open item named in the report.
1. **Criteria ↔ tests**: the criterion → test → result table **rendered in the chat message** (rule 7), not just written to the story file.
2. **The studio's review ran.** `grep -E 'SubagentStop \| (web-studio:)?([a-z-]+-(lead|engineer))' production/session-logs/agent-audit.log` shows a reviewer's Stop later than the branch's first commit. For a `security-sensitive` story (security rules for sensitive paths), `appsec-engineer` is among them. A review that exists only in the chat (Claude Code's built-in `/code-review`, a parent's own reading) is `NOT DONE (no studio review)`, naming the missing reviewer: the chat can claim an appsec review the log never recorded.
3. **Review APPROVED**: the reviewers' own verdict after the last fix (`/code-review` Phase 5), not the parent's summary of it.
4. **Findings recorded**: every `ARCH-NNN`/`SEC-NNN` named in the story card exists as a row in `production/findings.md` (`grep -c '<ID>' production/findings.md`). An ID with no row is an open DoD item, not a formality.
5. **Docs** (README/API/runbook) updated; contract and codegen in sync.
6. **Branch**: the story branch is pushed, with no uncommitted changes.
7. **CI green on the branch**: `gh run list --branch <branch>` when `gh` exists. A run in progress → wait (see above). No run at all because the workflows trigger on `pull_request` and no PR exists yet → name it; the PR opened in Phase 4 starts it, and Phase 5 waits for it before the merge question.

## Phase 4: Close
Only on `DONE`.
1. **Close gate**, one `AskUserQuestion`, recorded first as `Gate "/story-done Phase 4: close S-NNN?"` and cleared after the answer: "May I set the story status → Done, record the actual time, tick the roadmap, update the `## Docs` row, commit `docs: close S-NNN — Done, PR #N`, push it and open the PR if it does not exist yet (`gh pr create`)?" — close and open the PR (Recommended) · close without the PR · not now. This answer covers the close only, never the merge. The edits it covers:
   - **Actual time**: `⏱ Nh` on the roadmap line and `Actual:` in the card — wall-clock from the card's `Started:` line (written by `/dev-story` at branch time) to now, rounded to 0.5 h. No `Started:` → `⏱ ?` and one line naming the omission, never a guessed number.
   - **Roadmap line**: tick `[x]`, add `🔗 [PR #N](url)` inline (same rule as the ID: a file-relative link, not a `## Links` reference-definition), and refresh the `Updated:` line.
   - **`## Docs` → *production/stories/* block**: the story's row becomes `✅ … Done · PR #N`.
2. Before editing, count `grep -c "⏱" production/roadmap.md` and `grep -c "🔗 \[PR #" production/roadmap.md`.
3. After the "yes": `touch .claude/.write-consent`. Then **get the PR number before editing**, because the roadmap link, the `## Docs` row and the commit message all carry it:
   - a PR exists (the draft `/dev-story` opened, or one opened by hand) → `gh pr view --json number,url`;
   - no PR and the answer was "close and open the PR" → `gh pr create --fill` now (it needs only the pushed branch), then read its number and URL;
   - "close without the PR" → no PR number anywhere: the roadmap line gets no `🔗`, the `## Docs` row reads `✅ … Done`, the commit is `docs: close S-NNN — Done`.
   Then make the edits.
4. **Prove the edit instead of assuming it**: run the two counts again and re-read the story's row in the `## Docs` block. A story closed with a PR but without its `⏱` and `🔗 PR` in **both** places is an unfinished DoD item, printed as such in the report with the numbers quoted: an answer can carry numbers that never reached the file.
5. `git commit -m "docs: close S-NNN — Done, PR #N"` (without the PR: `docs: close S-NNN — Done`), then `git push`, so the PR carries the close commit.

## Phase 5: Merge (`.claude/docs/git-workflow.md`, step "Merge")
Only on `DONE` and only after Phase 4 is finished.
No PR ("close without the PR", or no `gh` and none opened by hand) → Phase 5 is skipped: say how to finish later — open the PR, then re-run `/story-done S-NNN`, which goes straight to the merge question for a story already Done.
1. **Wait for CI** on the PR's latest commit (see above). Red → `NOT DONE (CI red)`; nothing is merged. The Phase 4 close stays as it is — the story met its DoD on green CI in Phase 3, and a red run on the close commit is a new failure of the branch, not a reopened story. The report says so in one line ("closed, not merged: CI red on <commit>"); after the fix, re-running `/story-done S-NNN` goes straight to this phase.
2. **Merge gate**, a separate `AskUserQuestion`, recorded first as `Gate "/story-done Phase 5: merge PR #N?"` and cleared after the answer: "PR #N is open and CI is green. Merge it into `<default>` and delete the branch now?" — merge now (Recommended when CI is green) · leave the PR open.
3. "yes":
   1. A draft PR (opened by `/dev-story` Phase 6) → `gh pr ready <n>` first.
   2. `gh pr merge --merge --delete-branch` (`--squash` only when the project's CLAUDE.md says so).
   3. `git switch <default> && git pull --ff-only origin <default>`; delete the local story branch.
   4. Clear the session state with `<hooks>session-state.sh clear` (the same writer `/dev-story` used, so the file keeps its shape).
4. "no" (or no answer) → leave the PR open, keep `Branch:` in the session state, and say how to merge later: re-run `/story-done S-NNN` (a story already Done with an open PR goes straight to this question), or merge on GitHub and run `git switch <default> && git pull --ff-only origin <default>`.
5. Without `gh`: the same, by hand. `NOT DONE` → nothing is merged.

Verdict: `DONE` | `NOT DONE (reasons)`.

Next step — one `AskUserQuestion`:
- **`/clear`, then `/web-studio:dev-story S-NNN`** (copy mode `/dev-story S-NNN`) — the next story starts in a fresh session on the fresh default branch (Recommended). Name the statusline `ctx:` share when it is visible (rule 13: the parent's context is the studio's largest cost).
- `/web-studio:sprint-status`.
- stop here.

Continuing the next story in this session is an "Other" the user types, never an option offered.
