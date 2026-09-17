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
file through `Task` to `go-engineer` or `php-engineer` by stack (the parent writes no product code, coordination-rules rule 7),
"May I write?" as an `AskUserQuestion` before the first write, `touch .claude/.write-consent` after
the "write" answer. Behaviour does not change in a refactoring: a step that needs a new rule, a
contract change or a schema change is not a refactoring step — it is a `/impact` detour (rule 11).
References: `stack-reference/go.md` ("Architecture style", "Layered architecture", "Tests by layer",
"Project layout"), `stack-reference/php.md` (the same sections for PHP), `rules/go-code.md`,
`rules/php-code.md`, `rules/tests.md`, `docs/templates/go/` and `docs/templates/php/` (linter, gate, CI
targets), `docs/git-workflow.md`.

## Phase 1: Mode, scope, stack
Argument → mode: `<package|namespace|file>` (local), `layout` (architecture migration), `tests` (test hygiene),
`framework` (PHP only: what would move if the framework changed); none → **full pass**: every mode that
applies, in the order layout → packages → tests, each announced before it runs. Stack from
technical-preferences: Go and PHP in this version — anything else → `BLOCKED (refactor supports Go and PHP in
this version — inventory with /tech-debt, changes through /dev-story)`, one line, no plan. Read the stack's
fields — Go: `go_architecture`, `go_layers`, `go_composition_root`, `go_router`, `graphql_models`,
`go_domain_allow`; PHP: `php_framework`, `php_architecture`, `php_static_analysis`, `php_cs_tool`,
`php_domain_allow` — the coverage thresholds, the layout ADR, `production/findings.md`
(`ARCH-NNN` rows the plan must close) and the last `docs/ops/tech-debt-*.md`. In the full pass the
questions come first, all of them, before any step runs: the mode list to confirm, the Phase 3 choices
when `layout` applies, and the write gate for the plan — the user answers once and the pass runs through.

## Phase 2: Baseline by numbers
Nothing is planned from an impression. Run and tabulate. PHP, from the PHP root: `composer validate --strict`;
`php -l` over `src` and `tests`; the recorded analyser (`vendor/bin/phpstan analyse` / `vendor/bin/psalm`, error
count and level); the recorded standard tool in check mode; `vendor/bin/deptrac analyse` when a `deptrac.yaml`
exists, else `grep -rln 'use Yiisoft\\|use Symfony\\|use Illuminate\\|use App\\Infrastructure' src/Domain
src/Application`; `vendor/bin/phpunit` (tests, assertions, failures) with `--coverage-clover` when pcov/xdebug is
available and `scripts/coverage-gate.php` on it; class sizes (`wc -l` per `src/**/*.php`, classes over 400
lines); framework dependencies by layer (`grep -rc 'use Yiisoft\\' src/Domain src/Application src/Infrastructure`
or the namespaces of `php_framework`); test smells (`grep -rnE '\b(u?sleep)\(' tests`, `grep -rn 'getMessage()'
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

## Phase 3: Choices (`layout` mode; skipped when technical-preferences already records them)
The same questions `/setup-stack` asks, one `AskUserQuestion` each, recommendation first, the current
tree as evidence for the recommendation. Go: `go_architecture` layered | modular (staying modular ends the
mode with `PLANNED (no migration — modular confirmed)`); `go_layers` per-context | flat-usecase;
`go_composition_root` internal/app | main; ports in the domain (the layered rule) — shown, not asked;
`go_router` chi | ServeMux; `graphql_models` dto | bind; `go_domain_allow`; coverage thresholds. PHP:
`php_architecture` layered | framework (staying `framework` ends the mode the same way); `php_layers` per-context | flat; `php_static_analysis`
phpstan | psalm; `php_cs_tool` ecs | php-cs-fixer; `php_domain_allow`; coverage thresholds; in `framework` mode
the target `php_framework` — and the plan is written only after `/architecture-decision` has recorded the move.
The answers are written into `technical-preferences.md` under the plan's write gate (Phase 4) and the
architecture decision goes through `/architecture-decision` (named in the hand-off) — `/refactor`
never writes an ADR itself.

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
   composition root in the framework config; transport calling use cases. PHP `framework`: after the `layout`
   steps are done (or when the project is already `layered`), one step per Infrastructure sub-namespace
   (`Transport\Http`, `Transport\GraphQL`, `Persistence`, `Mail`, …) plus the composition root and
   `public/index.php`, each replacing one framework's adapters with the target's, with the deptrac `Framework`
   layer switched to the target's namespaces so the old framework fails the build the moment it is no longer
   allowed. `tests` mode plans one step per smell class (sleep → polling/synctest or a fake clock, string
   compare → `errors.Is` / `expectException(Class::class)`, ad-hoc → table-driven / data providers, doubles by
   layer, thresholds). `<package|namespace>` mode plans the split/move of that package or namespace only.
Every step names the `ARCH-NNN`/tech-debt row it closes. Steps that would change behaviour, a contract,
a schema or a dependency are listed under **Out of scope — /impact** with the reason, never absorbed.
Then one `AskUserQuestion`: "May I write `docs/ops/refactor-<date>-<scope>.md` (the tables above), update
`technical-preferences.md` with the Phase 3 answers, and create the stories through `/create-stories`
(one story per step group, `refactor` as the layer tag)?" — write and create stories (Recommended) ·
write the plan only · show only. After the "write" answer: `touch .claude/.write-consent` (rule 7).
Dry-run verdict: `PLANNED (N steps, M stories)`.

## Phase 5: Apply (`--apply S-NNN` only)
The story must be Ready and reference a plan document; otherwise `BLOCKED (no plan — run /refactor
--dry-run first)`. Branch per `git-workflow.md`: from an up-to-date default branch, `git switch -c
refactor/S-NNN-<slug>`, session state through `hooks/session-state.sh set Task "S-NNN …" Branch
refactor/S-NNN-<slug> Next "/code-review"`. Then, step by step from the plan: `Task` to `go-engineer`
with the step's row and the rule "move, do not improve — the diff of a refactoring step contains no new
behaviour"; after the step `go build ./... && go test -race -count=1 ./...` (and the gate/`arch-check` once
installed) — green → `git commit -m "refactor(S-NNN): <step>"` staging the step's files by name; red →
the same agent fixes it in the same step, or the step is reverted (`git restore` of its files) and the
plan is amended, never a red commit and never a second agent on the same step (a cut-off agent is resumed,
rule 7). PHP steps run `composer ci` (or its parts that exist yet) instead of the Go commands, through
`php-engineer`. The parent writes no code; the story result says who wrote each step from
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
`/architecture-decision` when Phase 3 changed the style, else `/create-stories` (Recommended) · show the
plan · stop here; after an apply `/code-review --diff` (Recommended) · show the before/after table ·
stop here.
