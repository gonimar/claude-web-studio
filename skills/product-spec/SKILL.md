---
name: product-spec
description: "Authors the product specification (goals, users, scope, NFRs, risks, MVP acceptance) section by section with the user. Produces docs/specs/product-spec.md. Required before feature specs."
argument-hint: "[product name] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion, Task
model: sonnet
agent: product-director
---

# Product Spec

Template: `.claude/docs/templates/product-spec.md`. Section by section: questions → section draft → edits → next.
The file is written once at the end (or per section, the user's choice), always after "May I write?".

## Phase 1: Context
Read `docs/specs/concept-brief.md` (if any), `technical-preferences.md`, `production/roadmap.md`.
If the stack is not configured — suggest `/setup-stack` before or after (not blocking).

## Phase 2: Sections 1–10
Per section: 1–3 `AskUserQuestion`s → draft → "like this?". Non-functional requirements get the studio defaults
(CWV, WCAG 2.2 AA, OWASP baseline) — the user confirms. Scope: insist on In/Later/Out; every Out item has a reason.

## Phase 3: Review
Mode (`--review` or `production/review-mode.txt`, default `lean`):
- `full`: `technical-director` (feasibility, stack risks) and `security-lead` (data, jurisdiction) in parallel via Task, verdict PASS/CONCERNS/FAIL with reasons.
- `lean`: `technical-director` only if there are non-trivial NFRs/integrations.
- `solo`: no review.
CONCERNS/FAIL — show, propose edits, never advance the stage automatically.

## Phase 4: Write
"May I write `docs/specs/product-spec.md`?" → write; propose `production/stage.txt` = `specification`.

Verdict: `APPROVED` | `NEEDS REVISION`. Next step: `/feature-spec` for Must features (or `/game-concept`).
