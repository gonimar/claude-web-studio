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

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

Reference: `stack-reference/index.md` (what the studio builds and with which versions); the brief feeds the
`product-spec.md` / `game-concept.md` templates that follow.

## Phase 1: Conversation
Clarify via `AskUserQuestion` (one at a time): for whom; which pain/desire; what already exists on the market
(allow `WebSearch` for 3–5 comparable products); constraints (time, budget, stack, platforms);
for games — genre, session, the player's "verb" (the most frequent action).

## Phase 2: Framing
Generate 3 positioning variants (narrow/medium/wide scope) with cost and risk; for games — 3 core-loop variants (MDA: mechanics → dynamics → aesthetics).
Propose success metrics and "what must be true" for the idea to work (hypotheses to validate).

## Phase 3: Concept brief
Draft `docs/specs/concept-brief.md` **from `docs/templates/concept-brief.md`** — the eight sections in the template's order (essence, personas, pain, differentiation, MVP candidate, hypotheses with a validation table, risks, next step). `/product-spec` Phase 1 reads this file as its input, so a brief that invents its own shape costs the next skill the facts it came for; a section with nothing behind it is written as `n/a — reason`, never dropped. "May I write it?" — one `AskUserQuestion`: write (Recommended) · show the draft/diff first · not now After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker).

Verdict: `COMPLETE`. Next step — one `AskUserQuestion`: `/setup-stack` (Recommended) · `/product-spec` or `/game-concept` directly · revise the brief.
