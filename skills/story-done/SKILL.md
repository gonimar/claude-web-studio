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

File writes and any mutation (git, deploy) happen only after an explicit "May I write?" / "Proceed?" → "yes"; delegated agents follow the same protocol.

## Phase 1: Story and evidence
Read the story, the feature-spec criteria, the latest `/code-review` report (chat history or `production/reviews/` if kept).

## Phase 2: Run
Run the tests from the criteria matrix (and the whole affected package), lint/typecheck, `govulncheck`/`audit` when dependencies changed; for UI — axe on new pages (if e2e exists). Output in the report. Anything red → `NOT DONE`.

## Phase 3: DoD checklist
Criteria ↔ tests ✅; review APPROVED; security rules for sensitive paths (appsec review happened?); docs (README/API/runbook) updated; contract and codegen in sync; the story branch is pushed with no uncommitted changes; CI green on the branch (`gh run list --branch <branch>` when `gh` exists).

## Phase 4: Close
"May I set the story status → Done, tick `[x]` in the roadmap, commit `docs: close S-NNN — Done, PR #N` and open the PR if it does not exist yet (`gh pr create`)?" Only on `DONE`.

## Phase 5: Merge (`.claude/docs/git-workflow.md`, step "Merge")
On `DONE`, with consent: `gh pr merge --merge --delete-branch` (`--squash` only when the project's CLAUDE.md says so); then `git switch <default> && git pull --ff-only`, delete the local story branch, clear `session-state/active.md`. Without `gh`: tell the user to merge the PR and run the switch/pull afterwards. `NOT DONE` → nothing is merged.

Verdict: `DONE` | `NOT DONE (reasons)`. Next step: the next story (`/dev-story S-NNN` from the fresh default branch) or `/sprint-status`.
