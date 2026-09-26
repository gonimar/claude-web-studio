---
name: perf-audit
description: "Measures and improves performance against budgets — Lighthouse (mobile) / Core Web Vitals, bundle analysis, API p95 with k6, DB EXPLAIN, Go/PHP profiles, game frame/draw-call/memory; ranks fixes by impact; writes docs/ops/perf-audit-<date>.md. Required before release."
argument-hint: "[web | api | db | game | full] [url]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Write, Task, AskUserQuestion
model: sonnet
agent: performance-engineer
---

# Perf Audit

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

Budgets — `technical-preferences.md` § Performance budgets; references `stack-reference/web-platform.md`, `database.md`, `graphql.md`, `threejs-webgames.md`; template `findings.md`. In the commands below, `<hooks>` is `.claude/hooks/` in copy mode and `${CLAUDE_PLUGIN_ROOT}/hooks/` in plugin mode.

**No budgets** — the section is missing or still holds `[N]` placeholders → the audit is not blocked: the Core Web Vitals defaults of `web-platform.md` (LCP / INP / CLS at p75 mobile, TTFB, initial JS) are the budget for the web metrics, the Phase 2 table says so in a note ("budget: CWV default, none recorded"), API/DB/game metrics with no default are reported as `NO BUDGET` (measured, not judged), and the report proposes recording the budgets in `technical-preferences.md` (`/setup-stack` / `/adopt` field). A missing budget is never silently replaced by a guess.

## Phase 1: Baseline (Bash, whatever is available)
Web: `lighthouse --preset=perf --form-factor=mobile` / Lighthouse CI; `ng build --stats-json` / `vite build` + visualizer; API: `k6 run` scenario (create with consent); DB: `EXPLAIN (ANALYZE, BUFFERS)` on top queries, `pg_stat_statements`; Go `pprof`, PHP Blackfire/Xdebug; game: `renderer.info`, a Performance trace, memory.
A missing tool — say so, offer installation.

## Phase 2: Analysis
Table "metric → value → budget → status"; findings with estimated gain and cost; the 3 cheapest.

## Phase 3: Fixes (with consent)
Through the relevant engineers; re-measure with the same method — before/after.

## Phase 4: Write
1. Show the report in the chat, then "May I write `docs/ops/perf-audit-<date>.md` and `docs/ops/measurements/<date>-perf-audit.md`?" — one `AskUserQuestion`: write (Recommended) · show the draft/diff first · not now. The measurement file holds the commands, the environment and the raw output of Phase 1 and of the Phase 3 re-measurements (rule 12); the report quotes its numbers from that file, never from the session state. After the "write" answer: `touch .claude/.write-consent` (rule 7).
2. For every `OVER BUDGET` metric, one `AskUserQuestion`: record it in `production/findings.md` (`PERF-NNN`, template `findings.md`) (Recommended) · improvement stories now · report only — so the budget miss reaches `/create-stories` and `/sprint-plan`. Record the gate before asking — `<hooks>session-state.sh set Gate "/perf-audit Phase 4: record PERF-NNN?"` — and clear it after the answer (`<hooks>session-state.sh set Gate "—"`).

## Phase 5: Commit (documents lane)
Right after the write (and the findings rows, when any were recorded), one commit gate (rule 7 (4), `.claude/docs/git-workflow.md` § Documents): `docs: perf audit <date>`, staging exactly the written documents — `docs/ops/perf-audit-<date>.md`, `docs/ops/measurements/<date>-perf-audit.md` (rule 12) and `production/findings.md` when rows were added. Record the gate before asking — `<hooks>session-state.sh set Gate "/perf-audit Phase 5: commit?"` — and clear it after the answer (`<hooks>session-state.sh set Gate "—"`).
- On the default branch when no story work is in progress: one `AskUserQuestion` — commit (Recommended) · leave uncommitted.
- When HEAD is a story branch, name it and ask one `AskUserQuestion`: switch to the default branch and commit there (Recommended — a pipeline-wide document) · commit here (the document belongs to this story) · leave uncommitted.
- A k6 scenario created in Phase 1 and the Phase 3 fixes are code, not documents: they never ride the `docs:` commit — name them and offer the improvement story they belong to or the chore lane (git-workflow.md § Chore / infra, branch `chore/<slug>`).

Nothing is committed without the answer.

Verdict: `WITHIN BUDGET` | `OVER BUDGET (metrics: …)`. Next step — one `AskUserQuestion`: improvement stories (Recommended) · `/release-checklist` · re-run `/perf-audit` after fixes.
