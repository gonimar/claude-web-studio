---
updated: 2026-09-26
sources: [https://platform.claude.com/docs/en/about-claude/models/overview, https://platform.claude.com/docs/en/build-with-claude/prompt-caching, https://platform.claude.com/docs/en/build-with-claude/batch-processing, https://platform.claude.com/docs/en/build-with-claude/structured-outputs, https://platform.claude.com/docs/en/agents-and-tools/mcp-connector, https://platform.claude.com/docs/en/test-and-evaluate/strengthen-guardrails/mitigate-jailbreaks, https://github.com/anthropics/anthropic-sdk-typescript, https://github.com/anthropics/anthropic-sdk-python, https://github.com/anthropics/anthropic-sdk-go, https://github.com/anthropics/anthropic-sdk-php, https://github.com/modelcontextprotocol/modelcontextprotocol, https://github.com/modelcontextprotocol/typescript-sdk, https://github.com/modelcontextprotocol/python-sdk, https://github.com/modelcontextprotocol/go-sdk, https://github.com/modelcontextprotocol/php-sdk, https://github.com/microsoft/playwright-mcp, https://github.com/github/github-mcp-server, https://github.com/GenAI-Security-Project/GenAI-LLM-Top10, https://code.claude.com/docs/en/mcp, https://code.claude.com/docs/en/hooks, https://code.claude.com/docs/en/plugins/components, "Claude Code bundled skill claude-api (shared/prompt-caching.md, shared/token-counting.md, shared/tool-use-concepts.md, shared/evals/build-eval.md, shared/evals/eval-audit.md, {lang}/claude-api/README.md)"]
---
# LLM integration — Claude API, MCP, evals, security

"LLM in the product" means the application calls a model (chat, extraction, classification, an agent
with tools) or takes part in the Model Context Protocol (MCP) as a server or a client. The studio
builds on the Anthropic Claude API; another provider is a technical-preferences decision with an ADR.
Facts below carry their date; the API moves monthly, so `/stack-update llm` before a design review.
The `claude-api` skill bundled with Claude Code is the working reference for code (`/claude-api`
loads it; its subcommands `build-eval`, `cost-optimize`, `migrate`, `prompt-audit`).

## Versions and support (2026-09-26)
| Item | Current | Notes |
|---|---|---|
| Messages API | `POST /v1/messages`, header `anthropic-version: 2023-06-01` | Everything — tools, structured outputs, caching — is a feature of this one endpoint |
| Claude Fable 5.1 | `claude-fable-5-1` — 1M context, 128K output, $10 / $50 per MTok | Demanding reasoning and long-horizon agentic work; thinking always on; retirement not sooner than 2027-09-01 |
| Claude Opus 5.5 | `claude-opus-5-5` — 1M / 128K, $4 / $20 | The docs' starting point "for most workloads"; default effort `medium`; retirement not sooner than 2027-09-22 |
| Claude Sonnet 5 | `claude-sonnet-5` — 1M / 128K, $2 / $10 | Speed and intelligence; retirement not sooner than 2027-06-30 |
| Claude Haiku 4.5 | `claude-haiku-4-5` — 200K / 64K, $1 / $5 | Fastest; input screens and classifiers; retirement not sooner than 2026-10-15 — plan the replacement |
| Legacy, still served | `claude-fable-5`, `claude-opus-5`, `claude-opus-4-8`, `claude-opus-4-7`, `claude-opus-4-6`, `claude-sonnet-4-6`, `claude-sonnet-4-5`, `claude-opus-4-5` | New code does not start on them |
| MCP specification | revision **2026-07-28** (earlier: 2024-11-05, 2025-03-26, 2025-06-18, 2025-11-25) | `docs/specification/` in the spec repository; `draft` is the next one |

Model ids from the 4.6 generation on are dateless and are themselves pinned snapshots — never append a
date suffix. Batch API requests are 50 % off; cache reads cost 10 % of the base input price (2.5 % on
Fable 5.1, 5 % on Opus 5.5). Partner platforms (Bedrock, Vertex AI, Foundry) price and retire separately.

## Studio default choices
| Task | Choice | Why |
|---|---|---|
| Provider / SDK | Anthropic Claude API through the official SDK of the project language (table below) | One provider, typed SDKs, the `claude-api` skill covers it; raw HTTP only where no SDK exists |
| Product model | `claude-opus-5-5`, pinned in `technical-preferences.md` § LLM features | The models overview names it for most workloads; a change is measured on the eval set first, never swapped in a story |
| High-volume / latency-bound routes | `claude-sonnet-5`; `claude-haiku-4-5` for screens and classifiers | Cost per completed task, measured — not a guess (the `cost-optimize` subcommand) |
| Thinking | `thinking: {type: "adaptive"}` + `output_config.effort` (`low` … `max`) | `budget_tokens` is deprecated (4.6) or rejected (later models); on Opus 5.5 thinking cannot be disabled — lower the effort instead |
| Output shape | structured outputs (`output_config.format`) or `strict: true` tools | Assistant prefill returns 400 on the 4.6+ family |
| Long outputs | streaming with the SDK's `finalMessage()` / `get_final_message()` | 128K output needs streaming to avoid HTTP timeouts |
| Offline volume | Message Batches API | 50 % off, ≤ 100,000 requests or 256 MB per batch |

The bundled `claude-api` skill (model table cached 2026-06-24) still writes generated code against
`claude-opus-5`; the studio default follows the models overview of the date above. Record the id you
ship in technical-preferences and re-check it with `/stack-update llm`.

## SDKs
| Language | Package | Status (source) |
|---|---|---|
| TypeScript / JavaScript | `@anthropic-ai/sdk` (`npm install @anthropic-ai/sdk`) | official, github.com/anthropics/anthropic-sdk-typescript |
| Python | `anthropic` (`pip install anthropic`); 1.x is built on `httpx2`, Python ≥ 3.10 | official, github.com/anthropics/anthropic-sdk-python (`MIGRATION.md` for 0.x → 1.x) |
| Go | `github.com/anthropics/anthropic-sdk-go` (`anthropic.NewClient()`, `client.Messages.New`) | official, github.com/anthropics/anthropic-sdk-go |
| PHP | `anthropic-ai/sdk` (`composer require "anthropic-ai/sdk"`, `new Anthropic\Client(apiKey: …)`) | official, github.com/anthropics/anthropic-sdk-php; named arguments are camelCase (`maxTokens`) |
| Java/Kotlin, Ruby, C# | `com.anthropic.*`, `anthropic` gem, `Anthropic` NuGet | official; not studio stacks |

- The zero-argument client resolves credentials in this order: `ANTHROPIC_API_KEY` → `ANTHROPIC_AUTH_TOKEN` →
  an `ant auth login` profile. Never hardcode a key; never pass it as a CLI flag.
- Cloud access uses the platform client, not a `base_url` override: Bedrock `AnthropicBedrockMantle`
  (model ids prefixed `anthropic.`), Vertex `AnthropicVertex`, Foundry `AnthropicFoundry`.
- Defaults: timeout 10 min (TypeScript in **milliseconds**, Python in seconds), `max_retries` 2 on
  408/409/429/5xx and connection errors; error handling is a most-specific-first chain
  (`NotFoundError` → `RateLimitError` → `APIStatusError` → `APIConnectionError`), never one broad catch.
- Use the SDK's types (`MessageParam`, `Tool`, `Message`) and helpers; do not re-implement the loop or
  the stream aggregation.

## Messages API essentials
- **System prompt**: top-level `system` (string or text blocks). Mid-conversation operator instructions go
  as `{"role": "system", "content": "…"}` appended to `messages` (Opus 5 / 5.5 / 4.8, Fable 5 / 5.1; not
  Sonnet 5): it preserves the cached prefix and is the non-spoofable operator channel — text inside a
  user turn or a tool result can be forged by whoever writes there.
- **Tool use**: `tools: [{name, description, input_schema, strict: true}]`; loop while
  `stop_reason == "tool_use"`, execute every `tool_use` block, return **all** `tool_result` blocks in one
  user message (`is_error: true` for a failed tool, never dropped); parse `tool_use.input` with
  `JSON.parse` / `json.loads`, never string-match it. Stop reasons to handle: `end_turn`, `max_tokens`
  (a truncated tool input can still validate — do not run it), `tool_use`, `pause_turn` (resume),
  `refusal` (read `stop_details.category`; Fable/Opus 5 code opts into the server-side `fallbacks`
  parameter). The SDK tool runners (`client.beta.messages.tool_runner` + `@beta_tool`, `betaZodTool` +
  `toolRunner`, Go `BetaToolRunner`, PHP `toolRunner()`) drive that loop with per-turn hooks for
  approval gates, logging and retries. Forced `tool_choice` (`any` / `tool`) returns 400 on Fable 5.1
  and Opus 5.5 — use `auto` plus an instruction, or structured outputs.
- **Server tools** run on Anthropic's side: `web_search_20260209`, `web_fetch_20260209` (with
  `allowed_domains` / `blocked_domains`, `max_uses`), `code_execution_20260521`; errors come back as
  HTTP 200 result blocks with an `error_code`, not exceptions.
