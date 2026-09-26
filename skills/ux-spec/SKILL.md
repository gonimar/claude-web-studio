---
name: ux-spec
description: "Authors a UX specification for a flow or screen — user goal, flow, screens, all states, UI copy, accessibility, responsive behaviour, UX metrics. Produces docs/specs/ux/UX-NNN-name.md. Use before implementing user-facing features."
argument-hint: "[flow or feature F-NNN]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, AskUserQuestion, Task
---

# UX Spec

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

Template `.claude/docs/templates/ux-spec.md`. In the commands below, `<hooks>` is `.claude/hooks/` in copy mode and `${CLAUDE_PLUGIN_ROOT}/hooks/` in plugin mode.

## Phase 1: Context
1. **The feature spec** the argument names (`F-NNN`, or the feature the named flow belongs to — ask when unclear). Missing → verdict `BLOCKED (no feature spec — run /feature-spec F-NNN first)`; write nothing.
2. **Read** `docs/specs/design-system.md` (missing → suggest `/design-system`, continue with the UI kit's base components from technical-preferences) and the product spec (personas, platforms).

## Phase 2: Flow and screens
Questions: entry point, device, frequency. A flow sketch (mermaid `flowchart`), then screens with design-system components;
**states per screen** (empty/loading/error/success/offline/no permission) are mandatory.

## Phase 3: Copy, accessibility, responsive
Copy table; focus order and aria; behaviour at 320–400 px; reduced motion.
`accessibility-specialist` via Task — a quick check of section 6, Accessibility (Haiku).

## Phase 4: Write
"May I write `docs/specs/ux/UX-NNN-<slug>.md`?" — one `AskUserQuestion`: write (Recommended) · show the draft/diff first · not now. After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker).

## Phase 5: Commit (documents lane)
Right after the write, one commit gate (rule 7 (4), `.claude/docs/git-workflow.md` § Documents): one `AskUserQuestion` offering `docs: UX spec UX-NNN`, staging exactly the written files — `docs/specs/ux/UX-NNN-<slug>.md`. Record the gate before asking — `<hooks>session-state.sh set Gate "/ux-spec Phase 5: commit?"` — and clear it after the answer (`<hooks>session-state.sh set Gate "—"`).
- On the default branch when no story work is in progress.
- When HEAD is a story branch, name it and offer: switch to the default branch and commit there (Recommended — a pipeline-wide document) · commit here (the document belongs to this story) · leave uncommitted.
- Code, configs, workflows and scripts never ride the `docs:` commit.

Nothing is committed without the answer.

Verdict: `APPROVED` | `NEEDS REVISION` | `BLOCKED`. Next step — one `AskUserQuestion`: `/create-stories F-NNN` (Recommended) · `/dev-story` · revise the spec; on `BLOCKED`: `/feature-spec F-NNN` (Recommended) · stop here.
