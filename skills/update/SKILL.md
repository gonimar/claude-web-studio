---
name: update
description: "Updates the Web Studio itself in this project — plugin mode: claude plugin update + re-seed changed docs/rules with a diff; copy mode: re-run install.sh from the kit repository. Shows CHANGELOG deltas, preserves local edits, never touches project data."
argument-hint: "[--kit <path-to-repo>] [--dry-run]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Edit, AskUserQuestion
---

# Update the studio

Language, `<hooks>`, command namespaces, gate mechanics and the documents-lane commit gate: `docs/coordination-rules.md` § Skill conventions.

Glossary:
- `<cache>/<version>` — `~/.claude/plugins/cache/claude-web-studio/web-studio/<version>/`.
- **this project's row** — the entry of `claude plugin list --json` selected in Phase 1, step "Plugin mode".
- v[X] — the installed version; v[Y] — the version this update brings.

## Phase 1: Detect the mode and versions
1. **Plugin mode — select this project's row.**
   1. Run `claude plugin list --json`. Its output covers every project on this machine, so the row is selected, never taken as the first match.
   2. Select the row whose `projectPath` is this project's root (`git rev-parse --show-toplevel`) and whose `installPath` contains `claude-web-studio/web-studio`. It carries the version, the scope and the install path.
   3. No such row → the plugin is not installed *here* (copy mode, or an install at `user` scope). Say that; never read a neighbour's row — a neighbour on a newer version reports this project as up to date.
   4. The form without `--json` carries no project path and cannot select the row; JSON unavailable → read `references/hybrid-install.md` § Fallback evidence.
2. **Copy mode**: `.claude/.web-studio-version` exists and `.claude/agents/technical-director.md` is present. The kit path comes from `--kit`, or ask for it.
3. **Hybrid install** — the plugin is installed *and* `.claude/agents/` or `.claude/skills/` carry studio files, a third mode: read `references/hybrid-install.md` § Detect; report `HYBRID INSTALL`, take the copy's real version from `cmp` against the cached versions (never from the stamp), list the files that match none.
4. **Changelog.** Read the kit's `CHANGELOG.md` (plugin cache or kit repo) and show the entries newer than the installed version.

## Phase 2: What will change
With `--dry-run`, the plugin update command is shown and not run, and the skill stops after this phase with `DRY RUN`; step "Diff" then compares against the installed `<cache>/<v[X]>`, so it shows local edits only — upstream changes are visible only in the CHANGELOG.

1. **Plugin mode — update.**
   1. Take the install scope (`user` | `project` | `local`) from this project's row.
   2. Update in that scope: `claude plugin update web-studio --scope <scope>` (`-y` as well when the session is non-interactive). The bare command assumes `user` and fails (`Plugin "web-studio" is not installed at scope user`) at any other scope (e.g. `--scope local`).
   3. If the scope cannot be read, print the candidates and let the owner choose. Never guess.
   4. Running `/update` is the consent for this command — an explicit exception to rule 7: it changes only the plugin's own install, never a file of the project, whose files change only after the Phase 3 seed gate.
2. **Diff.** The update brings agents/skills/hooks. Compare the plugin's `docs/` and `rules/` (`<cache>/<v[Y]>`) with `.claude/docs` and `.claude/rules` (`diff -rq`); list the files that differ and whether each is a local edit (present only in the project) or an upstream update.
   - Copy mode: `install.sh <project> --dry-run`, and the same diff for locally edited files.
3. **Template drift.** For every file under `docs/templates/` this update changes or adds, and for the two studio-owned sections of `CLAUDE.md`: read `references/claude-md-drift.md` § Detect and show the table "document → template → drift" (`CLAUDE.md` gets its own row). Nothing is edited here — the documents are `/migrate`'s work, and a `CLAUDE.md` without the `## Studio (Web Studio)` heading is reported with `/adopt` as the command that inserts it.

