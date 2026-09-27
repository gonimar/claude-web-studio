---
name: refactor
description: "Refactors Go or PHP code without changing behaviour: dry-run plan by numbers (build, tests, coverage, dependency graph), stories via /create-stories, `--apply S-NNN` execution with characterisation tests first and one green step per commit; modes <package|namespace|file>, layout, tests, framework (PHP), or every applicable mode without an argument. Use for 'refactor this package', 'migrate the layout'."
argument-hint: "[<package|namespace|file> | layout | tests | framework] [--dry-run (default) | --apply S-NNN]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Write, Edit, Task, Skill, AskUserQuestion
---

# Refactor

Language, paths and names, gates, the documents-lane commit gate, the `Skill` tool, subagents, CI wait and the hand-off form: `docs/coordination-rules.md` § Skill conventions (every project loads it).

**Dry-run is the default and writes no code.** It delivers a plan in the chat and, on consent, a plan
document; stories come from `/create-stories` afterwards. Code changes happen only with `--apply S-NNN`
(a Ready story produced from a dry-run plan) on a `refactor/S-NNN-<slug>` branch:
- every file goes through `Task` to `<engineer>`; the parent writes no product code (§ Subagents);
- "May I write?" is an `AskUserQuestion` before the first write, and `touch .claude/.write-consent` follows the "write" answer (rule 7).

**Behaviour does not change in a refactoring.** A step that needs a new rule, a contract change or a
schema change is not a refactoring step: it is a `/impact` detour (rule 11) — in a dry-run it is listed
under "Out of scope — /impact" (Phase 4 step 3); during an apply it runs through the `Skill` tool
(`references/apply.md` Phase 5 step 5), the only other skill this one runs mid-flow.

Names used below:
- `<engineer>`: `go-engineer` for Go, `php-engineer` for PHP — namespaced as § Skill conventions → Paths and names says.
- `<hooks>`, `<default>`, agent and command namespaces: § Skill conventions → Paths and names.
- Gates: each commit, start and push gate below is recorded before the question (`<hooks>session-state.sh set Gate "/refactor Phase N: <question>"`) and cleared after the answer (§ Skill conventions → Gates), so a resumed session continues at that question instead of reading `Next:`.
- `Skill` tool: this skill runs only `/impact` through it, during an apply, after the running `Task` has returned (§ Skill conventions → Another skill). `/create-stories`, `/architecture-decision` and `/code-review` are hand-offs in the closing `AskUserQuestion`, never run from here.
- `FRAMEWORK_NAMESPACES`: the regex alternative `docs/stack-reference/<framework>.md` names for the recorded `php_framework` (the value `docs/templates/php/deptrac.yaml` takes).
- `Write`/`Edit` are for the plan document, `technical-preferences.md`, the story card and the sprint row only.

References: `stack-reference/go.md` ("Architecture style", "Layered architecture", "Tests by layer",
"Project layout"), `stack-reference/php.md` ("Layered architecture", "Tests by layer"), `rules/go-code.md`,
`rules/php-code.md`, `rules/tests.md`, `docs/templates/go/` and `docs/templates/php/` (linter, gate, CI
targets), `docs/git-workflow.md`. Per-branch detail in `references/`: `baseline-go.md`, `baseline-php.md`
(Phase 2 commands, Phase 3 choices), `plan-orders.md` (Phase 4 step order by mode), `apply.md` (Phases 5–7, `--apply` only).

## Phase 1: Mode, scope, stack
1. **Mode from the argument.**
   - `<package|namespace|file>` → local mode.
   - `layout` → architecture migration.
   - `tests` → test hygiene.
   - `framework` → PHP only: what would move if the framework changed. It is never part of the full pass; it runs only when asked for. On a Go project → `BLOCKED (framework mode is PHP-only — Go has no framework layer to move; use /refactor layout or /refactor <package>)`, one line, no baseline, no plan.
   - No mode argument and no `--apply` → **full pass**: every mode that applies, in the order layout → packages → tests, each announced before it runs.
   - `--apply S-NNN` → mode and scope come from the story's plan document; check the story first (Phase 5). Phases 1 and 2 run (a refactoring starts from green, and Phase 2 is the "before" column of Phase 6); Phases 3 and 4 are skipped; Phase 5 follows.
2. **Stack** from technical-preferences: Go and PHP in this version. Anything else → `BLOCKED (refactor supports Go and PHP in this version — inventory with /tech-debt, changes through /dev-story)`, one line, no plan.
3. **Read the stack's fields.**
   - Go: `go_architecture`, `go_composition_root`, `go_router`, `graphql_models`, `go_domain_allow`.
   - PHP: `php_framework`, `php_architecture`, `php_static_analysis`, `php_cs_tool`, `php_domain_allow`.
   - Both: the coverage thresholds, the layout ADR, `production/findings.md` (`ARCH-NNN` rows the plan must close) and the last `docs/ops/tech-debt-*.md`.
4. **Which questions Phase 3 asks** (dry-run only).
   - Without an argument the pass is also a **full interview**: before any step runs, every choice of Phase 3 is asked, recorded or not, with the current value first ("keep: <value> (current)", Recommended) and the alternatives after it. This is how the owner changes the approach of a running project.
   - An answer equal to the current value creates no step. A different one becomes a plan step: `/architecture-decision` first, the migration after it.
   - With an argument, only the questions of that mode are asked.
   - The write gate for the plan is the one question that comes at the end (Phase 4), because it asks about tables that do not exist yet.

