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
**Fixture**: `.claude/.web-studio-version` = 0.5.1; session-start context prints `Plugin root: …/web-studio/0.5.5`. **Expected**: one line naming both versions and recommending `/update`; `/update` appears among the closing question's options; no drift line when the versions match or in copy mode (no plugin root).
- [ ] both versions named · [ ] /update offered · [ ] silent when equal

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
