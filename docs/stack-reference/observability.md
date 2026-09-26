---
updated: 2026-09-26
sources: [https://github.com/open-telemetry/opentelemetry.io/blob/main/data/instrumentation.yaml (opentelemetry.io/status), https://github.com/open-telemetry/opentelemetry.io/blob/main/content/en/docs/languages/php/_index.md, https://github.com/open-telemetry/opentelemetry.io/blob/main/content/en/docs/concepts/sampling/index.md, https://github.com/open-telemetry/opentelemetry.io/tree/main/content/en/docs/security (config-best-practices, hosting-best-practices, handling-sensitive-data), https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/logs/data-model.md, https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/trace/sdk.md, https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/configuration/sdk-environment-variables.md, https://github.com/open-telemetry/opentelemetry-proto/blob/main/docs/specification.md (OTLP), https://github.com/open-telemetry/semantic-conventions (docs/README.md, docs/http, docs/db, docs/graphql, docs/registry/attributes/deployment.md, tag v1.44.0), https://github.com/open-telemetry/opentelemetry-collector/blob/main/docs/security-best-practices.md, https://github.com/open-telemetry/opentelemetry-collector-releases (distributions/, tag v0.161.0), https://github.com/open-telemetry/opentelemetry-go/releases (v1.46.0, v1.47.0-rc.1), https://github.com/open-telemetry/opentelemetry-js/blob/main/README.md, https://github.com/prometheus/docs (docs/practices/naming.md, docs/instrumenting/clientlibs.md, docs/instrumenting/exposition_formats.md, docs/introduction/release-cycle.md), https://github.com/prometheus/prometheus (CHANGELOG.md, releases, tag v3.15.0), https://github.com/prometheus/client_js/blob/main/README.md, https://github.com/PromPHP/prometheus_client_php/blob/master/README.md, https://github.com/Seldaek/monolog/blob/main/doc/02-handlers-formatters-processors.md, https://github.com/pinojs/pino/blob/main/docs/api.md, https://proxy.golang.org, https://registry.npmjs.org, https://repo.packagist.org]
---
# Observability — logs, metrics, traces, health

The studio's operational contract for every service: **JSON logs to stdout**, **Prometheus metrics on `/metrics`**,
**OpenTelemetry traces over OTLP to a Collector**, **`/healthz` and `/readyz`**. `tooling-devops.md` names the pipeline
and the alerts; `kubernetes.md` wires the endpoints into probes. On the date the official sites (opentelemetry.io,
prometheus.io) were unreachable from the refresh environment, so every fact below comes from the projects' own source
repositories (the files the sites are rendered from), the registries and the git tag dates.

## Versions and status (2026-09-26)

### OpenTelemetry
| Component | Version on the date | Status by signal (opentelemetry.io/status data) |
|---|---|---|
| Specification: OTLP | `opentelemetry-proto` docs/specification.md | **Stable** for traces, metrics, logs; profiles in development |
| Semantic conventions | **v1.44.0** (2026-08-04); npm `@opentelemetry/semantic-conventions` 1.43.0 (2026-07-09) | HTTP spans **Stable**; database and HTTP READMEs "Mixed" (stable conventions behind `OTEL_SEMCONV_STABILITY_OPT_IN=database` / `http` during migration); GraphQL spans **Development** |
| Collector | **v0.161.0** (2026-09-16); distributions `otelcol`, `otelcol-contrib`, `otelcol-k8s`, `otelcol-otlp`, `otelcol-ebpf-profiler` | `otelcol-k8s` is built for monitoring a Kubernetes cluster and the services in it, OTLP exporters only |
| Go SDK | `go.opentelemetry.io/otel` + `sdk` + `sdk/metric` **v1.46.0** (2026-08-25); `log` + `sdk/log` v0.22.0; **v1.47.0-rc.1** (2026-08-28) is the release candidate that brings the logs API/SDK to v1; `contrib/instrumentation/net/http/otelhttp` v0.71.0, `contrib/bridges/otelslog` v0.20.1 (2026-08-26); `exporters/otlp/otlptrace/otlptracehttp` v1.46.0; `exporters/prometheus` v0.68.0 | traces **stable**, metrics **stable**, logs **release candidate**. The release notes say the next release requires at least Go 1.26 — fine with `go.md` (1.27/1.26) |
| JavaScript / Node SDK | `@opentelemetry/api` **1.9.1** (2026-03-25); stable SDK packages **2.11.0** (`sdk-metrics`, `sdk-trace-*`, 2026-08-31); experimental packages **0.222.0** (`sdk-node`, `sdk-logs`, `exporter-trace-otlp-http`, 2026-08-31); `auto-instrumentations-node` 0.80.0; `instrumentation-pino` 0.68.0 | traces **stable**, metrics **stable**, logs **development**. Supported runtimes: Node 22, 24, 26 — only Active or Maintenance LTS (`engines: ^18.19.0 || >=20.6.0` in the packages) |
| PHP SDK | `open-telemetry/sdk` **1.15.0** (2026-07-14), `api` 1.10.0, `exporter-otlp` 1.4.0 (2026-02-05); `opentelemetry-auto-psr15` 1.3.0, `opentelemetry-auto-psr18` 1.4.0, `opentelemetry-logger-monolog` 1.3.0, `opentelemetry-auto-symfony` 1.4.0, `opentelemetry-auto-laravel` 1.9.1, `opentelemetry-auto-yii` **0.4.0** (pre-1.0) | traces, metrics, logs all **stable**. Packages require `php ^8.1`; the SDK follows php.net supported versions; auto-instrumentation requires PHP 8.0+ (the `opentelemetry` extension — unverified on the date, check https://opentelemetry.io/docs/zero-code/php/) |

Defaults that matter (SDK environment-variable spec): sampler `parentbased_always_on` (= `ParentBased(root=AlwaysOn)`),
propagators `tracecontext,baggage` (W3C `traceparent`), `OTEL_SERVICE_NAME` sets `service.name`,
`OTEL_RESOURCE_ATTRIBUTES` the rest (`service.version`, `deployment.environment.name` — stable attribute).
OTLP ports: **4317** gRPC, **4318** HTTP; HTTP paths `/v1/traces`, `/v1/metrics`, `/v1/logs`; body
`application/x-protobuf` or `application/json`.

### Prometheus
- **Prometheus 3.15.0** (2026-09-25); **LTS 3.13** (2026-07-01) — an LTS line receives fixes for high-severity issues for
  one year; a minor release cycle is six weeks and an ordinary minor stops receiving fixes after that.
- Client libraries listed as official by prometheus.io: Go `prometheus/client_golang` **v1.24.1** (2026-07-24), Node.js
  `prometheus/client_js` — published on npm as **`@prometheus-io/client` 0.16.1** (2026-08-27, `engines: ^22 || ^24 || >=26`;
  "previously published as `prom-client`", whose last version is 15.1.3 of 2024-06-27 — new code uses the new name).
  PHP is third-party: **`promphp/prometheus_client_php` v2.15.1** (2026-05-28, `php ^8.2`), storage adapters Redis, Predis,
  APCu, APCng, in-memory — PHP workers need Redis or APCu so the counters survive the request.
- Exposition: the text format (`Content-Type: text/plain; version=0.0.4`) is what every client library serves; protobuf by
  HTTP content negotiation; OpenMetrics status on the date: unverified — check https://prometheus.io/docs/instrumenting/exposition_formats/.

### Logging libraries
- Go: `log/slog` (standard library; `go.md`) with `slog.NewJSONHandler`.
- PHP: **`monolog/monolog` 3.12.0** (2026-09-09) with `JsonFormatter`, `PsrLogMessageProcessor` (PSR-3 `{placeholders}`),
  `UidProcessor`; `open-telemetry/opentelemetry-logger-monolog` when logs should also travel over OTLP.
- Node: **`pino` 10.3.1** (2026-02-09) — JSON by default, `redact` option (paths removed before serialisation), `messageKey`, `timestamp`.

## Studio default set
| Concern | Choice | Why |
|---|---|---|
| Log format | One JSON object per line to stdout; keys `time` (RFC 3339, UTC), `level`, `msg`, `service`, `env`, `trace_id`, `span_id`, `request_id`, then the event's own fields; PSR-3 / slog / pino levels mapped to `debug`/`info`/`warn`/`error` | Collected by whatever the host runs (Loki/Vector, Collector `filelog`, `kubectl logs`) without a parser per service; the trace ids make a log line findable from a trace |
| Log content | Events, not prose: `user.login.failed` with fields, never `"Login failed for " + email`; errors with `error` (message) and `error.type`; no stack traces at `info` | Aggregation and alerts key on fields; the message text stays stable |
| Metrics | The Prometheus client library of the language on **`/metrics`**, pull, served on the **internal listener/port**, never behind the public proxy; RED per service (`http_requests_total{method,route,status_class}`, `http_request_duration_seconds` histogram), plus the domain's counters and queue/worker gauges | One dependency, the naming rules below, the same scrape config for every service, and the metrics feed the HPA (`kubernetes.md`). OTel metrics via `exporters/prometheus` are the alternative once a Collector is the only scrape target |
| Tracing | OpenTelemetry SDK from the first service; **OTLP/HTTP to a Collector** (`localhost:4318` in compose, the `otelcol-k8s`/`otelcol-contrib` service on Kubernetes), never straight from the app to a vendor; auto-instrumentation for HTTP server/client and the database driver, manual spans for use cases and jobs | The Collector owns credentials, retries, tail sampling and the backend (Tempo/Jaeger/vendor) — the app only knows one endpoint. A single service still benefits: `trace_id` in logs and DB spans |
| Sampling | dev/staging `parentbased_always_on`; prod `parentbased_traceidratio` with `OTEL_TRACES_SAMPLER_ARG` (start at `0.1`) and, when the volume needs it, the Collector `tail_sampling` processor keeping every trace with an error or over the latency budget | Head sampling is cheap but cannot keep "all errors"; tail sampling can, at the price of a stateful Collector — the concepts page's trade-off |
| Health | **`/healthz`** — liveness, the process only: 200 when the server loop runs, no dependency calls; **`/readyz`** — readiness: 200 when the DB, cache and pending migrations are fine, 503 with `{ "status": "fail", "checks": { "db": "ok", "cache": "fail" } }` otherwise; both without secrets, versions, hostnames | Kubernetes restarts on liveness and pulls traffic on readiness (`kubernetes.md`); a liveness that checks the DB turns a DB blip into a restart storm (the probes page's caution) |
| Correlation | `request_id` = the trace id of the active span (a generated UUIDv7 when tracing is off), echoed as `X-Request-Id`; `traceparent` propagated to every outgoing HTTP/gRPC call and queue message | One id from the browser's network tab to the log line and the trace |
| Cardinality | Labels and span attributes come from a **bounded set known at deploy time**: route template (`/users/{id}`), method, status class, queue name, job type; never raw paths, query strings, user ids, emails, IPs, session ids | Every new label value is a new time series; unbounded labels take Prometheus down and make traces unsearchable |
| Resource attributes | `service.name`, `service.version` (the release tag), `deployment.environment.name` via `OTEL_RESOURCE_ATTRIBUTES` — the same values as the `service`/`env` log keys | Semantic conventions: dashboards and alerts key on the same three names for every service |

## Idioms by language
- **Go**: `slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{Level: level}))` in `internal/app`; a small `slog.Handler`
  wrapper adds `trace_id`/`span_id` from `trace.SpanContextFromContext(ctx)` — the `otelslog` bridge is for exporting log
  records over OTLP, not for the stdout line. `otelhttp.NewHandler` on the router, `otelhttp.NewTransport` on clients,
  `promhttp.Handler()` on the internal mux; a `prometheus.Registry` of the app's own, not the global one, so tests can
  create it twice. Histograms in seconds with `prometheus.DefBuckets` unless the SLO says otherwise.
- **PHP**: `Monolog\Logger` with `StreamHandler('php://stdout')` + `JsonFormatter` + `PsrLogMessageProcessor`; a processor
  reads the active span (`OpenTelemetry\API\Trace\Span::getCurrent()`) into `trace_id`/`span_id`. Tracing through the
  `opentelemetry-auto-*` package of the recorded `php_framework` (PSR-15 for Yii3 and Slim — the Yii auto-package is 0.4.0,
  pre-1.0, so PSR-15 + PSR-18 are the stable pair); metrics via `promphp` with the APCu or Redis adapter on a
  `/metrics` route the proxy does not expose.
- **Node/TS**: `pino({ level, redact: ['req.headers.authorization', 'req.headers.cookie', '*.password'] })` as the app logger;
  `@opentelemetry/sdk-node` initialised in a `--import`ed file before the framework loads, `auto-instrumentations-node`
  for HTTP/pg/redis, `@opentelemetry/instrumentation-pino` for `trace_id`/`span_id` in the lines; `@prometheus-io/client`
  `Registry` + `collectDefaultMetrics()` on the internal server. Logs SDK is `development` — stdout JSON stays the log path.
- **Everywhere**: metric names `<app>_<what>_<unit>[_total]` — a single-word application prefix, base units (`seconds`, `bytes`),
  the unit suffix in plural, `_total` for accumulating counts, `_info` for build metadata; one metric = one unit and one
  quantity, `sum()`/`avg()` over the labels must mean something (prometheus.io naming practices).

## Security notes
- **No PII in spans, attributes or log lines** (opentelemetry.io "Handling sensitive data": data minimisation, `user.id` → a
  hash, truncated IPs, `user.email` deleted). Request bodies, query strings, `Authorization`/`Cookie` headers, tokens and
  passwords are never attributes; `redact` (pino), a Monolog processor and a slog `ReplaceAttr` strip them at the source, the
  Collector `redaction` processor is the second net, not the first.
- **The Collector is not a public endpoint**: receivers bind to the pod IP or `localhost`, never `0.0.0.0`; TLS on
  (`insecure: false` is the component default); the bearer-token or basic-auth extension in front of OTLP receivers on a
  shared network; the Collector runs as a non-root user with the least privilege its components need; its config holds
  tokens and certificates, so it is a secret (`kubernetes.md` § Secrets), not a ConfigMap.
- **`/metrics` is not public**: it lists routes, versions and load; served on the internal port and denied at the proxy /
  Gateway; scraped inside the network only.
- **Health responses carry no secrets, versions or hostnames**; `/readyz` names checks (`db`, `cache`) but not connection
  strings or error text.
- Log lines are evidence: no secrets, no full card or token values even at `debug`; `debug` never on in production by default.
- Third-party client libraries (`promphp`) get the same dependency review as any other package (`/dependency-audit`).

## Review checklist
1. Every service logs JSON to stdout with `time`, `level`, `msg`, `service`, `env`, `trace_id`, `span_id`, `request_id`; no prose messages with interpolated values.
2. `/healthz` touches no dependency; `/readyz` checks DB, cache and migrations; neither returns secrets, versions or hosts.
3. `/metrics` is on the internal listener and not routable from outside; RED metrics exist per HTTP service; names follow prefix + base unit + suffix; histograms in seconds.
4. Labels and attributes are bounded (route templates, status class, job type) — no ids, emails, IPs, query strings.
5. The OTel SDK is initialised before the framework, exports OTLP/HTTP to a Collector endpoint from configuration (`OTEL_EXPORTER_OTLP_ENDPOINT`), and `service.name`/`service.version`/`deployment.environment.name` are set.
6. `traceparent` is propagated on every outgoing call and queue message; `X-Request-Id` is returned.
7. Production sampling is configured (`parentbased_traceidratio` + arg; tail sampling for errors when a Collector runs).
8. Sensitive fields are redacted at the source (headers, bodies, tokens, PII); a test asserts the redaction.
9. The Collector config is a secret, bound to non-public interfaces, TLS on, auth on shared networks, non-root.
10. Versions pinned: OTel SDK packages, Prometheus client, logging library — the lockfile, not a range; the JS experimental (`0.x`) packages move together and are bumped together.
