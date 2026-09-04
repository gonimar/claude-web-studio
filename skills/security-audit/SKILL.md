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

Template `security-audit-report.md`; `security-baseline.md`, `security-standards.md`, `graphql.md` (security).

## Phase 1: Scope
Mode from the argument (`full` by default); surfaces from the threat model; stack from technical-preferences.

## Phase 2: In parallel via Task
- `appsec-engineer`: code review A01–A10 for the scope (auth/sessions/JWT, object and GraphQL field authorisation, injection/XSS surfaces, SSRF, files, webhooks, errors/logs); run `govulncheck`/`composer audit`/`pnpm audit`/`gitleaks`/`semgrep` when available — with output.
- `network-security-engineer` (`full`/`infra`): proxy/headers/TLS/compose/Dockerfile/CI permissions.
- `graphql-engineer` (if GraphQL): introspection, limits, persisted ops, DataLoader/DoS, batching.

## Phase 3: Consolidate
Deduplicate, severity (CVSS 4.0), BLOCKING/WARNING/INFO, fix and regression test per finding; A01–A10 checklist with statuses.

## Phase 4: Write
"May I write `docs/security/security-audit-<date>.md`?" Propose stories for BLOCKING (`/create-stories`) and a threat-model update.

Verdict: `PASS` | `CONCERNS (N warnings)` | `FAIL (N blocking)`. Next step: fixes → a repeated `quick`; then `/harden`.
