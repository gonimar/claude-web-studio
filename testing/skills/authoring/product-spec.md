# Skill Spec: /product-spec

> **Category**: authoring · **Priority**: critical · **Spec written**: 2026-09-05

## Summary
Product spec section by section with review per mode.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path
**Fixture**: concept brief exists, mode lean. **Expected**: 10 sections with questions; NFR defaults; written after consent.
- [ ] phase order followed · [ ] output matches the expectation · [ ] writes only after consent
### 2. Refusal / BLOCKED
**Fixture**: no clarity about the product. **Expected**: suggests /brainstorm.
- [ ] stops or explicitly flags the limitation · [ ] names the command/reason · [ ] writes no files
### 3. Mode/argument variant
**Fixture**: --review full → TD + security-lead in parallel. **Expected**: behaviour differs from case 1 according to the argument.
- [ ] argument parsed · [ ] the difference matches the skill description
### 4. Edge case
**Fixture**: feature out of scope → Out with a reason. **Expected**: handled explicitly, never silently skipped.
- [ ] the case is mentioned in the instructions · [ ] correct message/action
### 5. Gate / protocol
**Fixture**: CONCERNS → no stage advancement. **Expected**: the user decides; stage/statuses never change automatically.
- [ ] no self-advancing · [ ] verdict from the skill's vocabulary

### 6. BLOCKING from the review reaches findings.md
**Fixture**: lean mode; `technical-director` returns CONCERNS with one BLOCKING (a fact in the draft the repository contradicts) and one HIGH. **Expected**: the draft is corrected; for each of the two items one `AskUserQuestion` (record in `production/findings.md` as `ARCH-NNN` Recommended · story stubs · spec only); a declined BLOCKING is named in the verdict line as unrecorded; the row is written only after the answer.
- [ ] one question per BLOCKING/HIGH · [ ] `findings.md` row follows the template · [ ] unrecorded BLOCKING appears in the verdict line

### 7. Retrofit on an operate project
**Fixture**: stage `operate`, deployed code, no spec. **Expected**: retrofit mode — draft from CLAUDE.md/roadmap/code shown as a whole, questions only where facts are silent; `stage.txt` is not proposed backwards; a claim the repository contradicts is BLOCKING in the review.
- [ ] no stage proposal on operate · [ ] claims verified against the repo

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
