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
Reply in the project conversation language (CLAUDE.md → Language); until CLAUDE.md exists, the
language chosen in Phase 2 binds instead. Code, identifiers, paths and commit messages stay in English.

## Phase 1: Locate the studio files
Source of seed files, in order: `--plugin-root`; the "Plugin root:" line printed by the session-start
hook; `claude plugin list --json` (entry `web-studio`, its install path); `.claude/docs/stack-reference/index.md`
already present (copy mode — nothing to seed). If none is found, ask the user for the path to the
plugin/kit directory. Seed layout: `<root>/docs` → `.claude/docs`, `<root>/rules` → `.claude/rules`,
`<root>/templates/CLAUDE.md.template`, `<root>/templates/settings.plugin-mode.json`, `<root>/templates/statusline.sh`,
`<root>/docs/PROJECT-README.md` → `docs/web-studio/README.md`.

Detect whether code already exists (brownfield): a manifest with sources (`composer.json`, `go.mod`,
`package.json`), deploy files (`compose*.yaml`, `Dockerfile*`, `.github/workflows/*`) or a git history with
more than a handful of commits. Remember the answer — it decides the stage in Phase 3 and the hand-off.

## Phase 2: Language and review mode
`AskUserQuestion`: "Which language should we use for conversation and documents?". Options: English
plus the language of the user's own words when it differs — their messages in this session, or, on a
bare `/init` with no prose, the non-English language of existing project docs (README, CLAUDE.md) or
of the user's global `~/.claude/CLAUDE.md`. The question always carries at least two named options —
a single-option question is a railroad, not a choice; when nothing can be inferred, name the two or
three languages most plausible for this user's environment. Then review mode: `lean` (recommended
for solo), `full`, `solo` — the mode scopes **reviews only**: no mode skips `/start`/`/adopt`, the
specs or the catalog's required steps (review-workflow.md). `--language`/`--review` skip the questions.

From the moment the language answer arrives — an `AskUserQuestion` option, a `--language` argument,
or a language stated in the user's reply text — conduct the rest of `/init` in that language: every
question, the plan, the write summary and the hand-off. CLAUDE.md not existing yet is no excuse;
the whole session that follows inherits the tone `/init` sets.

## Phase 3: Plan
Show what will be created or changed:
- `CLAUDE.md`: create from the template with the language filled in, or (if it exists) insert the
  `## Language`, `## Studio (Web Studio)`, `## Stack` and `## Working principles` sections without
  touching other content — show the exact insertion.
- `.claude/docs/` (stack-reference, templates, roster, coordination, workflow catalog, technical-preferences with `[TO BE CONFIGURED]`) — copy only files that do not exist; list existing ones that differ.
- `.claude/rules/` — same policy.
- `.claude/settings.json`: create from `settings.plugin-mode.json` (permissions + statusline) or show a diff of `permissions.allow/deny` and `statusLine` to merge; hooks are provided by the plugin (copy mode: hooks already in `settings.json`).
- `.claude/statusline.sh`, `docs/web-studio/README.md`, `docs/{specs,architecture,security,ops}`, `production/{sprints,stories,releases,session-state,session-logs}`, `production/review-mode.txt`, `.gitignore` entries (`production/session-state/`, `production/session-logs/`, `.claude/settings.local.json`, `.claude/agent-memory-local/`).
- `production/stage.txt`: `discovery` for an empty project. For brownfield propose the stage from the facts — `build` (code, no release) or `operate` (deployed: release files, compose.prod, a deploy skill) — and confirm it in the "May I write?" question; never write `discovery` over a project that is already running.
  `operate` needs deploy artefacts **in the repository**; a README claiming a live URL alone is a
  signal to ask ("is it actually live, and is this working copy connected to that deployment?"),
  never to propose `operate` on its own — a detached copy of a deployed service is still `build`.
"May I write these files?" — one `AskUserQuestion`: write (Recommended) · show the draft/diff first · not now After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker).

## Phase 4: Write and verify
Apply; print the tree of created files; run `echo '{"cwd":"'"$PWD"'"}' | bash .claude/statusline.sh` as a smoke check.
Record the version in `.claude/.web-studio-version` (from `plugin.json`).

Verdict: `INITIALISED` | `ALREADY INITIALISED (N files differ)`. Next step — one `AskUserQuestion`:
`/adopt full` (Recommended for brownfield — the stack, artefacts and settings are audited and
`technical-preferences.md` is filled from the facts) · `/start` (Recommended for an empty project) ·
`/help` · stop here. Never hand off with a plain text line.

On `ALREADY INITIALISED` the hand-off is decided by facts, not by a default: `.claude/.web-studio-version`
older than the plugin (last segment of the "Plugin root:" line) → `/update` (Recommended); `technical-preferences.md`
still a placeholder, or no `docs/adoption-plan-*.md` on a project with code → `/adopt full` (Recommended);
otherwise `/help` (Recommended). "Do nothing" is never the recommended option on a project that has code.

`/init` scaffolds the studio and stops there — it never writes product code (`index.html`, a
`main`, a component) itself, however trivial the goal looks. A greenfield project's first product
artifact is authored through `/start` → the stack and spec steps, which for a genuinely tiny goal
may choose the shortest path — but that choice belongs to `/start`, not to init coding it inline.
Answering the hand-off with anything other than a pipeline command is the user's call; init does
not pre-empt it with code.
