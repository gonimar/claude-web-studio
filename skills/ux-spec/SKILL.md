---
name: ux-spec
description: "Authors a UX specification for a flow or screen — user goal, flow, screens, all states, UI copy, accessibility, responsive behaviour, UX metrics. Produces docs/specs/ux/UX-NNN-name.md. Use before implementing user-facing features."
argument-hint: "[flow or feature F-NNN]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion, Task
model: sonnet
agent: design-lead
---

# UX Spec

Template `.claude/docs/templates/ux-spec.md`.

## Phase 1: Context
Read the feature spec, `docs/specs/design-system.md` (missing → suggest `/design-system`, continue with the UI kit's base components from technical-preferences), the product spec (personas, platforms).

## Phase 2: Flow and screens
Questions: entry point, device, frequency. A flow sketch (mermaid `flowchart`), then screens with design-system components;
**states per screen** (empty/loading/error/success/offline/no permission) are mandatory.

## Phase 3: Copy, accessibility, responsive
Copy table; focus order and aria; behaviour at 320–400 px; reduced motion.
`accessibility-specialist` via Task — a quick check of section 6 (Haiku).

## Phase 4: Write
"May I write `docs/specs/ux/UX-NNN-<slug>.md`?"

Verdict: `APPROVED` | `NEEDS REVISION`. Next step: `/create-stories F-NNN` or `/dev-story`.
