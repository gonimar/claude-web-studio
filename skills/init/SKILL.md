---
name: init
description: "Scaffolds the Web Studio in a project (the studio's init, not Claude Code's): asks the conversation language and review mode, creates/updates CLAUDE.md sections, seeds .claude/docs, .claude/rules, docs/ and production/, merges settings; a re-run adds only what is missing and hands off to /update or /adopt. Run first in plugin mode (copy mode: to set the language), for 'set up the studio'."
argument-hint: "[--language <name>] [--review full|lean|solo] [--plugin-root <path> | --kit <path>]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, AskUserQuestion
---

# Init — scaffold the studio in this project

Language, `<hooks>`, gate mechanics (consent marker, `Gate` record) and the documents-lane commit gate: `docs/coordination-rules.md` § Skill conventions. Until CLAUDE.md exists, the language chosen in Phase 2 binds instead.

Writes files only after "May I write …?" → "yes".

Glossary: `<root>` — the seed root, **plugin mode only** (the install path found in Phase 1). Copy mode has no `<root>`: install.sh seeded docs, rules and hooks, and its stamp `.claude/.web-studio-version` is the only version source.

## Phase 1: Locate the studio files
1. **Mode and seed root**, in this order; the first that holds decides:
   1. `--plugin-root` → plugin mode, `<root>` is that path;
   2. `.claude/.web-studio-version` present (install.sh's stamp) → **copy mode**, nothing to seed — before the "Plugin root:" line and the plugin list: a plugin installed at user scope prints that line into every project's session and never turns a copy-mode project into plugin mode;
   3. the "Plugin root:" line printed by the session-start hook → plugin mode;
   4. `claude plugin list --json`: the `web-studio` row whose `projectPath` is this project's root (`git rev-parse --show-toplevel`), else its `user`-scope row → its install path; the list covers every project on this machine, never take the first match (`/update` Phase 1);
   5. `.claude/docs/stack-reference/index.md` already present — copy mode, nothing to seed.
   None found → ask the user for the path to the plugin/kit directory. Write nothing until a root is known; no path given → `NOT INITIALISED (no plugin root)` (Phase 6).
2. **Brownfield or empty** — code exists on the evidence of `references/seed-manifest.md` § Stage (a manifest with sources, deploy files, a git history beyond a handful of commits); the result decides the stage (Phase 3) and the hand-off (Phase 6).

## Phase 2: Language and review mode
`--language` / `--review` skip the matching question.
1. **Language**, one `AskUserQuestion`: "Which language should we use for conversation and documents?" Options: English plus the language of the user's own words when it differs (this session's messages; on a bare `/init` with no prose, a non-English README/CLAUDE.md or the user's global `~/.claude/CLAUDE.md` — a `Read` outside the project, allowed here). Always at least two named options — one option is a railroad, not a choice; nothing inferable → the two or three languages most plausible for this user's environment.
2. **Switch language now.** From the answer on (an option, `--language`, or a language stated in the reply text) every question, the plan, the write summary and the hand-off are in that language — CLAUDE.md not existing yet is no excuse; the session that follows inherits the tone `/init` sets.
3. **Review mode**, one `AskUserQuestion`: `lean` (Recommended for a single developer: lead plus security on sensitive work) · `full` (every significant artefact reviewed) · `solo` (reviews on request). It scopes **reviews only**: no mode skips `/start`/`/adopt`, the specs or the catalog's required steps (review-workflow.md).

## Phase 3: Plan
1. **Decide the stage** (`production/stage.txt`) from Phase 1 step 2: `discovery` for an empty project; brownfield → `build` (code, no release) or `operate` (release files, compose.prod, a deploy skill **in the repository** — `references/seed-manifest.md` § Stage; a README's live URL only prompts a question), proposed from the facts and confirmed in the "May I write?" question. Never write `discovery` over a running project.
2. **Show the plan** from `references/seed-manifest.md`: every path it lists as created or merged (settings template per mode as it says), marking existing files that differ; an existing `CLAUDE.md` gets the exact insertion shown.
3. **Write gate**: "May I write these files?" — one `AskUserQuestion`: write (Recommended) · show the draft/diff first · not now. "Not now" → nothing is written, `NOT INITIALISED (declined)`.
4. After the "write" answer: `touch .claude/.write-consent` (§ Gates).

## Phase 4: Write and verify
1. Apply the plan; print the tree of created files.
2. Smoke-check the statusline: `echo '{"cwd":"'"$PWD"'"}' | bash .claude/statusline.sh`.
3. **Version stamp — copy mode only.** Keep install.sh's `.claude/.web-studio-version`; missing → record the version of `<kit>/.claude-plugin/plugin.json` only when `--kit <path>` names the kit repository (the argument `/update` takes; `--plugin-root` means plugin mode), else name `install.sh` as the fix. Plugin mode writes none: `claude plugin list --json` holds the version, and a stamp would claim files the project does not hold (`/update` deletes it).

## Phase 5: Commit (documents lane)
Right after the write, one commit gate (§ Documents-lane commit gate; `.claude/docs/git-workflow.md` § Documents).
1. Record it: `<hooks>session-state.sh set Gate "/init Phase 5: commit?"`.
2. Ask, one `AskUserQuestion`: commit (Recommended) · leave uncommitted; on a story branch, name it and offer the § Documents-lane fork (switch to `<default>` Recommended — a pipeline-wide document · commit here · leave uncommitted). After the answer: `<hooks>session-state.sh set Gate "—"`.
3. On "commit": `docs: initialise web studio`, staging exactly the documents this run wrote — `CLAUDE.md`, `.claude/docs/`, `.claude/rules/`, `docs/web-studio/README.md`, `production/stage.txt`, `production/review-mode.txt`, `.claude/.web-studio-version` (copy mode). The seeded `docs/*` and `production/*` folders are not listed: git stages no empty folder.
4. `.claude/settings.json`, `.claude/statusline.sh` and the `.gitignore` lines are toolchain work, not documents: never in the `docs:` commit; name them in the result and offer the chore lane (git-workflow.md § Chore / infra).
5. Nothing is committed without the answer. Nothing written (`ALREADY INITIALISED` with 0 files differing, `NOT INITIALISED`) → no commit gate.

## Phase 6: Verdict and hand-off
1. **Verdict**, one line:
   - `INITIALISED` — neither the `## Studio (Web Studio)` block in `CLAUDE.md` nor a seeded `.claude/docs/` existed before this run (Phase 1 items 1.3 and 1.5 did not apply).
   - `ALREADY INITIALISED (N files differ)` — one of them did; N = seeded files whose content differs from the seed root (listed in Phase 3; recipe and ignore list in `references/rerun-handoff.md`); the run only added what was missing.
   - `NOT INITIALISED (declined)` — "not now" at the write gate; `NOT INITIALISED (no plugin root)` — no root found, no path given. Nothing was written.
2. **Next step** — one `AskUserQuestion`, never a plain text line, every command namespaced (§ Skill conventions → Paths and names):
   - After `INITIALISED`: `/adopt full` (Recommended for brownfield: audits stack, artefacts and settings, fills `technical-preferences.md` from the facts) · `/start` (Recommended for an empty project) · `/help` · stop here.
   - After `ALREADY INITIALISED`: read `references/rerun-handoff.md` — its ladder (`/update` · `/adopt full` · `/help`) marks **exactly one** option Recommended by the first fact that holds, offers the others, and never recommends "do nothing" on a project with code.
   - After `NOT INITIALISED`: `/init` again (`--plugin-root <path>` when no root was found; Recommended) · `/help` · stop here.
3. **`/init` scaffolds the studio and stops there.** It never writes product code (`index.html`, a `main`, a component), however trivial the goal: a greenfield project's first product artifact is `/start`'s, whose stack and spec steps may pick the shortest path — never init inline. A hand-off answered with anything but a pipeline command is the user's call; init does not pre-empt it with code.
