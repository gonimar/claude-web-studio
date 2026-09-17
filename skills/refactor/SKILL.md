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

**Dry-run is the default and writes no code.** Its deliverables are a plan in the chat, on consent a
plan document and stories. Code changes happen only with `--apply S-NNN` — a Ready story produced by a
dry-run — on a `refactor/S-NNN-<slug>` branch, with the same consent contour as `/dev-story`: every
file through `Task` to `go-engineer` or `php-engineer` by stack (the parent writes no product code — `/dev-story` Phase 4 is the rule),
"May I write?" as an `AskUserQuestion` before the first write, `touch .claude/.write-consent` after
the "write" answer. Behaviour does not change in a refactoring: a step that needs a new rule, a
contract change or a schema change is not a refactoring step — it is a `/impact` detour (rule 11).
References: `stack-reference/go.md` ("Architecture style", "Layered architecture", "Tests by layer",
"Project layout"), `stack-reference/php.md` (the same sections for PHP), `rules/go-code.md`,
`rules/php-code.md`, `rules/tests.md`, `docs/templates/go/` and `docs/templates/php/` (linter, gate, CI
targets), `docs/git-workflow.md`.

## Phase 1: Mode, scope, stack
Argument → mode: `<package|namespace|file>` (local), `layout` (architecture migration), `tests` (test hygiene),
`framework` (PHP only: what would move if the framework changed — never part of the full pass, it runs only when asked for); none → **full pass**: every mode that
applies, in the order layout → packages → tests, each announced before it runs. Stack from
technical-preferences: Go and PHP in this version — anything else → `BLOCKED (refactor supports Go and PHP in
this version — inventory with /tech-debt, changes through /dev-story)`, one line, no plan. Read the stack's
fields — Go: `go_architecture`, `go_composition_root`, `go_router`, `graphql_models`,
`go_domain_allow`; PHP: `php_framework`, `php_architecture`, `php_static_analysis`, `php_cs_tool`,
`php_domain_allow` — the coverage thresholds, the layout ADR, `production/findings.md`
(`ARCH-NNN` rows the plan must close) and the last `docs/ops/tech-debt-*.md`. **Without an argument the pass is also a full interview**: before any step runs, every choice of Phase 3 is asked —
recorded or not — with the current value first ("keep: <value> (current)", Recommended) and the alternatives after it;
this is how the owner changes the approach of a running project. An answer equal to the current value creates no
step; a different one becomes a plan step — `/architecture-decision` first, the migration after it. With an argument,
only the questions of that mode are asked. The write gate for the plan is the one question that comes at the end,
because it asks about tables that do not exist yet.

