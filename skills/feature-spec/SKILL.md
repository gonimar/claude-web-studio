---
name: feature-spec
description: "Authors a feature specification (scenarios, rules, data, API operations, UI states, edge cases, security, accessibility, acceptance criteria) from the product spec. Produces docs/specs/features/F-NNN-name.md. Run per feature before stories."
argument-hint: "[feature name] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion, Task
model: sonnet
---

# Feature Spec

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

Template `.claude/docs/templates/feature-spec.md`. Section by section; written after "May I write?".

## Phase 1: Context
1. `docs/specs/product-spec.md`. Missing → verdict `BLOCKED (no product spec — run /product-spec first)`; write nothing. The feature must be in its scope; otherwise ask whether to add it.
2. Existing `docs/specs/features/*.md`: F-NNN numbering, overlaps.
3. `technical-preferences.md`: the API style (GraphQL or REST) shapes section 5.
4. `docs/architecture/api/api-contract.md` and the schema file at `api_contract_path` (technical-preferences; default `api/schema.graphqls` for a Go module, `docs/architecture/api/schema.graphql` otherwise): existing types and operations.
5. `docs/architecture/threat-model.md`.

## Phase 2: Sections
1–3 Overview/scenarios/rules: questions to the user; formulas with a worked example.
4 Data: entities → propose what changes in `data-model.md`.
5 Contract: GraphQL — types/queries/mutations as SDL sketches; REST — endpoints; errors.
6 UI/states: the mandatory 5 states; copy (with the copy keys for a localised product); the product events the feature emits (name · trigger · properties, from the product spec §6 analytics list); for public pages, the SEO requirements (title/meta, structured data, canonical) that `seo-specialist` reviews in `/dev-story`.
7 Edge cases: a table, every row a concrete behaviour.
8 Security: object/field authorisation, limits, logging — ask `security-lead` via Task when the feature touches auth/money/files/personal data.
9 Accessibility/performance: concrete checks.
11 Acceptance criteria: Given/When/Then, ≥ 1 per scenario and per risky edge case.

## Phase 3: Review (per mode)
Mode from `--review`, else `production/review-mode.txt`, default `lean`. `full`: `technical-director` + `design-lead` + `security-lead`; `lean`: `security-lead` for sensitive features; `solo`: none. Verdict APPROVED / NEEDS REVISION. After `NEEDS REVISION` the edits go back to the **same** verifier for a short second pass, and the spec's verdict is the last review's; edits that were never re-checked are written down as `NEEDS REVISION (edits unverified)`, never silently promoted to APPROVED.

## Phase 4: Write
"May I write `docs/specs/features/F-NNN-<slug>.md`?" — one `AskUserQuestion`: write (Recommended) · show the draft/diff first · not now. Update the feature index in the product spec (section 5) with consent. After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker).

Verdict: `APPROVED` | `NEEDS REVISION` | `BLOCKED`. Next step — one `AskUserQuestion`: `/create-stories F-NNN` (Recommended) · `/api-contract` (if the contract changes) · `/ux-spec`; on `BLOCKED`: `/product-spec` (Recommended) · stop here.
