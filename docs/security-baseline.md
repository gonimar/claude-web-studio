# Security Baseline (mandatory for every release)

Sources: OWASP Top 10:2025 (final, January 2026), OWASP ASVS 5.0, OWASP Cheat Sheet Series,
Mozilla Web Security Guidelines. Stack details: `.claude/docs/stack-reference/security-standards.md`.

## OWASP Top 10:2025 → what we check

| # | Category | Minimum measure in the project |
|---|---|---|
| A01 | Broken Access Control (incl. SSRF) | Server-side authorisation on every request; deny by default; object ownership checks (IDOR); allow-list for outbound URLs |
| A02 | Security Misconfiguration | Production config without debug or default passwords; security headers; least-privilege containers; closed ports |
| A03 | Software Supply Chain Failures | Lockfile in git; `npm audit` / `composer audit` / `govulncheck` in CI; pinned versions; abandoned-package check; Dependabot/Renovate |
| A04 | Cryptographic Failures | TLS 1.3 everywhere; argon2id/bcrypt for passwords; secrets in the environment; no home-grown crypto |
| A05 | Injection | Parameterised queries always; boundary validation; context-aware escaping (HTML/JS/URL/SQL); CSP |
| A06 | Insecure Design | Threat model (`/threat-model`) before auth/payments/uploads; limits and quotas as part of the design |
| A07 | Authentication Failures | MFA-ready; login rate limiting; secure sessions (HttpOnly, Secure, SameSite); refresh-token rotation |
| A08 | Software & Data Integrity Failures | Signed artefacts/images; SRI for external scripts; signature-verified webhooks; no `eval`/untrusted deserialisation |
| A09 | Security Logging & Alerting Failures | Structured auth-event logs without secrets; alerts on 401/403/5xx spikes |
| A10 | Mishandling of Exceptional Conditions | Single error handler; no stack traces to clients; fail-closed in auth/payments; timeouts and backoff retries |

## Security headers (checked by `/harden` and `/security-audit`)
`Strict-Transport-Security: max-age=63072000; includeSubDomains; preload` ·
`Content-Security-Policy` (nonce/hash, no `unsafe-inline` for scripts) ·
`X-Content-Type-Options: nosniff` · `Referrer-Policy: strict-origin-when-cross-origin` ·
`Permissions-Policy` (minimal) · `Cross-Origin-Opener-Policy: same-origin` ·
`Cross-Origin-Resource-Policy` · cookies: `Secure; HttpOnly; SameSite=Lax|Strict`.

## Secrets
- Only environment / secret store; `.env` in `.gitignore`; `.env.example` without values.
- The `secret-guard` hook blocks writing key-like strings into tracked files.
- Keys never appear in logs, responses or command lines (pass via environment variables).

## Network and perimeter
- A reverse proxy (nginx/Caddy) terminates TLS; the backend is not exposed; Docker networks are split (frontend/backend/db).
- Rate limiting and body-size limits at the proxy and in the app; timeouts on every outbound call.
- WebSocket: `Origin` check, authentication at handshake, message limits.

## Release gate
`/security-audit full` without blocking findings, `/dependency-audit` clean, `/harden` checklist closed,
threat model current for every new attack surface.
