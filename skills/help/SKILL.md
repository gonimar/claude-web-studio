---
name: help
description: "Shows where you are in the Web Studio pipeline and what to do next; `commands` lists every command with its description, `guide [topic]` opens the playbook (what to run in every situation). Use when the user asks 'what now', 'what should I do next', 'which commands exist', 'what do I do if…', or is stuck."
argument-hint: "[what you just finished] | commands | guide [topic]"
user-invocable: true
allowed-tools: Read, Glob, Grep, AskUserQuestion
model: haiku
---

# Help — what next?

Read-only. Not a full audit (that is `/adopt`), a quick orientation. Reply in the project conversation language.

`Bash` is not in `allowed-tools`, and help runs no command of its own: Phase 1 step 3 reads the stack-reference date, the newest adoption plan, the roadmap's first open item, the stage and the review mode with `Read`/`Glob`.

Names used below:
- `<plugin root>` is the path on the "Plugin root:" line of the session-start context. That line is printed only in plugin mode; without it the project runs in copy mode.
- **Every command is printed with its namespace in plugin mode** (`/web-studio:product-spec`, `/web-studio:code-review`); copy mode prints `/<name>`. In plugin mode a bare `/code-review` is Claude Code's built-in review, not the studio's: no routing table, no appsec.

## Phase 0: Reference modes (`commands` · `guide`)
Two arguments answer a reference question instead of "what next". They end without the closing
`AskUserQuestion`, because there is nothing to decide (rule 7).

**`commands`** — every command with its description. Source: the skills themselves, never memory.
1. Glob `<plugin root>/skills/*/SKILL.md` and `.claude/skills/*/SKILL.md` (copy mode, and project-local skills).
2. From each frontmatter read `name:`, `description:` (first sentence) and `argument-hint:`.
3. Group by the phases of `.claude/docs/workflow-catalog.yaml`, in catalog order; a skill in no phase goes under "Maintenance and teams".
4. One line per command: `/name <argument-hint> — first sentence of the description`. Mark the catalog's required steps with `*`.
5. Then one line: `Details: /help guide · .claude/docs/playbook.md · README of the plugin`.

**`guide [topic]`** — the playbook.
1. **Find it**: `.claude/docs/playbook.md` (seeded by `/init`/`/update`), else `<plugin root>/docs/playbook.md`. When the project's conversation language has a translation in `.claude/docs/readme/PLAYBOOK.<lang>.md`, prefer it. Playbook missing everywhere → one line, `playbook not seeded — run /update`, and stop.
2. **Without a topic**: print the playbook's table of contents (its `##` and `###` headings with numbers) and the line `/help guide <topic> prints one section`.
3. **With a topic**: find the section that matches best.
   - A section number like `10.7`, or a case-insensitive match on the heading text **or on the first line of a section**.
   - Playbook headings are in the file's language, so also match the obvious synonyms the user would use: "hotfix", "secret", "release", "session", "CI".
   - Several matches → the section whose heading matches wins, then the earliest.
4. **Print that section verbatim**, then the numbers of up to three related sections. Never paraphrase or shorten a printed section.
5. **No match** → the table of contents with `no section matches "<topic>"`.

Verdict for both: `READY`. End with a text line, not a question.

## Phase 1: Catalog
1. Read `.claude/docs/workflow-catalog.yaml`: phases, steps, `artifact.glob`. Missing → the studio is not initialised: answer "run `/init`" and stop.
2. `technical-preferences.md` whose `**Type**` field is still `[TO BE CONFIGURED]`, on a project that has code → the studio was initialised but not adopted: NEXT is `/adopt full`. Check the field itself, never a grep of the whole file: the template's header comment names the placeholder, and every configured project keeps that line.
3. **Reads of its own** (`Read`/`Glob`, no command): `production/stage.txt` and `production/review-mode.txt`; the `updated:` line of `.claude/docs/stack-reference/index.md` (absent → `?`); the newest `docs/adoption-plan-*.md` by name (none → `none`); and, when `production/roadmap.md` exists, its first open `- [ ]` line and the count of open lines — the roadmap template promises "`/help` reads the first open item". That line is a NEXT candidate (Phase 2 step 7) and is always printed in the report as `Roadmap: N open — first: <line>`.

## Phase 2: Where we are
1. **Stage** from `production/stage.txt`; otherwise infer it from artefacts (the first phase with an unmet required step).
2. **Steps of the current phase**, each checked by its glob: ✅ done / ⬜ missing / 🔁 repeatable.
3. **Earlier phases.** A project that entered its phase directly (brownfield starts at `build`/`operate`) still owes the **required** steps of every earlier phase. Check their artifact globs too; an unmet one (e.g. no `docs/architecture/test-strategy.md`) becomes NEXT ahead of the current phase's own steps.
4. **The user's argument** ("just finished X"): find step X in the catalog and take the next step of its phase (or the first step of `next_phase`) as NEXT. Example: "finished security-audit" → `/dependency-audit`/`/harden` in hardening.
5. **Adoption plan.** If `docs/adoption-plan-*.md` exists, take the newest one and count its open items (`- [ ]`).
   - A plan written before 0.7.0 has a numbered **table** instead of checkboxes: read its rows as the items and say so in one line (`plan in table format — /adopt full rewrites it as checkboxes`). Never report `0 open` for such a plan.
   - Show `Adoption plan: N open`.
   - When the newest plan's verdict is `COMPLIANT`, its open items come **before** unmet required steps of earlier phases. Those steps are shown as `⬜ (not migrated by decision — see adoption plan)` and are not NEXT.
   - When the phase has no unmet required step (typical for `operate`), the first open plan item is NEXT.
   - Never call the NEXT you name "low-value"; if the plan ranks it low, name the plan's own first item instead.
