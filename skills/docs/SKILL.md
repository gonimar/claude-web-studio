---
name: docs
description: "Documentation for people, through tech-writer — README from technical-preferences and the product spec, API reference generated from the contract (GraphQL SDL / OpenAPI), user guide from the feature specs, runbook from docs/ops/deploy.md and the incident history; every command in the docs is run before it is written; --check only reports what is missing or stale. Use when documentation is missing or stale, before a hand-over and before a release."
argument-hint: "[readme | api | guide | runbook | all] [--check]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, AskUserQuestion
model: sonnet
---

# Docs — documentation for people

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

Agent `tech-writer` (rules: README structure, runbook structure, every command run, no duplication of CLAUDE.md
or the stack reference). Sources: `technical-preferences.md`, `docs/specs/product-spec.md`, `docs/specs/features/*.md`,
`docs/architecture/api/*`, `docs/ops/deploy.md` (template `deploy-runbook.md`), `docs/ops/incidents/*`, `CHANGELOG.md`.
Writes only after "May I write?". Documentation is derived from the pipeline's documents, never the other way round —
a fact missing from a spec or the contract is a spec gap (`/feature-spec`, `/api-contract`), not something to invent here.

## Phase 1: Inventory (`--check` stops after it)
Per target: what exists (`README.md`, `docs/api/*`, `docs/guide/*`, `docs/ops/*.md`), its last change vs the
last change of its sources (`git log -1 --format=%cs -- <path>`), and the gaps: README without a quick start, an
env table that misses variables present in `.env.example` or compose, an API reference behind the contract
(`graphql-inspector diff` / `openapi-diff` when installed, otherwise operation lists compared), a user guide
that does not cover a Done feature, a runbook without rollback or without the last incident's action. Table
"target → exists → stale vs → gaps". `--check` → verdict `COMPLETE (check only: N targets stale)` and stop.

## Phase 2: Draft (tech-writer via Task, one target at a time)
- **readme** — what it is (product spec §1) → quick start (commands from technical-preferences and the test
  strategy, **run here with output**) → configuration (env table from `.env.example`/compose, secrets named, never
  valued) → development (tests, lint, `/help`) → deploy (link to the runbook) → licence. Never duplicates CLAUDE.md.
- **api** — generated from the contract: GraphQL SDL → reference per type/operation with descriptions taken from
  the SDL (`graphql-markdown` or an equivalent from `stack-reference/graphql.md`; a hand-written page only when no
  generator fits, and then marked so); OpenAPI → Redoc/Scalar page or markdown per operation. Auth, errors, limits
  and deprecations come from the contract, not from memory.
- **guide** — one page per Done feature, from the feature spec's scenarios and UI states: the user's goal, steps,
  what they see in each state, what can go wrong (edge cases with the concrete behaviour the spec names);
  screenshots only when a Playwright run can take them.
- **runbook** — `docs/ops/deploy.md` completed from the deploy contract, the release files and the incidents:
  symptom → diagnosis (commands) → action → verification → rollback, per known failure; secrets by name and
  location only.
Each draft is rendered in the chat (rule 7); a command that fails when run is a finding, not prose.

## Phase 3: Write
Per target: "May I write `<path>`?" — one `AskUserQuestion`: write (Recommended) · adjust · skip. After the "write"
answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker). Then one commit gate:
`docs: <target> from <sources>` staging exactly the written files, on the branch git-workflow's documents lane
prescribes (a story branch when the docs belong to the story in progress).

Verdict: `COMPLETE (N targets written)` | `COMPLETE (check only: …)` | `BLOCKED (no product spec / no contract —
run /product-spec | /api-contract first)`. Next step — one `AskUserQuestion`: `/story-done S-NNN` when the docs
close a story (Recommended in that case) · `/release-checklist` before a release · stop here.
