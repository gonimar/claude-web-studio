---
name: code-review
description: "Reviews code (files, directory, or current diff) for correctness, standards compliance, ADR adherence, security (OWASP), performance, testability; routes to the right lead and specialist by file type (Go/PHP/TS/Angular/Vue/GraphQL/three.js) and to appsec-engineer for sensitive paths. Read-only findings with BLOCKING/WARNING/INFO."
argument-hint: "[paths | --diff] [story-path] [--security]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Task, AskUserQuestion
model: sonnet
---

# Code Review

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

Read-only plus running checks; fixes only on a separate request from the user.

## Phase 1: Target
Argument: paths or `--diff` (`git diff --name-only <default-branch>...HEAD` (`master` or `main`) + unstaged). Optional story path — extract ADR/criteria. Read CLAUDE.md, technical-preferences, applicable `.claude/rules/*.md`, the story's ADRs.

## Phase 2: Routing (in parallel via Task)
By extension/path: `*.go` → `go-engineer` (+ `backend-lead`); `*.php` → `php-engineer`; `*.graphql`/resolvers → `graphql-engineer`; Angular → `angular-engineer`; `*.vue` → `vue-engineer`; `*.css/scss` → `css-engineer`; `game/`, three.js → `threejs-engineer`/`web-game-engineer`; migrations/SQL → `database-engineer`; workflows/Docker → `devops-engineer`; tests → `test-engineer`.
Sensitive paths (`auth`, `security`, `payments`, `upload`, `webhook`, proxy configs) or `--security` → `appsec-engineer` is mandatory.
Give each the files, ADRs and rules; ask for findings as `severity | file:line | what | risk | fix`.
**Routing is printed, not implied**: before the reviewers run, a table — extension or path in the diff → the reviewer this list requires → spawned yes/no. A required reviewer may be skipped, but only as a line saying so and why; chosen "by eye", routing quietly shrinks to one reviewer on a diff that touches three layers.

## Phase 3: Automated checks (Bash, when tools exist)
`go vet`/`staticcheck`/`govulncheck`; PHP: `php -l`, the recorded analyser (`vendor/bin/phpstan analyse` or `vendor/bin/psalm`), the recorded coding-standard tool (`vendor/bin/ecs check` or `php-cs-fixer fix --dry-run`); `eslint`/`tsc --noEmit`/`vue-tsc`; `graphql-inspector diff`; tests of affected packages. Output goes into the report.
Go tests, on every `_test.go` in the diff: `grep -n 'time\.Sleep(' <files>` → WARNING `TEST-SLEEP | file:line | fixed wait in a test | flaky under load | poll with a deadline or testing/synctest`; `grep -nE '\.Error\(\) *[!=]=' <files>` → WARNING `TEST-ERRSTR | file:line | error compared as a string | breaks on the first %w wrap | errors.Is/As against the sentinel`; a Go test function with no `t.Run` and more than one scenario → INFO `TEST-TABLE`.
PHP tests, on every `*Test.php` in the diff: `grep -nE '\b(u?sleep)\(' <files>` → WARNING `TEST-SLEEP`; `grep -n 'getMessage()' <files>` inside an assertion → WARNING `TEST-ERRSTR | file:line | exception asserted by message | breaks on a wording change | expectException(Class::class)`; a `TestCase` with several `test*` methods that differ only in data → INFO `TEST-TABLE (data provider)`.
PHP layered (`php_architecture: layered`): `vendor/bin/deptrac analyse --no-progress` — a violation is BLOCKING `LAYER | file:line | <layer> depends on <layer> | the rule the architecture rests on | move the code, never widen the ruleset`; `scripts/coverage-gate.php` (when present) — a layer below its threshold is BLOCKING `COVERAGE`; a class changed under `src/Domain` or `src/Application` with no test change in the diff → WARNING `TEST-LAYER`; a `*Test.php` under `tests/Unit/Domain` that creates a mock, or one under `tests/Unit/Application` that boots the framework or opens a connection → WARNING `TEST-LAYER`; an entity with public writable state and its rules in a use case or action → WARNING `RICH-MODEL`; an action or resolver that injects a repository instead of a use case → WARNING `LAYER`; `Yiisoft\`/`Symfony\`/`Illuminate\` imported outside `src/Infrastructure` → BLOCKING `LAYER`. The numbers go into the report even when clean.
Go layered (`go_architecture: layered` in technical-preferences): `golangci-lint run ./...` — a `depguard` line is BLOCKING `LAYER | file:line | <layer> imports <outer layer> | the rule the architecture rests on | move the code, never widen the allow-list`; `scripts/coverage-gate.sh` (when present) — a layer below its threshold is BLOCKING `COVERAGE | internal/<layer> | N % < M % | untested rules | tests in the same story`; a file changed under `internal/domain` or `internal/usecase` with no `_test.go` change in the diff → WARNING `TEST-LAYER`; a `_test.go` under `internal/domain` that declares a mock/fake type, or one under `internal/usecase` importing `pgx`, `testcontainers`, `net/http` or `database/sql` → WARNING `TEST-LAYER`; an entity with exported mutable state and its rules in a use case or resolver → WARNING `RICH-MODEL`; a resolver/handler that imports `internal/infrastructure/postgres` (or any repository) instead of a use case → WARNING `LAYER`. The numbers (lint issues, gate lines) go into the report even when clean.
Go layout (`go.md` "Project layout", whenever the diff touches `cmd/` or the project has one): `wc -l cmd/*/*.go` and `grep -ln 'flag\.\|Fprint' cmd/*/*.go` — a second non-test file in `cmd/<app>`, a `main.go` over 50 lines or a `flag.`/`Fprint` hit there is a WARNING `LAYOUT | cmd/<app>/<file>:1 | application code in cmd/ | grows with every story, untestable without package main | move to internal/app/<app>`; the same dependency-graph struct literal in two files is BLOCKING when a field is already missing in one of them (that difference is the bug), WARNING otherwise (fix: one constructor). The numbers go into the report even when clean; a code comment calling the code "wiring" changes nothing.

## Phase 4: ADR conformance
Deviation from an accepted ADR: ARCHITECTURAL VIOLATION (BLOCKING) / DRIFT (WARNING) / MINOR (INFO).

## Phase 5: Report and fix commit
BLOCKING/WARNING/INFO summary, the routing table from Phase 2 with each reviewer's verdict next to it (a review whose reviewers are invisible cannot be audited later — `production/session-logs/agent-audit.log` names who actually ran), findings table, verdict `APPROVED` / `NEEDS CHANGES`. Then one `AskUserQuestion`: fix BLOCKING now (Recommended on NEEDS CHANGES) · fix BLOCKING and WARNING · report only — edits only after that answer (through the relevant specialist). After fixes: re-run Phase 3 checks, then with consent `git commit -m "fix(S-NNN): apply /code-review findings"` and `git push` on the story branch (`.claude/docs/git-workflow.md`, step "Review"). The review itself never commits or changes the branch.

Next step — one `AskUserQuestion`, never a bare "run /story-done?": `/story-done` (Recommended on APPROVED) · re-review after manual fixes · stop here.
