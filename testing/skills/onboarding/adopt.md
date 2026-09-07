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

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
