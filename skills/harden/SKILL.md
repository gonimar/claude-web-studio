---
name: harden
description: "Hardens the runtime and perimeter — security headers/CSP, TLS/HSTS, proxy (Caddy/nginx) config, rate/body limits, WebSocket protections, Docker network/container hardening, CI permissions, secrets hygiene; verifies with live curl/scanner output; writes docs/security/hardening-checklist.md."
argument-hint: "[full | headers | tls | proxy | docker | ci] [--apply]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Write, Edit, Task, AskUserQuestion
model: sonnet
agent: network-security-engineer
---

# Harden

`stack-reference/security-standards.md`, `security-baseline.md` (headers, network), rules `rules/ci-docker.md`, `rules/security-sensitive.md`.

## Phase 1: Inventory
Proxy configs — in this repository or in the **Infra repo / Proxy config** from `technical-preferences.md` (Infrastructure) when the proxy lives elsewhere; compose/Dockerfile, workflows, where TLS terminates, current headers (`curl -sI <url>` on dev/staging/prod with consent). No infra repo declared and no proxy config here → say so: the checklist can only be verified live, not fixed, and `/setup-stack`/`/adopt` records the field.

## Phase 2: Checklist
Headers (HSTS, CSP nonce/strict-dynamic — mind Angular `ngCspNonce`/Nuxt, nosniff, Referrer-Policy, Permissions-Policy, COOP/CORP), cookie flags; TLS profile; `server_tokens`/`limit_req`/`client_max_body_size`/timeouts; WebSocket Origin/limits; Docker: networks, non-root, `cap_drop`, `read_only`, pins, health checks; CI `permissions`; secrets (`.env` ignored, gitleaks). Per item — status and a verification command.

## Phase 3: Changes (`--apply` or with consent)
Show config diffs — in the infra repo when declared ("May I write [infra repo path/file]?"), otherwise the exact snippet for the owner of the proxy; validate with `nginx -t`/`caddy validate`/`docker compose config`; repeat `curl -I` — before/after output. The live headers are the evidence in both cases.

## Phase 4: Write
"May I write `docs/security/hardening-checklist.md`?" — one `AskUserQuestion`: write (Recommended) · show the draft/diff first · not now

Verdict: `HARDENED` | `PARTIAL (open: …)`. Next step — one `AskUserQuestion`: `/security-audit quick` (Recommended) · `/pentest` (optional) · stop here.
