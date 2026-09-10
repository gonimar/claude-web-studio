---
paths: ["docs/**", "production/**"]
---
# Document format rules (templates are contracts)

Every pipeline document is produced by its command from the template in `.claude/docs/templates/` and keeps the
template's structure for as long as it lives: `/help`, `/sprint-plan`, `/story-done`, `/release-checklist` and
the hooks read these documents by structure, so a document that drifts from its template is invisible to them.

| Document | Template | Required structure (prose may be in the project language; structure is what is checked) |
|---|---|---|
| `production/roadmap.md` | `roadmap.md` | header comment `roadmap-format: v3.1`, three-line managed-by/source/updated block, task lines `- [ ] [ID](path) · Title` + markers in the legend's order, sprint headings with ISO dates, `## Docs` board, `## Legend` |
| `production/backlog.md` | `backlog.md` | `I-NNN` entries with a recorded date and source; promoted/closed history; `last-review` |
| `production/decisions.md` | `decisions.md` | `D-NN` entries with options, recommendation, needed-by; decided history |
| `production/stories/**` | `story.md` | metadata line (feature, ADR, layer, size, status), Goal, Context, Tasks, Acceptance criteria **as a table** (criterion → test), Security and accessibility, Definition of Done |
| `production/sprints/sprint-NN.md` | `sprint-plan.md` | Goal, Stories table, Dependency updates, Risks and blockers, QA plan, Actions from the last retrospective, Retrospective (filled by `/retrospective`) |
| `docs/specs/product-spec.md` | `product-spec.md` | the ten numbered sections (essence … MVP acceptance criteria); NFR section names i18n, SEO and analytics explicitly (`n/a — reason` allowed) |
| `docs/specs/features/F-NNN-*.md` | `feature-spec.md` | the twelve numbered sections; Acceptance criteria in Given/When/Then; Security section; UI section lists product events and copy keys |
| `docs/architecture/adr-*.md` | `adr.md` | Status, Context, Options (≥ 2), Decision, Consequences, Verification |
| `docs/architecture/threat-model.md` | `threat-model.md` | Assets, boundaries, Attack surfaces table (including data export/deletion when PII exists), STRIDE table, Verification |
| `docs/architecture/data-model.md` | `data-model.md` | Entities, Tables, Key queries, Invariants, Migrations, Personal data (classification, **retention and deletion**), Backups and restore |
| `docs/architecture/test-strategy.md` | `test-strategy.md` | levels with tools, coverage thresholds, CI stages |
| `production/releases/vX.Y.Z.md` | `release-checklist.md` | Gates (each with evidence), Deploy, Rollback, Post-release |

Rules:
- A section that does not apply is kept with `n/a — reason`; it is never deleted, so a reader knows it was considered.
- Headings may be in the conversation language; their **number and order** follow the template — the `post-edit-check` hook
  warns (never blocks) when a document has fewer sections than its template, and `/update` reports documents that drifted
  after a template change.
- A document in an older or foreign format is not edited by hand into shape: `/migrate <type>` converts it, keeping IDs
  and history; `/adopt` lists the candidates.
- IDs (`S-`, `F-`, `ADR-`, `D-`, `I-`, `INC-`) are stable forever and always inline links, file-relative to the document
  that carries them (roadmap legend).
- Absolute dates (2026-09-05), never "next week". Identifiers, paths and commands in English.
