# /code-review — Scope and comment checks (Phase 3)

Read when there is a story (Scope) and for every `--diff` review (Comments). The Scope rules are part of the
reviewers' brief (Phase 2 step 5); the Comments checks run in the parent. The finding strings are the contract
(`severity | file:line | what | risk | fix`) and are used as written.

**Scope** (CLAUDE.md principle 9), with a story. Every changed line should trace to one of the story's acceptance criteria or to a check the story must pass. The numbers go into the report even when clean.
- The parent prints `git diff --stat <base>` next to the story's files (its Tasks, the criteria table's Test column): a file in the diff that the story does not name is listed, not yet judged.
- The reviewers judge the hunks. A hunk that serves no criterion — a refactor of neighbouring code, a fixed pre-existing lint issue, a renamed identifier the story does not touch → WARNING `SCOPE | file:line | change outside the story's criteria | review cost, an unowned behaviour change, merge conflicts with other stories | revert it here; record it with /backlog add or in production/findings.md`.
- An option, abstraction or error path no criterion asks for → WARNING `SCOPE-SPEC | file:line | speculative code | code with no test that pins it | remove it, or add the criterion through /impact`.
- A behaviour the story's new code exposes — a new route, a new input reaching old code — is inside the criteria even when the lines that misbehave are old: SCOPE covers changes, not consequences. Such a finding keeps the severity its reviewer gave it and is never downgraded to INFO as "pre-existing".
- Reformatting, reflowed comments or reordered imports in code the story does not otherwise change → INFO `SCOPE-STYLE`.
- Not findings: removing what this change itself made unused, the tests for the criteria, files a tool regenerated (lockfiles, generated code), and the changes a `/code-review` fix round was asked for.

**Comments**, on the added lines of the diff (`grep -nE '^\+' "$TMPDIR/review-<id>.diff"`), three checks; the counts go into the report even when zero, and an existing file's old comments are not a finding of this review (`rules/comments.md`: new code only):
- a `TODO`/`FIXME`/`HACK` without `(S-NNN)`/`(I-NNN)` → WARNING `TODO-NOID | file:line | TODO without a story or idea id | never reaches /tech-debt, forgotten at merge | TODO(S-NNN): … after /backlog add`;
- a comment line (test files excluded; the well-formed `TODO(S-NNN)`/`TODO(I-NNN)` lines of the first check skipped with `grep -vE '(TODO|FIXME|HACK)\((S|I)-[0-9]+\)'`) matching `\b(S|I|OPS|ARCH|SEC|GEO|TL)-[0-9]+\b|pre-S-|used to|previously|was .* until|/code-review|review (round|found|raised|asked)|out of (this|the) story` → INFO `COMMENT-HISTORY | file:line | comment tells the story's history | stale at merge, read as a requirement later | keep the contract or the reason, the rest is in the PR (rules/comments.md)`;
- a doc comment on an exported Go symbol longer than 15 lines → INFO `COMMENT-LONG | file:line | doc comment is a design note | rendered by go doc as the API | contract above, reason in the body, the rest to an ADR`.
