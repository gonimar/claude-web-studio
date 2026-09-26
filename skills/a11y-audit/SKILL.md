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

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

`stack-reference/web-platform.md` ("Accessibility"); template `findings.md`. In the commands below, `<hooks>` is `.claude/hooks/` in copy mode and `${CLAUDE_PLUGIN_ROOT}/hooks/` in plugin mode.

**One axe file, two moments.** The axe spec is one Playwright file, `<e2e dir>/a11y/axe.spec.ts` (`<e2e dir>` is the Playwright `testDir`, resolved in this order: `testDir` in `playwright.config.{ts,js,mjs}` first; then the directory `docs/architecture/test-strategy.md` names for the e2e level, when it names one; else `e2e/`, with one line in the report saying the path was assumed). Phase 2 creates it to run the audit; Phase 4 keeps that same file as the regression test — never a second file for the same routes.

## Phase 1: Scope
Routes/pages (from UX specs or the argument); is the dev server running? (offer to start it).

## Phase 2: Automation
`@axe-core/playwright` over the routes in `<e2e dir>/a11y/axe.spec.ts` — created only after "May I write `<e2e dir>/a11y/axe.spec.ts`?" (one `AskUserQuestion`: write (Recommended) · show the draft first · skip automation; `touch .claude/.write-consent` after the "write" answer) — plus Lighthouse a11y; the output of both is in the report.

## Phase 3: Manual checklist
Keyboard, focus (2.4.11/2.4.13), names, ARIA, contrast, target size (2.5.8), forms (3.3.7/3.3.8), motion; games — keyboard/gamepad menus, settings.
**Canvas menus**: a menu, HUD or settings screen drawn on the canvas with no accessible DOM overlay mirroring it (web-platform.md "Accessibility": the canvas is mirrored by an accessible DOM overlay for menus) is a **critical** finding — the menu is invisible to keyboard and screen-reader users — never a note or a WARNING, whatever axe reports (axe sees no elements to fail).

## Phase 4: Report
1. Table "finding → WCAG criterion → severity → file → fix".
2. "May I write `docs/ops/a11y-audit-<date>.md` and the axe regression test `<e2e dir>/a11y/axe.spec.ts`?" — one `AskUserQuestion`: write (Recommended) · show the draft/diff first · not now. The regression test is the Phase 2 spec in its final form (the routes in scope pinned; a rule disabled only for a finding recorded in `production/findings.md`, with its `A11Y-NNN` in a comment); when Phase 2 skipped automation, the file is created here. After the "write" answer: `touch .claude/.write-consent` (rule 7).
3. For every critical finding, one `AskUserQuestion`: record it in `production/findings.md` (`A11Y-NNN`, template `findings.md`) (Recommended) · fix stories now · report only. Record the gate before asking — `<hooks>session-state.sh set Gate "/a11y-audit Phase 4: record A11Y-NNN?"` — and clear it after the answer (`<hooks>session-state.sh set Gate "—"`).

## Phase 5: Commit (documents lane)
Right after the write (and the findings rows, when any were recorded), one commit gate (rule 7 (4), `.claude/docs/git-workflow.md` § Documents): `docs: a11y audit <date>`, staging exactly the written documents — `docs/ops/a11y-audit-<date>.md` and `production/findings.md` when rows were added. Record the gate before asking — `<hooks>session-state.sh set Gate "/a11y-audit Phase 5: commit?"` — and clear it after the answer (`<hooks>session-state.sh set Gate "—"`).
- On the default branch when no story work is in progress: one `AskUserQuestion` — commit (Recommended) · leave uncommitted.
- When HEAD is a story branch, name it and ask one `AskUserQuestion`: switch to the default branch and commit there (Recommended — a pipeline-wide document) · commit here (the document belongs to this story) · leave uncommitted.
- `<e2e dir>/a11y/axe.spec.ts` is test code, not a document: it never rides the `docs:` commit — name it and offer the chore lane (git-workflow.md § Chore / infra, branch `chore/a11y-axe-regression`) or the fix story it belongs to.

Nothing is committed without the answer.

Verdict: `PASS` | `FAIL (N critical)`. Next step — one `AskUserQuestion`: fix the critical findings via `angular-engineer`/`vue-engineer`/`css-engineer` (Recommended) · re-run `/a11y-audit` after fixes · `/release-checklist`.
