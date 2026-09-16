# Skill Spec: /code-review

> **Category**: review · **Priority**: critical · **Spec written**: 2026-09-05

## Summary
Review with routing by file type and security for sensitive paths.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path
**Fixture**: --diff with Go + Angular + GraphQL. **Expected**: parallel Tasks; automated checks with output; severity summary.
- [ ] phase order followed · [ ] output matches the expectation · [ ] writes only after consent
### 2. Refusal / BLOCKED
**Fixture**: no changes. **Expected**: reports it.
- [ ] stops or explicitly flags the limitation · [ ] names the command/reason · [ ] writes no files
### 3. Mode/argument variant
**Fixture**: --security → appsec mandatory. **Expected**: behaviour differs from case 1 according to the argument.
- [ ] argument parsed · [ ] the difference matches the skill description
### 4. Edge case
**Fixture**: auth/ path without the flag → appsec anyway. **Expected**: handled explicitly, never silently skipped.
- [ ] the case is mentioned in the instructions · [ ] correct message/action
### 5. Gate / protocol
**Fixture**: fixes only after "yes". **Expected**: the user decides; stage/statuses never change automatically; the fix offer and the hand-off are `AskUserQuestion`s (fix BLOCKING · fix BLOCKING and WARNING · report only; `/story-done` · re-review · stop), not text yes/no prompts.
- [ ] no self-advancing · [ ] verdict from the skill's vocabulary · [ ] fix offer and hand-off are `AskUserQuestion`s with a Recommended option and alternatives
### 6. Fix commit
**Fixture**: BLOCKING fixed after "yes" on `feat/S-004-…`. **Expected**: checks re-run, then a `fix(S-004): apply /code-review findings` commit and push after consent; the review never commits by itself.
- [ ] checks re-run before the commit · [ ] commit scope is the story ID · [ ] no commit without fixes

### The diff decides the reviewers, and the report shows them
**Fixture**: a diff touching `*.go`, `Makefile`, `*_test.go` and a migration. **Expected**: Phase 2 prints the routing table (path → required reviewer → spawned yes/no) before the reviewers run, at least the Go, DevOps, test and database roles appear or are explicitly skipped with a reason, and Phase 5 repeats that table with each reviewer's verdict.
- [ ] routing table before the run · [ ] every required role spawned or skipped with a reason · [ ] reviewers and verdicts in the report

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
