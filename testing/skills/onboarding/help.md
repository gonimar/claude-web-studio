# Skill Spec: /help

> **Category**: onboarding · **Priority**: critical · **Spec written**: 2026-09-05

## Summary
Where we are in the pipeline and one next step; read-only.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path
**Fixture**: stage=build, 3 Ready stories. **Expected**: phase step table, NEXT — /dev-story.
- [ ] phase order followed · [ ] output matches the expectation · [ ] writes only after consent
### 2. Refusal / BLOCKED
**Fixture**: workflow-catalog.yaml missing. **Expected**: says run /init and stops.
- [ ] stops or explicitly flags the limitation · [ ] names the command/reason · [ ] writes no files
### 3. Mode/argument variant
**Fixture**: argument "finished security-audit" → next /harden. **Expected**: behaviour differs from case 1 according to the argument.
- [ ] argument parsed · [ ] the difference matches the skill description
### 4. Edge case
**Fixture**: reference older than 60 days → a /stack-update line. **Expected**: handled explicitly, never silently skipped.
- [ ] the case is mentioned in the instructions · [ ] correct message/action
### 5. Gate / protocol
**Fixture**: no file writes at all. **Expected**: the user decides; stage/statuses never change automatically; the next step is one `AskUserQuestion` (the "Next" command Recommended · up to two alternatives · nothing now), not a text line to retype.
- [ ] no self-advancing · [ ] verdict from the skill's vocabulary · [ ] next step is an `AskUserQuestion` with a Recommended option and alternatives

### 6. Adopted project in operate
**Fixture**: `stage.txt = operate`, `docs/adoption-plan-2026-09-08.md` with 3 open items, no unmet required step. **Expected**: output shows `Adoption plan: 3 open — first: …`; NEXT is the first open plan item, Recommended in the `AskUserQuestion`.
- [ ] adoption plan read · [ ] first open item is NEXT · [ ] still read-only
### 7. Initialised but not adopted
**Fixture**: code in the repo, `technical-preferences.md` all `[TO BE CONFIGURED]`. **Expected**: NEXT is `/adopt full`, with the reason.
- [ ] the placeholder is detected · [ ] `/adopt full` Recommended

### 8. Open findings and missing deploy artefacts
**Fixture**: `production/findings.md` has 2 open BLOCKING without a story; build phase with Deploy target set and no `docs/ops/deploy.md`. **Expected**: both lines shown; findings take precedence in NEXT.
- [ ] findings line · [ ] deploy artefacts line · [ ] NEXT = `/create-stories`
### 9. Game gate
**Fixture**: type game, all F-001 stories Done, no `production/releases/gate-prototype.md`. **Expected**: NEXT is `/game-concept gate`.
- [ ] gate detected · [ ] Recommended option is the gate

### 10. External signal
**Fixture**: CI on the default branch red for two days (billing), tech-debt report with one CRITICAL. **Expected**: one `Attention:` line each with where to fix; no `gh run`/log investigation; the closing `AskUserQuestion` offers pipeline steps only.
- [ ] Attention lines · [ ] no investigation · [ ] question about the pipeline only

### 11. Plugin version drift
**Fixture**: plugin mode, session-start context prints `Plugin root: …/web-studio/0.5.5`; `.claude/docs/coordination-rules.md` differs from `<plugin root>/docs/coordination-rules.md`; no `.claude/.web-studio-version`. **Expected**: one line `Seeded docs differ from plugin v0.5.5 (1 file) — /update re-seeds changed docs/rules` and `/update` among the closing options; with `claude plugin list --json` reporting 0.5.6 installed, a second line `session runs v0.5.5, v0.5.6 is installed — restart the session`; a stray stamp in plugin mode is ignored as a copy-mode leftover. Copy mode: the stamp compared with the kit's `plugin.json` when the kit path is known, otherwise the check is skipped.
- [ ] both versions named · [ ] /update offered · [ ] silent when equal

### 12. Adoption plan in table format
**Fixture**: newest `docs/adoption-plan-*.md` written before 0.7.0 (numbered table, no checkboxes). **Expected**: rows are read as items, `Adoption plan: N open` with a one-line note about the format, never `0 open`.
- [ ] table rows counted · [ ] format note shown
### 13. Brownfield operate with a COMPLIANT plan
**Fixture**: stage `operate`, adoption plan `COMPLIANT` with open optional items, no product spec. **Expected**: NEXT is the plan's first open item; the missing product spec is shown as `⬜ (not migrated by decision)`, not as NEXT; the report never calls its own NEXT low-value.
- [ ] plan items precede earlier-phase steps · [ ] no self-contradicting NEXT

