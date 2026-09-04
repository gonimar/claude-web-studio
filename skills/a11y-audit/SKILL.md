---
name: a11y-audit
description: "Audits accessibility against WCAG 2.2 AA — axe-core via Playwright, Lighthouse a11y, a manual keyboard/screen-reader checklist for key flows, game accessibility settings; findings with WCAG criteria and fixes. Required before release."
argument-hint: "[url or route list | all]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Write, Task, AskUserQuestion
model: haiku
agent: accessibility-specialist
---

# A11y Audit

`web-platform.md` ("Accessibility").

## Phase 1: Scope
Routes/pages (from UX specs or the argument); is the dev server running? (offer to start it).

## Phase 2: Automation
`@axe-core/playwright` over the routes (create the spec with consent), Lighthouse a11y — output.

## Phase 3: Manual checklist
Keyboard, focus (2.4.11/2.4.13), names, ARIA, contrast, target size (2.5.8), forms (3.3.7/3.3.8), motion; games — keyboard/gamepad menus, settings.

## Phase 4: Report
Table "finding → WCAG criterion → severity → file → fix". "May I write `docs/ops/a11y-audit-<date>.md` and an axe regression test?"

Verdict: `PASS` | `FAIL (N critical)`. Next step: fixes via `angular-engineer`/`vue-engineer`/`css-engineer`.
