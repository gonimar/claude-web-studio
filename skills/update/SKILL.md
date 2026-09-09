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
Plugin mode: `claude plugin list --json` shows `web-studio` → current plugin version and install path.
Copy mode: `.claude/.web-studio-version` exists and `.claude/agents/technical-director.md` is present → kit path from `--kit`, or ask.
Read the kit's `CHANGELOG.md` (from the plugin cache or the kit repo) and show entries newer than the installed version.

## Phase 2: What will change
Plugin mode: `claude plugin update web-studio` updates agents/skills/hooks automatically; then compare the plugin's `docs/` and `rules/` with `.claude/docs` and `.claude/rules` (`diff -rq`) — list files that differ and whether the difference is a local edit (present only in the project) or an upstream update.
Copy mode: `install.sh <project> --dry-run`; the same diff for locally edited files.

## Phase 3: Apply
"Update v[X] → v[Y]? Locally edited files [list] would be overwritten — keep copies in `.claude/local-overrides/`?"
After "yes", **before copying anything**, re-read the installed version: plugin mode — `claude plugin list --json`
again; copy mode — the kit's `.claude-plugin/plugin.json`. Compare it with the version this session's skills come
from (the last path segment of the skill's base directory or of the "Plugin root:" line). The gate may have stayed
open for a long time and the plugin may have been updated meanwhile: seeding `docs/` and `rules/` from the session's
cache would stamp `.claude/.web-studio-version` with a version that is no longer installed. If the two differ: print
one line — "this session runs v[X'], v[Z] is installed: restart the session so that skills, hooks and the seed files
come from v[Z]" — and stop with the verdict `RESTART REQUIRED`; never apply from the session's copy.
Otherwise: copies → update/install → `git status` → summary of changed files.
Project data (`docs/specs`, `docs/architecture`, `production/`, a configured `technical-preferences.md`, `CLAUDE.md`) is never touched — verify and state it in the output.

Verdict: `UPDATED` | `UP TO DATE` | `DRY RUN` | `RESTART REQUIRED`. Next step — one `AskUserQuestion`: commit the update (Recommended) · `/skill-test static all` (if the testing framework is installed) · stop here.
