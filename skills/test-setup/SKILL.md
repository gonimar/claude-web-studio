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

Template `test-strategy.md`; reference `testing.md`; rules `tests.md`.

## Phase 1: Stack and current state
technical-preferences; what exists (`vitest.config`, `playwright.config`, `phpunit.xml`, `_test.go`, workflows); gaps.

## Phase 2: Strategy
A table of tools per level and language; the `test` environment (compose profile/testcontainers); contract tests per API style (GraphQL: codegen check + N+1 test; REST: schema validation); security/a11y/perf stages; thresholds; flaky rules.

## Phase 3: Configs (`--apply` or with consent)
`test-engineer` via Task: configs, a first smoke test per level, CI stages (`devops-engineer`). A run — output in the result.
Everything the generated CI references must exist after this run: a compose profile or service named in a workflow (`docker compose --profile test …`) is created as a minimal `compose.yaml` fragment (profile + services with healthchecks) in the same run, or the skill stops with `BLOCKED (compose profile 'test' missing — story S-NNN adds it)` naming the story — never a CI that cannot pass. Self-check before finishing: `docker compose --profile test config` when docker is available, and every service named in `test-strategy.md` exists in compose.

## Phase 4: Write
"May I write `docs/architecture/test-strategy.md` and the configs [list]?"

Verdict: `COMPLETE` | `PARTIAL (missing tool: …)` | `BLOCKED (compose profile missing — …)`. Next step — one `AskUserQuestion`: `/create-stories` (Recommended) · `/qa-plan` · revise the strategy.
