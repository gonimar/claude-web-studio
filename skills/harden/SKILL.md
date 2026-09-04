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

`security-baseline.md` (headers, network), `security-standards.md`, rules `ci-docker.md`, `security-sensitive.md`.

## Phase 1: Inventory
Proxy configs, compose/Dockerfile, workflows, where TLS terminates, current headers (`curl -sI <url>` on dev/staging/prod with consent).

## Phase 2: Checklist
Headers (HSTS, CSP nonce/strict-dynamic — mind Angular `ngCspNonce`/Nuxt, nosniff, Referrer-Policy, Permissions-Policy, COOP/CORP), cookie flags; TLS profile; `server_tokens`/`limit_req`/`client_max_body_size`/timeouts; WebSocket Origin/limits; Docker: networks, non-root, `cap_drop`, `read_only`, pins, health checks; CI `permissions`; secrets (`.env` ignored, gitleaks). Per item — status and a verification command.

## Phase 3: Changes (`--apply` or with consent)
Show config diffs; "May I write [files]?"; validate with `nginx -t`/`caddy validate`/`docker compose config`; repeat `curl -I` — before/after output.

## Phase 4: Write
"May I write `docs/security/hardening-checklist.md`?"

Verdict: `HARDENED` | `PARTIAL (open: …)`. Next step: `/security-audit quick`, `/pentest` (optional).
