---
name: design-system
description: "Defines the project design system — principles, --ds-* tokens (colour roles, spacing, type, radius, motion) for light/dark, component inventory with states and aria patterns, mapping to Angular Material / Taiga UI / Vue kits, game HUD rules. Produces docs/specs/design-system.md and a tokens CSS draft."
argument-hint: "[--base material|taiga|primevue|vuetify|custom]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, AskUserQuestion, Task
model: sonnet
agent: design-lead
---

# Design System

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

Template `.claude/docs/templates/design-system.md`. References: `web-platform.md` (WCAG, CSS Baseline), `angular.md`/`vue.md` (UI-kit themes). In the commands below, `<hooks>` is `.claude/hooks/` in copy mode and `${CLAUDE_PLUGIN_ROOT}/hooks/` in plugin mode.

## Phase 1: Base and principles
Base from `technical-preferences.md` or the argument; questions: tone (strict/playful), density, brand colours (if any), dark theme needed?, target devices.
**No product spec** (`docs/specs/product-spec.md` missing) → not blocking: the questions above are asked all the same, the component needs Phase 3 would read from the spec are asked here too (the screens and controls the product will have), and the document says its inventory came from these answers, not from a spec — `/product-spec` is named as the follow-up that will confirm it.

## Phase 2: Tokens
Draft colour roles with computed contrast (4.5:1 / 3:1), spacing/typography scales (fluid `clamp()`), radii/shadows/motion.
- **Dark theme wanted** (Phase 1 answer): two colour sets, light and dark, each with its contrast computed; `color-scheme: light dark` and `light-dark()` per role in the draft.
- **No dark theme**: one colour set, `color-scheme: light`, no `light-dark()` — the role names stay the same, so a dark set can be added later without renaming a token.
- **Mapping onto the base kit**: `--mat-*` (Material — the theme itself is a `mat.theme()` call in the theme SCSS, as `angular.md` states; the `--ds-*` roles are mapped onto the `--mat-*` system tokens, never onto component internals) / `--tui-*` (Taiga) / `@theme` (Tailwind-based kits and `custom`).
Show a `tokens.css` draft (`@layer base { :root { --ds-… } }`, with `light-dark()` only in the dark-theme case) and, for Material, the `mat.theme()` snippet.

## Phase 3: Components and patterns
Inventory from the needs of the product spec/feature specs (or the Phase 1 answers when there is no spec); per component — states and aria pattern (WAI-ARIA APG); patterns for forms/tables/empty states/dialogs.

## Phase 4: Write
Show the tokens table and the inventory in the chat, then "May I write `docs/specs/design-system.md` and `[frontend_root]/src/styles/tokens.css`?" — one `AskUserQuestion`: write (Recommended) · show the draft/diff first · not now — the CSS is written by `css-engineer` via Task after consent. After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker).

## Phase 5: Commit (documents lane)
Right after the write, one commit gate (rule 7 (4), `.claude/docs/git-workflow.md` § Documents): `docs: design system`, staging exactly `docs/specs/design-system.md`. Record the gate before asking — `<hooks>session-state.sh set Gate "/design-system Phase 5: commit?"` — and clear it after the answer (`<hooks>session-state.sh set Gate "—"`).
- On the default branch when no story work is in progress: one `AskUserQuestion` — commit (Recommended) · leave uncommitted.
- When HEAD is a story branch, name it and ask one `AskUserQuestion`: switch to the default branch and commit there (Recommended — a pipeline-wide document) · commit here (the document belongs to this story) · leave uncommitted.
- `[frontend_root]/src/styles/tokens.css` (and a Material theme SCSS) is code, not a document: it never rides the `docs:` commit — name it and offer the chore lane (git-workflow.md § Chore / infra, branch `chore/design-tokens`) or the first UI story it belongs to.

Nothing is committed without the answer.

Verdict: `COMPLETE`. Next step — one `AskUserQuestion`: `/ux-spec` for the first flow (Recommended) · `/feature-spec` · revise the tokens.
