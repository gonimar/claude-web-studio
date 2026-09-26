---
name: update
description: "Updates the Web Studio itself in this project — plugin mode: claude plugin update + re-seed changed docs/rules with a diff; copy mode: re-run install.sh from the kit repository. Shows CHANGELOG deltas, preserves local edits, never touches project data."
argument-hint: "[--kit <path-to-repo>] [--dry-run]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Edit, AskUserQuestion
---

# Update the studio

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

In the steps below, `<cache>/<version>` is `~/.claude/plugins/cache/claude-web-studio/web-studio/<version>/`, **this project's row** is the entry of `claude plugin list --json` selected in Phase 1 step 1, and `<hooks>` is `.claude/hooks/` in copy mode and `${CLAUDE_PLUGIN_ROOT}/hooks/` in plugin mode.

## Phase 1: Detect the mode and versions
1. **Plugin mode — select this project's row.**
   - Run `claude plugin list --json`. Its output covers every project on this machine, so the row is selected, never taken as the first match.
   - Select the row whose `projectPath` is this project's root (`git rev-parse --show-toplevel`) and whose `installPath` contains `claude-web-studio/web-studio`. It carries the version, the scope and the install path.
   - No such row → the plugin is not installed *here* (copy mode, or an install at `user` scope). Say that; never read a neighbour's row. With several projects on different versions side by side, a project on 0.10.0 otherwise reads a neighbour's 0.10.1 and reports itself up to date.
   - The form without `--json` cannot be used for this: its blocks carry Version, Scope and Status and no project path.
   - JSON unavailable → the fallback evidence is the update command's own line (`Plugin "web-studio" updated from X to Y for scope <scope> (<project path>)`) and the cache directory `<cache>/<version>`.
2. **Copy mode**: `.claude/.web-studio-version` exists and `.claude/agents/technical-director.md` is present. The kit path comes from `--kit`, or ask for it.
3. **Hybrid install.** Both at once is a third mode, not a contradiction: the plugin is installed *and* `.claude/agents/` or `.claude/skills/` carry studio files. The project copies shadow the plugin by name, so a bare `/help` runs the copy while `/web-studio:help` runs the plugin.
   - Report it as `HYBRID INSTALL`.
   - Establish the copy's real version instead of trusting `.claude/.web-studio-version`: compare `.claude/skills/*/SKILL.md` and `.claude/agents/*.md` with each cached version (`<cache>/<version>`) and name the one they match byte for byte (`cmp`). The stamp is evidence of nothing (a project stamped 0.5.8 had 0.4.3 files).
   - List one by one the files that match no cached version: the local edits and the project's own additions (a kit's skill and agent).
   - Everything that matches a cached version can be removed without loss.
4. **Changelog.** Read the kit's `CHANGELOG.md` (from the plugin cache or the kit repo) and show the entries newer than the installed version.

## Phase 2: What will change
With `--dry-run`, the plugin update command is shown and not run, and the skill stops after this phase with `DRY RUN`.

1. **Plugin mode.**
   - Take the install scope (`user` | `project` | `local`) from this project's row.
   - Update in that scope: `claude plugin update web-studio --scope <scope>` (`-y` as well when the session is non-interactive). The bare command assumes `user` and fails with `Plugin "web-studio" is not installed at scope user` in every project installed with `--scope local`.
   - If the scope cannot be read, print the candidates and let the owner choose. Never guess.
   - Running `/update` is the consent for this command: it changes only the plugin's own install, never a file of the project. The project's files change only after the Phase 3 gate.
   - The update brings agents/skills/hooks. Then compare the plugin's `docs/` and `rules/` with `.claude/docs` and `.claude/rules` (`diff -rq`). List the files that differ and whether each difference is a local edit (present only in the project) or an upstream update.
2. **Copy mode**: `install.sh <project> --dry-run`, and the same diff for locally edited files.
3. **Template drift.** For every file under `docs/templates/` that this update changes or adds, list the project documents of that type (`rules/docs-format.md` table) whose structure predates it: fewer second-level sections than the template, a roadmap without the `roadmap-format:` header, story cards without a criteria table. Show a table "document → template → drift". These documents are never edited here; they are `/migrate`'s work.
   - `CLAUDE.md` gets its own row: compare the project's two studio-owned sections — `## Studio (Web Studio)` and `## Working principles (non-negotiable)` — with `templates/CLAUDE.md.template`, and list the principles missing or changed (by number and title) and the Studio lines that differ. Nothing else in the file is compared; the title, `## Language`, `## Project`, `## Stack` and any section the template does not have belong to the project. A `CLAUDE.md` without the `## Studio (Web Studio)` heading has no studio block: reported as such, with `/adopt` as the command that inserts one.

