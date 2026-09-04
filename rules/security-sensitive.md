---
paths: ["**/auth/**", "**/security/**", "**/middleware/**", "**/nginx/**", "**/Caddyfile", "**/*.conf", "**/payments/**", "**/upload*/**", "**/webhook*/**"]
---
# Rules for security-sensitive code
- Any change here → `appsec-engineer` review before merge (run `/code-review --security`).
- Fail closed: on error, deny rather than allow. Authorisation on every request, object-ownership checks.
- Secrets from the environment; constant-time token comparison; logging without secrets/PII.
- Rate and size limits on input; timeouts on outbound calls; SSRF allow-list.
- Webhooks: verify the signature before parsing; idempotency by event id.
- Proxy config changes are validated with `nginx -t`/`caddy validate` and a header test (`/harden`).
- Update `docs/architecture/threat-model.md` when an attack surface is added.
