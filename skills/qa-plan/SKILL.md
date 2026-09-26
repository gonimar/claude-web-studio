---
name: qa-plan
description: "Creates the QA plan for a sprint or feature — maps each story's acceptance criteria to test levels/tools/files, test data and environment, regression set, quality risks; writes production/sprints/qa-plan-NN.md. Run at sprint start."
argument-hint: "[sprint NN | F-NNN]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Bash, AskUserQuestion, Task
model: sonnet
agent: qa-lead
---

# QA Plan

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

Template `test-plan.md`; the project's `test-strategy.md` (missing → `/test-setup` first). In the commands below, `<hooks>` is `.claude/hooks/` in copy mode and `${CLAUDE_PLUGIN_ROOT}/hooks/` in plugin mode.

## Phase 1: Stories
Sprint/feature → stories → acceptance criteria.

## Phase 2: Matrix
Criterion → level (unit/integration/contract/e2e/security/a11y/perf) → tool → file → owner agent; test data; regression set; risks (`test-engineer` via Task — effort estimate).
**A criterion no level can automate** — a visual or editorial judgement, a third-party flow with no sandbox, a physical device or a real e-mail inbox — gets level `manual` (a value of the template's Level column), with the steps, the tester and the evidence to keep (a screenshot, a log line) in the row's `Manual (steps · tester · evidence)` column (template `test-plan.md`; `—` on automated rows), and a `manual` flag the plan's risks section counts ("N criteria manual"). It is never dropped from the matrix, never assigned a tool that cannot test it, and never marked covered by a neighbouring automated test.

## Phase 3: Write
Show the matrix as a table in the chat, then "May I write `production/sprints/qa-plan-NN.md`?" — one `AskUserQuestion`: write (Recommended) · show the draft/diff first · not now. After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker).

## Phase 4: Commit (documents lane)
Right after the write, one commit gate (rule 7 (4), `.claude/docs/git-workflow.md` § Documents): `docs: qa plan NN` (`docs: qa plan F-NNN` for a feature), staging exactly `production/sprints/qa-plan-NN.md`. Record the gate before asking — `<hooks>session-state.sh set Gate "/qa-plan Phase 4: commit?"` — and clear it after the answer (`<hooks>session-state.sh set Gate "—"`).
- On the default branch when no story work is in progress (the normal case at sprint start): one `AskUserQuestion` — commit (Recommended) · leave uncommitted.
- When HEAD is a story branch, name it and ask one `AskUserQuestion`: switch to the default branch and commit there (Recommended — a pipeline-wide document) · commit here (the document belongs to this story) · leave uncommitted.
- The plan names test files; it does not write them — they are written by `/dev-story` in the story's branch and never ride the `docs:` commit.

Nothing is committed without the answer.

Verdict: `READY`. Next step — one `AskUserQuestion`: `/dev-story` (Recommended) · `/sprint-plan` adjustments · stop here.