## Phase 3: Apply
1. **Print the locally edited files** before the question: present only in the project, or differing from the plugin in a way the plugin's own history does not explain (e.g. a project column added to `agent-roster.md`).
2. **Ask** one `AskUserQuestion`: "Seed v[Y] into the project (v[X] files now)? Locally edited files [list] would be overwritten — keep copies in `.claude/local-overrides/`?" The options always include "keep copies in `.claude/local-overrides/` and re-apply after seeding". The skill never decides on its own that a local edit "is duplicated elsewhere" and may be dropped. After the "seed" answer: `touch .claude/.write-consent` (rule 7 — the seeding of step 5 and the copies of step 4 are writes).
3. **Re-read the installed version** after "yes", before copying anything. The gate may have stayed open for a long time and the plugin may have been updated meanwhile; seeding from the session's cache would then stamp `.claude/.web-studio-version` with a version that is no longer installed.
   - Plugin mode: `claude plugin list --json` again, selecting this project's row by `projectPath` exactly as Phase 1 did. Copy mode: the kit's `.claude-plugin/plugin.json`.
   - Plugin mode: compare it with the version this session's skills come from — the `<cache>/<version>` directory in the "Plugin root:" line. If the two differ, print one line — "this session runs v[X'], v[Z] is installed: restart the session so that skills, hooks and the seed files come from v[Z]" — and stop with the verdict `RESTART REQUIRED`. Never apply from the session's copy.
   - Copy mode: the session's skills are the project's old copies, so they are never the seed source and no restart is needed; compare the kit's `plugin.json` with the v[Y] the gate named instead. If the kit moved on while the gate was open, show the new version and its changelog entries and ask the gate again for that version; never seed a version the user did not see.
4. **Copies**: when the answer asked for them, copy the locally edited files to `.claude/local-overrides/`.
5. **Update/install and seed.** Seeding is one command, never a hand-written `cp -r`:
   - Plugin mode: `<cache>/<installed version>/install.sh <project root> --seed-only`.
   - Copy mode: the kit's `install.sh <project root>` without the flag.
   - That script is the only implementation of the rule that excludes a configured `technical-preferences.md` and leaves `.claude/local-overrides/` alone. A hand-written `cp -r .../docs/* .claude/docs/` has overwritten a filled `technical-preferences.md` in real projects: it is project data living inside a seeded directory, so the rule does not enforce itself.
6. **Check instead of asserting**: `git diff --quiet .claude/docs/technical-preferences.md`. Clean → print `technical-preferences.md: kept (configured)`. Not clean → restore it (`git checkout -- .claude/docs/technical-preferences.md`) and say so in the summary and in the commit message.
7. **Re-apply `.claude/local-overrides/`** as an explicit step with a diff per file, not a promise made at the gate.
8. **`CLAUDE.md` studio sections**, its own gate, only when Phase 2 found drift there. Show the diff of the two studio-owned sections (`## Studio (Web Studio)`, `## Working principles (non-negotiable)`) between the project file and the template, with the project's own lines in them — a principle the template never had, an edited sentence — listed separately as local edits. Then one `AskUserQuestion` — "May I write the two studio sections of `CLAUDE.md`?": replace both sections with the template's and append my own principles after its list (Recommended) · replace both sections, drop my lines · keep as is. On a replace: `touch .claude/.write-consent`, copy the current file to `.claude/local-overrides/CLAUDE.md` first; then `Edit` each section from its heading to the next `## ` heading (or the end of the file) — never the title, `## Language`, `## Project`, `## Stack` or any other section, which the project owns; the project's own principles keep their text and are renumbered after the template's list. A file without the studio block is not edited here (`/adopt` inserts it). Show the resulting two sections in the chat (rule 7, an update shows the changed rows).
9. **Summary**: `git status`, then the summary of changed files.
10. **Version stamp.** `.claude/.web-studio-version` is written **only in copy mode**. In plugin mode the installed version is what `claude plugin list --json` reports; a stamp left from an earlier copy install is deleted together with the copy (step 11). A stamp naming a version whose files are not in the project is worse than no stamp at all.
11. **Hybrid install** (Phase 1 said so). The update is not finished while the copies shadow the plugin: the project keeps running last month's skills from `.claude/skills/` whenever a command is typed without the `web-studio:` prefix.
    1. Offer the removal as its own gate, with the list from Phase 1: what matches a cached version is deleted, what matches none is kept and named.
    2. Move agent memory written under the copy's names to the plugin's: `.claude/agent-memory/<agent>` → `.claude/agent-memory/web-studio-<agent>`. Where both carry `MEMORY.md`, append its pointer lines, never overwrite.
    3. Read `.claude/settings.json` for a `hooks` section pointing at `.claude/hooks/`. Without one, those copies never ran and the plugin's own `hooks.json` is what fires. With one, rewire the hooks before the files go.
    4. Delete the matched copies and the stamp.
    5. Close the step with one line: "restart the session — removing `.claude/skills` empties the skill registry of the session that is running".
12. **Project data** (`docs/specs`, `docs/architecture`, `production/`, a configured `technical-preferences.md`, and `CLAUDE.md` outside its two studio-owned sections) is never touched; the studio sections of `CLAUDE.md` change only behind the step 8 gate, with the previous file kept in `.claude/local-overrides/`. State it in the output only after the step 6 check has run.

Verdict: `UPDATED` | `UPDATED (N documents need /migrate)` | `UPDATED (hybrid install removed — restart the session)` | `HYBRID INSTALL` (reported, removal declined) | `UP TO DATE` | `DRY RUN` | `RESTART REQUIRED`. Next step — one `AskUserQuestion`: commit the update (Recommended) · `/migrate all --dry-run` (Recommended instead when documents drifted — the update is not finished while `/help` cannot read them) · `/skill-test static all` (if the testing framework is installed) · stop here. The "commit the update" option is this skill's commit gate (`docs: update Web Studio vX -> vY`, staging exactly the seeded files — `.claude/docs/`, `.claude/rules/`, the `CLAUDE.md` studio sections and, in copy mode, `.claude/.web-studio-version`; git-workflow.md § Documents): before asking, record it — `<hooks>session-state.sh set Gate "/update Phase 3: commit?"` — and clear it after the answer (`<hooks>session-state.sh set Gate "—"`); nothing is committed without the answer.
