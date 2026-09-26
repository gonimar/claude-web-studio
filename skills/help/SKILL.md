---
name: help
description: "Shows where you are in the Web Studio pipeline and what to do next; `commands` lists every command with its description, `guide [topic]` opens the playbook (what to run in every situation). Use when the user asks 'what now', 'what should I do next', 'which commands exist', 'what do I do if…', or is stuck."
argument-hint: "[what you just finished] | commands | guide [topic]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, AskUserQuestion
model: haiku
---

# Help — what next?

Language, command namespaces (`/web-studio:<name>` in plugin mode), the built-in `/code-review` collision and the closing question: `docs/coordination-rules.md` § Skill conventions.

Read-only: no file writes; the only commands are `diff -rq` and `claude plugin list --json` (Phase 4 version drift). A quick orientation, not a full audit (that is `/adopt`).

Names:
- `<plugin root>` — the path on the "Plugin root:" line of the session-start context, printed only in plugin mode. A `/clear`ed session may lack the line: then `installPath` from `claude plugin list --json`; no web-studio entry there either → copy mode.
- "A project that has code" — a manifest (`go.mod`, `composer.json`, `package.json`, …) or source files outside `.claude/`, `docs/` and `production/`.
- **Every command named in the answer comes from the catalog or from a skill's own frontmatter, never from memory.** A sub-command only when the skill's `argument-hint` lists it: there is no `/dev-story complete S-NNN`, a story is closed by `/story-done`; an invented shape sends the user to a dead end with the studio's authority behind it.

## Phase 0: Reference modes
Argument `commands` or `guide [topic]` → read `references/reference-modes.md` and follow it, then stop: verdict `READY`, a text line, no closing `AskUserQuestion` (rule 7: nothing to decide).

## Phase 1: Catalog and reads
1. Read `.claude/docs/workflow-catalog.yaml`: phases, steps, `artifact.glob`. Missing → the studio is not initialised: answer "run `/init`" and stop.
2. `technical-preferences.md` whose `**Type**` field is still `[TO BE CONFIGURED]`, on a project that has code → initialised but not adopted: NEXT is `/adopt full`. Check the field itself, never a grep of the whole file: the template's header comment names the placeholder too.
3. **Reads of its own** (`Read`/`Glob`; Phases 2–4 reuse them, nothing is read twice):
   - `production/stage.txt` and `production/review-mode.txt`;
   - the `updated:` line of `.claude/docs/stack-reference/index.md` (absent → `?`);
   - the newest `docs/adoption-plan-*.md` by name (none → `none`);
   - the `name:` of every `.claude/skills/*/SKILL.md` and `<plugin root>/skills/*/SKILL.md`;
   - when `production/roadmap.md` exists, its first open `- [ ]` line and the count of open lines: a NEXT candidate (rank 7), always printed as `Roadmap: N open — first: <line>`.

## Phase 2: Where we are
NEXT precedence, highest first (each step cites its rank):
1. Overrides — open BLOCKING findings without a story, the game gate (step 6).
2. The user's argument "just finished X" (step 4).
3. Open items of a `COMPLIANT` adoption plan (step 5).
4. Unmet required steps of earlier phases (step 3).
5. Steps of the current phase (step 2).
6. Open items of any other adoption plan (step 5).
7. The roadmap's first open line (step 7).

