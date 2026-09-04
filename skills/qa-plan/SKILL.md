---
name: qa-plan
description: "Creates the QA plan for a sprint or feature — maps each story's acceptance criteria to test levels/tools/files, test data and environment, regression set, quality risks; writes production/sprints/qa-plan-NN.md. Run at sprint start."
argument-hint: "[sprint NN | F-NNN]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, AskUserQuestion, Task
model: sonnet
agent: qa-lead
---

# QA Plan

Template `test-plan.md`; the project's `test-strategy.md` (missing → `/test-setup` first).

## Phase 1: Stories
Sprint/feature → stories → acceptance criteria.

## Phase 2: Matrix
Criterion → level (unit/integration/contract/e2e/security/a11y/perf) → tool → file → owner agent; test data; regression set; risks (`test-engineer` via Task — effort estimate).

## Phase 3: Write
"May I write `production/sprints/qa-plan-NN.md`?"

Verdict: `READY`. Next step: `/dev-story`.
