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
A **first release** is one with no earlier release tag (`git tag --list 'v*'` is empty); two gates below apply only to it.
1. **Stories**: the release stories are Done; check their CI tests (`gh run` if available).
2. **Audits**: the latest `docs/security/security-audit-*`, `docs/security/hardening-checklist.md`, `docs/ops/perf-audit-*` and `docs/ops/a11y-audit-*` reports; run the `/dependency-audit` tools now.
3. **Changelog**: `CHANGELOG.md` contains the version.
4. **Migrations** since the last tag: backward compatibility, checked by `database-engineer` via Task.
5. **Env**: new env variables are documented and present in `.env.example` / the deploy instructions.
6. **Backup and restore**: the backup and the date of the last tested restore. On the first release of a project with a database the restore drill is a gate: no date in `data-model.md` §7 or the runbook → ❌ with the story to run ("Backup & restore drill", `/create-stories` adds it). Later releases show the date and warn when it is older than 90 days.
7. **Observability**: `/healthz` with dependency checks, structured logs, an alert on error rate. On the first release when technical-preferences has a Deploy target this is a gate: missing → ❌ with the story to run ("Observability", `/create-stories` adds it).
8. **Security verdict**: `security-lead` via Task gives the final security verdict.

## Phase 2: Checklist
Every item ✅/❌ with a link to evidence. Any ❌ in the gates → `NOT READY`.

## Phase 3: Write and tag
1. Show the checklist in the chat, then ask "May I write `production/releases/vX.Y.Z.md` (with deploy/rollback steps)?" — one `AskUserQuestion`: write (Recommended) · show the draft/diff first · not now. After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker).
2. **Tag**, only on `READY` and as its own `AskUserQuestion` after the write: tag now (Recommended) · not now. Releases are tags on the default branch, never on a story branch (git-workflow), so run `git switch <default> && git pull --ff-only origin <default>`, then `git tag -a vX.Y.Z -m "Release vX.Y.Z"`. Without `-m`, `git tag -a` opens an editor the session cannot use.

Verdict: `READY` | `NOT READY (…)`. Next step — one `AskUserQuestion`: `/deploy vX.Y.Z` (Recommended) · fix the NOT READY items · stop here.
