# /threat-model — the LLM / MCP surface (Phase 2 step 2)

Read when technical-preferences § LLM features is not `none` or the code imports an LLM/MCP SDK
(`@anthropic-ai/sdk`, `anthropic`, `github.com/anthropics/anthropic-sdk-go`, `anthropic-ai/sdk`,
`@modelcontextprotocol/*`, `mcp`, `mcp/sdk`). Facts and mitigations: `stack-reference/llm-integration.md`
§ Security (OWASP GenAI LLM Top 10 2026). Every row uses the model's own columns — STRIDE letters,
likelihood/impact, mitigation referencing the baseline, status (exists/planned/none).

## Trust boundaries to draw in the DFD
- **User → model**: the user's text is untrusted input (direct injection).
- **Third-party content → model**: tool results, RAG documents, fetched pages, e-mails, OCR text, MCP
  tool descriptions and responses — a boundary of its own; it crosses into the model only inside
  `tool_result` blocks, labelled with its source.
- **Model → tools**: every tool input is model output and therefore untrusted; the tool handler is a
  boundary (allow-lists, path confinement, parameterised queries, confirmation for side effects).
- **Model → user / renderer / executor**: the answer is untrusted output until validated (escaping,
  schema, enumerated actions).
- **Product ↔ MCP servers**: each server the product **runs** is an API surface with its own auth;
  each server the product **connects to** is a third-party dependency with its own credentials.

## Rows to add (per surface, STRIDE)
| Surface | Threats (STRIDE) | Minimum mitigation (status column filled from the code) |
|---|---|---|
| Model input — direct injection | T (instructions override), I (system prompt / hidden context leak), E (role escalation via prompt) | Input screen (small model, boolean structured output); system prompt states boundaries and refusal; operator instructions only in `system`; throttling of repeat offenders |
| Model input — indirect injection (tool results, RAG, web, e-mail, MCP responses) | T, I, E | Untrusted content only in `tool_result`, labelled and JSON-encoded; policy in the system prompt; tool-output screen; red-team cases in the eval set |
| Tool calls — side effects and exfiltration | T (unwanted writes), I (data sent out), D (loops, spend), E (tool reaches more than the user may) | Least-privilege tools; egress allow-lists; no read-private + write-external tool pair without confirmation; application-enforced confirmation for send/pay/delete/deploy/merge; step, tool-call and spend budgets; per-user authorisation inside every tool |
| Model output — rendering, execution, queries | T (XSS, command / SQL injection through output), S (spoofed UI text) | Escaping; parameterised queries; enumerated actions via structured output; path confinement; command allow-list; generated content marked in the UI |
| RAG / document ingestion and vector store | T (poisoned documents), I (cross-tenant retrieval), R (no provenance) | Allow-listed sources with provenance; screening at ingestion; tenant-scoped indexes with authorisation at query time; re-index on revocation |
| Secrets and hidden context in prompts | I | No keys, tokens, connection strings or other users' data in prompts; assume the system prompt leaks; secret-guard on `**/prompts/**` |
| MCP server the product **runs** | S (unauthenticated client), T, I, D (no limits), E (tool authorisation) | Auth and per-tool / per-object authorisation; rate and body limits; audit log; read-only tools by default; contract in the API contract; TLS behind the proxy for HTTP, environment credentials for stdio |
| MCP server the product **connects to** | S (spoofed server), T (poisoned tool descriptions), I (token passthrough, confused deputy), D | Pinned version / digest; tool allow-list; scoped short-lived tokens; never forward the user's token; tool descriptions reviewed on update; `/dependency-audit` lists the servers |
| Consumption and cost | D | Quotas per user / tenant / route; `max_tokens`; loop budgets; spend alerts; rate limiting at the proxy |
| Logging and evidence | R | Per-call structured log without contents; suspected injections surfaced and alerted; eval-set version recorded |

## What goes to Phase 3
An LLM row with status `none` on injection, exfiltration or side effects is among the top 5 by default:
the mitigation is a story (`/create-stories`) with the eval-set case that proves it, or an ADR when
the choice is architectural (MCP role, provider, where the confirmation lives).
