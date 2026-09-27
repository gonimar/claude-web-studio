# /help — reference modes (`commands` · `guide [topic]`)

Read from `SKILL.md` Phase 0 when the argument is `commands` or `guide [topic]`. Two arguments answer a reference question instead of "what next". They end without the closing `AskUserQuestion`, because there is nothing to decide (rule 7). `<plugin root>` and the command namespaces are the ones SKILL.md names.

**`commands`** — every command with its description. Source: the skills themselves, never memory.
1. Glob `<plugin root>/skills/*/SKILL.md` and `.claude/skills/*/SKILL.md` (copy mode, and project-local skills).
2. From each frontmatter read `name:`, `description:` (first sentence) and `argument-hint:`.
3. Group by the phases of `.claude/docs/workflow-catalog.yaml`, in catalog order; a skill in no phase goes under "Maintenance and teams".
4. One line per command: `/name <argument-hint> — first sentence of the description`. Mark the catalog's required steps with `*`.
5. Then one line: `Details: /help guide · .claude/docs/playbook.md · README of the plugin`.

**`guide [topic]`** — the playbook.
1. **Find it**: `.claude/docs/playbook.md` (seeded by `/init`/`/update`), else `<plugin root>/docs/playbook.md`. When the project's conversation language has a translation in `.claude/docs/readme/PLAYBOOK.<lang>.md`, prefer it. Playbook missing everywhere → one line, `playbook not seeded — run /update`, and stop.
2. **Without a topic**: print the playbook's table of contents (its `##` and `###` headings with numbers) and the line `/help guide <topic> prints one section`.
3. **With a topic**: find the section that matches best.
   - A section number like `10.7`, or a case-insensitive match on the heading text **or on the first line of a section**.
   - Playbook headings are in the file's language, so also match the obvious synonyms the user would use: "hotfix", "secret", "release", "session", "CI".
   - Several matches → the section whose heading matches wins, then the earliest.
4. **Print that section verbatim**, then the numbers of up to three related sections. Never paraphrase or shorten a printed section.
5. **No match** → the table of contents with `no section matches "<topic>"`.

Verdict for both: `READY`. End with a text line, not a question.
