---
name: brainstorm
description: "Explores a product or web-game idea before specification — audience, problem, competitors, constraints, differentiation, MVP candidates; for games also MDA and core loop. Produces a concept brief. Use when the idea is vague."
argument-hint: "[topic or idea]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, WebSearch, AskUserQuestion, Task
model: sonnet
agent: product-director
---

# Brainstorm

## Phase 1: Conversation
Clarify via `AskUserQuestion` (one at a time): for whom; which pain/desire; what already exists on the market
(allow `WebSearch` for 3–5 comparable products); constraints (time, budget, stack, platforms);
for games — genre, session, the player's "verb" (the most frequent action).

## Phase 2: Framing
Generate 3 positioning variants (narrow/medium/wide scope) with cost and risk; for games — 3 core-loop variants (MDA: mechanics → dynamics → aesthetics).
Propose success metrics and "what must be true" for the idea to work (hypotheses to validate).

## Phase 3: Concept brief
Draft `docs/specs/concept-brief.md`: essence, personas, pain, differentiation, MVP candidate, hypotheses and how to validate them
(landing page/prototype/interviews), risks, next step. "May I write it?"

Verdict: `COMPLETE`. Next step: `/setup-stack`, then `/product-spec` (or `/game-concept`).
