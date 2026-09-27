# /update — Hybrid install and listing fallbacks

Read from Phase 1 when the plugin is installed *and* `.claude/agents/` or `.claude/skills/` carry studio files (§ Detect), from Phase 3 to remove the copies (§ Remove), and when `claude plugin list --json` cannot be used (§ Fallback evidence). `<cache>/<version>` is the SKILL.md glossary entry. Commands named in this state are the plugin's (`/web-studio:` prefix) unless the text says otherwise.

## Fallback evidence (Phase 1, plugin mode)
- The form without `--json` cannot be used to select this project's row: its blocks carry Version, Scope and Status and no project path.
- JSON unavailable → the fallback evidence is the update command's own line (`Plugin "web-studio" updated from X to Y for scope <scope> (<project path>)`) and the cache directory `<cache>/<version>`.

## Detect (Phase 1)
Both at once is a third mode, not a contradiction: the plugin is installed *and* `.claude/agents/` or `.claude/skills/` carry studio files. The project copies shadow the plugin by name, so a bare `/help` runs the copy while `/web-studio:help` runs the plugin.
- Report it as `HYBRID INSTALL`.
- Establish the copy's real version instead of trusting `.claude/.web-studio-version`: compare `.claude/skills/*/SKILL.md` and `.claude/agents/*.md` with each cached version (`<cache>/<version>`) and name the one they match byte for byte (`cmp`). The stamp is evidence of nothing: it can name a version whose files were never seeded.
- List one by one the files that match no cached version: the local edits and the project's own additions (a kit's skill and agent).
- Everything that matches a cached version can be removed without loss.

## Remove (Phase 3)
The update is not finished while the copies shadow the plugin: the project keeps running the copy's older skills from `.claude/skills/` whenever a command is typed without the `web-studio:` prefix.
1. Offer the removal as its own gate, with the list from § Detect: what matches a cached version is deleted, what matches none is kept and named.
2. Move agent memory written under the copy's names to the plugin's: `.claude/agent-memory/<agent>` → `.claude/agent-memory/web-studio-<agent>`. Where both carry `MEMORY.md`, append its pointer lines, never overwrite.
3. Read `.claude/settings.json` for a `hooks` section pointing at `.claude/hooks/`. Without one, those copies never ran and the plugin's own `hooks.json` is what fires. With one, rewire the hooks before the files go.
4. Delete the matched copies and the stamp (`.claude/.web-studio-version`).
5. Close the step with one line: "restart the session — removing `.claude/skills` empties the skill registry of the session that is running".
