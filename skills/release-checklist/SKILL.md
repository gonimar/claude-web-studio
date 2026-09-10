---
name: release-checklist
description: "Runs the release gate — verifies stories done, audits (security/deps/harden/perf/a11y) without blocking findings, migration compatibility, changelog, secrets/env, backup; writes production/releases/vX.Y.Z.md with deploy and rollback steps."
argument-hint: "[version]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Write, Task, AskUserQuestion
model: sonnet
agent: qa-lead
---

# Release Checklist

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

Template `release-checklist.md`.

## Phase 1: Evidence
Release stories Done (check CI tests: `gh run` if available); latest `docs/security/security-audit-*`, `hardening-checklist.md`, `docs/ops/perf-audit-*`, a11y reports; run `/dependency-audit` tools now; the CHANGELOG contains the version; migrations since the last tag — backward compatibility (`database-engineer` via Task); new env variables documented and present in `.env.example`/deploy instructions; backup and the date of the last tested restore.
`security-lead` via Task — the final security verdict.

## Phase 2: Checklist
Every item ✅/❌ with a link to evidence. Any ❌ in the gates → `NOT READY`.

## Phase 3: Write
"May I write `production/releases/vX.Y.Z.md` (with deploy/rollback steps)?" — one `AskUserQuestion`: write (Recommended) · show the draft/diff first · not now. Tag with consent: `git tag -a vX.Y.Z`. After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker).

Verdict: `READY` | `NOT READY (…)`. Next step — one `AskUserQuestion`: `/deploy vX.Y.Z` (Recommended) · fix the NOT READY items · stop here.
