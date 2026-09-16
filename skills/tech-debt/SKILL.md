---
name: tech-debt
description: "Inventories technical debt — outdated dependencies vs the stack reference, TODO/FIXME, skipped tests, lint suppressions, ADR drift, missing docs, security/perf shortcuts; scores by impact/effort and proposes stories. Read-only report in docs/ops/tech-debt-<date>.md on approval."
argument-hint: "[area or 'full']"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Write, Task, AskUserQuestion
model: sonnet
agent: technical-director
---

# Tech Debt

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

## Phase 1: Collect (Bash + Grep)
Dependencies: `go list -m -u all` / `composer outdated` / `pnpm outdated` vs `stack-reference/index.md`; `TODO|FIXME|HACK`; `skip|xit|@group skip|t.Skip`; `eslint-disable|@psalm-suppress|nolint`; ADRs in Proposed older than 30 days; feature specs without stories; Done stories without tests; missing runbooks; open findings from the last audits (security/perf/a11y).

## Phase 2: Score
Table "debt → impact (security/velocity/risk) → effort → priority → proposed story".

## Phase 3: Report
Show; "May I write `docs/ops/tech-debt-<date>.md` and add the top 5 to the roadmap?" as one `AskUserQuestion`: report and roadmap (Recommended) · report only · not now. After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker).

Go code-shape debt is measured, not felt: packages over 1 500 lines, files over 500, a `.golangci.yml` in v1 format, `time.Sleep` in tests, error strings compared, a `go_architecture: layered` project whose tree or `depguard` block does not match — each a row with the number, and the proposed story is `/refactor <package>` / `/refactor layout` / `/refactor tests` rather than a rewrite.

Verdict: `COMPLETE (N items, M critical)`. Next step — one `AskUserQuestion`: `/create-stories` for critical items (Recommended when any) · `/refactor --dry-run` for code-shape items · `/stack-update` for outdated majors · stop here.
