---
name: update
description: "Updates the Web Studio itself in this project — plugin mode: claude plugin update + re-seed changed docs/rules with a diff; copy mode: re-run install.sh from the kit repository. Shows CHANGELOG deltas, preserves local edits, never touches project data."
argument-hint: "[--kit <path-to-repo>] [--dry-run]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, AskUserQuestion
model: haiku
---

# Update the studio

## Phase 1: Detect the mode and versions
Plugin mode: `claude plugin list --json` shows `web-studio` → current plugin version and install path.
Copy mode: `.claude/.web-studio-version` exists and `.claude/agents/technical-director.md` is present → kit path from `--kit`, or ask.
Read the kit's `CHANGELOG.md` (from the plugin cache or the kit repo) and show entries newer than the installed version.

## Phase 2: What will change
Plugin mode: `claude plugin update web-studio` updates agents/skills/hooks automatically; then compare the plugin's `docs/` and `rules/` with `.claude/docs` and `.claude/rules` (`diff -rq`) — list files that differ and whether the difference is a local edit (present only in the project) or an upstream update.
Copy mode: `install.sh <project> --dry-run`; the same diff for locally edited files.

## Phase 3: Apply
"Update v[X] → v[Y]? Locally edited files [list] would be overwritten — keep copies in `.claude/local-overrides/`?"
After "yes": copies → update/install → `git status` → summary of changed files.
Project data (`docs/specs`, `docs/architecture`, `production/`, a configured `technical-preferences.md`, `CLAUDE.md`) is never touched — verify and state it in the output.

Verdict: `UPDATED` | `UP TO DATE` | `DRY RUN`. Next step: commit; `/skill-test static all` if the testing framework is installed.
