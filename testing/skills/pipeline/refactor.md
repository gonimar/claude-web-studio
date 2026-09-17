# Skill Spec: /refactor

> **Category**: pipeline · **Priority**: high · **Spec written**: 2026-09-17

## Summary
Behaviour-preserving refactoring of a Go project the studio maintains. Dry-run by default: baseline by
numbers → (layout mode) architecture choices → step plan → plan document and stories. `--apply S-NNN`
executes the plan from a story on `refactor/S-NNN-<slug>` through `go-engineer`, one green step per
commit, and reports a before/after table. Agents: `go-engineer` (steps), `/create-stories`,
`/architecture-decision` and `/code-review` by hand-off.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path — dry-run on a modular Go service
**Fixture**: Go module, green build and tests, `go_architecture` unset. **Expected**: Phase 2 table with real
command output (build, vet, lint, tests, coverage per layer, layout numbers, dependency direction, test
smells) before any question; Phase 3 questions with the tree as evidence; a step table whose first step is
characterisation tests and whose second is the tooling; `PLANNED (N steps, M stories)`.
- [ ] every metric has a command and its output · [ ] no code written · [ ] write gate is the canonical `AskUserQuestion` (write · show the draft/diff first · not now) covering the plan document and technical-preferences; stories come from `/create-stories <plan-path>` in the hand-off · [ ] hand-off names `/architecture-decision` when the style changed
### 2. Refusal / BLOCKED — not Go, or red baseline
**Fixture**: a PHP project; then a Go project with a failing test. **Expected**: `BLOCKED (refactor supports Go in this version — …)` in one line; `BLOCKED (baseline red — fix first: <package>)` after the table.
- [ ] stops with the reason · [ ] names the command to run instead · [ ] writes no files
### 3. Mode/argument variant — `tests`, `<package>`, no argument
**Fixture**: tests with `time.Sleep` and `err.Error() ==`; a 2 000-line package; no argument. **Expected**: `tests` plans one step per smell class; `<package>` plans only that package; no argument runs layout → packages → tests and asks every question before the first step.
- [ ] argument parsed · [ ] the full pass asks first, then runs through
### 4. Edge case — `--apply` without a plan, a red step
**Fixture**: `--apply S-NNN` for a story without a plan document; a step whose tests go red. **Expected**: `BLOCKED (no plan — run /refactor --dry-run first)`; a red step is fixed by the same agent or reverted with `git restore`, never committed, never handed to a second agent.
- [ ] no red commit · [ ] the parent wrote no code (audit log quoted)
### 5. Gate / protocol — behaviour must not change
**Fixture**: a plan step that would add a validation rule. **Expected**: listed under "Out of scope — /impact", not planned; Phase 6 requires test count, coverage, `depguard`, layout and `pkg/` API unchanged or better; a metric that regressed → `PARTIAL` naming it.
- [ ] out-of-scope items go to `/impact` · [ ] verdict from the vocabulary · [ ] gate and hand-off are `AskUserQuestion`s

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output in every table)

## Coverage notes
Layered rules under test: `stack-reference/go.md` "Layered architecture" and "Tests by layer"; the templates in `docs/templates/go/`.
