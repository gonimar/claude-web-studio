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
rules `.claude/rules/docs-format.md` (required sections per document type). Writes only after "May I write?", one
document type per gate. Not a rewrite: the content, the decisions and every ID survive; only structure,
markers and links change. `/adopt` classifies the gap, this skill closes it.

## Phase 1: Detect
1. **Initialised?** No `.claude/docs/workflow-catalog.yaml` → `BLOCKED (not initialised — run /init)`, and stop.
2. **Files in scope.** For each type in the argument (`all` = every type), list the files that exist. No files of the requested type at all → `BLOCKED (no documents of this type)`.
3. **Fingerprint each file:**
   - roadmap: the `roadmap-format:` header comment (v3.1), a reference-style `## Links` block, `📅 sprint-NN` markers, numbered "Owner decisions", or a foreign format (a companion tool's table, a plain list, a spreadsheet export);
   - stories: the template sections present (Goal, Acceptance criteria as a table, Definition of Done);
   - ADRs: Status / Context / Options / Decision / Consequences / Verification;
   - specs: the numbered template sections;
   - sprints: Goal / Stories / Dependency updates / Risks / Retrospective.
4. **Keep the documents' prose language.** Compare headings by structure and count; never translate them back to English.
5. **Show the table** "document → format found → drift (sections missing, markers to convert) → action". Documents already in the current format are listed as `up to date` and never touched. Every document up to date → `COMPLETE (0 documents migrated, N up to date)`, with no write gate.

## Phase 2: Mapping
1. **Show the exact rules per document type** before anything is rendered:
   - **Roadmap → v3.1**:
     - every task line becomes `- [ ] [ID](path) · Title` + markers in the legend's order;
     - IDs are kept verbatim (a foreign scheme such as `T-12` or `H-37` stays — the format allows any stable prefix);
     - paths become file-relative inline links (a card that does not exist yet links to `backlog.md#id`, or stays a bare ID with a note);
     - `📅 sprint-NN` → the sprint heading with ISO dates;
     - "Owner decisions" → `production/decisions.md` (`D-NN`), referenced from the lines that wait on them with `⛔ [D-NN](decisions.md#d-nn)`;
     - ideas without a card → `production/backlog.md` (`I-NNN`);
     - closed sprints, the Backlog and the Legend fold into `<details>`;
     - the three-line header names the manager, the source of truth and today's date;
     - the `## Docs` board is generated from the actual files.
   - **Stories**: missing sections are added with `n/a — reason` or filled from the card's prose (criteria in prose → the Given/When/Then table, one row per criterion, test column `[to map]`); status and links kept.
   - **ADRs**: `/architecture-decision retrofit` semantics applied in bulk — an option list of at least two (the rejected alternative reconstructed from the text when it is there, otherwise `[not recorded]`), Verification added as `[to define]`; Status kept.
   - **Specs**: sections renumbered to the template, missing ones `n/a — reason`; acceptance criteria never dropped.
   - **Sprints**: the `## Retrospective` and `## Dependency updates` sections added empty where missing; the header gets
     `Status:` — `closed <date>` (the date of the retrospective commit, else of the last `⏱`/`🔗` story) when the sprint's
     roadmap block is folded or every one of its lines is `[x]`, `active` otherwise; `## Stories` rows take their status
     from the roadmap lines (the file's own column drifts as soon as a story closes without `/story-done` writing it).
2. **Questions before the render.** Anything that cannot be mapped mechanically is listed and asked as one `AskUserQuestion` with the real alternatives. Never guess it.

## Phase 3: Dry run
1. **Render each converted document in the chat message** (rule 7: a roadmap as its list, a criteria table as a table).
2. **Summary line per file**: `N lines → M lines · K IDs kept · sections added: … · questions: 0`.
3. **Compare IDs and links before and after.** Every ID of the original must still be there: `grep -oE '\b[A-Z]{1,4}-[0-9]+\b' <file> | sort -u` on the original and on the converted files; name any missing ID and fix the conversion before the write gate. IDs the migration introduces (`D-NN`, `I-NNN`) are listed separately.
4. `--dry-run` stops here with the verdict `DRY RUN (N documents ready, M questions)`.

## Phase 4: Write (one type per gate)
1. **Write gate**, one `AskUserQuestion` per type: "May I write `<the files of this type>` (N files; git history is the backup)?" — write (Recommended) · show the full diff first · skip this type. One answer never covers a second type.
2. After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker). Then write the files.
3. **Commit gate** for the batch (rule 7, `.claude/docs/git-workflow.md` § Documents), right after the write, one `AskUserQuestion`: `docs: migrate <type> to template <version>`, staging exactly the written files of this type.
   - On the default branch when no story work is in progress.
   - When HEAD is a story branch, name it and ask: switch to the default branch and commit there (Recommended — migrated documents are pipeline-wide) · commit here (the documents belong to this story) · leave uncommitted.
   - Before asking, record the gate — `<hooks>session-state.sh set Gate "/migrate Phase 4: commit <type>?"` (`<hooks>` is `.claude/hooks/` in copy mode and `${CLAUDE_PLUGIN_ROOT}/hooks/` in plugin mode) — and clear it after the answer (`<hooks>session-state.sh set Gate "—"`).
   - Nothing is committed without the answer; one commit per type, never one answer covering two types.
4. **After the roadmap**: `/help` must be able to read it. Run the read `/help` Phase 1 step 3 performs on the roadmap (the first open `- [ ]` line, plus the count of open lines) in this skill and show the result — `/help` itself is the hand-off below, not a call from here (this skill does not list `Skill`).

Verdict: `COMPLETE (N documents migrated, M up to date)` | `DRY RUN (…)` | `BLOCKED (not initialised — run /init |
no documents of this type)`. Next step — one `AskUserQuestion`: `/help` (Recommended) · migrate the next type ·
stop here.
