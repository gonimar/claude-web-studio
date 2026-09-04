---
name: sprint-plan
description: "Plans a sprint — goal, capacity, story selection by priority and dependencies, risks, QA plan link; writes production/sprints/sprint-NN.md and roadmap markers. Use at sprint start."
argument-hint: "[sprint number] [--days N]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion
model: sonnet
agent: product-director
---

# Sprint Plan

Template `sprint-plan.md`.

## Phase 1: State
Ready stories (`production/stories/**`), the roadmap (priority/blocker markers), the last sprint (unfinished work, retro actions), capacity (ask: days, hours per day).

## Phase 2: Selection
The sprint goal as one verifiable statement. Stories by priority and dependencies within capacity (20 % buffer); first the one that removes the biggest risk. Blockers and external dependencies explicit.

## Phase 3: Write
Show the plan; "May I write `production/sprints/sprint-NN.md` and mark priorities in the roadmap?" Propose `/qa-plan NN`.

Verdict: `READY`. Next step: `/qa-plan`, then `/dev-story`.
