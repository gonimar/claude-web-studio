# Skill Spec: /migrate

> **Category**: onboarding · **Priority**: high · **Spec written**: 2026-09-10

## Summary
Converts a project's documents to the current templates keeping content, IDs and history: roadmap → v3.1, stories, ADRs, specs, sprints. Detect → mapping → rendered dry run → one write gate per type → commit gate. Sonnet, rule `docs-format.md`.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] template/rules link

## Cases
### 1. Happy path — roadmap in a foreign format
**Fixture**: `production/roadmap.md` written by a companion tool: numbered table, IDs `H-01…H-37`, a reference-style `## Links` block, a numbered "Owner decisions" section, `📅 sprint-02` markers. **Expected**: the fingerprint names each drift; the mapping keeps `H-NN` verbatim as inline links, moves decisions to `production/decisions.md` as `D-NN` with `⛔ [D-NN](decisions.md#d-nn)` on the waiting lines, turns `📅 sprint-02` into a sprint heading with ISO dates; the rendered roadmap is shown as a list in the chat; ID count before/after matches; "May I write?" per type; `/help` is run afterwards and shows the open items.
- [ ] IDs kept · [ ] decisions extracted · [ ] rendered before the gate · [ ] `/help` reads the result
### 2. Refusal / BLOCKED — nothing to migrate
**Fixture**: every document already carries the current structure. **Expected**: table of `up to date` rows, `COMPLETE (0 migrated, N up to date)`, no write gate.
- [ ] writes no files · [ ] says why
### 3. Mode/argument variant — `--dry-run`
**Fixture**: `/migrate stories --dry-run` on eight cards with prose criteria. **Expected**: criteria rendered as Given/When/Then tables, summary line per card, verdict `DRY RUN (8 documents ready, 0 questions)`, nothing written.
- [ ] argument parsed · [ ] nothing written · [ ] tables rendered
### 4. Edge case — documents in the project language
**Fixture**: ADRs with Russian headings and only Context/Decision sections. **Expected**: headings are not translated; sections are compared by count and order; Options gets `[not recorded]` (or the reconstructed alternative when the text names one) and Verification `[to define]`; status kept.
- [ ] language preserved · [ ] missing sections added, not invented · [ ] status unchanged
### 5. Gate / protocol — one type per gate, questions first
**Fixture**: three story cards lack a feature link that cannot be inferred. **Expected**: one `AskUserQuestion` with the real alternatives before any render; then one write gate for the story type; `docs: migrate stories …` commit gate staging exactly those files; never a second type on the same answer.
- [ ] questions before the render · [ ] one gate per type · [ ] commit gate with the exact file list

## Protocol
- [ ] "May I write?" before writes · [ ] draft before approval · [ ] next step · [ ] never advances the stage itself

## Coverage notes
Closes roadmap R-02; `/adopt` hands off here for HIGH format findings, `/update` when a template changed.
