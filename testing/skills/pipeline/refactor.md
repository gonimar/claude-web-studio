# Skill Spec: /refactor

> **Category**: pipeline · **Priority**: high · **Spec written**: 2026-09-17

## Summary
Behaviour-preserving refactoring of a Go or PHP project the studio maintains. Dry-run by default: baseline by
numbers → (layout mode) architecture choices → step plan → plan document and stories. `--apply S-NNN`
executes the plan from a story on `refactor/S-NNN-<slug>` through `go-engineer`, one green step per
commit, and reports a before/after table. Agents: `go-engineer` / `php-engineer` (steps), `/create-stories`,
`/architecture-decision` and `/code-review` by hand-off.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path — dry-run on a modular Go service
**Fixture**: Go module, green build and tests, `go_architecture` unset. **Expected**: Phase 2 table with real
command output (build, vet, lint, tests, coverage per layer, layout numbers, dependency direction, test
smells) before any question; Phase 3 questions with the tree as evidence; a step table whose first step is
characterisation tests and whose second is the tooling; `PLANNED (N steps)` — no story count, because stories come from `/create-stories <plan-path>` afterwards.
- [ ] every metric has a command and its output · [ ] no code written · [ ] write gate is the canonical `AskUserQuestion` (write · show the draft/diff first · not now) covering the plan document and technical-preferences; stories come from `/create-stories <plan-path>` in the hand-off · [ ] hand-off names `/architecture-decision` when the style changed
### 2. Refusal / BLOCKED — not Go or PHP, or red baseline
**Fixture**: a Node project; then a Go project with a failing test. **Expected**: `BLOCKED (refactor supports Go and PHP in this version — …)` in one line; `BLOCKED (baseline red — fix first: <package>)` after the table.
- [ ] stops with the reason · [ ] names the command to run instead · [ ] writes no files
### 3. Mode/argument variant — `tests`, `<package>`, no argument
**Fixture**: tests with `time.Sleep` and `err.Error() ==`; a 2 000-line package; no argument on a project whose technical-preferences records every field. **Expected**: `tests` plans one step per smell class; `<package>` plans only that package; no argument asks every Phase 3 choice before the first step with the current value first ("keep", Recommended), creates no step for a kept value and an ADR-first step for a changed one, then runs layout → packages → tests.
- [ ] argument parsed · [ ] the full pass asks everything first, current values first, then runs through · [ ] a kept value produces no step
### 4. Edge case — `--apply` without a plan, a red step
**Fixture**: `--apply S-NNN` for a story without a plan document; a step whose tests go red. **Expected**: `BLOCKED (no plan — run /refactor --dry-run first)`; a red step is fixed by the same agent or reverted with `git restore`, never committed, never handed to a second agent.
- [ ] no red commit · [ ] the parent wrote no code (audit log quoted)
### 5. Gate / protocol — behaviour must not change
**Fixture**: a plan step that would add a validation rule. **Expected**: listed under "Out of scope — /impact", not planned; Phase 6 requires test count, coverage, `depguard`, layout and `pkg/` API unchanged or better; a metric that regressed → `PARTIAL` naming it.
- [ ] out-of-scope items go to `/impact` · [ ] verdict from the vocabulary · [ ] gate and hand-off are `AskUserQuestion`s

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output in every table)

### 6. PHP — `framework` mode
**Fixture**: a Yii3 project with `php_architecture: layered`, `Yiisoft\` imported in three Infrastructure classes and one Application class. **Expected**: the Phase 2 framework table shows 1 import in Application and 3 in Infrastructure, and the plan's first non-ADR step (Phase 4 framework step 2) explicitly targets the Application layer — it names that class and moves the import behind a port, and is absent when both columns are zero; the target framework is asked even though every `php_*` field is recorded; the plan's step 1 is `/architecture-decision`, the hand-off recommends it, and `--apply S-NNN` on that plan is refused while the ADR is not `Accepted`; `php_framework` in technical-preferences is unchanged after the dry-run. On a Go project, `framework` → `BLOCKED (framework mode is PHP-only — …)` in one line, no baseline run, no plan.
- [ ] framework dependencies counted per layer from deptrac or the `grep -rcE` output · [ ] the Domain/Application step names the class from the table · [ ] the ADR is step 1 and the apply gate · [ ] no write to `php_framework` before the last apply step · [ ] Go → BLOCKED with the PHP-only reason

### 7. `--apply` — stamps, status commits and CI
**Fixture**: `--apply S-021` on a Ready story with a plan; `.github/workflows/ci.yml` triggers on `pull_request` only; one step's engineer reports that the move would need a new validation rule. **Expected**: after the branch the story card gets `Status: In Progress` and `Started: <ISO minute>`, committed at once as `docs: refactor S-021 — In Progress` (the card never rides a `refactor(S-021)` step commit); the validation rule goes to `/impact` through the `Skill` tool after that `Task` has returned, its verdict is quoted and the step continues or is amended; at the end the status → `Review` is its own `docs: refactor S-021 — Review` commit before the push; after the push gate the skill reads the triggers, opens a draft PR, waits with one background `gh run watch --exit-status`, and never waits for a run that was not queued. All of it under the single Phase 5 "start" answer plus the push question.
- [ ] `Started:` and In Progress at branch time · [ ] both status changes are `docs:` commits, named · [ ] `Skill` in `allowed-tools`, `/impact` after the `Task` returns · [ ] draft PR when only `pull_request` triggers · [ ] no wait on a non-existent run

## Coverage notes
PHP rules under test: `stack-reference/php.md` "Layered architecture" and "Tests by layer"; templates in `docs/templates/php/`. Layered rules under test: `stack-reference/go.md` "Layered architecture" and "Tests by layer"; the templates in `docs/templates/go/`.
