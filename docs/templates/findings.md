# Findings — open decisions from audits

<!-- production/findings.md. Written by /security-audit, /perf-audit, /a11y-audit (after "May I write?");
     read by /create-stories, /sprint-plan, /sprint-status, /help. One row per finding; the row stays
     after closing (status changes), ids are never reused. -->

| ID | Date | Source | Severity | Area / feature | Finding | Decision needed | Status | Story |
|---|---|---|---|---|---|---|---|---|
| SEC-001 | YYYY-MM-DD | docs/security/security-audit-<date>.md #1 | BLOCKING | F-002 · `node(id)` resolver | IDOR: any authenticated user can read any node | ownership check in the resolver or a per-type authorisation rule | open | — |
| PERF-001 | YYYY-MM-DD | docs/ops/perf-audit-<date>.md | OVER BUDGET | LCP mobile 3.4 s (budget 2.5 s) | hero image not sized/priority | image strategy | open | — |
| A11Y-001 | YYYY-MM-DD | docs/ops/a11y-audit-<date>.md | critical | checkout form | labels missing on 3 inputs | fix + axe regression test | open | — |

Status: `open` → `planned (S-NNN)` → `done (PR)` → `accepted risk (who, why, date)`.
