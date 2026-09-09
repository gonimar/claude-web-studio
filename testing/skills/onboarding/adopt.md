# Skill Spec: /adopt

> **Category**: onboarding · **Priority**: critical · **Spec written**: 2026-09-05

## Summary
Attach the studio to an existing project: stack detection, artefact audit, settings merge, plan.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path
**Fixture**: PHP/Yii3 project with an existing deploy skill. **Expected**: `technical-preferences.md` filled from composer.json / compose / CI facts in this run; companion skill noted; prioritised adoption plan with checkbox items.
- [ ] phase order followed · [ ] output matches the expectation · [ ] writes only after consent · [ ] no `[TO BE CONFIGURED]` left for fields the files answer · [ ] the unknown fields asked in one `AskUserQuestion`
### 2. Refusal / BLOCKED
**Fixture**: not a git repository. **Expected**: stops.
- [ ] stops or explicitly flags the limitation · [ ] names the command/reason · [ ] writes no files
### 3. Mode/argument variant
**Fixture**: settings mode → only the settings diff. **Expected**: behaviour differs from case 1 according to the argument.
- [ ] argument parsed · [ ] the difference matches the skill description
### 4. Edge case
**Fixture**: CLAUDE.md exists without the studio block → insertion proposed, not overwrite. **Expected**: handled explicitly, never silently skipped.
- [ ] the case is mentioned in the instructions · [ ] correct message/action
### 5. Gate / protocol
**Fixture**: plan written after "May I write?". **Expected**: the user decides; stage/statuses never change automatically.
- [ ] no self-advancing · [ ] verdict from the skill's vocabulary

### 6. Plan and hand-off
**Fixture**: plan written. **Expected**: `docs/adoption-plan-<date>.md` follows `templates/adoption-plan.md`, items are `- [ ]` checkboxes; hand-off is one `AskUserQuestion` with the first open item Recommended (`/help` · stop).
- [ ] template used · [ ] checkbox items · [ ] hand-off is an `AskUserQuestion`

### 7. Deploy delegate detection
**Fixture**: `.claude/agents/<kit>-ops.md` without `deploy-target:`; a `/<kit>` slash command. **Expected**: `Deploy target: <kit>`, `Deploy delegate: none` with the reason "kit ships only a slash command — add `deploy-target:` to its agent"; Tier 0 row notes it.
- [ ] detection by frontmatter/script, not by command name · [ ] reason recorded

### 8. Preferences are gated
**Fixture**: stack detected. **Expected**: the filled draft is shown and `technical-preferences.md` is written only after the `AskUserQuestion` answer — never before; a write-then-ask is a protocol violation even if reverted.
- [ ] draft shown · [ ] AskUserQuestion before the write · [ ] no write before the answer

### 9. No git repository
**Fixture**: sources without `.git`; the user's global git config sets `init.defaultBranch=master`. **Expected**: one `AskUserQuestion` (initialize git now Recommended · stop); on "stop" the skill ends with `BLOCKED (not a git repository — adoption relies on history and branches)` and never asks again in the same run; on "yes" it runs plain `git init` — the resulting branch is `master` (the user's configured default), never a hardcoded `-b main`.
- [ ] exactly one question, no re-ask after a decline · [ ] decline ends in BLOCKED · [ ] plain `git init`, branch honours `init.defaultBranch`

### 10. Owner's goal is solicited
**Fixture**: adoption plan produced with N open items. **Expected**: the hand-off question offers, alongside the first open item, an explicit "describe your goal in your own words" option; a stated goal ("modernise versions and swap the HTTP layer, don't break behaviour") reorders the plan — goal-serving items first — before any command is recommended.
- [ ] goal option present in the hand-off · [ ] stated goal visibly reorders the plan

### 11. HIGH from the artefact audit reaches findings.md
**Fixture**: `full` mode on a deployed project; the artefact audit finds one HIGH (traceability lost: a decision recorded as done whose artefact does not exist). **Expected**: besides the plan row, one `AskUserQuestion` (record in `production/findings.md` as `ADOPT-NNN` Recommended · story stubs · plan only); on "record" the row is written after the answer; on "plan only" the verdict line still lists the item as unrecorded.
- [ ] question asked per BLOCKING/HIGH · [ ] row written only after consent · [ ] verdict line names unrecorded items

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
