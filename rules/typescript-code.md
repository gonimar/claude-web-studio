---
paths: ["**/*.ts", "**/*.tsx", "**/*.mts", "**/*.js", "**/*.mjs"]
---
# TypeScript/JS rules
- `strict`; no `any` (except an explicitly justified `// eslint-disable-next-line` with a reason); types come from schemas (zod / GraphQL codegen / OpenAPI), never duplicated by hand.
- ESM; named exports; no import cycles; kebab-case files.
- Promises handled (`no-floating-promises`); typed errors; `AbortController` for cancellable requests.
- No secrets or env values in the client bundle except explicitly public ones (`VITE_*`/`NG_APP_*` are reviewed).
- Vitest test next to the module (`*.spec.ts`), behaviour over implementation.
- ESLint and `tsc` clean on the lines the story's diff touches — a finding the story introduces is fixed in the same story; one that predates the branch, like the neighbouring code's style, comments or dead code, is reported under *Outside the brief* (CLAUDE.md principle 9), never fixed in passing.
- Server logs (Node): `pino` to stdout with `redact` for `authorization`, `cookie`, passwords and tokens; one event per line with `time`, `level`, `msg`, `service`, `env`, `trace_id`, `span_id`, `request_id` (`@opentelemetry/instrumentation-pino`); event names with fields, never template-string prose; `console.log` only in scripts.
- Metrics (Node, when `metrics` in the Observability block of technical-preferences is not `none`): `@prometheus-io/client` `Registry` + `collectDefaultMetrics()`, `/metrics` on the internal server only; names `<app>_<what>_<unit>[_total]`, histograms in seconds; labels from a bounded set — never ids, paths, IPs.
- Tracing (Node, when `tracing` is not `none`): `@opentelemetry/sdk-node` initialised in a `--import`ed file before the framework, `auto-instrumentations-node`, OTLP/HTTP to the Collector from `OTEL_*` env; `traceparent` propagated on every outgoing call. Browser code sends no telemetry unless `technical-preferences` says so.
- For a service with an HTTP listener: `/healthz` returns without touching a dependency; `/readyz` checks DB, cache and migrations; neither returns secrets or versions. Details and the review checklist: `.claude/docs/stack-reference/observability.md`.
- Reference: `.claude/docs/stack-reference/typescript.md`.
- Comments per `rules/comments.md`: TSDoc on exported symbols — summary first, details under `@remarks`, no `@param {type}` (the signature has it); the reason in the body, one paragraph; no story IDs or review history in code; `TODO(S-NNN):`/`TODO(I-NNN):` or no TODO (`unicorn/expiring-todo-comments` with `allowWarningComments: false` rejects a bare one).