- **Streaming**: `client.messages.stream(...)`; events `message_start` → `content_block_start` /
  `content_block_delta` / `content_block_stop` → `message_delta` (carries `stop_reason` and usage) →
  `message_stop`; `finalMessage()` when the events themselves are not needed. Default streaming for
  anything with long input, long output or large `max_tokens` (~16000 non-streaming, ~64000 streaming
  unless there is a reason for less).
- **Prompt caching**: `cache_control: {type: "ephemeral"}` on a block (or at the top level of the
  request for automatic caching); a **prefix match** over `tools` → `system` → `messages`; at most 4
  breakpoints; minimum cacheable prefix 512 tokens (Fable 5 / 5.1, Opus 5 / 5.5), 1,024 (Opus 4.8,
  Sonnet 5 / 4.6), 4,096 (Haiku 4.5); TTL 5 min (write 1.25× input) or `ttl: "1h"` (2×); reads 0.1×.
  Verify with `usage.cache_read_input_tokens` — zero across repeated requests means a silent
  invalidator: a timestamp or user id in the system prompt, unsorted JSON, a per-user tool list, a
  model switch. Keep the system prompt frozen; inject the dynamic part later in `messages`.
- **Token counting**: `POST /v1/messages/count_tokens` (`client.messages.count_tokens` /
  `countTokens`), model-specific — never `tiktoken` (it undercounts Claude tokens by 15–20 % and more
  on code); the tokenizer changed with Opus 4.7, re-baseline when migrating from Opus 4.6 or older.
