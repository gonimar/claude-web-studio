# Skill Spec: /design-system

> **Category**: authoring · **Priority**: high · **Spec written**: 2026-09-05

## Summary
Tokens, themes, components, mapping onto Material/Taiga.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path
**Fixture**: --base taiga. **Expected**: tokens.css draft, contrast computed.
- [ ] phase order followed · [ ] output matches the expectation · [ ] writes only after consent
### 2. Refusal / BLOCKED
**Fixture**: no product spec. **Expected**: continues with questions (not blocking): the component needs are asked in Phase 1, the document says the inventory came from answers, `/product-spec` is named as the follow-up.
- [ ] explicitly flags the limitation · [ ] names the command/reason · [ ] writes no files before the gate
### 3. Mode/argument variant
**Fixture**: `--base material`. **Expected**: behaviour differs from case 1 according to the argument: a `mat.theme()` snippet for the theme SCSS and the `--ds-*` roles mapped onto the `--mat-*` system tokens (not `--tui-*`).
- [ ] argument parsed · [ ] the difference matches the skill description
### 4. Edge case
**Fixture**: no dark theme (Phase 1 answer) → one colour set. **Expected**: handled explicitly, never silently skipped: `color-scheme: light`, no `light-dark()` in the draft, role names unchanged.
- [ ] the case is mentioned in the instructions · [ ] correct message/action
### 5. Gate / protocol
**Fixture**: CSS written by css-engineer after consent. **Expected**: the user decides; stage/statuses never change automatically.
- [ ] no self-advancing · [ ] verdict from the skill's vocabulary

### 6. Commit gate on the documents lane
**Fixture**: document and `tokens.css` written while HEAD is `feat/S-001-…` (a story branch). **Expected**: right after the write gate one commit gate offers `docs: design system` staging exactly `docs/specs/design-system.md`, names the current branch and asks where it belongs (switch to the default branch Recommended for a pipeline-wide document · commit here · leave uncommitted); `tokens.css` is named and offered the chore lane or a UI story, never staged with the document; nothing is committed without the answer.
- [ ] commit gate follows the write · [ ] current branch named · [ ] default-branch option Recommended · [ ] `tokens.css` never rides the `docs:` commit

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
