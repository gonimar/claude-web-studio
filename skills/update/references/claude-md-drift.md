# /update — Template drift and the CLAUDE.md studio sections

Read from Phase 2 step "Template drift" (§ Detect) and Phase 3 step "CLAUDE.md studio sections" (§ Apply). Drifted documents are never edited by `/update` (they are `/migrate`'s work); only the two studio-owned sections of `CLAUDE.md` change, behind their own gate.

## Detect (Phase 2)
For every file under `docs/templates/` that this update changes or adds, list the project documents of that type (`rules/docs-format.md` table) whose structure predates it: fewer second-level sections than the template, a roadmap without the `roadmap-format:` header, story cards without a criteria table. Show a table "document → template → drift". These documents are never edited here; they are `/migrate`'s work.

`CLAUDE.md` gets its own row: compare the project's two studio-owned sections — `## Studio (Web Studio)` and `## Working principles (non-negotiable)` — with `templates/CLAUDE.md.template`, and list the principles missing or changed (by number and title) and the Studio lines that differ. Nothing else in the file is compared; the title, `## Language`, `## Project`, `## Stack` and any section the template does not have belong to the project. A `CLAUDE.md` without the `## Studio (Web Studio)` heading has no studio block: reported as such, with `/adopt` as the command that inserts one.

## Apply (Phase 3)
Its own gate, only when § Detect found drift in `CLAUDE.md`.
1. Show the diff of the two studio-owned sections (`## Studio (Web Studio)`, `## Working principles (non-negotiable)`) between the project file and the template, with the project's own lines in them — a principle the template never had, an edited sentence — listed separately as local edits.
2. Ask one `AskUserQuestion` — "May I write the two studio sections of `CLAUDE.md`?": replace both sections with the template's and append my own principles after its list (Recommended) · replace both sections, drop my lines · keep as is.
3. On a replace: `touch .claude/.write-consent`, and copy the current file to `.claude/local-overrides/CLAUDE.md` first.
4. `Edit` each section from its heading to the next `## ` heading (or the end of the file) — never the title, `## Language`, `## Project`, `## Stack` or any other section, which the project owns.
5. The project's own principles keep their text and are renumbered after the template's list.
6. Show the resulting two sections in the chat (rule 7, an update shows the changed rows). A file without the studio block is not edited here (`/adopt` inserts it).