- **Batches**: `POST /v1/messages/batches` with `requests: [{custom_id, params}]`; poll
  `processing_status` until `ended`, stream results and key them by `custom_id` (any order); 50 %
  off, most batches finish within an hour, all expire at 24 h, results kept 29 days.
- **Context**: 1M windows; server-side compaction (beta `compact-2026-01-12`, keep `response.content`
  verbatim in history) and context editing (`clear_tool_uses_20250919`) for long agent loops; a history
  is append-only on Fable 5.1 / Opus 5.5 — editing earlier turns invalidates thinking blocks.
- **Files, PDFs, citations**: `client.files.upload` (no beta), `document` blocks (base64 or `file_id`),
  `citations: {enabled: true}` per document (incompatible with `output_config.format`).

## Structured output patterns
- `output_config: {format: {type: "json_schema", schema}}` — no beta header; the old `output_format`
  parameter is deprecated. Every object needs `additionalProperties: false` and `required`; no
  recursion, no `minimum` / `maxLength`-style constraints (the SDKs strip them and validate client-side).
- Prefer the parsing helpers: Python `client.messages.parse(..., output_format=PydanticModel)` →
  `response.parsed_output`; TypeScript `client.messages.parse({output_config: {format:
  zodOutputFormat(schema)}})`; PHP `StructuredOutputModel`; Go raw schemas through `OutputConfigParam`.
- Extraction / classification: one schema, one call, `claude-haiku-4-5` or `claude-sonnet-5` at
  `low` effort, validate again in the application (the schema proves shape, not truth).
- When the output drives code (a query, a command, a file path), the schema is an allow-list of
  enumerated actions, not free text — see Security.

