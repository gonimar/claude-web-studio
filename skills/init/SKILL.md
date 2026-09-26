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
1. **Find the seed root**, in this order:
   1. `--plugin-root`;
   2. the "Plugin root:" line printed by the session-start hook;
   3. `claude plugin list --json`: the `web-studio` row whose `projectPath` is this project's root (`git rev-parse --show-toplevel`), else its `user`-scope row; take its install path. The output covers every project on this machine, so never take the first match (`/update` Phase 1);
   4. `.claude/docs/stack-reference/index.md` already present — copy mode, nothing to seed.
   None found → ask the user for the path to the plugin/kit directory. Write nothing until a root is known.
2. **Seed layout**: `<root>/docs` → `.claude/docs`, `<root>/rules` → `.claude/rules`,
   `<root>/templates/CLAUDE.md.template`, `<root>/templates/settings.plugin-mode.json`, `<root>/templates/statusline.sh`,
   `<root>/docs/PROJECT-README.md` → `docs/web-studio/README.md`.
3. **Brownfield or empty.** Code already exists when there is a manifest with sources (`composer.json`, `go.mod`,
   `package.json`), deploy files (`compose*.yaml`, `Dockerfile*`, `.github/workflows/*`) or a git history with
   more than a handful of commits. Remember the result: it decides the stage in Phase 3 and the hand-off.

## Phase 2: Language and review mode
`--language` / `--review` skip the matching question.
1. **Language**, one `AskUserQuestion`: "Which language should we use for conversation and documents?"
   - Options: English, plus the language of the user's own words when it differs — their messages in this session, or, on a
     bare `/init` with no prose, the non-English language of existing project docs (README, CLAUDE.md) or
     of the user's global `~/.claude/CLAUDE.md`.
   - The question always carries at least two named options; a single-option question is a railroad, not a choice. When nothing can be inferred, name the two or
     three languages most plausible for this user's environment.
2. **Switch language now.** From the moment the language answer arrives — an `AskUserQuestion` option, a `--language` argument,
   or a language stated in the user's reply text — conduct the rest of `/init` in that language: every
   question, the plan, the write summary and the hand-off. CLAUDE.md not existing yet is no excuse;
   the whole session that follows inherits the tone `/init` sets.
3. **Review mode**, one `AskUserQuestion`: `lean` (recommended for solo), `full`, `solo`. The mode scopes **reviews only**: no mode skips `/start`/`/adopt`, the
   specs or the catalog's required steps (review-workflow.md).

## Phase 3: Plan
1. **Show what will be created or changed:**
   - `CLAUDE.md`: create from the template with the language filled in, or (if it exists) insert the
     `## Language`, `## Studio (Web Studio)`, `## Stack` and `## Working principles` sections without
     touching other content — show the exact insertion.
   - `.claude/docs/` (stack-reference, templates, roster, coordination, workflow catalog, `playbook.md` with its `readme/PLAYBOOK.*.md` translations and `roadmap.md` — what `/help guide` reads, technical-preferences with `[TO BE CONFIGURED]`) — copy only files that do not exist; list existing ones that differ.
   - `.claude/rules/` — same policy.
   - `.claude/settings.json`: create from `settings.plugin-mode.json` (permissions + statusline) or show a diff of `permissions.allow/deny` and `statusLine` to merge; hooks are provided by the plugin (copy mode: hooks already in `settings.json`).
   - `.claude/statusline.sh`, `docs/web-studio/README.md`, `docs/{specs,architecture,security,ops}`, `production/{sprints,stories,releases,session-state,session-logs}`, `production/review-mode.txt`, `.gitignore` entries (`production/session-state/`, `production/session-logs/`, `.claude/settings.local.json`, `.claude/agent-memory-local/`).
   - `production/stage.txt`: `discovery` for an empty project. For brownfield, propose the stage from the facts — `build` (code, no release) or `operate` (deployed: release files, compose.prod, a deploy skill) — and confirm it in the "May I write?" question. Never write `discovery` over a project that is already running.
     `operate` needs deploy artefacts **in the repository**. A README claiming a live URL alone is a
     signal to ask ("is it actually live, and is this working copy connected to that deployment?"),
     never to propose `operate` on its own: a detached copy of a deployed service is still `build`.