## Phase 3: Apply
1. **Session check** (plugin mode), before the gate so that no answer is lost to a restart: re-read the installed version (`claude plugin list --json`, this project's row by `projectPath` as in Phase 1) and compare it with the version this session's skills come from — the `<cache>/<version>` directory in the "Plugin root:" line. If they differ, print "this session runs v[X'], v[Z] is installed: restart the session so that skills, hooks and the seed files come from v[Z]" and stop with `RESTART REQUIRED`. Never apply from the session's copy.
   - Copy mode: the session's skills are the project's old copies, never the seed source, so no restart is needed; the kit's `.claude-plugin/plugin.json` names v[Y].
2. **Print the locally edited files** before the question: present only in the project, or differing from the plugin in a way its own history does not explain (e.g. a project column added to `agent-roster.md`).
3. **Seed gate**, one `AskUserQuestion`: "May I write the seed files — v[Y] into the project (v[X] files now)? Locally edited files [list] would be overwritten — keep copies in `.claude/local-overrides/`?" The options always include "keep copies in `.claude/local-overrides/` and re-apply after seeding". The skill never decides on its own that a local edit "is duplicated elsewhere" and may be dropped.
4. **After "seed"**: `touch .claude/.write-consent` (rule 7 — the seeding and the copies below are writes). Then re-read the installed version once more before copying anything — the plugin may have been updated while the gate was open, and a seed from the session's cache would stamp a version no longer installed. Plugin mode: repeat the session check; a mismatch ends with `RESTART REQUIRED`, nothing seeded, the gate asked again after the restart. Copy mode: compare the kit's `plugin.json` with the v[Y] the gate named; if the kit moved on, show the new version and its changelog entries and ask the gate again — never seed a version the user did not see.
5. **Copies**: when the answer asked for them, copy the locally edited files to `.claude/local-overrides/`.
6. **Update/install and seed.** Seeding is one command, never a hand-written `cp -r`:
   - Plugin mode: `<cache>/<installed version>/install.sh <project root> --seed-only`.
   - Copy mode: the kit's `install.sh <project root>` without the flag.
   - That script is the only implementation of the rule that excludes a configured `technical-preferences.md` and leaves `.claude/local-overrides/` alone; a hand-written `cp -r` overwrites a filled `technical-preferences.md` — project data inside a seeded directory.
7. **Check instead of asserting**: `git diff --quiet .claude/docs/technical-preferences.md`. Clean → print `technical-preferences.md: kept (configured)`. Not clean → restore it (`git checkout -- .claude/docs/technical-preferences.md`) and say so in the summary and in the commit message.
8. **Re-apply `.claude/local-overrides/`** as an explicit step with a diff per file, not a promise made at the gate.
9. **`CLAUDE.md` studio sections**, its own gate, only when Phase 2 found drift there: read `references/claude-md-drift.md` § Apply — its six steps: the diff of the two sections (the project's own lines listed as local edits); the gate "May I write the two studio sections of `CLAUDE.md`?" (replace and append my principles (Recommended) · replace, drop my lines · keep as is); on a replace: consent marker, previous file to `.claude/local-overrides/CLAUDE.md`, `Edit` of the two sections only, result shown in the chat.
10. **Summary**: `git status`, then the summary of changed files.
11. **Version stamp.** `.claude/.web-studio-version` is written **only in copy mode**; in plugin mode the installed version is what `claude plugin list --json` reports, and a stamp from an earlier copy install goes with the copy (step "Hybrid install") — a stamp naming files the project does not hold sends the next run down the copy-mode branch.
12. **Hybrid install** (Phase 1 said so): the update is not finished while the copies shadow the plugin. Read `references/hybrid-install.md` § Remove and follow its five steps — removal gate with the Phase 1 list, agent memory moved, `.claude/settings.json` hooks checked, matched copies and stamp deleted, the "restart the session" line.
13. **Project data** (`docs/specs`, `docs/architecture`, `production/`, a configured `technical-preferences.md`, `CLAUDE.md` outside its two studio-owned sections) is never touched; the studio sections change only behind the gate of step "CLAUDE.md studio sections", the previous file kept in `.claude/local-overrides/`. State it only after step "Check instead of asserting" has run.

## Phase 4: Commit
The commit gate (§ Skill conventions, documents-lane commit gate; git-workflow.md § Documents): `docs: update Web Studio vX -> vY`, staging exactly the seeded files — `.claude/docs/`, `.claude/rules/`, the `CLAUDE.md` studio sections and, in copy mode, `.claude/.web-studio-version`. Nothing is committed without the answer.
1. Record it: `<hooks>session-state.sh set Gate "/update Phase 3: commit?"`.
2. Ask the Next-step question below; its "commit the update" option is this gate.
3. On "commit": `git add` the listed paths, then `git commit -m "docs: update Web Studio vX -> vY"`.
4. After the answer: `<hooks>session-state.sh set Gate "—"`.

Verdict: `UPDATED` | `UPDATED (N documents need /migrate)` | `UPDATED (hybrid install removed — restart the session)` | `HYBRID INSTALL` (reported, removal declined) | `UP TO DATE` | `DRY RUN` | `RESTART REQUIRED`.

Next step — one `AskUserQuestion`: commit the update (Recommended) · `/migrate all --dry-run` (Recommended instead when documents drifted — the update is not finished while `/help` cannot read them) · `/skill-test static all` (if the testing framework is installed) · stop here.