## Phase 2: Baseline by numbers
Nothing is planned from an impression. Run every command and tabulate its output.
1. Read `references/baseline-go.md` (Go, from the Go root) or `references/baseline-php.md` (PHP, from the PHP root) § Baseline and run every command it lists. The Go list saves the `pkg/` API to `${TMPDIR:-/tmp}/refactor-<scope>-pkgapi.txt`, the baseline Phase 6 diffs against.
2. **The table** (metric · value · rule it is measured against) is rendered in the chat before any question (rule 7).
3. `framework` mode (PHP) adds one table: namespace · classes importing the framework · of which in Domain / Application / Infrastructure. The Domain and Application columns are what a framework change has to touch before Infrastructure, and under `layered` they must be zero.
4. A red build or a failing test stops here: `BLOCKED (baseline red — fix first: <package>)`. Refactoring starts from green.

## Phase 3: Choices (dry-run only)
1. **Scope by mode**: no argument → every choice, current value first; `layout` → the fields not recorded yet; `framework` → the target only (step 4).
2. **Three `AskUserQuestion`s**, the same choices `/setup-stack` records: architecture and shape · transport (router, GraphQL models) · thresholds and allow-list. In each, the current value (from technical-preferences, the layout ADR or the tree) is the first, Recommended option ("keep"), the alternatives follow, and the tree is shown as evidence.
3. **The fields per stack**: read `references/baseline-<stack>.md` § Choices and take its field list and options; keeping the current architecture ends the `layout` mode with the `PLANNED (no migration — <style> confirmed)` verdict it names.
4. **`framework` mode** asks one thing only: the target framework (yii3 · symfony · laravel · slim · none). It writes nothing into technical-preferences: the current `php_framework` stays the truth until the ADR is accepted and the last apply step lands.
5. **Where the answers go.** The `layout` answers are written into `technical-preferences.md` under the plan's write gate (Phase 4). The architecture decision goes through `/architecture-decision`, named in the hand-off; `/refactor` never writes an ADR itself.

## Phase 4: Plan (the dry-run deliverable)
1. **Step table.** Each step is small enough for one `<engineer>` call and green on its own. Columns:
   step · what moves (from → to, by package or namespace) · mechanics (`gopls rename`, `gofmt -r`, a new
   package + move + `goimports`, an interface extracted, a struct split) · check after the step (Go:
   `go build ./... && go test -race ./...`, plus the gate or `arch-check` once they exist; PHP: `composer ci`)
   · size (files, lines).
2. **Step order by mode.** Read `references/plan-orders.md` and take the order for this run's mode (Go `layout` · PHP `layout` · PHP `framework` · `tests` · `<package|namespace|file>`), its step names verbatim into the table. Invariants: a `layout` order starts with characterisation tests (without that step no move is planned), then tooling; PHP `framework` requires `php_architecture: layered`, else `PLANNED (layout first — run /refactor layout)`, and its step 1 is always the `/architecture-decision` ADR, which `--apply` requires `Accepted`.
3. **Traceability and scope.** Every step names the `ARCH-NNN`/tech-debt row it closes. Steps that would change behaviour, a contract, a schema or a dependency are listed under **Out of scope — /impact** with the reason, never absorbed.
4. **Write gate.** Render the tables in the chat, then one `AskUserQuestion`: "May I write `docs/ops/refactor-<date>-<scope>.md` (the tables above) and the Phase 3 answers into `technical-preferences.md`?" — write (Recommended) · show the draft/diff first · not now. After the "write" answer: `touch .claude/.write-consent` (rule 7; the consent-guard hook checks the marker).
5. **Commit gate** (§ Skill conventions → Documents-lane commit gate), recorded first as `Gate "/refactor Phase 4: commit the plan?"` and cleared after the answer: one `AskUserQuestion` offering `docs: refactor plan <scope>` staging exactly the written files, on the branch the documents lane prescribes (commit (Recommended) · leave uncommitted).
6. **Stories are not written here.** The plan document is the spec `/create-stories <plan-path>` slices: one story per step group, layer `backend`, the title prefixed `refactor:`, the story card citing the plan. That command owns its own gate.

Dry-run verdict: `PLANNED (N steps)`.

## Phase 5: Apply (`--apply S-NNN` only)
Read `references/apply.md` § Phase 5 and follow its six steps in order: story check (`Ready` or `In Progress` with a plan document, else `BLOCKED (no plan — run /refactor --dry-run first)`; a `framework` plan needs its ADR `Accepted`) · the one "start" consent (`Gate "/refactor Phase 5: start S-NNN?"`) that covers every commit of the apply · branch · record the start (`Started:` and In Progress, committed as `docs:`, before the first `Task`) · one `Task` to `<engineer>` per step, one commit per green step, never a red commit · who wrote it.

## Phase 6: Verification by numbers (`--apply` only)
Read `references/apply.md` § Phase 6: the Phase 2 table before · after · rule, the seven conditions for `COMPLETE`, and `PARTIAL (…)` naming any metric that moved the wrong way.

## Phase 7: Report and hand-off
1. **After an apply**: read `references/apply.md` § Phase 7 step 1 and run its four steps in order — story status → `Review` with its own `docs:` commit, the push gate (`Gate "/refactor Phase 7: push?"`), what starts CI, wait for CI.
2. **Verdict**: `PLANNED (…)` | `COMPLETE` | `PARTIAL (open: …)` | `BLOCKED (…)`.
3. **Next step**, one `AskUserQuestion`:
   - after a dry-run: `/architecture-decision` when Phase 3 changed the style or the mode was `framework` (Recommended then), else `/create-stories <plan-path>` (Recommended) · show the plan · stop here;
   - after an apply: `/web-studio:code-review --diff <story-path>` (copy mode `/code-review --diff <story-path>`) (Recommended) · show the before/after table · stop here — never the bare `/code-review` in plugin mode (§ Skill conventions → Verdict and next step).