2. **Write gate**: "May I write these files?" — one `AskUserQuestion`: write (Recommended) · show the draft/diff first · not now.
3. After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker).

## Phase 4: Write and verify
1. Apply the plan; print the tree of created files.
2. Smoke-check the statusline: `echo '{"cwd":"'"$PWD"'"}' | bash .claude/statusline.sh`.
3. Record the version in `.claude/.web-studio-version` (from `<root>/.claude-plugin/plugin.json`).

## Phase 5: Commit (documents lane)
Right after the write, one commit gate (rule 7, `.claude/docs/git-workflow.md` § Documents): `docs: initialise web studio`, staging exactly the documents this run wrote — `CLAUDE.md`, `.claude/docs/`, `.claude/rules/`, `docs/web-studio/README.md`, `production/stage.txt`, `production/review-mode.txt`, `.claude/.web-studio-version` and the seeded folders.
- On the default branch when no story work is in progress.
- When HEAD is a story branch, name it and ask one `AskUserQuestion`: switch to the default branch and commit there (Recommended — a pipeline-wide document) · commit here (the document belongs to this story) · leave uncommitted.
- `.claude/settings.json`, `.claude/statusline.sh` and the `.gitignore` lines are toolchain work, not documents: they do not ride the `docs:` commit. Name them in the result and offer the chore lane for them (git-workflow.md § Chore / infra).

Nothing is committed without the answer. When nothing was written (`ALREADY INITIALISED` with 0 files differing, or "not now" at the write gate), there is no commit gate.

Verdict: `INITIALISED` | `ALREADY INITIALISED (N files differ)`.
- `INITIALISED` — the studio was not in this project before this run: no `## Studio (Web Studio)` block in `CLAUDE.md` and no seeded `.claude/docs/` (Phase 1 step 1.4 did not apply).
- `ALREADY INITIALISED (N files differ)` — the studio block was already in `CLAUDE.md` or `.claude/docs/` was already seeded when the run started; N counts the seeded files whose content differs from the seed root (Phase 3 lists them), and the run only added what was missing.

Next step — one `AskUserQuestion`, never a plain text line:
- After `INITIALISED`: `/adopt full` (Recommended for brownfield — the stack, artefacts and settings are audited and
  `technical-preferences.md` is filled from the facts) · `/start` (Recommended for an empty project) ·
  `/help` · stop here.
- After `ALREADY INITIALISED` the Recommended option is decided by facts, not by a default, and **exactly one option is marked Recommended**. The facts are checked in this order and the first that holds decides; the others are still offered as alternatives:
  1. `.claude/.web-studio-version` older than the plugin (last segment of the "Plugin root:" line) → `/update` (Recommended — the seeded docs and rules are behind the plugin, and `/adopt` would audit stale references);
  2. otherwise `technical-preferences.md` still a placeholder, or no `docs/adoption-plan-*.md` on a project with code → `/adopt full` (Recommended);
  3. otherwise `/help` (Recommended).
  When both 1 and 2 hold, `/update` is Recommended and `/adopt full` is the second option with the note "after /update".
  "Do nothing" is never the recommended option on a project that has code.

**`/init` scaffolds the studio and stops there.** It never writes product code (`index.html`, a
`main`, a component) itself, however trivial the goal looks. A greenfield project's first product
artifact is authored through `/start` → the stack and spec steps, which for a genuinely tiny goal
may choose the shortest path; that choice belongs to `/start`, not to init coding it inline.
Answering the hand-off with anything other than a pipeline command is the user's call; init does
not pre-empt it with code.
