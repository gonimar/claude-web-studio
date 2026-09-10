---
name: migrate
description: "Migrates a project's documents to the studio's current templates without losing content — a roadmap of any format to v3.1 with stable IDs and inline links, story cards, ADRs, product and feature specs, sprint files; detects each document's format, shows the mapping and a rendered dry run before any write, keeps history and IDs. Use after /adopt on a project whose documents predate or differ from the templates, and when /update reports template drift."
argument-hint: "[roadmap | stories | adrs | specs | sprints | all] [--dry-run]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, AskUserQuestion
model: sonnet
---

# Migrate — documents to the current templates

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

Templates `.claude/docs/templates/{roadmap,story,adr,product-spec,feature-spec,sprint-plan,backlog,decisions}.md`;
rules `rules/docs-format.md` (required sections per document type). Writes only after "May I write?", one
document type per gate. Not a rewrite: the content, the decisions and every ID survive; only structure,
markers and links change. `/adopt` classifies the gap, this skill closes it.

## Phase 1: Detect
Per type in scope: which files exist, and the format fingerprint of each — roadmap: `roadmap-format:` header
comment (v3.1), reference-style `## Links`, `📅 sprint-NN` markers, numbered "Owner decisions", a foreign format
(a companion tool's table, a plain list, a spreadsheet export); stories: template sections present (Goal,
Acceptance criteria as a table, Definition of Done); ADRs: Status/Context/Options/Decision/Consequences/
Verification; specs: numbered template sections; sprints: Goal/Stories/Dependency updates/Risks/Retrospective.
The prose language of the documents is kept — headings are compared by structure and count, never translated
back to English. Table "document → format found → drift (sections missing, markers to convert) → action";
documents already in the current format are listed as `up to date` and never touched.

## Phase 2: Mapping
Per document type the exact rules, shown before anything is rendered:
- **Roadmap → v3.1**: every task line becomes `- [ ] [ID](path) · Title` + markers in the legend's order; IDs are
  kept verbatim (a foreign scheme such as `T-12` or `H-37` stays — the format allows any stable prefix); paths become
  file-relative inline links (a card that does not exist yet links to `backlog.md#id` or stays a bare ID with a
  note); `📅 sprint-NN` → the sprint heading with ISO dates; "Owner decisions" → `production/decisions.md` (`D-NN`,
  referenced from the lines that wait on them with `⛔ [D-NN](decisions.md#d-nn)`); ideas without a card →
  `production/backlog.md` (`I-NNN`); closed sprints, the Backlog and the Legend fold into `<details>`; the three-line
  header names the manager, the source of truth and today's date; the `## Docs` board is generated from the
  actual files.
- **Stories**: missing sections added with `n/a — reason` or filled from the card's prose (criteria in prose →
  the Given/When/Then table, one row per criterion, test column `[to map]`); status and links kept.
- **ADRs**: `/architecture-decision retrofit` semantics applied in bulk — an option list of at least two (the
  rejected alternative reconstructed from the text when it is there, otherwise `[not recorded]`), Verification added
  as `[to define]`; Status kept.
- **Specs**: sections renumbered to the template, missing ones `n/a — reason`; acceptance criteria never dropped.
- **Sprints**: the `## Retrospective` and `## Dependency updates` sections added empty where missing.
Anything that cannot be mapped mechanically is listed as a question **before** the render, one `AskUserQuestion`
with the real alternatives — never guessed.

## Phase 3: Dry run
Render each converted document **in the chat message** (rule 7: a roadmap as its list, a criteria table as a
table) with a summary line per file: `N lines → M lines · K IDs kept · sections added: … · questions: 0`.
Compare IDs and links before/after (`grep -o '\[[A-Z]+-[0-9]+\]'` counts must match). `--dry-run` stops here
with the verdict `DRY RUN (N documents ready, M questions)`.

## Phase 4: Write (one type per gate)
"May I write `<the files of this type>` (N files; git history is the backup)?" — one `AskUserQuestion`: write
(Recommended) · show the full diff first · skip this type. After the "write" answer: `touch .claude/.write-consent`
(rule 7 — the consent-guard hook checks the marker). Then one commit gate per batch: `docs: migrate <type> to
template <version>` staging exactly the written files, on the branch git-workflow's documents lane prescribes.
After the roadmap: `/help` must read it — run its checks (open items count, first open item) and show the result.

Verdict: `COMPLETE (N documents migrated, M up to date)` | `DRY RUN (…)` | `BLOCKED (not initialised — run /init |
no documents of this type)`. Next step — one `AskUserQuestion`: `/help` (Recommended) · migrate the next type ·
stop here.
