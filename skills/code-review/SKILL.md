---
name: code-review
description: "Reviews code (files, directory, or current diff) for correctness, standards compliance, ADR adherence, security (OWASP), performance, testability; routes to the right lead and specialist by file type (Go/PHP/TS/Angular/Vue/GraphQL/three.js) and to appsec-engineer for sensitive paths. Read-only findings with BLOCKING/WARNING/INFO."
argument-hint: "[paths | --diff] [story-path] [--security]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Task, SendMessage, AskUserQuestion
model: sonnet
---

# Code Review

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

Read-only plus running checks; fixes only on a separate request from the user.

In the steps below, `<default>` is the default branch (`master` or `main`); `<base>` is `$(git merge-base origin/<default> HEAD)`, taken after `git fetch origin`; `<id>` is the story ID (`S-NNN`); without a story it is the scope of the branch's own fix commit when there is one (a `hotfix/<slug>` branch: the `<scope>` of its `fix(<scope>): …` commit), else the branch name; `<hooks>` is `.claude/hooks/` in copy mode and `${CLAUDE_PLUGIN_ROOT}/hooks/` in plugin mode; `$TMPDIR` falls back to `/tmp` when unset. A reviewer's `subagent_type` is `web-studio:<name>` in plugin mode and `<name>` in copy mode.

## Phase 1: Target
1. **Target files.** The argument's paths, or with `--diff` the changed files: `git diff --name-only <base>` (committed, staged and unstaged changes since the branch left `<default>`).
2. **Nothing to review.** An empty list → report it with the command that produced it and stop. No reviewers are spawned.
3. **Story.** With a story path, extract its ADRs and criteria.
4. **Read** CLAUDE.md, technical-preferences, the applicable `.claude/rules/*.md` and the story's ADRs.

## Phase 2: Routing (in parallel via Task)
1. **Map files to reviewers** by extension/path: `*.go` → `go-engineer` (+ `backend-lead`); `*.php` → `php-engineer`; `*.graphql`/resolvers → `graphql-engineer`; Angular → `angular-engineer`; `*.vue` → `vue-engineer`; `*.css/scss` → `css-engineer`; `game/`, three.js → `threejs-engineer`/`web-game-engineer`; migrations/SQL → `database-engineer`; workflows/Docker/`Makefile` → `devops-engineer`; tests → `test-engineer`.
2. **Security.** Sensitive paths (`auth`, `security`, `payments`, `upload`, `webhook`, proxy configs) or `--security` → `appsec-engineer` is mandatory.
3. **Write the diff once**: `git diff <base> > "$TMPDIR/review-<id>.diff"`, plus `git diff -M --name-status <base>` for the file list. A reviewer that reads the diff through `sed -n` in pieces runs out of turns on a third of the diffs and returns a verdict about the part it reached.
4. **Print the routing table** before the reviewers run: extension or path in the diff → the reviewer this list requires → spawned yes/no. A required reviewer may be skipped, but only as a line saying so and why; chosen "by eye", routing quietly shrinks to one reviewer on a diff that touches three layers.
5. **Spawn the reviewers** in one parallel batch. Each gets the diff path, the file list, the ADRs, the story's acceptance criteria (when there is a story) and the rules, and returns findings as `severity | file:line | what | risk | fix`.
6. **The first line of every verdict is `Read: N/M files`** — the diff files the reviewer actually opened. `N < M` makes that verdict `PARTIAL`, printed as such in the routing table, and a `PARTIAL` reviewer never contributes to `APPROVED`.

## Phase 3: Automated checks (Bash, when tools exist)
Every check's output goes into the report.

**General**: `go vet`/`staticcheck`/`govulncheck`; PHP: `php -l`, the recorded analyser (`vendor/bin/phpstan analyse` or `vendor/bin/psalm`), the recorded coding-standard tool (`vendor/bin/ecs check` or `php-cs-fixer fix --dry-run`); `eslint`/`tsc --noEmit`/`vue-tsc`; `graphql-inspector diff`; tests of affected packages.

**Go tests**, on every `_test.go` in the diff (files importing `testing/synctest` and comment lines excluded):
- `grep -n 'time\.Sleep(' <files>` → WARNING `TEST-SLEEP | file:line | fixed wait in a test | flaky under load | poll with a deadline or testing/synctest`.
- `grep -nE '\.Error\(\) *[!=]=' <files>` → WARNING `TEST-ERRSTR | file:line | error compared as a string | breaks on the first %w wrap | errors.Is/As against the sentinel`.
- A Go test function with no `t.Run` and more than one scenario → INFO `TEST-TABLE`.

