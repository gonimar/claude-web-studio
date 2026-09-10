---
name: help
description: "Shows where you are in the Web Studio pipeline and what to do next; `commands` lists every command with its description, `guide [topic]` opens the playbook (what to run in every situation). Use when the user asks 'what now', 'what should I do next', 'which commands exist', 'what do I do if…', or is stuck."
argument-hint: "[what you just finished] | commands | guide [topic]"
user-invocable: true
allowed-tools: Read, Glob, Grep, AskUserQuestion
context: |
  !echo "stage: $(cat production/stage.txt 2>/dev/null || echo 'not set') | review-mode: $(cat production/review-mode.txt 2>/dev/null || echo 'lean') | studio: $(cat .claude/.web-studio-version 2>/dev/null || echo '?') | stack-ref: $(sed -n 's/^updated: *//p' .claude/docs/stack-reference/index.md 2>/dev/null) | adoption-plan: $(ls docs/adoption-plan-*.md 2>/dev/null | tail -1 || echo 'none')"
model: haiku
---

# Help — what next?

Read-only. Not a full audit (that is `/adopt`), a quick orientation. Reply in the project conversation language.

## Phase 0: Reference modes (`commands` · `guide`)
Two arguments answer a reference question instead of "what next" and end without the closing
`AskUserQuestion` — there is nothing to decide (rule 7).
- **`commands`** — every command with its description. Source: the skills themselves, never memory —
  Glob `<plugin root>/skills/*/SKILL.md` (the "Plugin root:" line of the session-start context) and
  `.claude/skills/*/SKILL.md` (copy mode, and project-local skills); read `name:`, `description:` (first
  sentence) and `argument-hint:` from each frontmatter. Group by the catalog's phases in catalog order
  (a skill in no phase goes under "Maintenance and teams"), one line per command:
  `/name <argument-hint> — first sentence of the description`. Mark the catalog's required steps with
  `*`. Then one line: `Details: /help guide · .claude/docs/playbook.md · README of the plugin`.
- **`guide [topic]`** — the playbook `.claude/docs/playbook.md` (seeded by `/init`/`/update`; fall back to
  `<plugin root>/docs/playbook.md`; a translation next to it in `.claude/docs/readme/PLAYBOOK.<lang>.md`
  when the project's conversation language has one — prefer it). Without a topic: print the playbook's
  table of contents (its `##` and `###` headings with numbers) and the line `/help guide <topic> prints
  one section`. With a topic: find the heading that matches it best (a section number like `10.7`, or a
  case-insensitive match on the heading text **or on the first line of a section** — playbook headings
  are in the file's language, so also match the obvious synonyms the user would use: "hotfix", "secret",
  "release", "session", "CI"; several matches → the section whose heading matches wins, then the earliest);
  print that section verbatim, then the numbers of up to three related sections. No match → the table
  of contents with `no section matches "<topic>"`. Never paraphrase or shorten a printed section.
  Playbook missing everywhere → one line: `playbook not seeded — run /update` and stop.
Verdict for both: `READY`. End with a text line, not a question.

## Phase 1: Catalog
Read `.claude/docs/workflow-catalog.yaml`: phases, steps, `artifact.glob`. Missing → the studio is not initialised: answer "run `/init`" and stop.
`technical-preferences.md` still `[TO BE CONFIGURED]` on a project that has code → the studio was initialised but not adopted: NEXT is `/adopt full`.

## Phase 2: Where we are
Stage from `production/stage.txt`; otherwise infer from artefacts (the first phase with an unmet required step).
For the current phase check every step by glob: ✅ done / ⬜ missing / 🔁 repeatable. A project that
entered its phase directly (brownfield starts at `build`/`operate`) still owes the **required** steps
of every earlier phase: check their artifact globs too, and an unmet one (e.g. no
`docs/architecture/test-strategy.md`) becomes NEXT ahead of the current phase's own steps. Take the user's argument into account ("just finished X"): find step X in the catalog and take the next step of its phase (or the first step of `next_phase`) as NEXT — e.g. "finished security-audit" → `/dependency-audit`/`/harden` in hardening.
If `docs/adoption-plan-*.md` exists (the newest one), count its open items (`- [ ]`); a plan written before 0.7.0 has a
numbered **table** instead of checkboxes — read its rows as the items and say so in one line (`plan in table format —
/adopt full rewrites it as checkboxes`), never report `0 open` for such a plan. Show `Adoption plan: N open`.
Priority on a brownfield project: when the newest plan's verdict is `COMPLIANT`, its open items come **before** unmet
required steps of earlier phases — those steps are shown as `⬜ (not migrated by decision — see adoption plan)` and are
not NEXT; when the phase has no unmet required step (typical for `operate`), the first open plan item is NEXT. Never call
the NEXT you name "low-value" — if the plan ranks it low, name the plan's own first item instead.

## Phase 3: Uncatalogued skills
Glob `.claude/skills/*/SKILL.md` (copy mode) and the plugin's skills if visible; compare `name:` with the catalog's `command:`; show up to 8 relevant to the phase as "Also available".

## Phase 4: Output
```
Stage: [label] ([N/M] required done)
✅ /setup-stack — stack pinned
⬜ /product-spec — no docs/specs/product-spec.md   ← NEXT
🔁 /feature-spec — 2 specs exist
Adoption plan: 3 open — first: /threat-model (docs/adoption-plan-2026-09-08.md #2)
Next: /product-spec  (why: nothing to check features against without it)
Also available: /stack-update, /team-feature …
Docs: /help commands (every command) · /help guide (what to run in every situation) · /help guide 10.7 (one section)
```
The `Docs:` line is always printed — it is how a user discovers the reference modes.
If the stack reference is older than 60 days — one line recommending `/stack-update`.
Version drift: `.claude/.web-studio-version` records what seeded this project; the running plugin
version is the last path segment of the "Plugin root:" line the session-start hook prints (copy mode —
no plugin root: skip the check). Different → one line: `Studio files seeded by vX, plugin is vY —
/update re-seeds changed docs/rules`, and `/update` joins the closing question's options.
If `production/session-state/active.md` exists — show its `Task:`/`Next:`.
If `production/backlog.md` has open ideas (`### I-NNN` without `[x]`) — one line `Backlog: N ideas, oldest N days → /backlog review` (a reminder when the oldest passes 30 days or `last-review` is older than 7 days; never an option in the closing question).
If `production/findings.md` has open BLOCKING findings without a story — one line `Open BLOCKING findings: N without a story → /create-stories` (they take precedence over the next feature).
External signals (a red CI, a failed deploy, a billing or access problem seen in `session-state`, a tech-debt CRITICAL) are **one `Attention:` line each** with the command or place that fixes them — never the subject of the closing question and never investigated here (no `gh run`, no log reading: help is orientation, not diagnosis).
Build phase with a Deploy target in technical-preferences and no `docs/ops/deploy.md` — one line: the "Deploy artefacts" story is missing (`/create-stories` adds it).
Game project (technical-preferences type game / game+backend): when every story of the first feature is Done and `production/releases/gate-prototype.md` is missing — NEXT is `/game-concept gate`, not the next feature.

Verdict: `READY`. Next step — one `AskUserQuestion` about the pipeline only: the "Next" command (Recommended) · up to two "Also available" commands relevant to the phase · nothing now. Run nothing without that answer; `Attention:` items are not options here.
