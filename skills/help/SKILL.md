---
name: help
description: "Shows where you are in the Web Studio pipeline and what to do next. Use when the user asks 'what now', 'what should I do next', or is stuck."
argument-hint: "[optional: what you just finished]"
user-invocable: true
allowed-tools: Read, Glob, Grep, AskUserQuestion
context: |
  !echo "stage: $(cat production/stage.txt 2>/dev/null || echo 'not set') | review-mode: $(cat production/review-mode.txt 2>/dev/null || echo 'lean') | studio: $(cat .claude/.web-studio-version 2>/dev/null || echo '?') | stack-ref: $(sed -n 's/^updated: *//p' .claude/docs/stack-reference/index.md 2>/dev/null)"
model: haiku
---

# Help — what next?

Read-only. Not a full audit (that is `/adopt`), a quick orientation. Reply in the project conversation language.

## Phase 1: Catalog
Read `.claude/docs/workflow-catalog.yaml`: phases, steps, `artifact.glob`. Missing → the studio is not initialised: answer "run `/init`" and stop.

## Phase 2: Where we are
Stage from `production/stage.txt`; otherwise infer from artefacts (the first phase with an unmet required step).
For the current phase check every step by glob: ✅ done / ⬜ missing / 🔁 repeatable. Take the user's argument into account ("just finished X").

## Phase 3: Uncatalogued skills
Glob `.claude/skills/*/SKILL.md` (copy mode) and the plugin's skills if visible; compare `name:` with the catalog's `command:`; show up to 8 relevant to the phase as "Also available".

## Phase 4: Output
```
Stage: [label] ([N/M] required done)
✅ /setup-stack — stack pinned
⬜ /product-spec — no docs/specs/product-spec.md   ← NEXT
🔁 /feature-spec — 2 specs exist
Next: /product-spec  (why: nothing to check features against without it)
Also available: /stack-update, /team-feature …
```
If the stack reference is older than 60 days — one line recommending `/stack-update`.
If `production/session-state/active.md` exists — show its `Task:`/`Next:`.

Verdict: `READY`. Next step — one `AskUserQuestion`: the "Next" command (Recommended) · up to two "Also available" commands relevant to the phase · nothing now. Run nothing without that answer.
