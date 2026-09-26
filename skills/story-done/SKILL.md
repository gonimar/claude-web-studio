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

In the commands below, `<hooks>` is `.claude/hooks/` in copy mode and `${CLAUDE_PLUGIN_ROOT}/hooks/` in plugin mode.

**Waiting for CI** (Phases 3–5): one background command with a single completion notification — `gh run watch <run-id> --exit-status` (or `gh pr checks <n> --watch`) via Bash `run_in_background`. Never a polling `Monitor`, never `ScheduleWakeup`, and never an `AskUserQuestion` as a pause (rule 7: a question is a decision for the user, not a wait). If the runner queue exceeds ~10 minutes, say so in one line and end the turn; the notification resumes the skill. Wait only for a run that exists.

## Phase 1: Story and evidence
Read the story, the feature-spec criteria, and the latest `/code-review` report (chat history, or `production/reviews/` if kept).

## Phase 2: Run
1. Run the tests from the criteria matrix and the whole affected package.
2. Run lint/typecheck; `govulncheck` / `audit` when dependencies changed.
3. For UI: axe on new pages (if e2e exists).
4. Put the output in the report. Anything red → `NOT DONE`.

## Phase 3: DoD checklist
Each item is ✅ or an open item named in the report.
1. **Criteria ↔ tests**: the criterion → test → result table **rendered in the chat message** (rule 7), not just written to the story file.
2. **The studio's review ran.** `grep -E 'SubagentStop \| (web-studio:)?([a-z]+-lead|[a-z]+-engineer)' production/session-logs/agent-audit.log` shows a reviewer's Stop later than the branch's first commit. For a `security-sensitive` story (security rules for sensitive paths), `appsec-engineer` is among them. A review that exists only in the chat (Claude Code's built-in `/code-review`, a parent's own reading) is `NOT DONE (no studio review)`, naming the missing reviewer: the chat can claim an appsec review the log never recorded.
3. **Review APPROVED**: the reviewers' own verdict after the last fix (`/code-review` Phase 5), not the parent's summary of it.
4. **Findings recorded**: every `ARCH-NNN`/`SEC-NNN` named in the story card exists as a row in `production/findings.md` (`grep -c '<ID>' production/findings.md`). An ID with no row is an open DoD item, not a formality.
5. **Docs** (README/API/runbook) updated; contract and codegen in sync.
6. **Branch**: the story branch is pushed, with no uncommitted changes.
7. **CI green on the branch**: `gh run list --branch <branch>` when `gh` exists. A run in progress → wait (see above). No run at all because the workflows trigger on `pull_request` and no PR exists yet → name it; the PR opened in Phase 4 starts it, and Phase 5 waits for it before the merge question.

## Phase 4: Close
Only on `DONE`.
1. **Close gate**, one `AskUserQuestion`: "May I set the story status → Done, record the actual time, tick the roadmap, update the `## Docs` row, commit `docs: close S-NNN — Done, PR #N`, push it and open the PR if it does not exist yet (`gh pr create`)?" — close and open the PR (Recommended) · close without the PR · not now. This answer covers the close only, never the merge. The edits it covers:
   - **Actual time**: `⏱ Nh` on the roadmap line and `Actual:` in the card — wall-clock from the card's `Started:` line (written by `/dev-story` at branch time) to now, rounded to 0.5 h. No `Started:` → `⏱ ?` and one line naming the omission, never a guessed number.
   - **Roadmap line**: tick `[x]`, add `🔗 [PR #N](url)` inline (same rule as the ID: a file-relative link, not a `## Links` reference-definition), and refresh the `Updated:` line.
   - **`## Docs` → *production/stories/* block**: the story's row becomes `✅ … Done · PR #N`.
2. Before editing, count `grep -c "⏱" production/roadmap.md` and `grep -c "🔗 \[PR #" production/roadmap.md`.
3. After the "yes": `touch .claude/.write-consent`; make the edits.
4. **Prove the edit instead of assuming it**: run the two counts again and re-read the story's row in the `## Docs` block. A story closed without its `⏱` and `🔗 PR` in **both** places is an unfinished DoD item, printed as such in the report with the numbers quoted: an answer can carry numbers that never reached the file.
5. `git commit -m "docs: close S-NNN — Done, PR #N"`, then `git push`, so the PR carries the close commit.
6. No PR yet and the answer was "close and open the PR" → `gh pr create`.

## Phase 5: Merge (`.claude/docs/git-workflow.md`, step "Merge")
Only on `DONE` and only after Phase 4 is finished.
1. **Wait for CI** on the PR's latest commit (see above). Red → `NOT DONE (CI red)`; nothing is merged.
2. **Merge gate**, a separate `AskUserQuestion`: "PR #N is open and CI is green. Merge it into `<default>` and delete the branch now?" — merge now (Recommended when CI is green) · leave the PR open.
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
