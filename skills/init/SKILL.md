---
name: init
description: "One-time studio scaffolding for a project: asks the conversation language and review mode, creates/updates CLAUDE.md sections, seeds .claude/docs (stack reference, templates, roster), .claude/rules, docs/ and production/ folders, and merges settings (permissions/statusline). Run first in plugin mode; copy mode runs it to set the language."
argument-hint: "[--language <name>] [--review full|lean|solo] [--plugin-root <path>]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, AskUserQuestion
model: sonnet
---

# Init — scaffold the studio in this project

Writes files only after "May I write …?" → "yes".

## Phase 1: Locate the studio files
Source of seed files, in order: `--plugin-root`; the "Plugin root:" line printed by the session-start
hook; `claude plugin list --json` (entry `web-studio`, its install path); `.claude/docs/stack-reference/index.md`
already present (copy mode — nothing to seed). If none is found, ask the user for the path to the
plugin/kit directory. Seed layout: `<root>/docs` → `.claude/docs`, `<root>/rules` → `.claude/rules`,
`<root>/templates/CLAUDE.md.template`, `<root>/templates/settings.plugin-mode.json`, `<root>/templates/statusline.sh`,
`<root>/docs/PROJECT-README.md` → `docs/web-studio/README.md`.

## Phase 2: Language and review mode
`AskUserQuestion`: "Which language should we use for conversation and documents?" (options: English,
the user's message language if different, Other). Then review mode: `lean` (recommended for solo),
`full`, `solo`. `--language`/`--review` skip the questions.

## Phase 3: Plan
Show what will be created or changed:
- `CLAUDE.md`: create from the template with the language filled in, or (if it exists) insert the
  `## Language`, `## Studio (Web Studio)`, `## Stack` and `## Working principles` sections without
  touching other content — show the exact insertion.
- `.claude/docs/` (stack-reference, templates, roster, coordination, workflow catalog, technical-preferences with `[TO BE CONFIGURED]`) — copy only files that do not exist; list existing ones that differ.
- `.claude/rules/` — same policy.
- `.claude/settings.json`: create from `settings.plugin-mode.json` (permissions + statusline) or show a diff of `permissions.allow/deny` and `statusLine` to merge; hooks are provided by the plugin (copy mode: hooks already in `settings.json`).
- `.claude/statusline.sh`, `docs/web-studio/README.md`, `docs/{specs,architecture,security,ops}`, `production/{sprints,stories,releases,session-state,session-logs}`, `production/review-mode.txt`, `production/stage.txt` = `discovery`, `.gitignore` entries (`production/session-state/`, `production/session-logs/`, `.claude/settings.local.json`, `.claude/agent-memory-local/`).
"May I write these files?"

## Phase 4: Write and verify
Apply; print the tree of created files; run `bash .claude/statusline.sh </dev/null` as a smoke check.
Record the version in `.claude/.web-studio-version` (from `plugin.json`).

Verdict: `INITIALISED` | `ALREADY INITIALISED (N files differ)`. Next step: `/start` (new project) or `/adopt` (existing code).