Steps:
1. **Stage** from `production/stage.txt`; otherwise infer it from artefacts (the first phase with an unmet required step).
2. **Steps of the current phase** (rank 5), each checked by its glob: ✅ done / ⬜ missing / 🔁 repeatable.
3. **Earlier phases** (rank 4). A brownfield project that started at `build`/`operate` still owes the **required** steps of every earlier phase (check their globs); an unmet one (e.g. no `docs/architecture/test-strategy.md`) precedes the current phase's steps.
4. **The user's argument** (rank 2, "just finished X"): find step X in the catalog; NEXT is the next step of its phase (or the first step of `next_phase`). "finished security-audit" → `/dependency-audit`/`/harden` in hardening.
5. **Adoption plan** (rank 3 or 6). Count the open items (`- [ ]`) of the Phase 1 plan.
   - A plan written before 0.7.0 has a numbered **table**, no checkboxes: its rows are the items, said in one line (`plan in table format — /adopt full rewrites it as checkboxes`). Never report `0 open` for such a plan.
   - Show `Adoption plan: N open`.
   - Verdict `COMPLIANT` → rank 3: its open items come **before** unmet required steps of earlier phases, which are shown as `⬜ (not migrated by decision — see adoption plan)` and are not NEXT.
   - Otherwise rank 6: when the phase has no unmet required step (typical for `operate`), the first open plan item is NEXT.
   - Never call the NEXT you name "low-value"; if the plan ranks it low, name the plan's own first item.
6. **NEXT overrides** (rank 1).
   - `production/findings.md` has open BLOCKING findings without a story → NEXT is `/create-stories`.
   - Game project (technical-preferences type game / game+backend): every story of the first feature Done and `production/releases/gate-prototype.md` missing → NEXT is `/game-concept gate`.
7. **Roadmap** (rank 7). When ranks 1–6 claim nothing, the roadmap's first open line (Phase 1) is NEXT: `/dev-story S-NNN` for a story line, the line's own command otherwise (a `⛔ [D-NN]` marker → `/backlog review`/the decision named, never the blocked story).

## Phase 3: Uncatalogued skills
1. Compare the skill names from Phase 1 with the catalog's `command:`. Show up to 8 relevant to the phase as "Also available".
2. **Shadow copies**: plugin installed and `.claude/skills/` holds skills of the same names → the copies win for a bare command, `/web-studio:<name>` runs the plugin. Print one line ("N project copies shadow the plugin: `/update` to check and remove them"); the project's own skills are named separately, they stay.

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
The `Docs:` line is always printed: it is how users discover the reference modes.

Add one line each, when it applies — read `references/signals.md` for the exact line and command:
1. **Stack reference** older than 60 days → `/stack-update`.
2. **Version drift** — evidence, never a stamp. Plugin mode: `diff -rq <plugin root>/docs .claude/docs` (and `rules`), `claude plugin list --json` (session vs installed). Copy mode: the `.claude/.web-studio-version` stamp against the kit's `plugin.json` when the session-start context names a kit path, else skipped → `/update`, also a closing option.
3. **Session state**: `production/session-state/active.md` exists → its `Task:`/`Next:`.
4. **Backlog**: open ideas in `production/backlog.md`, oldest past 30 days or `last-review` older than 7 days → `/backlog review`; never a closing option.
5. **Findings**: open BLOCKING findings without a story → `/create-stories` (rank 1 made it NEXT).
6. **External signals**: a red CI, a failed deploy, a billing or access problem seen in `session-state`, a tech-debt CRITICAL → one `Attention:` line each with the fixing command or place; never investigated (no `gh run`, no logs: orientation, not diagnosis), never a closing option.
7. **Sprint over and not closed**: the latest `production/sprints/sprint-NN.md`, header only → `Attention: … /retrospective NN`, rules of 6.
8. **Deploy artefacts**: build phase, a Deploy target in technical-preferences, no `docs/ops/deploy.md` → the "Deploy artefacts" story is missing, `/create-stories` adds it.
9. **Session-start signals**: a merged branch, a CLAUDE.md template placeholder, a stack reference older than 60 days or an open `Gate:` printed at session start → repeated here, one line each.

Verdict: `READY`.

Next step — one `AskUserQuestion` about the pipeline only: the "Next" command (Recommended) · up to two "Also available" commands relevant to the phase · nothing now. `Attention:` items are never options.

**The answer is not executed here**: help runs on Haiku and a skill started from its answer inherits the turn's model. After the answer print one line, `Run: /web-studio:<command> <args>` (copy mode `/<command>`), and end the turn; the user sends it next.
