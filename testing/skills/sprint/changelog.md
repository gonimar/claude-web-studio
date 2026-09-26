# Skill Spec: /changelog

> **Category**: sprint · **Priority**: medium · **Spec written**: 2026-09-05

## Summary
CHANGELOG from Conventional Commits.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path
**Fixture**: tag v1.1.0, 12 commits. **Expected**: Added/Fixed/… groups; minor bump.
- [ ] phase order followed · [ ] output matches the expectation · [ ] writes only after consent
### 2. Refusal / BLOCKED
**Fixture**: no tags. **Expected**: from the start of history.
- [ ] stops or explicitly flags the limitation · [ ] names the command/reason · [ ] writes no files
### 3. Mode/argument variant
**Fixture**: `--unreleased`, tag v1.1.0, 5 commits since. **Expected**: the five commits are listed grouped under `## [Unreleased]` (created when missing), no `## [1.2.0]` heading, the bump only shown, no tag; existing Unreleased entries kept and deduplicated by hash; the commit gate offers `docs: changelog unreleased`; the next step names `/changelog X.Y.Z` when the release is due. Later `/changelog 1.2.0` moves the Unreleased entries under `## [1.2.0] — YYYY-MM-DD` and leaves the `## [Unreleased]` heading empty.
- [ ] argument parsed · [ ] the difference matches the skill description · [ ] Unreleased entries move under the version heading
### 4. Edge case
**Fixture**: non-standard messages → Other. **Expected**: handled explicitly, never silently skipped.
- [ ] the case is mentioned in the instructions · [ ] correct message/action
### 5. Gate / protocol
**Fixture**: written after consent. **Expected**: the user decides; stage/statuses never change automatically; the write gate and the hand-off are `AskUserQuestion`s with a Recommended option and alternatives.
- [ ] no self-advancing · [ ] verdict from the skill's vocabulary · [ ] gate and hand-off are `AskUserQuestion`s, not text

### 6. Commit gate
**Fixture**: `CHANGELOG.md` written for 1.2.0 while HEAD is `feat/S-040-…`. **Expected**: one `docs: changelog v1.2.0` commit gate staging exactly `CHANGELOG.md` that names the story branch and offers: switch to the default branch and commit there (Recommended) · commit here · leave uncommitted; nothing committed without the answer; no other file staged.
- [ ] commit gate after the write · [ ] branch named and choice offered · [ ] only CHANGELOG.md staged

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
