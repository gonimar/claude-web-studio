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

Budgets — `technical-preferences.md`; references `web-platform.md`, `database.md`, `graphql.md`, `threejs-webgames.md`.

## Phase 1: Baseline (Bash, whatever is available)
Web: `lighthouse --preset=perf --form-factor=mobile` / Lighthouse CI; `ng build --stats-json` / `vite build` + visualizer; API: `k6 run` scenario (create with consent); DB: `EXPLAIN (ANALYZE, BUFFERS)` on top queries, `pg_stat_statements`; Go `pprof`, PHP Blackfire/Xdebug; game: `renderer.info`, a Performance trace, memory.
A missing tool — say so, offer installation.

## Phase 2: Analysis
Table "metric → value → budget → status"; findings with estimated gain and cost; the 3 cheapest.

## Phase 3: Fixes (with consent)
Through the relevant engineers; re-measure with the same method — before/after.

## Phase 4: Write
"May I write `docs/ops/perf-audit-<date>.md`?"

Verdict: `WITHIN BUDGET` | `OVER BUDGET (metrics: …)`. Next step: improvement stories; `/release-checklist`.
