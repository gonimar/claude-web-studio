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
- [ ] checks re-run before the commit · [ ] commit scope is the story ID · [ ] no commit without fixes · [ ] `Gate: /code-review Phase 5: commit the fixes?` recorded through `<hooks>session-state.sh set` before the question and cleared after it

### Fix commit on a hotfix branch
**Fixture**: `--diff --security` on `hotfix/login-500`, whose only commit beyond the tag is `fix(auth): login 500 on expired refresh token`, pushed with an upstream; separately the same branch never pushed. **Expected**: the fix commit after "yes" is `fix(auth): apply /code-review findings` — the scope of the branch's own fix commit, no `S-NNN` invented; with an upstream it is pushed; without one (`git rev-parse --abbrev-ref @{u}` fails) the commit stays local and the report says so instead of a failed push.
- [ ] scope taken from the branch's fix commit · [ ] push only with an upstream · [ ] local commit named, no failed push

### The diff decides the reviewers, and the report shows them
**Fixture**: a diff touching `*.go`, `Makefile`, `*_test.go` and a migration. **Expected**: Phase 2 prints the routing table (path → required reviewer → spawned yes/no) before the reviewers run, at least the Go, DevOps, test and database roles appear or are explicitly skipped with a reason, and Phase 5 repeats that table with each reviewer's verdict.
- [ ] routing table before the run · [ ] every required role spawned or skipped with a reason · [ ] reviewers and verdicts in the report

### Reviewers read the whole diff (0.12)
**Fixture**: a 25-file Go diff, `backend-lead` cut off after 14 files. **Expected**: the diff was written once to a file and passed as a path; the lead's verdict starts `Read: 14/25 files`, the routing table prints `PARTIAL` for it and the review is not `APPROVED` on its account.
- [ ] diff as one file · [ ] `Read: N/M` first line · [ ] PARTIAL never counts towards APPROVED
### The verdict is the reviewer's (0.12)
**Fixture**: `appsec-engineer` NEEDS CHANGES with one BLOCKING; the fix is applied; CI is green. **Expected**: the fix diff goes to `appsec-engineer` by `SendMessage` and the verdict becomes APPROVED only on its answer; the routing table gains a `re-review` column; the parent never downgrades the BLOCKING itself; a fix the parent wrote is named "written by the parent: …".
- [ ] re-review by the same reviewer · [ ] `SendMessage` listed in `allowed-tools`, `Task` to the same reviewer as the fallback · [ ] no verdict change on CI alone · [ ] severity untouched by the parent · [ ] hand-off names `/web-studio:story-done`

### Changes outside the story are named (0.13)
**Fixture**: `--diff` on story S-002 (a `/forecast` endpoint): besides `forecast.go` and its test, the diff moves the legacy `/` handler of `main.go` into a new `newMux()` and fixes a pre-existing unchecked error there; one import block is reordered in an untouched file. **Expected**: the report lists `main.go` hunks that serve no criterion as WARNING `SCOPE` (revert here, record through `/backlog add` or findings), the reordered imports as INFO `SCOPE-STYLE`; the route line the story needs is not a finding; the new route falling through to the legacy catch-all keeps its WARNING (a behaviour the new code exposes is inside the criteria, not "pre-existing"); the `git diff --stat` next to the story's files is in the report.
- [ ] story criteria reach the reviewers · [ ] SCOPE for the refactor, not for the route line · [ ] SCOPE-STYLE is INFO · [ ] stat printed

### Comments are checked on the added lines (0.13)
**Fixture**: the diff adds `// TODO: handle IPv6 later`, `// pre-S-050 this was in cmd/` in `internal/app/api/api.go`, `// Regression: OPS-008.` in `api_test.go`, and a 40-line doc comment on an exported `Bootstrap`. **Expected**: WARNING `TODO-NOID` for the first, INFO `COMMENT-HISTORY` for the second, nothing for the test line, INFO `COMMENT-LONG` for the doc comment; the counts appear in the report; an old `// used to …` line not touched by the diff is not a finding.
- [ ] added lines only · [ ] test exception honoured · [ ] counts printed even when zero

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
