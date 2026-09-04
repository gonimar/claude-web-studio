---
name: tech-debt
description: "Inventories technical debt — outdated dependencies vs the stack reference, TODO/FIXME, skipped tests, lint suppressions, ADR drift, missing docs, security/perf shortcuts; scores by impact/effort and proposes stories. Read-only report in docs/ops/tech-debt-<date>.md on approval."
argument-hint: "[area or 'full']"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Write, Task
model: sonnet
agent: technical-director
---

# Tech Debt

## Phase 1: Collect (Bash + Grep)
Dependencies: `go list -m -u all` / `composer outdated` / `pnpm outdated` vs `stack-reference/index.md`; `TODO|FIXME|HACK`; `skip|xit|@group skip|t.Skip`; `eslint-disable|@psalm-suppress|nolint`; ADRs in Proposed older than 30 days; feature specs without stories; Done stories without tests; missing runbooks; open findings from the last audits (security/perf/a11y).

## Phase 2: Score
Table "debt → impact (security/velocity/risk) → effort → priority → proposed story".

## Phase 3: Report
Show; "May I write `docs/ops/tech-debt-<date>.md` and add the top 5 to the roadmap?"

Verdict: `COMPLETE (N items, M critical)`. Next step: `/create-stories` for critical items or `/stack-update` for outdated majors.