### 14. `commands` — every command from the skill files
**Fixture**: argument `commands`; plugin root visible in the session-start context, one project-local skill in `.claude/skills/`. **Expected**: one line per command (`/name <argument-hint> — first sentence`), read from the frontmatters (Glob), grouped by catalog phase in catalog order with required steps marked `*`, the project-local skill under "Maintenance and teams"; a `Details:` line; verdict `READY`; no closing `AskUserQuestion`.
- [ ] read from files, not memory · [ ] grouped and marked · [ ] ends with a text line
### 15. `guide` — playbook table of contents and one section
**Fixture**: argument `guide`, then `guide 10.7`, then `guide hotfix`; `.claude/docs/playbook.md` seeded, project language with a translation in `.claude/docs/readme/`. **Expected**: `guide` prints the numbered headings and the one-line usage hint; `guide 10.7` prints that section verbatim (the translation when one exists) plus up to three related section numbers; `guide hotfix` matches §10.26/§10.1 by heading text; an unknown topic prints the table of contents with `no section matches`; playbook absent everywhere → `playbook not seeded — run /update`. Never paraphrased.
- [ ] TOC from headings · [ ] section verbatim · [ ] synonym match · [ ] not-seeded line
### 16. `Docs:` line in the normal output
**Fixture**: case 1. **Expected**: the report ends with `Docs: /help commands · /help guide · /help guide <n>` before the closing question — always, on every project.
- [ ] Docs line present

### 17. Backlog reminder and first-line guide match
**Fixture**: `production/backlog.md` with four open ideas, oldest 45 days, `last-review` 12 days ago; `/help guide "two sessions"`. **Expected**: one line `Backlog: 4 ideas, oldest 45 days → /backlog review` in the report (never an option in the closing question); the guide prints §10.12 because its first line matches, heading matches win over first-line matches when both exist.
- [ ] backlog line · [ ] not in the question · [ ] first-line match

### A merged branch, a placeholder and a command that does not exist
**Fixture**: session-start printed "branch already merged into origin/master" and a `[One paragraph: …]` placeholder in CLAUDE.md; the project has one story in progress. **Expected**: both signals appear as their own lines in the answer; the next step names only commands that exist in the catalog or in a skill's `argument-hint` — closing a story is `/story-done`, never `/dev-story complete S-NNN`.
- [ ] session-start warnings repeated · [ ] no invented sub-command · [ ] every named command resolves to a skill

### No frontmatter context, two read-only commands (0.14)
**Fixture**: no `docs/adoption-plan-*.md`, no `.claude/docs/stack-reference/index.md`. **Expected**: the frontmatter carries no `context:` block (the only documented value is `fork`, which a gated skill cannot use); Phase 1 reads the files itself and prints `adoption-plan: none` / `stack-ref: ?` when they are absent; the body names the only two commands the skill runs — `diff -rq` for the drift signal and `claude plugin list --json` for the installed version — and says it writes no file; `Bash` is pre-granted for those two commands only.
- [ ] no `context:` in the frontmatter · [ ] `none` / `?` as the fallback · [ ] Phase 1 reads the files itself · [ ] the two commands named, "no file writes" stated

### Roadmap first open item
**Fixture**: `production/roadmap.md` in v3.1 whose first open line is `- [ ] [S-012](stories/S-012.md) · Repository layer ~8h`; no adoption plan; stage `build` with every required step met. **Expected**: the report carries `Roadmap: N open — first: S-012 · Repository layer`; NEXT is `/dev-story S-012`, Recommended in the closing question; with an open adoption-plan item or an unmet required step, those come first and the roadmap line is still printed.
- [ ] roadmap line printed · [ ] first open item is NEXT when nothing else claims it · [ ] plan items and required steps still precede it

### The answer is not executed here (0.12)
**Fixture**: plugin mode, `/help` after `/dev-story`, the user picks "/web-studio:code-review (Recommended)". **Expected**: the output names every command as `/web-studio:<name>`; after the answer the skill prints `Run: /web-studio:code-review --diff …` and ends the turn — no `Skill` call in the same turn (the skill would inherit Haiku).
- [ ] namespaced commands in plugin mode · [ ] no Skill call after the closing question · [ ] `Run:` line printed

### An overdue sprint is an Attention line (0.13)
**Fixture**: latest `sprint-04.md` header `Status: active`, its roadmap heading's end date yesterday (or no `- [ ]` left under it). **Expected**: `Attention: sprint 04 is over and not closed — /web-studio:retrospective 04` as one line; it is not an option of the closing question and no sprint file is read beyond the header.
- [ ] one Attention line · [ ] not in the question · [ ] no diagnosis

### The argument beats a COMPLIANT plan's open items (0.14)
**Fixture**: adoption plan `COMPLIANT` with open optional items; the user runs `/help "finished security-audit"`. **Expected**: NEXT is the next step of the hardening phase (rank 2, the user's explicit position), the plan's first open item is printed right after it (rank 3); case 13 still holds without an argument.
- [ ] argument wins over plan items · [ ] plan item still printed · [ ] no argument → case 13

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
