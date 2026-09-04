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
Criteria ↔ tests ✅; review APPROVED; security rules for sensitive paths (appsec review happened?); docs (README/API/runbook) updated; contract and codegen in sync; PR created/ready.

## Phase 4: Close
"May I set the story status → Done, tick `[x]` in the roadmap, clear `session-state/active.md`?"

Verdict: `DONE` | `NOT DONE (reasons)`. Next step: the next story or `/sprint-status`.
