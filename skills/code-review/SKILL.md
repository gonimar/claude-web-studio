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

## Phase 3: Automated checks (Bash, when tools exist)
`go vet`/`staticcheck`/`govulncheck`; `vendor/bin/psalm`/`php -l`; `eslint`/`tsc --noEmit`/`vue-tsc`; `graphql-inspector diff`; tests of affected packages. Output goes into the report.
Go layout (`go.md` "Project layout", whenever the diff touches `cmd/` or the project has one): `wc -l cmd/*/*.go` and `grep -ln 'flag\.\|Fprint' cmd/*/*.go` — a second non-test file in `cmd/<app>`, a `main.go` over 50 lines or a `flag.`/`Fprint` hit there is a WARNING `LAYOUT | cmd/<app>/<file>:1 | application code in cmd/ | grows with every story, untestable without package main | move to internal/app/<app>`; the same dependency-graph struct literal in two files is BLOCKING when a field is already missing in one of them (that difference is the bug), WARNING otherwise (fix: one constructor). The numbers go into the report even when clean; a code comment calling the code "wiring" changes nothing.

## Phase 4: ADR conformance
Deviation from an accepted ADR: ARCHITECTURAL VIOLATION (BLOCKING) / DRIFT (WARNING) / MINOR (INFO).

## Phase 5: Report and fix commit
BLOCKING/WARNING/INFO summary, findings table, verdict `APPROVED` / `NEEDS CHANGES`. Then one `AskUserQuestion`: fix BLOCKING now (Recommended on NEEDS CHANGES) · fix BLOCKING and WARNING · report only — edits only after that answer (through the relevant specialist). After fixes: re-run Phase 3 checks, then with consent `git commit -m "fix(S-NNN): apply /code-review findings"` and `git push` on the story branch (`.claude/docs/git-workflow.md`, step "Review"). The review itself never commits or changes the branch.

Next step — one `AskUserQuestion`, never a bare "run /story-done?": `/story-done` (Recommended on APPROVED) · re-review after manual fixes · stop here.
