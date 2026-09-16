# Skill Spec: /brainstorm

> **Category**: authoring · **Priority**: medium · **Spec written**: 2026-09-05

## Summary
Idea exploration: audience, pain, comparables, framing, hypotheses; concept brief.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path
**Fixture**: idea "court booking service". **Expected**: one question at a time; 3 scope variants; brief after consent.
- [ ] phase order followed · [ ] output matches the expectation · [ ] writes only after consent
### 2. Refusal / BLOCKED
**Fixture**: no topic. **Expected**: asks.
- [ ] stops or explicitly flags the limitation · [ ] names the command/reason · [ ] writes no files
### 3. Mode/argument variant
**Fixture**: game → MDA and core loop. **Expected**: behaviour differs from case 1 according to the argument.
- [ ] argument parsed · [ ] the difference matches the skill description
### 4. Edge case
**Fixture**: WebSearch unavailable → no comparables, flagged. **Expected**: handled explicitly, never silently skipped.
- [ ] the case is mentioned in the instructions · [ ] correct message/action
### 5. Gate / protocol
**Fixture**: no review. **Expected**: the user decides; stage/statuses never change automatically.
- [ ] no self-advancing · [ ] verdict from the skill's vocabulary

### The brief follows its template
**Fixture**: a `/brainstorm` run that reaches Phase 3. **Expected**: `docs/specs/concept-brief.md` carries the template's eight sections in order, hypotheses as a table with a validation method per row, and a next step naming a command; an empty section is written as `n/a — reason` rather than omitted, so `/product-spec` Phase 1 finds what it reads.
- [ ] template used · [ ] hypotheses table present · [ ] next step names a command · [ ] no section silently dropped

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
