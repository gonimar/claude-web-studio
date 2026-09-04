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

## Phase 4: Write
"May I write `docs/architecture/test-strategy.md` and the configs [list]?"

Verdict: `COMPLETE` | `PARTIAL (missing tool: …)`. Next step: `/create-stories` / `/qa-plan`.