6. **NEXT overrides.**
   - `production/findings.md` has open BLOCKING findings without a story → NEXT is `/create-stories`; they take precedence over the next feature.
   - Game project (technical-preferences type game / game+backend): when every story of the first feature is Done and `production/releases/gate-prototype.md` is missing → NEXT is `/game-concept gate`, not the next feature.
7. **Roadmap.** When no unmet required step, no open adoption-plan item (step 5) and no override (step 6) claims NEXT, the roadmap's first open line from Phase 1 step 3 is NEXT: `/dev-story S-NNN` for a story line, the line's own command otherwise (a `⛔ [D-NN]` marker → `/backlog review`/the decision named, never the blocked story).

## Phase 3: Uncatalogued skills
1. Glob `.claude/skills/*/SKILL.md` (copy mode) and `<plugin root>/skills/*/SKILL.md`; compare `name:` with the catalog's `command:`. Show up to 8 relevant to the phase as "Also available".
2. **Shadow copies**: when the plugin is installed and `.claude/skills/` holds skills of the same names, the project copies win for a bare command while `/web-studio:<name>` runs the plugin. Print one line ("N project copies shadow the plugin: `/update` to check and remove them") and name the project's own skills separately, since those are meant to stay.

## Phase 4: Output
```
Stage: [label] ([N/M] required done)
✅ /setup-stack — stack pinned
⬜ /product-spec — no docs/specs/product-spec.md   ← NEXT
🔁 /feature-spec — 2 specs exist
Adoption plan: 3 open — first: /threat-model (docs/adoption-plan-2026-09-08.md #2)
Roadmap: 12 open — first: S-012 · Repository layer (production/roadmap.md)
Next: /product-spec  (why: nothing to check features against without it)
Also available: /stack-update, /team-feature …
Docs: /help commands (every command) · /help guide (what to run in every situation) · /help guide 10.7 (one section)
```
The `Docs:` line is always printed; it is how a user discovers the reference modes.

Add one line each, when it applies:
- **Stack reference** older than 60 days → recommend `/stack-update`.
- **Version drift** — evidence, never a stamp in plugin mode. Plugin mode: `diff -rq <plugin root>/docs .claude/docs` and `diff -rq <plugin root>/rules .claude/rules` (ignoring `technical-preferences.md` and `local-overrides/`); N files differ → `Seeded docs differ from plugin vY (N files) — /update re-seeds changed docs/rules`, and `/update` joins the closing question's options; when `claude plugin list --json` reports an installed version other than the plugin root's → `session runs vX, vZ is installed — restart the session`. Copy mode: `.claude/.web-studio-version` records what seeded this project; older than the kit's `plugin.json` (when the kit path is known) → the same `/update` line; no kit path → skip the check. A stamp found in plugin mode is a copy-mode leftover (`/update` removes it), not a version to compare.
- **Session state**: `production/session-state/active.md` exists → show its `Task:`/`Next:`.
- **Backlog**: `production/backlog.md` has open ideas (`### I-NNN` without `[x]`) → `Backlog: N ideas, oldest N days → /backlog review`. It is a reminder when the oldest passes 30 days or `last-review` is older than 7 days; never an option in the closing question.
- **Findings**: open BLOCKING findings without a story → `Open BLOCKING findings: N without a story → /create-stories` (Phase 2 step 6 made it NEXT).
- **External signals** (a red CI, a failed deploy, a billing or access problem seen in `session-state`, a tech-debt CRITICAL, a sprint that is over and not closed — the latest `production/sprints/sprint-NN.md` without `Status: closed` — a file without a `Status:` line counts as closed when its roadmap block is folded in `<details>`, as `/sprint-status` and `/sprint-plan` read it — while its roadmap block has no `- [ ]` line left or its heading's end date is in the past: `Attention: sprint NN is over and not closed — /web-studio:retrospective NN`) → one `Attention:` line each, with the command or place that fixes it. Never the subject of the closing question and never investigated here: no `gh run`, no log reading; help is orientation, not diagnosis.
- **Deploy artefacts**: build phase with a Deploy target in technical-preferences and no `docs/ops/deploy.md` → the "Deploy artefacts" story is missing (`/create-stories` adds it).
- **Session-start signals**: the session-start context is data, not decoration. A merged branch, a template placeholder left in CLAUDE.md, a stack reference older than 60 days or an open `Gate:` printed there is repeated here, one line each; the user reads this answer, not the startup block a second time.

**Every command named anywhere in the answer comes from the catalog or from a skill's own frontmatter, never from memory.** A sub-command is named only when its skill's `argument-hint` lists it. There is no `/dev-story complete S-NNN`: a story is closed by `/story-done`, and an invented command shape sends the user to a dead end with the studio's authority behind it.

Verdict: `READY`.

Next step — one `AskUserQuestion` about the pipeline only: the "Next" command (Recommended) · up to two "Also available" commands relevant to the phase · nothing now. `Attention:` items are not options here.

**The answer is not executed here.** Help runs on Haiku, and a skill started from its answer inherits the model of the turn, so a review or a story close would run on Haiku. After the answer print one line, `Run: /web-studio:<command> <args>` (copy mode `/<command>`), and end the turn; the user sends it as the next message.
