---
name: start
description: "First-time onboarding for a new web project — asks where you are, configures the stack, and routes to product-spec or game-concept. Use when starting from scratch or when technical-preferences.md is still [TO BE CONFIGURED]."
argument-hint: "[no arguments]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Bash, AskUserQuestion
model: sonnet
---

# Start

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

Entry point for a new project. Assumes nothing — asks, then routes. Writes files only after "May I write?" → "yes".
`Bash` is used for two things: `touch .claude/.write-consent` after the Phase 3 write answer, and the Phase 5 commit with its gate record; every other step reads and asks. A command in a hand-off is `/web-studio:<command>` in plugin mode and `/<command>` in copy mode; `<hooks>` is `.claude/hooks/` in copy mode and `${CLAUDE_PLUGIN_ROOT}/hooks/` in plugin mode.

## Phase 1: Silent state detection
1. Read (without showing): `.claude/docs/technical-preferences.md` (exists? configured?), `docs/specs/product-spec.md`,
   `docs/specs/game-concept.md`, code presence (`go.mod`, `composer.json`, `package.json`, `angular.json`, `nuxt.config.*`),
   `production/roadmap.md`, `production/review-mode.txt`, `production/stage.txt`, `CLAUDE.md` Language section.
2. `.claude/docs/` missing → the studio is not initialised: run `/web-studio:init` first (copy mode `/init`; in plugin mode the bare `/init` is Claude Code's built-in, which does not scaffold the studio).
3. **Code or specs already exist → stop and hand off to `/adopt`.** The test is mechanical, never a feeling about the repository:
   - specs exist when `docs/specs/` holds at least one `.md` file (`product-spec.md`, `game-concept.md` or `features/*.md`);
   - code exists when a manifest (`go.mod`, `composer.json`, `package.json`) sits next to a source tree — a `.go` file outside `vendor/`, a `src/`, `app/`, `cmd/` or `internal/` directory with files in it, or `angular.json`/`nuxt.config.*`. A manifest alone (an empty scaffold) is not code.
   Either holds → say what was found (the paths), verdict `BLOCKED (existing project — run /adopt full)`, write nothing, and end with one `AskUserQuestion`: `/adopt full` (Recommended — the stack and artefacts are audited and `technical-preferences.md` is filled from the facts) · `/help` · stop here. `/start` never re-asks the review mode or rewrites the stage of a project that already has work in it.

## Phase 2: Where are you
`AskUserQuestion`: "Where are we starting from?"
- **A) Just an idea** — a theme or pain, nothing written → `/brainstorm`.
- **B) Clear product** — we know what we build → `/setup-stack` → `/product-spec`.
- **C) Browser game** — a game concept → `/setup-stack` (type game) → `/game-concept` → `/product-spec` (light).
- **D) Existing work** — code/documents already exist → `/adopt`.

## Phase 3: Project type and review mode
Second question: type (site | spa | api | fullstack | game | game+backend) and, **only when `production/review-mode.txt` is absent**, the review mode
(`full` — all gates; `lean` — lead + security on sensitive work (default for solo); `solo`).
`/init` normally writes the review mode already: when the file exists, print its value in one line ("review mode: lean, set by /init") and keep it — the question is not asked again and the file is not rewritten. Changing the mode is a deliberate edit of that file, never a side effect of `/start`.
The same holds for `production/stage.txt`: absent → `discovery`; present with `discovery` → nothing to write; present with any other value → say so and leave it (a project past discovery is `/adopt`'s case, Phase 1 step 3).
Write the files that are absent (`production/review-mode.txt`, `production/stage.txt` = `discovery`) after "May I write?" — one `AskUserQuestion`: write (Recommended) · show the draft/diff first · not now. After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker). Nothing absent → no write gate in this phase.

## Phase 4: Route
1. Show the next 3 steps from `.claude/docs/workflow-catalog.yaml` with commands.
2. `production/roadmap.md` missing → offer to create it (checkbox list) or, if an external advisor skill is installed, suggest its init command.
3. `.claude/settings.web-studio.json` exists (settings.json pre-dated the install) → offer to merge hooks/permissions (show the diff, ask).

## Phase 5: Commit (documents lane)
Right after the last write, one commit gate (rule 7, `.claude/docs/git-workflow.md` § Documents): `docs: initialise web studio`, staging exactly the documents this run wrote (`production/review-mode.txt`, `production/stage.txt`, `production/roadmap.md` when Phase 4 created it).
- On the default branch when no story work is in progress.
- When HEAD is a story branch, name it and ask one `AskUserQuestion`: switch to the default branch and commit there (Recommended — a pipeline-wide document) · commit here (the document belongs to this story) · leave uncommitted.
- A merged `.claude/settings.json` (Phase 4 step 3) is toolchain work, not a document: it does not ride the `docs:` commit. Name it in the result and offer the chore lane for it (git-workflow.md § Chore / infra).
- Before asking, record the gate — `<hooks>session-state.sh set Gate "/start Phase 5: commit?"` — and clear it after the answer (`<hooks>session-state.sh set Gate "—"`).

Nothing is committed without the answer; when this run wrote nothing, there is no commit gate.

Verdict: `READY` — project type and review mode chosen, next step named | `BLOCKED (existing project — run /adopt full)`. Next step — one `AskUserQuestion`, the route from Phase 2 first (Recommended): `/setup-stack` (B, C) · `/brainstorm` (A, or the idea is still vague) · `/adopt` (D) · stop here.
