---
name: refactor
description: "Refactors the code the studio maintains without changing behaviour: a dry-run plan by numbers (build, tests, coverage, dependency graph, layout, test smells) with the step list an engineer can execute, stories through /create-stories, and — only from a story — the execution in refactor/S-NNN with characterisation tests first, one green step per commit and a before/after table. Modes: <package|namespace|file>, layout (migration to the layered architecture, choices asked as in /setup-stack), tests (bring tests to the rules), framework (PHP: inventory and plan for moving to another framework); no argument runs every applicable mode after asking. Go and PHP in this version."
argument-hint: "[<package|namespace|file> | layout | tests | framework] [--dry-run (default) | --apply S-NNN]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Write, Edit, Task, AskUserQuestion
model: sonnet
---

# Refactor

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

**Dry-run is the default and writes no code.** It delivers a plan in the chat and, on consent, a plan
document; stories come from `/create-stories` afterwards. Code changes happen only with `--apply S-NNN`
(a Ready story produced from a dry-run plan) on a `refactor/S-NNN-<slug>` branch, with the same consent
contour as `/dev-story`:
- every file goes through `Task` to `<engineer>`; the parent writes no product code (`/dev-story` Phase 4 is the rule);
- "May I write?" is an `AskUserQuestion` before the first write, and `touch .claude/.write-consent` follows the "write" answer (rule 7).

**Behaviour does not change in a refactoring.** A step that needs a new rule, a contract change or a
schema change is not a refactoring step: it is a `/impact` detour (rule 11).

Names used below: `<engineer>` is `go-engineer` for Go and `php-engineer` for PHP; a studio agent is
`web-studio:<name>` in plugin mode and `<name>` in copy mode; `<hooks>` is `.claude/hooks/` in copy mode and
`${CLAUDE_PLUGIN_ROOT}/hooks/` in plugin mode; a command in a hand-off is `/web-studio:<command>` in plugin
mode and `/<command>` in copy mode (coordination-rules § Subagents).

References: `stack-reference/go.md` ("Architecture style", "Layered architecture", "Tests by layer",
"Project layout"), `stack-reference/php.md` ("Layered architecture", "Tests by layer"), `rules/go-code.md`,
`rules/php-code.md`, `rules/tests.md`, `docs/templates/go/` and `docs/templates/php/` (linter, gate, CI
targets), `docs/git-workflow.md`.

## Phase 1: Mode, scope, stack
1. **Mode from the argument.**
   - `<package|namespace|file>` → local mode.
   - `layout` → architecture migration.
   - `tests` → test hygiene.
   - `framework` → PHP only: what would move if the framework changed. It is never part of the full pass; it runs only when asked for.
   - No mode argument and no `--apply` → **full pass**: every mode that applies, in the order layout → packages → tests, each announced before it runs.
   - `--apply S-NNN` → mode and scope come from the story's plan document; check the story first (Phase 5 step 1). Phases 1 and 2 run (a refactoring starts from green, and Phase 2 is the "before" column of Phase 6); Phases 3 and 4 are skipped; Phase 5 follows.
2. **Stack** from technical-preferences: Go and PHP in this version. Anything else → `BLOCKED (refactor supports Go and PHP in this version — inventory with /tech-debt, changes through /dev-story)`, one line, no plan.
3. **Read the stack's fields.**
   - Go: `go_architecture`, `go_composition_root`, `go_router`, `graphql_models`, `go_domain_allow`.
   - PHP: `php_framework`, `php_architecture`, `php_static_analysis`, `php_cs_tool`, `php_domain_allow`.
   - Both: the coverage thresholds, the layout ADR, `production/findings.md` (`ARCH-NNN` rows the plan must close) and the last `docs/ops/tech-debt-*.md`.
4. **Which questions Phase 3 asks.**
   - Without an argument the pass is also a **full interview**: before any step runs, every choice of Phase 3 is asked, recorded or not, with the current value first ("keep: <value> (current)", Recommended) and the alternatives after it. This is how the owner changes the approach of a running project.
   - An answer equal to the current value creates no step. A different one becomes a plan step: `/architecture-decision` first, the migration after it.
   - With an argument, only the questions of that mode are asked.
   - The write gate for the plan is the one question that comes at the end (Phase 4), because it asks about tables that do not exist yet.

