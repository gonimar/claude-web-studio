---
name: security-audit
description: "Audits the application against OWASP Top 10:2025 / ASVS for the project's stack (Go/PHP/Node, Angular/Vue, GraphQL/REST, WebSocket, containers) — code review by appsec-engineer, tooling (govulncheck, composer/pnpm audit, gitleaks, semgrep), findings with CVSS and fixes; writes docs/security/security-audit-<date>.md. Required before release."
argument-hint: "[full | quick | api | auth | infra | <path>]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Write, Task, AskUserQuestion
model: sonnet
agent: security-lead
---

# Security Audit

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

Templates `templates/security-audit-report.md`, `findings.md`; `stack-reference/security-standards.md`, `security-baseline.md`, `graphql.md` (security).

## Phase 1: Scope
Mode from the argument (`full` by default): `quick` = HIGH/BLOCKING classes only (auth, authorisation/IDOR, injection, secrets, dependency CVEs) without the network and GraphQL deep passes; `api`/`auth`/`infra`/`<path>` narrow the scope. Surfaces from the threat model; no `docs/architecture/threat-model.md` → continue from technical-preferences and the code, say so in the report and propose `/threat-model` as a follow-up — never a silent full pass. Stack from technical-preferences.

## Phase 2: In parallel via Task
- `appsec-engineer`: code review A01–A10 for the scope (auth/sessions/JWT, object and GraphQL field authorisation, injection/XSS surfaces, SSRF, files, webhooks, errors/logs); run `govulncheck`/`composer audit`/`pnpm audit`/`gitleaks`/`semgrep` when available — with output; a tool that is not installed is listed in the report as "not run: <tool> missing" with the install hint, never skipped silently.
- `network-security-engineer` (`full`/`infra`): proxy/headers/TLS/compose/Dockerfile/CI permissions.
- `graphql-engineer` (if GraphQL): introspection, limits, persisted ops, DataLoader/DoS, batching.

## Phase 3: Consolidate
Deduplicate, severity (CVSS 4.0), BLOCKING/WARNING/INFO, fix and regression test per finding; A01–A10 checklist with statuses.

## Phase 4: Write
"May I write `docs/security/security-audit-<date>.md`?" Then, for every BLOCKING (and WARNING that needs a decision), one `AskUserQuestion`: record it in `production/findings.md` (template `findings.md`; id `SEC-NNN`, severity, area/feature, the decision needed) (Recommended) · story stubs now via `/create-stories` · report only. A BLOCKING that is neither recorded nor turned into a story is reported as such in the verdict line — it must not silently stay in the report (`/create-stories`, `/sprint-plan` and `/help` read `production/findings.md`). Propose a threat-model update. After the "write" answer: `touch .claude/.write-consent` (rule 7).

Verdict: `PASS` | `CONCERNS (N warnings)` | `FAIL (N blocking)`. Next step — one `AskUserQuestion`: fixes, then a repeated `/security-audit quick` (Recommended) · `/harden` · report only.
