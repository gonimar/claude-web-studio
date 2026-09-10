---
name: harden
description: "Hardens the runtime and perimeter — security headers/CSP, TLS/HSTS, proxy (Caddy/nginx) config, rate/body limits, WebSocket protections, Docker network/container hardening, CI permissions, secrets hygiene; verifies with live curl/scanner output; writes docs/security/hardening-checklist.md."
argument-hint: "[full | headers | tls | proxy | docker | ci | secrets] [--apply]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Write, Edit, Task, AskUserQuestion
model: sonnet
agent: network-security-engineer
---

# Harden

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

`stack-reference/security-standards.md`, `security-baseline.md` (headers, network), rules `rules/ci-docker.md`, `rules/security-sensitive.md`.

## Phase 1: Inventory
Proxy configs — in this repository or in the **Infra repo / Proxy config** from `technical-preferences.md` (Infrastructure) when the proxy lives elsewhere; compose/Dockerfile, workflows, where TLS terminates, current headers (`curl -sI <url>` on dev/staging/prod with consent). No infra repo declared and no proxy config here → say so: the checklist can only be verified live, not fixed, and `/setup-stack`/`/adopt` records the field.

## Phase 2: Checklist
Headers (HSTS, CSP nonce/strict-dynamic — mind Angular `ngCspNonce`/Nuxt, nosniff, Referrer-Policy, Permissions-Policy, COOP/CORP), cookie flags; TLS profile; `server_tokens`/`limit_req`/`client_max_body_size`/timeouts; WebSocket Origin/limits; Docker: networks, non-root, `cap_drop`, `read_only`, pins, health checks; CI `permissions`; secrets (`.env` ignored, gitleaks). Per item — status and a verification command.
**`secrets` mode (rotation checklist)** — an inventory, never the values: every secret the project uses, from the deploy contract's Prerequisites & secrets, `.env.example`, compose `environment:`/`env_file:`, workflow `secrets.*` references and the platform UI names; per secret: where it lives (platform env, `~/.config/<project>/*.env`, CI secret, registry token), which component reads it, the provider's rotation steps (issue new → deploy → verify → revoke old), the last rotation date if recorded. Then the checks: `gitleaks` / `git log -p -S` for the old value pattern (never the value itself in the command line), no secret in images (`docker history`, build args), CI `permissions` least-privilege, `.env` ignored. Output: the rotation table + the order to rotate in (dependencies first) + the verification per secret; written into `docs/security/hardening-checklist.md` § Secrets. Trigger: a leak (`/incident`), a departure, quarterly.

## Phase 3: Changes (`--apply` or with consent)
Show config diffs — in the infra repo when declared ("May I write [infra repo path/file]?"), otherwise the exact snippet for the owner of the proxy; validate with `nginx -t`/`caddy validate`/`docker compose config`; repeat `curl -I` — before/after output. The live headers are the evidence in both cases.

## Phase 4: Write
"May I write `docs/security/hardening-checklist.md`?" — one `AskUserQuestion`: write (Recommended) · show the draft/diff first · not now After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker).

Verdict: `HARDENED` | `PARTIAL (open: …)`. Next step — one `AskUserQuestion`: `/security-audit quick` (Recommended) · `/pentest` (optional) · stop here.
