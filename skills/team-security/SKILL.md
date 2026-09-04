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

File writes and any mutation (git, deploy) happen only after an explicit "May I write?" / "Proceed?" → "yes"; delegated agents follow the same protocol.

## Phase 1: Threat model
`/threat-model` (refresh for new surfaces).

## Phase 2: In parallel
`/security-audit full` (`appsec-engineer`) ‖ `/dependency-audit` ‖ `/harden` (`network-security-engineer`) ‖ `graphql-engineer` — GraphQL checklist (if applicable).

## Phase 3: Dynamic (`--pentest`)
`/pentest` on dev/staging within the agreed scope.

## Phase 4: Consolidation
One deduplicated findings list, priorities, stories for BLOCKING/High; threat-model statuses updated; the release-gate verdict.

Verdict: `PASS` | `CONCERNS` | `FAIL`. Next step: `/create-stories` for fixes → a repeated `/security-audit quick`.
