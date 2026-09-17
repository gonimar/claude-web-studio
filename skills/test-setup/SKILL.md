---
name: test-setup
description: "Sets up the test strategy and infrastructure for the chosen stack — Vitest/Playwright/PHPUnit/go test, testcontainers or a compose test profile, contract tests from GraphQL/OpenAPI, axe/Lighthouse/k6 hooks, CI stages, coverage thresholds. Produces docs/architecture/test-strategy.md and config files."
argument-hint: "[--apply]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, AskUserQuestion, Task
model: sonnet
agent: qa-lead
---

# Test Setup

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

Template `templates/test-strategy.md`; reference `stack-reference/testing.md`; rules `rules/tests.md`.

## Phase 1: Stack and current state
technical-preferences; what exists (`vitest.config`, `playwright.config`, `phpunit.xml`, `_test.go`, workflows); gaps.

## Phase 2: Strategy
A table of tools per level and language; the `test` environment (compose profile/testcontainers); contract tests per API style (GraphQL: codegen check + N+1 test; REST: schema validation); security/a11y/perf stages; thresholds; flaky rules (no fixed waits, errors by identity). Go: the tests-by-layer table from `go.md` when `go_architecture: layered` — domain without doubles, use cases with fakes/`moq`, infrastructure with containers — and the coverage gate with the thresholds from technical-preferences (default domain 90 % / usecase 80 %).

## Phase 3: Configs (`--apply` or with consent)
`test-engineer` via Task: configs, a first smoke test per level, CI stages (`devops-engineer`). Go module — templates from `.claude/docs/templates/go/` (copy mode) or `${CLAUDE_PLUGIN_ROOT}/docs/templates/go/` (plugin mode), copied with `cp`, never retyped: `.golangci.yml` from `golangci.yml` (`MODULE_PATH` replaced from `go.mod`; the `depguard` block kept under `layered`, removed under `modular`; `go_domain_allow` entries added to the `domain` allow-list), `scripts/coverage-gate.sh` from `coverage-gate.sh` (`chmod +x` — a file created with Write has no exec bit), the `fmt`/`lint`/`test`/`coverage-gate`/`layout-check`/`arch-check`/`ci`/`ci-full` targets from `Makefile.snippet` merged into the Makefile with `GO_COVERAGE_DOMAIN`/`GO_COVERAGE_USECASE` set from technical-preferences (`layout-check` dropped from `ci` under `go_composition_root: main`), `moq` as a `tool` directive when a port has more than three methods; `make ci` runs once and its output is in the result — a gate that has never failed on purpose is not known to work, so the run also shows `make coverage-gate GO_COVERAGE_DOMAIN=100` failing on the current numbers **within the budget rules of `stack-reference/tooling-devops.md` § CI** — one job per toolchain, `paths:` filters, e2e and security on pull requests to the default branch, `concurrency: cancel-in-progress`, `runs-on: ${{ vars.CI_RUNNER || 'ubuntu-latest' }}`. The report states the estimated minutes per run and per month at the project's current merge rate; on a private repository the free tier is 2 000 minutes a month and every job is rounded up to the minute, so a seven-job pipeline of forty-second jobs costs seven minutes per push. A run — output in the result.
Everything the generated CI references must exist after this run: a compose profile or service named in a workflow (`docker compose --profile test …`) is created as a minimal `compose.yaml` fragment (profile + services with healthchecks) in the same run, or the skill stops with `BLOCKED (compose profile 'test' missing — story S-NNN adds it)` naming the story — never a CI that cannot pass. Self-check before finishing: `docker compose --profile test config` when docker is available, and every service named in `test-strategy.md` exists in compose.

## Phase 4: Write
"May I write `docs/architecture/test-strategy.md` and the configs [list]?" — one `AskUserQuestion`: write (Recommended) · show the draft/diff first · not now After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker).

Verdict: `COMPLETE` | `PARTIAL (missing tool: …)` | `BLOCKED (compose profile missing — …)`. Next step — one `AskUserQuestion`: `/create-stories` (Recommended) · `/qa-plan` · revise the strategy.
