---
name: feature-spec
description: "Authors a feature specification (scenarios, rules, data, API operations, UI states, edge cases, security, accessibility, acceptance criteria) from the product spec. Produces docs/specs/features/F-NNN-name.md. Run per feature before stories."
argument-hint: "[feature name] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion, Task
model: sonnet
---

# Feature Spec

Template `.claude/docs/templates/feature-spec.md`. Section by section; written after "May I write?".

## Phase 1: Context
Read `docs/specs/product-spec.md` (the feature must be in scope — otherwise ask whether to add it),
existing `docs/specs/features/*.md` (F-NNN numbering, overlaps), `technical-preferences.md` (API style GraphQL/REST — shapes section 5),
`docs/architecture/api/` (existing types/operations), `docs/architecture/threat-model.md`.

## Phase 2: Sections
1–3 Overview/scenarios/rules: questions to the user; formulas with a worked example.
4 Data: entities → propose what changes in `data-model.md`.
5 Contract: GraphQL — types/queries/mutations as SDL sketches; REST — endpoints; errors.
6 UI/states: the mandatory 5 states; copy.
7 Edge cases: a table, every row a concrete behaviour.
8 Security: object/field authorisation, limits, logging — ask `security-lead` via Task when the feature touches auth/money/files/personal data.
9 Accessibility/performance: concrete checks.
11 Acceptance criteria: Given/When/Then, ≥ 1 per scenario and per risky edge case.

## Phase 3: Review (per mode)
`full`: `technical-director` + `design-lead` + `security-lead`; `lean`: `security-lead` for sensitive features; `solo`: none. Verdict APPROVED / NEEDS REVISION.

## Phase 4: Write
"May I write `docs/specs/features/F-NNN-<slug>.md`?" Update the feature index in the product spec (section 5) with consent.

Verdict: `APPROVED` | `NEEDS REVISION`. Next step: `/api-contract` (if the contract changes), `/ux-spec`, then `/create-stories F-NNN`.
