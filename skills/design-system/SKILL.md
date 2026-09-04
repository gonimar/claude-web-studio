---
name: design-system
description: "Defines the project design system — principles, --ds-* tokens (colour roles, spacing, type, radius, motion) for light/dark, component inventory with states and aria patterns, mapping to Angular Material / Taiga UI / Vue kits, game HUD rules. Produces docs/specs/design-system.md and a tokens CSS draft."
argument-hint: "[--base material|taiga|primevue|vuetify|custom]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion, Task
model: sonnet
agent: design-lead
---

# Design System

Template `.claude/docs/templates/design-system.md`. References: `web-platform.md` (WCAG, CSS Baseline), `angular.md`/`vue.md` (UI-kit themes).

## Phase 1: Base and principles
Base from `technical-preferences.md` or the argument; questions: tone (strict/playful), density, brand colours (if any), dark theme needed?, target devices.

## Phase 2: Tokens
Draft colour roles for light/dark with computed contrast (4.5:1 / 3:1), spacing/typography scales (fluid `clamp()`), radii/shadows/motion. Mapping onto `--mat-*`/`--tui-*`/`@theme`.
Show a `tokens.css` draft (`@layer base { :root { --ds-… } }`, `light-dark()`).

## Phase 3: Components and patterns
Inventory from the needs of the product spec/feature specs; per component — states and aria pattern (WAI-ARIA APG); patterns for forms/tables/empty states/dialogs.

## Phase 4: Write
"May I write `docs/specs/design-system.md` and `[frontend_root]/src/styles/tokens.css`?" — the CSS is written by `css-engineer` via Task after consent.

Verdict: `COMPLETE`. Next step: `/ux-spec` for the first flow.
