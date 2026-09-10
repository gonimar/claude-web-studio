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

File writes and any mutation (git, deploy) happen only after an explicit "May I write?" / "Proceed?" → "yes", asked as an `AskUserQuestion` with the recommended action first and the real alternatives (coordination-rules, rule 7); delegated agents follow the same protocol. After the "write" answer: `touch .claude/.write-consent` (rule 7).

## Phase 1: Story and evidence
Read the story, the feature-spec criteria, the latest `/code-review` report (chat history or `production/reviews/` if kept).

## Phase 2: Run
Run the tests from the criteria matrix (and the whole affected package), lint/typecheck, `govulncheck`/`audit` when dependencies changed; for UI — axe on new pages (if e2e exists). Output in the report. Anything red → `NOT DONE`.

## Phase 3: DoD checklist
Criteria ↔ tests ✅ — the criterion → test → result table **rendered in the chat message** (rule 7), not just written to the story file; review APPROVED; security rules for sensitive paths (appsec review happened?); docs (README/API/runbook) updated; contract and codegen in sync; the story branch is pushed with no uncommitted changes; CI green on the branch (`gh run list --branch <branch>` when `gh` exists).

## Phase 4: Close
"May I set the story status → Done, record the actual time (`⏱ Nh` on the roadmap line and `Actual:` in the card — wall-clock from the card's `Started:` line, written by `/dev-story` at branch time, to now, rounded to 0.5 h; no `Started:` → `⏱ ?` and one line naming the omission, never a guessed number), tick `[x]` in the roadmap (add `🔗 [PR #N](url)` inline — same rule as the ID: file-relative link, not a `## Links` reference-definition — and refresh the `Updated:` line), update the story's row in the roadmap's `## Docs` → *production/stories/* block to `✅ … Done · PR #N`, commit `docs: close S-NNN — Done, PR #N` and open the PR if it does not exist yet (`gh pr create`)?" Only on `DONE`; asked as one `AskUserQuestion`: close and open the PR (Recommended) · close without the PR · not now. This answer covers the close only — never the merge.

**Waiting for CI** (Phase 4/5): one background command with a single completion notification — `gh run watch <run-id> --exit-status` (or `gh pr checks <n> --watch`) via Bash `run_in_background` — never a polling `Monitor`, never `ScheduleWakeup`, and never an `AskUserQuestion` as a pause (rule 7: a question is a decision for the user, not a wait). If the runner queue exceeds ~10 minutes, say so in one line and end the turn; the notification resumes the skill.

## Phase 5: Merge (`.claude/docs/git-workflow.md`, step "Merge")
Only on `DONE` and only after Phase 4 is finished, ask a separate `AskUserQuestion`: "PR #N is open and CI is green. Merge it into `<default>` and delete the branch now?" — merge now (Recommended when CI is green) · leave the PR open.
- "yes" → `gh pr merge --merge --delete-branch` (`--squash` only when the project's CLAUDE.md says so); then `git switch <default> && git pull --ff-only`, delete the local story branch, clear `session-state/active.md`.
- "no" (or no answer) → leave the PR open, keep `Branch:` in the session state, and say how to merge later: re-run `/story-done S-NNN` (a story already Done with an open PR goes straight to this question), or merge on GitHub and run `git switch <default> && git pull --ff-only`.
Without `gh`: the same, by hand. `NOT DONE` → nothing is merged.

Verdict: `DONE` | `NOT DONE (reasons)`. Next step — one `AskUserQuestion`: the next story — `/dev-story S-NNN` from the fresh default branch (Recommended) · `/sprint-status` · stop here.
