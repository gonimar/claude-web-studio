---
name: help
description: "Shows where you are in the Web Studio pipeline and what to do next. Use when the user asks 'what now', 'what should I do next', or is stuck."
argument-hint: "[optional: what you just finished]"
user-invocable: true
allowed-tools: Read, Glob, Grep, AskUserQuestion
context: |
  !echo "stage: $(cat production/stage.txt 2>/dev/null || echo 'not set') | review-mode: $(cat production/review-mode.txt 2>/dev/null || echo 'lean') | studio: $(cat .claude/.web-studio-version 2>/dev/null || echo '?') | stack-ref: $(sed -n 's/^updated: *//p' .claude/docs/stack-reference/index.md 2>/dev/null) | adoption-plan: $(ls docs/adoption-plan-*.md 2>/dev/null | tail -1 || echo 'none')"
model: haiku
---

# Help — what next?

Read-only. Not a full audit (that is `/adopt`), a quick orientation. Reply in the project conversation language.

## Phase 1: Catalog
Read `.claude/docs/workflow-catalog.yaml`: phases, steps, `artifact.glob`. Missing → the studio is not initialised: answer "run `/init`" and stop.
`technical-preferences.md` still `[TO BE CONFIGURED]` on a project that has code → the studio was initialised but not adopted: NEXT is `/adopt full`.

## Phase 2: Where we are
Stage from `production/stage.txt`; otherwise infer from artefacts (the first phase with an unmet required step).
For the current phase check every step by glob: ✅ done / ⬜ missing / 🔁 repeatable. Take the user's argument into account ("just finished X"): find step X in the catalog and take the next step of its phase (or the first step of `next_phase`) as NEXT — e.g. "finished security-audit" → `/dependency-audit`/`/harden` in hardening.
If `docs/adoption-plan-*.md` exists (the newest one), count its open items (`- [ ]`): show `Adoption plan: N open`;
when the phase has no unmet required step (typical for `operate`), the first open plan item is NEXT.

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
```
If the stack reference is older than 60 days — one line recommending `/stack-update`.
If `production/session-state/active.md` exists — show its `Task:`/`Next:`.
If `production/findings.md` has open BLOCKING findings without a story — one line `Open BLOCKING findings: N without a story → /create-stories` (they take precedence over the next feature).
External signals (a red CI, a failed deploy, a billing or access problem seen in `session-state`, a tech-debt CRITICAL) are **one `Attention:` line each** with the command or place that fixes them — never the subject of the closing question and never investigated here (no `gh run`, no log reading: help is orientation, not diagnosis).
Build phase with a Deploy target in technical-preferences and no `docs/ops/deploy.md` — one line: the "Deploy artefacts" story is missing (`/create-stories` adds it).
Game project (technical-preferences type game / game+backend): when every story of the first feature is Done and `production/releases/gate-prototype.md` is missing — NEXT is `/game-concept gate`, not the next feature.

Verdict: `READY`. Next step — one `AskUserQuestion` about the pipeline only: the "Next" command (Recommended) · up to two "Also available" commands relevant to the phase · nothing now. Run nothing without that answer; `Attention:` items are not options here.