## MCP as a product feature
The Model Context Protocol (spec revision 2026-07-28) lets a model host discover and call tools,
read resources and use prompts from a server. Transports: **stdio** (a local subprocess; credentials
from the environment) and **Streamable HTTP** (remote; the older HTTP+SSE transport is deprecated —
migrate). The 2026-07-28 revision made the protocol stateless (no `Mcp-Session-Id`; every request
carries `io.modelcontextprotocol/protocolVersion` in `_meta`), added a mandatory `server/discover`
RPC and `subscriptions/listen`, moved tasks to the extension `io.modelcontextprotocol/tasks`, gave
every result a `resultType` (`complete` | `input_required`) and deprecated `roots`, `sampling` and
`logging`; OAuth Dynamic Client Registration is superseded by Client ID Metadata Documents.
Authorization for HTTP transports is OAuth-based (spec § authorization — unverified in detail — check
https://modelcontextprotocol.io/specification/2026-07-28/basic/authorization); the base message format
is JSON-RPC (unverified — check https://modelcontextprotocol.io/specification/2026-07-28/basic).

| SDK | Package | Facts (source) |
|---|---|---|
| TypeScript | `@modelcontextprotocol/server`, `@modelcontextprotocol/client` (v2, spec 2026-07-28; `McpServer`, `StdioServerTransport`, Streamable HTTP) | github.com/modelcontextprotocol/typescript-sdk; the v1 package `@modelcontextprotocol/sdk` is still published (1.30.1, 2026-09-23) for code on the v1 API; new code takes the v2 packages |
| Python | `mcp` (`pip install "mcp[cli]"`; `MCPServer("name")`, `@mcp.tool()`; stdio, Streamable HTTP, SSE; `Client(url)`; Python ≥ 3.10) | github.com/modelcontextprotocol/python-sdk |
| Go | `github.com/modelcontextprotocol/go-sdk` (official, with Google; v1.7+, spec 2026-07-28; `mcp.Server`, `mcp.Client`, `mcp.StdioTransport`, `mcp.CommandTransport`) | github.com/modelcontextprotocol/go-sdk |
| PHP | `mcp/sdk` (official, PHP Foundation + Symfony; experimental until 1.0; stdio and HTTP; conformance against 2026-07-28 and 2025-11-25) | github.com/modelcontextprotocol/php-sdk |

**The application exposes an MCP server** (`MCP role: server`):
- It is an API surface: authentication, authorisation per tool and per object, rate limits, body
  limits, audit log and the OWASP API Security Top 10 apply as to any endpoint (security-standards.md).
  Remote servers speak Streamable HTTP behind the reverse proxy with TLS; a stdio server is a
  local process and reads its credentials from the environment, never from arguments.
- Tools are the contract: one server per bounded context, verbs the domain already has, descriptions
  that state side effects and preconditions, read-only tools by default and mutating tools separate and
  few. Tool annotations that mark a tool read-only or destructive exist in the spec (unverified —
  check https://modelcontextprotocol.io/specification/2026-07-28/server/tools).
- Every tool input is untrusted (it was produced by a model that read untrusted content): validate by
  allow-list, confine paths to a root, parameterise queries, cap sizes, time out.
- The contract lives with the API contract (`api_contract_path`); a tool added or changed is an
  `/impact` architecture change and a `/threat-model mcp` surface.

**The application consumes MCP servers** (`MCP role: client`):
- Two ways: the **MCP connector** of the Messages API (beta `mcp-client-2025-11-20`;
  `mcp_servers: [{type: "url", url, name, authorization_token?}]` **and** `tools: [{type: "mcp_toolset",
  mcp_server_name}]` — both halves or a validation error; remote Streamable HTTP or SSE servers only,
  no stdio; allow-list tools with `default_config: {enabled: false}` + `configs`; Claude API, Claude
  Platform on AWS and Foundry in beta, not Bedrock / Google Cloud), or the application's own MCP client
  (SDK above) that turns the server's tools into `tools[]` and executes the calls itself.
- A connected server is a dependency: pin its version or image digest, review its tool list at each
  update (the tool descriptions reach the model as instructions), keep the OAuth token scoped and
  short-lived, and never forward the user's token to a server (confused deputy).
- Tool results are third-party content: see Security — they never override the system prompt.

Claude Code's own MCP tools appear as `mcp__<server>__<tool>` (plugin servers:
`mcp__plugin_<plugin>_<server>__<tool>`), matchable in permission rules and hook matchers
(`mcp__plugin_web-studio_github__.*`); the studio's optional servers are in `.mcp.json` (playbook § MCP servers).

## Evals for LLM features (`eval set path`)
An eval is three things: a set of inputs, a runner that executes the feature on each, a grader per
output. Without one, a prompt or model change is a guess; the studio treats a missing eval like a
missing test (`/story-done` will not close an LLM story whose acceptance criteria have no measured run).
- **Golden set**: 30–100 real cases from transcripts or written by the product owner, tagged with their
  provenance (human-written · human-verified · model X's output). Never grade model A against gold
  produced by model A when the question is A vs B. Split train / validation / test; the test share is
  scored on every change and is the headline. No label may be visible to the model (few-shot examples
  copied from the golden set are leakage).
- **Graders**: exact match or a schema check where possible; for agents that act, grade the **end state**
  in a disposable workspace (tests pass, rows present, nothing off-limits touched, tool calls within
  budget), not the transcript. Score properties separately (`correct`, `formatted`, `concise`).
- **LLM-as-judge caveats**: verbosity bias (say length is not merit), self-preference (not the model
  under test, ideally another family or a small jury), label deference (never say which answer is the
  reference), a concrete rubric with checkable properties, candidate text treated as untrusted data,
  structured output for a deterministic parse, calibration against a few dozen human labels (agreement
  well below ~90 % on clear-cut cases means the judge prompt is not ready), and known negatives
  (empty string, "I don't know", a confident wrong answer) that must all fail. Record the judge's model
  and usage separately from the feature's.
- **Living suite**: every production failure becomes a case; infra errors are not scored as model
  failures; the cost per run is measured before it becomes a CI gate. `/claude-api build-eval` runs the
  interview; the runner lives beside the tests (`tests/llm/` or the language's test dir).

## Cost and latency controls
1. **Caching first** — a stable prefix (frozen system prompt, sorted tools) and one breakpoint on the
   last stable block; measure `cache_read_input_tokens`.
2. **Effort per route** — `low` / `medium` for chat, classification and high-volume routes; `high` /
   `xhigh` for reasoning and agentic work; tune per route from a sample of real requests.
3. **Model per route** — the cheapest model that holds the eval; judge cost per completed task, not
   per request (a cheap call that needs retries is not cheap). Fewer models means more cache reuse
   (caches are model-scoped).
4. **Batches** for anything that can wait an hour (50 % off); token counting before big documents;
   `max_tokens` sized to the task; streaming so nothing waits for a whole answer.
5. **Loops**: a step and tool-call budget per agent run, `task_budget` (beta) so the model paces
   itself, compaction or context editing instead of resending everything.
6. **Limits**: per-user and per-tenant quotas (Unbounded Consumption), a monthly spend alert, 429
   handled with `retry-after`, no unbounded fan-out.

## Observability of LLM calls
Log one structured event per call (the observability reference, `observability.md`, holds the
stack-wide conventions): `request_id`, feature/route, model, effort, `usage.input_tokens`,
`output_tokens`, `cache_creation_input_tokens`, `cache_read_input_tokens`, latency, `stop_reason`
(and `stop_details.category` on refusals), tool calls (name, duration, `is_error`), the eval-set
version the prompt was tuned against. Prompt and completion **contents** are not logged by default
(PII, secrets, injected content); a sampled, redacted store with a retention period is a product
decision recorded in the product spec. Alerts: refusal rate, 429 / 5xx spikes, cost per day per
feature, p95 latency per route, tool error rate. Batch and connector calls carry the same fields.

## Security
Standard: **OWASP GenAI LLM Top 10 2026** (released 2026-08, GenAI Security Project; the 2025 edition
is archived): LLM01 Prompt Injection · LLM02 Sensitive Information Disclosure · LLM03 Excessive Agency ·
LLM04 Supply Chain · LLM05 Data and Model Poisoning · LLM06 Unbounded Consumption · LLM07 Misinformation ·
LLM08 Hidden Context Exposure (replaces System Prompt Leakage; covers retrieved documents, memory,
application state and tool responses) · LLM09 Vector and Embedding Weaknesses · LLM10 Improper Output
Handling. Entry names from the project's GitHub release listing; the canonical page
https://genai.owasp.org/resource/owasp-genai-llm-top-10-2026/ was unreachable at the time of writing —
verify there. `/threat-model` adds these as a surface (`references/llm-surface.md`); the paths
`**/prompts/**`, `**/llm/**`, `**/mcp/**` are security-sensitive (`rules/security-sensitive.md`).

| Threat | Where it enters | Mitigations |
|---|---|---|
| **Direct prompt injection / jailbreak** (LLM01) | The user's own input | A harmlessness / injection screen with `claude-haiku-4-5` and a boolean structured output before the main call; input validation against known patterns; a system prompt that states the boundaries and how to refuse; throttling and banning repeat offenders; the operator channel is `system` (top-level or `role: system`), never text pasted into a user turn |
| **Indirect prompt injection** (LLM01, LLM08) | Tool results, RAG documents, fetched web pages, e-mails, OCR text, MCP server responses and tool descriptions | Untrusted content **only inside `tool_result` blocks**, never in `system` or plain user text; say what it is and where it came from (tool description or result structure); JSON-encode third-party strings so a payload cannot close a tag; the system prompt states that tool / document / search content is data — instructions inside it are reported, never followed; screen tool outputs with the same small-model classifier before returning them; never place your own instructions in a tool result (a following user turn or a mid-conversation system message instead); red-team with poisoned documents before release |
| **Data exfiltration through tool calls** (LLM02, LLM03) | A tool that can reach the network or a store, driven by injected instructions | Least-privilege tools (no secret the feature does not need); egress allow-lists (`allowed_domains` on web tools, a host allow-list in own tools); no tool that both reads private data and writes to an external destination in the same context without confirmation; output filtering for keys and PII; the model never sees credentials — tool handlers hold them |
| **Excessive agency** (LLM03) | Agents with mutating tools (send, pay, delete, deploy, merge) | Read-only by default; every side effect behind a human confirmation the application enforces (not the prompt); step / tool-call / spend budgets; disposable sandboxes for code execution; no autonomous run on production data without an approved scope |
| **Insecure output handling** (LLM10) | Model output rendered, executed or queried | Treat output as untrusted input: context-aware escaping in HTML, parameterised queries, enumerated actions via structured output instead of free-form commands, paths canonicalised and confined to a root, a command allow-list (never a blocklist) with shell operators rejected, size and time limits |
| **Secrets and hidden context in prompts** (LLM02, LLM08) | System prompts, retrieved context, memory, tool responses | No API keys, tokens, connection strings or another user's data in any prompt; assume the system prompt leaks — nothing in it is a control; per-tenant retrieval filters before the context is built; the `secret-guard` hook blocks key-like strings written into prompt files |
| **Supply chain** (LLM04) | SDKs, MCP servers, model routers, prompt libraries, datasets | Pinned versions and image digests; `/dependency-audit` covers the MCP server list; review the tool list on every server update; SBOM includes servers |
| **Unbounded consumption** (LLM06) | Public chat, long documents, agent loops | Quotas per user / tenant / route, `max_tokens`, token counting before acceptance, loop budgets, spend alerts, rate limiting at the proxy |
| **Misinformation** (LLM07) | Answers presented as facts | Citations from `document` blocks where the answer must be grounded; the eval set measures factuality; a UI that marks generated content |
| **Vector / embedding weaknesses, poisoning** (LLM09, LLM05) | RAG stores, fine-tuning data | Tenant-scoped indexes with authorisation at query time; ingest only from allow-listed sources with provenance; content screening at ingestion; re-index on source revocation |

Logging (A09): every call and every tool execution is logged with the fields above; refusals and
suspected injections (`injection_suspected: true`) are surfaced to the user and alerted on.

## Review checklist (`/code-review --security`, `/security-audit`, `/threat-model`)
- [ ] technical-preferences § LLM features filled: provider/SDK, pinned model id, MCP role, eval set path, injection controls
- [ ] Official SDK, zero-argument client, no key in code, config or logs; `secret-guard` clean on `**/prompts/**`
- [ ] System prompt stable (cacheable), no secrets or per-user data in it; dynamic context injected in `messages`
- [ ] Untrusted content only in `tool_result` blocks, labelled with its source, JSON-encoded; policy stated in the system prompt
- [ ] Every tool least-privilege; side effects behind an application-enforced confirmation; allow-lists for hosts, paths, commands
- [ ] Model output validated before rendering / executing / querying; structured output or `strict` tools where the output drives code
- [ ] Tool loop handles `max_tokens`, `refusal`, `pause_turn`; `is_error` results returned, never dropped; parallel results in one message
- [ ] Budgets: `max_tokens`, effort per route, loop and spend limits, quotas per user; 429 with `retry-after`
- [ ] Eval set exists at the recorded path, provenance tagged, run before the change; judge caveats applied
- [ ] Per-call structured log without contents; alerts on refusal / 429 / cost
- [ ] MCP server (if any): auth, per-tool authorisation, rate limits, contract in the API contract, threat model row; MCP client (if any): servers pinned, tools allow-listed, tokens scoped, no token passthrough
- [ ] `/threat-model` has the LLM surface rows; `/dependency-audit` covers SDKs and servers