**PHP tests**, on every `*Test.php` in the diff:
- `grep -nE '(^|[^>[:alnum:]_])u?sleep\(' <files>` → WARNING `TEST-SLEEP`.
- An `assertSame`/`assertEquals`/`assertStringContainsString` on `getMessage()` → WARNING `TEST-ERRSTR | file:line | exception asserted by message | breaks on a wording change | expectException(Class::class)`.
- A `TestCase` with several `test*` methods that differ only in data → INFO `TEST-TABLE (data provider)`.

**PHP layered** (`php_architecture: layered`). The numbers go into the report even when clean.
- `composer arch-check` (deptrac): a violation is BLOCKING `LAYER | file:line | <layer> depends on <layer> | the rule the architecture rests on | move the code; a value library the domain genuinely needs goes into php_domain_allow through technical-preferences and /test-setup, never into deptrac.yaml by hand`.
- `composer coverage-gate` on the clover report of the tests already run (`composer test:coverage` writes it), only when the diff touches `src/Domain/` or `src/Application/`: a layer below its threshold is BLOCKING `COVERAGE`.
- A class changed under `src/Domain` or `src/Application` with no test change in the diff → WARNING `TEST-LAYER`.
- A `*Test.php` under `tests/Unit/Domain` that creates a mock, or one under `tests/Unit/Application` that boots the framework or opens a connection → WARNING `TEST-LAYER`.
- An entity with public writable state and its rules in a use case or action → WARNING `RICH-MODEL`.
- An action or resolver that injects a repository instead of a use case → WARNING `LAYER`.
- A framework namespace (the `FRAMEWORK_NAMESPACES` of the recorded `php_framework`) imported outside `src/Infrastructure` → BLOCKING `LAYER`.

**Go layered** (`go_architecture: layered` in technical-preferences). The numbers (lint issues, gate lines) go into the report even when clean.
- `golangci-lint run --new-from-rev=<base> ./...` — only the issues the diff introduces; the whole-module run belongs to `make ci` and the engineer's own result. A `depguard` line is BLOCKING `LAYER | file:line | <layer> imports <outer layer> | the rule the architecture rests on | move the code; a value library the domain genuinely needs goes into go_domain_allow through technical-preferences and /test-setup, never into the linter config by hand`.
- `make coverage-gate` on the profile of the tests already run (`make test` writes it), only when the diff touches `internal/domain/` or `internal/usecase/`: a layer below its threshold is BLOCKING `COVERAGE | internal/<layer> | N % < M % | untested rules | tests in the same story`.
- A file changed under `internal/domain` or `internal/usecase` with no `_test.go` change in the diff → WARNING `TEST-LAYER`.
- A `_test.go` under `internal/domain` that declares a mock/fake type, or one under `internal/usecase` importing `pgx`, `testcontainers`, `net/http` or `database/sql` → WARNING `TEST-LAYER`.
- An entity with exported mutable state and its rules in a use case or resolver → WARNING `RICH-MODEL`.
- A resolver/handler that imports `internal/infrastructure/postgres` (or any repository) instead of a use case → WARNING `LAYER`.

**Go layout** (`go.md` "Project layout"), whenever the diff touches `cmd/` or the project has one. The numbers go into the report even when clean; a code comment calling the code "wiring" changes nothing.
- `wc -l cmd/*/*.go` and `grep -ln 'flag\.\|Fprint' cmd/*/*.go`: a second non-test file in `cmd/<app>`, a `main.go` over 50 lines or a `flag.`/`Fprint` hit there is a WARNING `LAYOUT | cmd/<app>/<file>:1 | application code in cmd/ | grows with every story, untestable without package main | move to internal/app/<app>`.
- The same dependency-graph struct literal in two files is BLOCKING when a field is already missing in one of them (that difference is the bug), WARNING otherwise (fix: one constructor).