## Phase 2: Baseline by numbers
Nothing is planned from an impression. Run and tabulate. PHP, from the PHP root: `composer ci` once when the
composer scripts exist (it prints validate, the analyser, the standard tool, deptrac, phpunit with coverage and the
gate in one run); without them, the same commands one by one (`composer validate --strict`, the recorded analyser,
the recorded standard tool in check mode, `vendor/bin/deptrac analyse` when a `deptrac.yaml` exists, else
`grep -rlE 'use (FRAMEWORK_NAMESPACES|App\\Infrastructure)\\' src/Domain src/Application` with the namespaces of the
recorded `php_framework`, `vendor/bin/phpunit` with `--coverage-clover` when pcov/xdebug is available and
`composer coverage-gate` on it); class sizes (`wc -l` per `src/**/*.php`, classes over 400 lines); framework
dependencies by layer (`grep -rcE 'use (FRAMEWORK_NAMESPACES)' src/Domain src/Application src/Infrastructure`); test smells (`grep -rnE '\b(u?sleep)\(' tests`, `grep -rn 'getMessage()'
tests`, `TestCase`s without data providers whose methods differ only in data, mocks under `tests/Unit/Domain`, a
booted framework under `tests/Unit/Application`); DDL outside migration files (`grep -rln 'CREATE TABLE\|ALTER TABLE'
src`). Go, from the Go root: `go build ./...`; `go vet ./...`;
`golangci-lint run ./...` (issue count by linter; a v1-format `.golangci.yml` is itself a finding);
`go test -race -count=1 ./...` (packages, tests, failures); `scripts/coverage-gate.sh` when present, else
`go test -cover` per `internal/<layer>`; the layout numbers (`wc -l cmd/*/*.go`, `grep -ln 'flag\.\|Fprint'
cmd/*/*.go`); the dependency direction (`go list -deps ./internal/domain/...` and `./internal/usecase/...`
filtered to the module's `internal/`); package sizes (`find internal -name '*.go' ! -name '*_test.go' |
xargs wc -l` grouped by directory, files per package); test smells (`grep -rn 'time\.Sleep(' --include='*_test.go'`,
`grep -rnE '\.Error\(\) *[!=]=' --include='*_test.go'`, test functions without `t.Run`, non-English case
names, a mock type in a domain test, `pgx`/`testcontainers`/`net/http` imports in a use-case test).
The table — metric · value · rule it is measured against — is rendered in the chat before anything else
(rule 7). `framework` mode (PHP) adds one table: namespace · classes importing the framework · of which in
Domain / Application / Infrastructure — the first two columns are what a framework change has to touch
before the last one, and under `layered` they must be zero. A red build or a failing test stops here: `BLOCKED (baseline red — fix first: <package>)`;
refactoring starts from green.

## Phase 3: Choices (no argument: every choice, current value first; `layout` mode: the fields not recorded yet; `framework` mode: the target)
The same choices `/setup-stack` records, batched into three `AskUserQuestion`s — architecture and shape ·
transport (router, GraphQL models) · thresholds and allow-list — the current value from technical-preferences, the
layout ADR or the tree as the first, Recommended option ("keep"), the alternatives after it, the tree as evidence:
`go_architecture` layered | modular (keeping modular ends the `layout` mode with `PLANNED (no migration — modular
confirmed)`); the use-case shape — one package per context | one `usecase` package (the layout ADR's tree; a change
is an ADR step); `go_composition_root` internal/app | main; ports in the domain (the layered rule) — shown, not asked;
`go_router` chi | ServeMux; `graphql_models` dto | bind; `go_domain_allow`; coverage thresholds. PHP:
`php_architecture` layered | framework (keeping `framework` ends the mode the same way); the use-case shape per context
| flat (ADR tree); `php_static_analysis` phpstan | psalm; `php_cs_tool` ecs | php-cs-fixer; `php_domain_allow`;
coverage thresholds. `framework` mode asks one
thing only — the target framework (yii3 · symfony · laravel · slim · none) — and writes nothing into
technical-preferences: the current `php_framework` stays the truth until the ADR is accepted and the last apply step
lands. The `layout` answers are written into `technical-preferences.md` under the plan's write gate (Phase 4);
the architecture decision goes through `/architecture-decision` (named in the hand-off) — `/refactor` never writes
an ADR itself.

## Phase 4: Plan (the dry-run deliverable)
A table of steps, each small enough for one `go-engineer` call and green on its own: step · what moves
(from → to, by package) · mechanics (`gopls rename`, `gofmt -r`, a new package + move + `goimports`, an
interface extracted, a struct split) · check after the step (`go build ./... && go test -race ./...`,
plus the gate or `arch-check` once they exist) · size (files, lines). Fixed order for `layout`:
1. **characterisation tests first** — pin the behaviour at the boundaries the move will cross (handlers,
   services, exported functions) until the touched packages reach the coverage thresholds; without this
   step no move is planned; 2. tooling: `.golangci.yml` v2 with `depguard`, `scripts/coverage-gate.sh`,
   the Makefile targets from `docs/templates/go/`, all failing on purpose at first and reported so;
3. domain extraction (entities with rules, sentinel errors, ports); 4. use cases (one struct per scenario,
   `Execute`); 5. adapters into `internal/infrastructure/…` implementing the ports; 6. the composition root
   (`internal/app/<app>`, one `newServices`); 7. transport (resolvers/handlers calling use cases).
   PHP `layout`: the same order with PHP names — characterisation tests through the PSR-15 pipeline and the
   services; tooling (`deptrac.yaml`, the analyser at its baseline, the standard tool, `phpunit.xml`,
   `scripts/coverage-gate.php`, composer scripts); `App\Domain` extraction (entities with `public private(set)`
   state, domain exceptions, ports); use cases; adapters into `App\Infrastructure` with the ORM mapping;
   composition root in the framework config; transport calling use cases. PHP `framework`: requires `php_architecture: layered` (else
   `PLANNED (layout first — run /refactor layout)`); step 1 is always "ADR: `/architecture-decision` records the move
to <target>" and `--apply` refuses while that ADR is not `Accepted`; then one step per Infrastructure
   sub-namespace (`Transport\Http`, `Transport\GraphQL`, `Persistence`, `Mail`, …) plus the composition root and
   `public/index.php`, each replacing one framework's adapters with the target's; the last step switches the deptrac
   `Framework` layer and `php_framework` to the target, so the old framework fails the build the moment it is no
   longer allowed. The plan document is written like every other mode's (Phase 4 gate); the ADR is its first step,
   not a precondition of writing it. `tests` mode plans one step per smell class (sleep → polling/synctest or a fake clock, string
   compare → `errors.Is` / `expectException(Class::class)`, ad-hoc → table-driven / data providers, doubles by
   layer, thresholds). `<package|namespace>` mode plans the split/move of that package or namespace only.
Every step names the `ARCH-NNN`/tech-debt row it closes. Steps that would change behaviour, a contract,
a schema or a dependency are listed under **Out of scope — /impact** with the reason, never absorbed.
Then one `AskUserQuestion`: "May I write `docs/ops/refactor-<date>-<scope>.md` (the tables above) and the Phase 3
answers into `technical-preferences.md`?" — write (Recommended) · show the draft/diff first · not now. After the
"write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker). Stories are not
written here: the plan document is the spec `/create-stories <plan-path>` slices (one story per step group, layer
`backend`, the title prefixed `refactor:`; the story card cites the plan), and that command owns its own gate.
Dry-run verdict: `PLANNED (N steps)`.

## Phase 5: Apply (`--apply S-NNN` only)
The story must be Ready and reference a plan document; otherwise `BLOCKED (no plan — run /refactor
--dry-run first)`. Branch per `git-workflow.md` ("Refactor" lane): from an up-to-date default branch, `git switch -c
refactor/S-NNN-<slug>`, session state through `hooks/session-state.sh set Task "S-NNN …" Branch
refactor/S-NNN-<slug> Next "/code-review"`. Then, step by step from the plan: `Task` to `go-engineer`
with the step's row and the rule "move, do not improve — the diff of a refactoring step contains no new
behaviour"; after the step `go build ./... && go test -race -count=1 ./...` (and the gate/`arch-check` once
installed) — green → `git commit -m "refactor(S-NNN): <step>"` staging the step's files by name; red →
the same agent fixes it in the same step, or the step is reverted (`git restore` of its files) and the
plan is amended, never a red commit and never a second agent on the same step (a cut-off agent is resumed,
`/dev-story` Phase 4). PHP steps run `composer ci` (the local chain, no network) instead of the Go commands, through `php-engineer`. The parent writes no code; the story result says who wrote each step from
`production/session-logs/agent-audit.log`.

## Phase 6: Verification by numbers
The Phase 2 table again, side by side: before · after · rule. Required for `COMPLETE`: build, vet and
lint clean; every test that existed still exists and passes (count not lower); coverage per layer not
lower and at or above the thresholds where a gate exists; `depguard`/`arch-check` (Go) or `deptrac` (PHP)
clean; layout numbers within the contract; public API of `pkg/` unchanged (`go doc ./pkg/... | diff`
against the baseline); no new dependency in `go.mod` / `composer.json` beyond the tooling the plan named. A metric that moved the wrong way is a `PARTIAL (…)` with the metric named.

## Phase 7: Report and hand-off
Push with consent (`git push -u origin refactor/S-NNN-<slug>`), draft PR when a workflow starts on
`pull_request` (as `/dev-story` Phase 6). Story status → `Review`. Verdict: `PLANNED (…)` | `COMPLETE` |
`PARTIAL (open: …)` | `BLOCKED (…)`. Next step — one `AskUserQuestion`: after a dry-run
`/architecture-decision` when Phase 3 changed the style or the mode was `framework` (Recommended then), else
`/create-stories <plan-path>` (Recommended) · show the plan · stop here; after an apply `/code-review --diff` (Recommended) · show the before/after table ·
stop here.
