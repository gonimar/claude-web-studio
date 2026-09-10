---
name: team-security
description: "Full security cycle: threat-model refresh → security-audit (code) → dependency-audit → harden (perimeter/containers) → optional pentest of the project's own app → consolidated report and stories. Use before release or after adding auth/payments/uploads/multiplayer."
argument-hint: "[full | pre-release] [--pentest]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Write, Task, AskUserQuestion
model: opus
agent: security-lead
---

# Team: Security

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

File writes and any mutation (git, deploy) happen only after an explicit "May I write?" / "Proceed?" — each one `AskUserQuestion` (proceed (Recommended) · show the draft/diff first · not now) → "yes"; delegated agents follow the same protocol. After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker).

## Phase 1: Threat model
`/threat-model` (refresh for new surfaces).

## Phase 2: In parallel
`/security-audit full` (`appsec-engineer`) ‖ `/dependency-audit` ‖ `/harden` (`network-security-engineer`) ‖ `graphql-engineer` — GraphQL checklist (if applicable).

## Phase 3: Dynamic (`--pentest`)
`/pentest` on dev/staging within the agreed scope.

## Phase 4: Consolidation
One deduplicated findings list, priorities, stories for BLOCKING/High; threat-model statuses updated; the release-gate verdict.

Verdict: `PASS` | `CONCERNS` | `FAIL`. Next step — one `AskUserQuestion`: `/create-stories` for the fixes (Recommended) · a repeated `/security-audit quick` · report only.
