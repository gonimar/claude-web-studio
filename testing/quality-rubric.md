# Quality rubric for skills and agents

Used by `/skill-test category` and `/skill-test agent`. A metric is PASS when the skill/agent text
clearly ensures the criterion; WARN when partially; FAIL when absent or contradictory.

## Skill categories

### `onboarding`
| Metric | PASS |
|---|---|
| O1 — Detect before asking | Reads project state (technical-preferences, specs, lockfiles) before the first question |
| O2 — One next step | Output ends with one concrete command |
| O3 — Project data untouched | No writes to `docs/specs`, `docs/architecture`, `production/`, a configured `technical-preferences.md` without "May I write?" |
| O4 — Reference freshness | Considers the `stack-reference/index.md` date and recommends `/stack-update` beyond 60 days (where relevant) |
| O5 — Language and companions | Respects the CLAUDE.md conversation language; notices companion skills (advisor, deploy) and pre-existing settings |

### `authoring`
| Metric | PASS |
|---|---|
| A1 — Template | References a concrete `.claude/docs/templates/` file and fills its sections |
| A2 — Section by section | Questions → draft → edits, not one big dump |
| A3 — "May I write?" | Every file write is gated by an explicit question |
| A4 — Security and accessibility | The document has security and accessibility sections/items (or a justified "n/a") |
| A5 — Review mode | Honours `--review`/`production/review-mode.txt` and never advances the stage itself |
| A6 — Stack facts | Versions/claims come from `stack-reference/`, not memory |

### `review`
| Metric | PASS |
|---|---|
| R1 — Read-only | Does not modify reviewed files; fixes only on a separate "yes" |
| R2 — Routing | Sends files to the right specialists by type and to `appsec-engineer` for sensitive paths |
| R3 — Finding format | severity (BLOCKING/WARNING/INFO) + file:line + fix |
| R4 — ADR conformance | Checks deviations from accepted ADRs and classifies them |
| R5 — Verdict | Exactly one word from the vocabulary (APPROVED/NEEDS CHANGES or PASS/CONCERNS/FAIL) |

### `pipeline`
| Metric | PASS |
|---|---|
| P1 — Input checks | Missing spec/contract/ADR → BLOCKED naming what to run |
| P2 — Criterion ↔ test | Table criteria → tests → results with output |
| P3 — Delegation | Code is written by specialist engineers via Task, not by the skill |
| P4 — Session state | Updates `production/session-state/active.md` |
| P5 — Handoff | Ends with the next skill in the chain |

### `sprint`
| Metric | PASS |
|---|---|
| S1 — From artefacts | Statuses from files/git/CI, not claims |
| S2 — Verdict word | READY / ON TRACK / AT RISK / DONE / NOT DONE etc. |
| S3 — Roadmap compatibility | The `production/roadmap.md` checkbox format is preserved |
| S4 — No self-advancing | `stage.txt` changes only with consent |

### `analysis`
| Metric | PASS |
|---|---|
| N1 — Tools with output | Commands per stack listed; output included; missing tools reported |
| N2 — Finding format | severity/CVSS, file:line, fix, regression test |
| N3 — Templated report | Written to `docs/security|ops/…` via the template and "May I write?" |
| N4 — Scope boundary | `pentest` only the project's own systems with the scope recorded; others take the scope from the argument |
| N5 — Follow-ups | Stories/ADRs for BLOCKING; a verdict word |

### `team`
| Metric | PASS |
|---|---|
| T1 — Parallelism | Independent Tasks spawned in one batch; dependent ones sequentially |
| T2 — BLOCKED surfaced | Any agent's block is raised immediately; a partial report is mandatory |
| T3 — Right agents | Team composition matches the roster (leads + stack specialists) |
| T4 — The user decides | Drafts shown; writes and mutations with consent |
| T5 — Final summary | Table of criteria/findings/numbers and the next step |

### `ops`
| Metric | PASS |
|---|---|
| D1 — Confirmed mutations | Every production mutation after an explicit "yes" |
| D2 — Rollback | Rollback steps described before execution |
| D3 — Delegation | An installed deployment skill is used when present |
| D4 — Result verification | By containers/smoke requests, not response codes |
| D5 — Documentation | runbook/release/incident file updated |

## Agent tiers

### `agents:directors`
| Metric | PASS |
|---|---|
| G1 — Domain and boundaries | States what it owns and does not; delegates to leads |
| G2 — Options with cost | Decisions through 2–3 options, a recommendation, an ADR |
| G3 — Advisory gates | PASS/CONCERNS/FAIL verdict without self-advancing |
| G4 — Protocol | The "Collaboration protocol" block is present |

### `agents:leads`
| Metric | PASS |
|---|---|
| L1 — Specialists named | Lists subordinate specialists and when to delegate to whom |
| L2 — References | Names the `stack-reference/` files to read first |
| L3 — Review format | BLOCKING/WARNING/INFO, file:line |
| L4 — Escalation | Conflicts → technical-director / product-director |
| L5 — Protocol | Present |

### `agents:backend`, `agents:frontend`, `agents:game`, `agents:security`, `agents:quality-ops`
| Metric | PASS |
|---|---|
| E1 — Reference first | Links a concrete `stack-reference/*.md` |
| E2 — Working order | Spec → questions → sketch → code → tests → run with output |
| E3 — "Never" | A list of stack-specific prohibitions |
| E4 — Executable verification | Requires test/lint/measurement output in the result |
| E5 — Boundaries | No decisions outside the domain (architecture → lead/TD; security → `security-lead`) |
| E6 — Protocol | Present |
