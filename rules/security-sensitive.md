---
paths: ["**/auth/**", "**/security/**", "**/middleware/**", "**/nginx/**", "**/Caddyfile", "**/*.conf", "**/payments/**", "**/upload*/**", "**/webhook*/**", "**/prompts/**", "**/llm/**", "**/mcp/**"]
---
# Rules for security-sensitive code
- Any change here → `appsec-engineer` review before merge (run `/code-review --security`).
- Fail closed: on error, deny rather than allow. Authorisation on every request, object-ownership checks.
- Secrets from the environment; constant-time token comparison; logging without secrets/PII.
- Rate and size limits on input; timeouts on outbound calls; SSRF allow-list.
- Webhooks: verify the signature before parsing; idempotency by event id.
- Proxy config changes are validated with `nginx -t`/`caddy validate` and a header test (`/harden`).
- LLM prompts, tool handlers and MCP code: untrusted content only in `tool_result` blocks; no secrets in prompts; model output validated before it is rendered, executed or queried; side effects behind an application-enforced confirmation (`stack-reference/llm-integration.md` § Security).
- Update `docs/architecture/threat-model.md` when an attack surface is added (an LLM feature or an MCP server/client is one — `/threat-model llm`).