**Scope** (CLAUDE.md principle 9), with a story. Every changed line should trace to one of the story's acceptance criteria or to a check the story must pass. The numbers go into the report even when clean.
- The parent prints `git diff --stat <base>` next to the story's files (its Tasks, the criteria table's Test column): a file in the diff that the story does not name is listed, not yet judged.
- The reviewers judge the hunks. A hunk that serves no criterion — a refactor of neighbouring code, a fixed pre-existing lint issue, a renamed identifier the story does not touch → WARNING `SCOPE | file:line | change outside the story's criteria | review cost, an unowned behaviour change, merge conflicts with other stories | revert it here; record it with /backlog add or in production/findings.md`.
- An option, abstraction or error path no criterion asks for → WARNING `SCOPE-SPEC | file:line | speculative code | code with no test that pins it | remove it, or add the criterion through /impact`.
- A behaviour the story's new code exposes — a new route, a new input reaching old code — is inside the criteria even when the lines that misbehave are old: SCOPE covers changes, not consequences. Such a finding keeps the severity its reviewer gave it and is never downgraded to INFO as "pre-existing".
- Reformatting, reflowed comments or reordered imports in code the story does not otherwise change → INFO `SCOPE-STYLE`.
- Not findings: removing what this change itself made unused, the tests for the criteria, files a tool regenerated (lockfiles, generated code), and the changes a `/code-review` fix round was asked for.

## Phase 4: ADR conformance
Deviation from an accepted ADR: ARCHITECTURAL VIOLATION (BLOCKING) / DRIFT (WARNING) / MINOR (INFO).

## Phase 5: Report and fix commit
1. **Report**: the BLOCKING/WARNING/INFO summary; the routing table from Phase 2 with each reviewer's verdict next to it (a review whose reviewers are invisible cannot be audited later — `production/session-logs/agent-audit.log` names who actually ran); the findings table; the verdict `APPROVED` / `NEEDS CHANGES`.
2. **Fix question**, one `AskUserQuestion`: fix BLOCKING now (Recommended on NEEDS CHANGES) · fix BLOCKING and WARNING · report only. No edits before that answer; after a "fix" answer `touch .claude/.write-consent`, and again before each `Task` batch of step 3 (rule 7, delegated steps), so the consent-guard sees the specialists' writes as approved.
3. **Fixes go through specialists**: the relevant engineer via `Task` for code and tests, `tech-writer` for documents. The answer covers the findings it names; a specialist that needs to go beyond them reports back and the parent asks. The parent writes no code in review rounds either (coordination-rules § Subagents), because "faster to fix it myself" is how review rounds drift. A fix the parent wrote anyway is named in the report ("written by the parent: <finding>").
4. **Re-run the Phase 3 checks.**
5. **Commit gate**, one `AskUserQuestion` (`.claude/docs/git-workflow.md`, step "Review"), recorded first as `Gate "/code-review Phase 5: commit the fixes?"` in the session state (`<hooks>session-state.sh set Gate …`, rule 7: an open gate survives the next turn) and cleared after the answer (`set Gate "—"`): on "yes", `git commit -m "fix(<id>): apply /code-review findings"` (`fix(S-NNN): …` on a story branch, `fix(<scope>): …` on a hotfix branch) and `git push` on the current branch — only when it has an upstream (`git rev-parse --abbrev-ref @{u}`); without one, the commit stays local and the report says so instead of a failed push. No fixes → no commit. The review itself never commits or changes the branch.
6. **Re-review by the reviewer who raised each finding**: `SendMessage` (listed in `allowed-tools`) to that agent — its id from the Phase 2 `Task` result — with the fix diff (`git diff <fix-commit>^!`, or `git diff HEAD` when the commit was declined) and the question "closed / not closed". Where `SendMessage` is not available, or the reviewer's session is gone, spawn the same reviewer through `Task` with its finding and the fix diff. The routing table gets a `re-review` column (yes · no · PARTIAL).
7. **The verdict moves from `NEEDS CHANGES` to `APPROVED` only on the reviewers' answers**, never on a green CI or the parent's own reading.
8. **Severity belongs to the reviewer**: a BLOCKING is downgraded only by the reviewer that raised it or by `technical-director` through `/impact`. The parent records its disagreement as a line under the finding; it does not edit the severity.

Next step — one `AskUserQuestion`, never a bare "run /story-done?": `/web-studio:story-done` (copy mode `/story-done`) (Recommended on APPROVED) · re-review after manual fixes — past 50 % context in a fresh session: `/clear`, then `/web-studio:code-review --diff` (copy mode `/code-review --diff`) (rule 13) · stop here.
