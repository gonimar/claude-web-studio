---
updated: 2026-09-05
sources: [https://owasp.org/Top10/2025/, https://owasp.org/www-project-application-security-verification-standard/, https://cheatsheetseries.owasp.org, https://owasp.org/API-Security/, https://infosec.mozilla.org/guidelines/web_security, https://ssl-config.mozilla.org, https://www.w3.org/TR/CSP3/, https://datatracker.ietf.org/doc/html/rfc9457]
---
# Security standards — what we apply and how we verify

## Catalogue
| Standard | Version | Use in the studio |
|---|---|---|
| OWASP Top 10 | **2025** (final 2026-01): A01 Access Control (+SSRF), A02 Misconfiguration, A03 Supply Chain (new), A04 Crypto, A05 Injection, A06 Insecure Design, A07 Auth, A08 Integrity, A09 Logging & Alerting, A10 Exceptional Conditions (new) | `/security-audit` checklist, release gate |
| OWASP ASVS | 5.0 (2025-05) | L1 minimum for everything, L2 for auth/payments/personal data |
| OWASP API Security Top 10 | 2023 | API review: BOLA, BFLA, mass assignment, unrestricted resource consumption |
| OWASP Cheat Sheets | living | Primary source for concrete measures (Auth, Session, CSRF, CSP, File Upload, WebSocket, GraphQL, Docker, Node/Go/PHP) |
| Mozilla Web Security Guidelines + SSL Config Generator | living | Headers, TLS configs for nginx/Caddy |
| CSP Level 3 | W3C | nonce/`strict-dynamic`, no `unsafe-inline` for scripts |
| OAuth 2.1 (draft) / OIDC / WebAuthn L3 (passkeys) | — | External authentication; PKCE mandatory; passkeys the preferred second factor |
| RFC 9457 Problem Details | 2023 | API error format (`application/problem+json`) |
| RFC 9110/9111 HTTP Semantics/Caching | 2022 | Idempotency, cache headers |
| NIST SP 800-63B | rev. 4 (2025) | Password policy: length ≥ 8/15, no forced rotation, breach checks |
| GDPR / local privacy law (by jurisdiction) | — | Data minimisation, consent, deletion on request — recorded in the product spec |

## Authentication and sessions
- Passwords: argon2id (memory ≥ 64 MB) or bcrypt cost ≥ 12; breach check via haveibeenpwned (k-anonymity).
- Cookie sessions (`Secure; HttpOnly; SameSite=Lax`), id rotation on login, server-side storage (Redis/DB), absolute and idle timeouts.
- JWT only when statelessness is genuinely needed: short access (≤ 15 min) + rotating refresh with reuse detection; algorithm fixed (`EdDSA`/`RS256`), `alg: none` rejected; client storage via HttpOnly cookie through a BFF, not `localStorage`.
- MFA: TOTP/passkeys; login/OTP rate limits (per IP and per account); uniform "invalid credentials" response.
- Password reset: single-use tokens with TTL, no account-existence leaks.

## Input, output, injection
- Boundary validation by allow-list (schemas: zod / yiisoft/validator / go-validator); sizes and types; path canonicalisation.
- Parameterised SQL always; ORMs without raw concatenation.
- Context-aware output escaping (framework templating); `v-html`/`innerHTML`/`bypassSecurityTrust*` only under review with DOMPurify.
- SSRF: host allow-list, block private/link-local ranges after resolution, timeouts, no redirect following by default.
- Files: MIME check by content, generated names, storage outside the webroot/in object storage, antivirus by risk, `Content-Disposition: attachment` for untrusted content.
- Deserialising untrusted data (`unserialize`, `eval`, `Function`) is forbidden.

## Headers and transport
See `security-baseline.md`. TLS 1.3 (1.2 minimum with modern ciphers), HSTS preload, OCSP stapling, HTTP/2+HTTP/3; Mozilla "intermediate" profile; ACME certificates (Let's Encrypt), auto-renewal, alert 14 days before expiry.

## Network and infrastructure
- Reverse proxy → app over an internal Docker network; DB/Redis without published ports; firewall (ufw/nftables) — only 80/443/SSH with keys; fail2ban or equivalent; SSH without passwords.
- Containers: non-root user, `read_only` fs where possible, `cap_drop: [ALL]`, `no-new-privileges`, health checks, image tags pinned (digest), image scanning (Trivy) in CI.
- Rate limiting at the proxy (`limit_req`) and in the app (token bucket per key); body limits (`client_max_body_size`); upstream timeouts.
- WebSocket: Origin check, auth at handshake, max message size, ping/pong idle timeouts, backpressure.
- Logs: structured JSON, no secrets/PII (masking), correlation `request_id`; alerts on 401/403/429/5xx spikes and new admin logins.
- Secrets: env/secret store, rotation, `.env` not in git, repository scanning (gitleaks) in CI.

## Supply chain (A03)
Lockfile; `npm audit`/`pnpm audit`/`composer audit`/`govulncheck` in CI failing on high; Renovate with a 3–7 day delay on new versions; maintainer/abandonment checks; SRI for external `<script>`; image signatures (cosign) as maturity allows; SBOM (syft) for releases.

## Dynamic testing of the project's own applications (`/pentest`)
Only against the project's own systems or with written permission. Tools: OWASP ZAP (baseline/full scan, API scan from OpenAPI/GraphQL), Nuclei (templates), `sslyze`/`testssl.sh`, `nmap` against the project's own perimeter, Schemathesis (API fuzzing), Burp Community for manual checks. Report via the `pentest-report.md` template with CVSS 4.0 and a remediation plan.