## Phase 2: Baseline by numbers
Nothing is planned from an impression. Run every command and tabulate its output.

**PHP, from the PHP root**
1. `composer ci` once when the composer scripts exist. It prints validate, the analyser, the standard tool, deptrac, phpunit with coverage and the gate in one run.
2. Without the scripts, the same commands one by one:
   - `composer validate --strict`;
   - the recorded analyser;
   - the recorded standard tool in check mode;
   - `vendor/bin/deptrac analyse` when a `deptrac.yaml` exists, else `grep -rlE 'use (FRAMEWORK_NAMESPACES|App\\Infrastructure)\\' src/Domain src/Application` with the namespaces of the recorded `php_framework`;
   - `vendor/bin/phpunit`, with `--coverage-clover` when pcov/xdebug is available, and `composer coverage-gate` on it.
3. Class sizes: `wc -l` per `src/**/*.php`, classes over 400 lines.
4. Framework dependencies by layer: `grep -rcE 'use (FRAMEWORK_NAMESPACES)' src/Domain src/Application src/Infrastructure`.
5. Test smells: `grep -rnE '\b(u?sleep)\(' tests`, `grep -rn 'getMessage()' tests`, `TestCase`s without data providers whose methods differ only in data, mocks under `tests/Unit/Domain`, a booted framework under `tests/Unit/Application`.
6. DDL outside migration files: `grep -rln 'CREATE TABLE\|ALTER TABLE' src`.

**Go, from the Go root**
1. `go build ./...`; `go vet ./...`.
2. `golangci-lint run ./...`: issue count by linter. A v1-format `.golangci.yml` is itself a finding.
3. `go test -race -count=1 ./...`: packages, tests, failures.
4. Coverage: `scripts/coverage-gate.sh` when present, else `go test -cover` per `internal/<layer>`.
5. Layout numbers: `wc -l cmd/*/*.go`, `grep -ln 'flag\.\|Fprint' cmd/*/*.go`.
6. Dependency direction: `go list -deps ./internal/domain/...` and `go list -deps ./internal/usecase/...`, filtered to the module's `internal/`.
7. Package sizes: `find internal -name '*.go' ! -name '*_test.go' | xargs wc -l`, grouped by directory, and files per package.
8. Public API of `pkg/`, when it exists: `go list ./pkg/... | xargs -n1 go doc -all`, saved outside the repository (the session scratchpad) as the baseline Phase 6 diffs against.
9. Test smells: `grep -rn 'time\.Sleep(' --include='*_test.go'`, `grep -rnE '\.Error\(\) *[!=]=' --include='*_test.go'`, test functions without `t.Run`, non-English case names, a mock type in a domain test, `pgx`/`testcontainers`/`net/http` imports in a use-case test.

**The table** (metric · value · rule it is measured against) is rendered in the chat before any question (rule 7).
- `framework` mode (PHP) adds one table: namespace · classes importing the framework · of which in Domain / Application / Infrastructure. The Domain and Application columns are what a framework change has to touch before Infrastructure, and under `layered` they must be zero.
- A red build or a failing test stops here: `BLOCKED (baseline red — fix first: <package>)`. Refactoring starts from green.

## Phase 3: Choices (no argument: every choice, current value first; `layout` mode: the fields not recorded yet; `framework` mode: the target)
The same choices `/setup-stack` records, batched into three `AskUserQuestion`s: architecture and shape ·
transport (router, GraphQL models) · thresholds and allow-list. In each, the current value (from
technical-preferences, the layout ADR or the tree) is the first, Recommended option ("keep"), the
alternatives follow, and the tree is shown as evidence.

