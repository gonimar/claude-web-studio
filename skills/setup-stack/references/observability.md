# Observability — read from Phase 2 step 7, after the deploy target

Reference: `.claude/docs/stack-reference/observability.md` (versions, the studio default set, the review checklist). The answer fills the `Observability` block of technical-preferences: the headline choice and the four fields `log_format`, `metrics`, `tracing`, `health_endpoints`.

- **Observability**, one `AskUserQuestion`, recommendation first:
  - **studio stack** (Recommended): JSON logs to stdout (Go `log/slog` | PHP monolog `JsonFormatter` | Node pino), Prometheus `/metrics` on the internal listener (`client_golang` | `promphp/prometheus_client_php` | `@prometheus-io/client`), OpenTelemetry traces over OTLP/HTTP to a Collector, `/healthz` + `/readyz`. Fields: `log_format: json`, `metrics: prometheus`, `tracing: opentelemetry`, `health_endpoints: /healthz + /readyz`.
  - **minimal**: JSON logs and `/healthz` + `/readyz` only — a PoC, a static site, a tool without traffic. Fields: `metrics: none`, `tracing: none`; the reason is recorded with the value.
  - **custom**: the owner names what differs (an existing vendor SDK, a platform that ships its own agent); every field gets a value and the reason.
- PHP with the studio stack → one follow-up: the `promphp` storage adapter — **APCu** (Recommended for PHP-FPM/FrankenPHP on one host) | Redis (several hosts, or Redis already in the stack). Recorded inside `metrics`.
- The production sampler ratio is not asked here: `tracing` records `parentbased_traceidratio <ratio>` with the reference's starting value (`0.1`); `/perf-audit` and `/incident` revise it.
- Versions come from the reference at question time (Phase 1 read `index.md`); the question quotes none of its own.
- `--quick`: takes the studio stack (and APCu for PHP) without asking.
