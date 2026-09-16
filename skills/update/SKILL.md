---
name: update
description: "Updates the Web Studio itself in this project — plugin mode: claude plugin update + re-seed changed docs/rules with a diff; copy mode: re-run install.sh from the kit repository. Shows CHANGELOG deltas, preserves local edits, never touches project data."
argument-hint: "[--kit <path-to-repo>] [--dry-run]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, AskUserQuestion
model: haiku
---

# Update the studio

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

## Phase 1: Detect the mode and versions
Plugin mode: `claude plugin list --json` — **its output covers every project on this machine**, so the row is selected, never taken as the first match: the one whose `projectPath` is this project's root (`git rev-parse --show-toplevel`) and whose `installPath` contains `claude-web-studio/web-studio` carries the version, the scope and the install path. No such row means the plugin is not installed *here* — copy mode, or an install at `user` scope — and the skill says that instead of reading a neighbour's row: with four projects on three different versions side by side, a project on 0.10.0 otherwise reads a neighbour's 0.10.1 and reports itself up to date. The form without `--json` cannot be used for this at all — its blocks carry Version, Scope and Status and no project path. If the JSON is unavailable, the update command's own line (`Plugin "web-studio" updated from X to Y for scope <scope> (<project path>)`) and the cache directory `~/.claude/plugins/cache/claude-web-studio/web-studio/<version>/` are the fallback evidence.
Copy mode: `.claude/.web-studio-version` exists and `.claude/agents/technical-director.md` is present → kit path from `--kit`, or ask.
**Both at once is a third mode, not a contradiction.** When the plugin is installed *and* `.claude/agents/` or `.claude/skills/` carry studio files, the project runs a hybrid: the project copies shadow the plugin by name, so a bare `/help` runs the copy while `/web-studio:help` runs the plugin. Report it as `HYBRID INSTALL` and establish the copy's real version instead of trusting `.claude/.web-studio-version` — compare `.claude/skills/*/SKILL.md` and `.claude/agents/*.md` with each cached version (`~/.claude/plugins/cache/claude-web-studio/web-studio/<version>/`) and name the one they match byte for byte. Files that match no cached version are the local edits and the project's own additions (a kit's skill and agent): list them one by one. Everything that matches a cached version can be removed without loss, and the stamp is evidence of nothing — a project stamped 0.5.8 while its files were 0.4.3.
Read the kit's `CHANGELOG.md` (from the plugin cache or the kit repo) and show entries newer than the installed version.

## Phase 2: What will change
Plugin mode: take the install scope from the row Phase 1 selected — the one matching this project's `projectPath` (`user` | `project` | `local`) and update in it — `claude plugin update web-studio --scope <scope>` (`-y` as well when the session is non-interactive). The bare command assumes `user` and fails with `Plugin "web-studio" is not installed at scope user` in every project installed with `--scope local`; if the scope cannot be read, print the candidates and let the owner choose — never guess. The update brings agents/skills/hooks; then compare the plugin's `docs/` and `rules/` with `.claude/docs` and `.claude/rules` (`diff -rq`) — list files that differ and whether the difference is a local edit (present only in the project) or an upstream update.
Copy mode: `install.sh <project> --dry-run`; the same diff for locally edited files.
**Template drift**: for every file under `docs/templates/` that this update changes or adds, list the project documents of that type (`rules/docs-format.md` table) whose structure predates it — fewer second-level sections than the template, a roadmap without the `roadmap-format:` header, story cards without a criteria table; a table "document → template → drift". These are never edited here; they are `/migrate`'s work.

## Phase 3: Apply
"Update v[X] → v[Y]? Locally edited files [list] would be overwritten — keep copies in `.claude/local-overrides/`?"
The list of locally edited files (present only in the project, or differing from the plugin in a way the plugin's own
history does not explain — e.g. a project column added to `agent-roster.md`) is printed **before** the question, and the
question always carries the option "keep copies in `.claude/local-overrides/` and re-apply after seeding"; the skill never
decides on its own that a local edit "is duplicated elsewhere" and may be dropped.
After "yes", **before copying anything**, re-read the installed version: plugin mode — `claude plugin list --json`
again, selecting the row by `projectPath` exactly as Phase 1 did; copy mode — the kit's `.claude-plugin/plugin.json`. Compare it with the version this session's skills come
from (the last path segment of the skill's base directory or of the "Plugin root:" line). The gate may have stayed
open for a long time and the plugin may have been updated meanwhile: seeding `docs/` and `rules/` from the session's
cache would stamp `.claude/.web-studio-version` with a version that is no longer installed. If the two differ: print
one line — "this session runs v[X'], v[Z] is installed: restart the session so that skills, hooks and the seed files
come from v[Z]" — and stop with the verdict `RESTART REQUIRED`; never apply from the session's copy.
Otherwise: copies → update/install → seeding → `git status` → summary of changed files.
**Seeding is one command, never a hand-written `cp -r`**: `<plugin cache>/<installed version>/install.sh <project root> --seed-only`
(copy mode: the same `install.sh` without the flag). That script is the only implementation of the rule below — it
excludes a configured `technical-preferences.md` and leaves `.claude/local-overrides/` alone. `cp -r .../docs/* .claude/docs/`
written by hand has overwritten a filled `technical-preferences.md` in real projects: it is project data living inside a
seeded directory, so the rule does not enforce itself.
After seeding, check instead of asserting: `git diff --quiet .claude/docs/technical-preferences.md` — print
`technical-preferences.md: kept (configured)` when it is clean, and when it is not, restore it
(`git checkout -- .claude/docs/technical-preferences.md`) and say so in the summary and in the commit message.
Re-applying `.claude/local-overrides/` is an explicit step with a diff per file, not a promise made at the gate.
**Hybrid install** (Phase 1 said so): the update is not finished while the copies shadow the plugin — the project keeps running last month's skills from `.claude/skills/` whenever a command is typed without the `web-studio:` prefix. Offer the removal as its own gate, with the list from Phase 1: what matches a cached version is deleted, what matches none is kept and named. Two checks come first. Agent memory written under the copy's names moves to the plugin's — `.claude/agent-memory/<agent>` → `.claude/agent-memory/web-studio-<agent>`; where both carry `MEMORY.md`, its pointer lines are appended, never overwritten. And `.claude/settings.json` is read for a `hooks` section pointing at `.claude/hooks/`: without one those copies never ran and the plugin's own `hooks.json` is what fires, with one there the hooks must be rewired before the files go. Close the step with one line: "restart the session — removing `.claude/skills` empties the skill registry of the session that is running".
`.claude/.web-studio-version` is written **only in copy mode**. In plugin mode the installed version is what `claude plugin list --json` reports, and a stamp left from an earlier copy install is deleted together with the copy: a stamp naming a version whose files are not in the project is worse than no stamp at all.
Project data (`docs/specs`, `docs/architecture`, `production/`, a configured `technical-preferences.md`, `CLAUDE.md`) is never touched — state it in the output only after the check above has run.

Verdict: `UPDATED` | `UPDATED (N documents need /migrate)` | `UPDATED (hybrid install removed — restart the session)` | `HYBRID INSTALL` (reported, removal declined) | `UP TO DATE` | `DRY RUN` | `RESTART REQUIRED`. Next step — one `AskUserQuestion`: commit the update (Recommended) · `/migrate all --dry-run` (Recommended instead when documents drifted — the update is not finished while `/help` cannot read them) · `/skill-test static all` (if the testing framework is installed) · stop here.