**Go**
- `go_architecture`: layered | modular. Keeping `modular` ends the `layout` mode with `PLANNED (no migration — modular confirmed)`.
- Use-case shape: one package per context | one `usecase` package (the layout ADR's tree; a change is an ADR step).
- `go_composition_root`: internal/app | main.
- Ports in the domain (the layered rule): shown, not asked.
- `go_router`: chi | ServeMux. `graphql_models`: dto | bind. `go_domain_allow`. Coverage thresholds.

**PHP**
- `php_architecture`: layered | framework. Keeping `framework` ends the `layout` mode the same way.
- Use-case shape: per context | flat (the ADR tree).
- `php_static_analysis`: phpstan | psalm. `php_cs_tool`: ecs | php-cs-fixer. `php_domain_allow`. Coverage thresholds.

**`framework` mode** asks one thing only: the target framework (yii3 · symfony · laravel · slim · none).
It writes nothing into technical-preferences: the current `php_framework` stays the truth until the ADR
is accepted and the last apply step lands.

**Where the answers go.** The `layout` answers are written into `technical-preferences.md` under the
plan's write gate (Phase 4). The architecture decision goes through `/architecture-decision`, named in the
hand-off; `/refactor` never writes an ADR itself.

## Phase 4: Plan (the dry-run deliverable)
1. **Step table.** Each step is small enough for one `<engineer>` call and green on its own. Columns:
   step · what moves (from → to, by package or namespace) · mechanics (`gopls rename`, `gofmt -r`, a new
   package + move + `goimports`, an interface extracted, a struct split) · check after the step (Go:
   `go build ./... && go test -race ./...`, plus the gate or `arch-check` once they exist; PHP: `composer ci`)
   · size (files, lines).
2. **Step order by mode.**
   - Go `layout`, fixed order:
     1. **Characterisation tests first**: pin the behaviour at the boundaries the move will cross (handlers, services, exported functions) until the touched packages reach the coverage thresholds. Without this step no move is planned.
     2. Tooling: `.golangci.yml` v2 with `depguard`, `scripts/coverage-gate.sh`, the Makefile targets from `docs/templates/go/`. All fail on purpose at first and are reported so.
     3. Domain extraction (entities with rules, sentinel errors, ports).
     4. Use cases (one struct per scenario, `Execute`).
     5. Adapters into `internal/infrastructure/…` implementing the ports.
     6. The composition root (`internal/app/<app>`, one `newServices`).
     7. Transport (resolvers/handlers calling use cases).
   - PHP `layout`: the same order with PHP names:
     1. Characterisation tests through the PSR-15 pipeline and the services.
     2. Tooling: `deptrac.yaml`, the analyser at its baseline, the standard tool, `phpunit.xml`, `scripts/coverage-gate.php`, composer scripts.
     3. `App\Domain` extraction (entities with `public private(set)` state, domain exceptions, ports).
     4. Use cases.
     5. Adapters into `App\Infrastructure` with the ORM mapping.
     6. Composition root in the framework config.
     7. Transport calling use cases.
   - PHP `framework`: requires `php_architecture: layered`, else `PLANNED (layout first — run /refactor layout)`.
     1. Step 1 is always "ADR: `/architecture-decision` records the move to <target>". `--apply` refuses while that ADR is not `Accepted`.
     2. Then one step per Infrastructure sub-namespace (`Transport\Http`, `Transport\GraphQL`, `Persistence`, `Mail`, …), plus the composition root and `public/index.php`, each replacing one framework's adapters with the target's.
     3. The last step switches the deptrac `Framework` layer and `php_framework` to the target, so the old framework fails the build the moment it is no longer allowed.
     The plan document is written like every other mode's (step 4 below); the ADR is its first step, not a precondition of writing it.
   - `tests`: one step per smell class: sleep → polling/synctest or a fake clock; string compare → `errors.Is` / `expectException(Class::class)`; ad-hoc → table-driven / data providers; doubles by layer; thresholds.
   - `<package|namespace|file>`: the split/move of that package, namespace or file only.
3. **Traceability and scope.** Every step names the `ARCH-NNN`/tech-debt row it closes. Steps that would change behaviour, a contract, a schema or a dependency are listed under **Out of scope — /impact** with the reason, never absorbed.
4. **Write gate.** Render the tables in the chat, then one `AskUserQuestion`: "May I write `docs/ops/refactor-<date>-<scope>.md` (the tables above) and the Phase 3 answers into `technical-preferences.md`?" — write (Recommended) · show the draft/diff first · not now. After the "write" answer: `touch .claude/.write-consent` (rule 7; the consent-guard hook checks the marker).
5. **Commit gate** (rule 7, `git-workflow.md` documents lane): one `AskUserQuestion` offering `docs: refactor plan <scope>` staging exactly the written files, on the branch the documents lane prescribes (commit (Recommended) · leave uncommitted).
6. **Stories are not written here.** The plan document is the spec `/create-stories <plan-path>` slices: one story per step group, layer `backend`, the title prefixed `refactor:`, the story card citing the plan. That command owns its own gate.

Dry-run verdict: `PLANNED (N steps)`.

## Phase 5: Apply (`--apply S-NNN` only)
1. **Story check.** The story must be Ready and reference a plan document; otherwise `BLOCKED (no plan — run /refactor --dry-run first)`. For a `framework` plan, the step-1 ADR must be `Accepted`; otherwise `BLOCKED (ADR not Accepted — /architecture-decision)`.
2. **Consent.** One `AskUserQuestion`: start — branch `refactor/S-NNN-<slug>`, update the session state, then run the plan's steps with one commit per green step (Recommended) · show the plan first · stop. The "start" answer is the "May I write?" consent for the branch, the session state, the step commits and the files the plan names; `touch .claude/.write-consent` after it and again before each step's `Task` call.
3. **Branch** per `git-workflow.md` ("Refactor" lane), from an up-to-date default branch:
   1. `git fetch origin`.
   2. `git switch <default> && git pull --ff-only origin <default>`.
   3. `git switch -c refactor/S-NNN-<slug>`.
4. **Session state** through the studio's writer: `<hooks>session-state.sh set Task "S-NNN …" Branch refactor/S-NNN-<slug> Next "/code-review"`.
5. **Run the plan step by step.** For each step:
   1. `Task` to `<engineer>` with the step's row and the rule "move, do not improve — the diff of a refactoring step contains no new behaviour". The engineer cannot ask the user: a step that needs a file outside its row, or would change behaviour, stops and reports; the parent then asks, or detours to `/impact`.
   2. After the step, the parent runs the check: Go `go build ./... && go test -race -count=1 ./...` (and the gate/`arch-check` once installed); PHP `composer ci` (the local chain, no network).
   3. Green → `git commit -m "refactor(S-NNN): <step>"`, staging the step's files by name.
   4. Red → the same agent fixes it in the same step, or the step is reverted (`git restore` of its changed files, the files it created removed) and the plan is amended. Never a red commit, and never a second agent on the same step; a cut-off agent is resumed (`/dev-story` Phase 4).
6. **Who wrote it.** The parent writes no code; the story result says who wrote each step, from `production/session-logs/agent-audit.log`.

## Phase 6: Verification by numbers
The Phase 2 table again, side by side: before · after · rule. Required for `COMPLETE`:
- build, vet and lint clean;
- every test that existed still exists and passes (count not lower);
- coverage per layer not lower, and at or above the thresholds where a gate exists;
- `depguard`/`arch-check` (Go) or `deptrac` (PHP) clean;
- layout numbers within the contract;
- public API of `pkg/` unchanged: `go list ./pkg/... | xargs -n1 go doc -all` diffed against the Phase 2 baseline;
- no new dependency in `go.mod` / `composer.json` beyond the tooling the plan named.

A metric that moved the wrong way is a `PARTIAL (…)` with the metric named.

## Phase 7: Report and hand-off
1. **After an apply**:
   1. Push with consent, one `AskUserQuestion`: push (Recommended) · not now. Then `git push -u origin refactor/S-NNN-<slug>`.
   2. Open a draft PR when a workflow starts on `pull_request` (as `/dev-story` Phase 6).
   3. Story status → `Review`.
2. **Verdict**: `PLANNED (…)` | `COMPLETE` | `PARTIAL (open: …)` | `BLOCKED (…)`.
3. **Next step**, one `AskUserQuestion`:
   - after a dry-run: `/architecture-decision` when Phase 3 changed the style or the mode was `framework` (Recommended then), else `/create-stories <plan-path>` (Recommended) · show the plan · stop here;
   - after an apply: `/web-studio:code-review --diff` (copy mode `/code-review --diff`) (Recommended) · show the before/after table · stop here. In plugin mode the bare `/code-review` is Claude Code's built-in review, which runs general-purpose agents without the studio's leads.
