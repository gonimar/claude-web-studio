# Skill Spec: /tech-debt

> **Category**: analysis · **Priority**: medium · **Spec written**: 2026-09-05

## Summary
Debt inventory across code, dependencies, ADRs, audits.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path
**Fixture**: full. **Expected**: prioritised table.
- [ ] phase order followed · [ ] output matches the expectation · [ ] writes only after consent
### 2. Refusal / BLOCKED
**Fixture**: no code. **Expected**: empty with a note.
- [ ] stops or explicitly flags the limitation · [ ] names the command/reason · [ ] writes no files
### 3. Mode/argument variant
**Fixture**: area → subset. **Expected**: behaviour differs from case 1 according to the argument.
- [ ] argument parsed · [ ] the difference matches the skill description
### 4. Edge case
**Fixture**: outdated major → /stack-update. **Expected**: handled explicitly, never silently skipped.
- [ ] the case is mentioned in the instructions · [ ] correct message/action
### 5. Gate / protocol
**Fixture**: written with consent. **Expected**: the user decides; stage/statuses never change automatically; the write gate and the hand-off are `AskUserQuestion`s with a Recommended option and alternatives.
- [ ] no self-advancing · [ ] verdict from the skill's vocabulary · [ ] gate and hand-off are `AskUserQuestion`s, not text

### 6. Commit gate on the documents lane
**Fixture**: report written and the top 5 added to the roadmap while HEAD is `feat/S-001-…` (a story branch). **Expected**: right after the write gate one commit gate offers `docs: tech debt <date>` staging exactly `docs/ops/tech-debt-<date>.md` and `production/roadmap.md`, names the current branch and asks where it belongs (switch to the default branch Recommended for a pipeline-wide document · commit here · leave uncommitted); nothing is committed without the answer.
- [ ] commit gate follows the write · [ ] current branch named · [ ] default-branch option Recommended · [ ] only the written documents staged

### TODOs by id and comment history (0.13)
**Fixture**: `TODO(S-020): …` where S-020 is `[x]`, `TODO(S-999)` with no such line, three bare `TODO:`, and a package whose non-test comments carry 42 lines with `S-0NN`/`used to`; `go doc -all` shows 15 such lines. **Expected**: one row each for S-020 (closed) and S-999 (unknown), one row "3 TODOs without an id — /backlog add", one row for the package with 42 / 15 and the proposed story `chore(<package>): comments per rules/comments.md`; nothing proposed as a drive-by in a feature story.
- [ ] ids checked against roadmap/backlog · [ ] history counted per package · [ ] rendered go doc counted

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
