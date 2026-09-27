---
paths: ["**/*.php"]
---
# PHP code rules
- `declare(strict_types=1)`; types everywhere; `readonly`, `final`, enums, constructor promotion; PHP 8.5 unless **Language/runtime** says 8.4.
- PER Coding Style 3.1 through the recorded tool (`php_cs_tool`); PSR-7/15/11/3 interfaces rather than concrete classes.
- Framework per `php_framework`; its reference file (`yii3.md`, `symfony.md`, `laravel.md`) or, for a stub, the official documentation named in the result. The framework lives in Infrastructure and the composition root only.
- Architecture per `php_architecture`: `framework` (the framework's layout, thin actions) or `layered` (`src/Domain` → `src/Application` → `src/Infrastructure`, inwards only, `composer arch-check`; ports in the domain; one class per use case with `execute`; rich models with `public private(set)` state and domain exceptions; actions and resolvers call use cases). The directory shape is the tree the layout ADR shows. A `layered` story reports the `coverage-gate` lines and the deptrac violation count. Details: `php.md` "Layered architecture".
- A value library the domain needs goes into `php_domain_allow` through technical-preferences and `/test-setup`, never into `deptrac.yaml` by hand.
- No logic in controllers, actions or config; schema changes only as migration files (`rules/database.md`).
- Errors: domain exceptions (incl. a domain `NotFoundException`) mapped to RFC 9457 in the error-handler middleware.
- Parameterised SQL; escaped output; CSRF on mutations; argon2id passwords.
- Logs: Monolog `StreamHandler('php://stdout')` + `JsonFormatter` + `PsrLogMessageProcessor`, one event per line with `time`, `level`, `msg`, `service`, `env`, `trace_id`, `span_id`, `request_id` (a processor reads the current span); PSR-3 `{placeholders}` with context, never interpolated strings; no PII, tokens or bodies.
- Metrics (when `metrics` in the Observability block of technical-preferences is not `none`): `promphp/prometheus_client_php` with the adapter recorded in `metrics` (APCu | Redis), `/metrics` on a route the proxy does not expose; names `<app>_<what>_<unit>[_total]`, histograms in seconds; labels from a bounded set — never ids, paths, IPs.
- Tracing (when `tracing` is not `none`): `open-telemetry/sdk` + `exporter-otlp` (OTLP/HTTP to the Collector), auto-instrumentation `opentelemetry-auto-psr15`/`psr18` (plus the framework package where it is ≥ 1.0), a span per use case and job; `traceparent` propagated on every outgoing call.
- For a service with an HTTP listener: `/healthz` returns without touching a dependency; `/readyz` checks DB, cache and migrations; neither returns secrets or versions. Details and the review checklist: `.claude/docs/stack-reference/observability.md`.
- Tests per `rules/tests.md` and `php.md` "Tests by layer"; `phpunit --filter` on the classes touched after each change, `composer ci` once before the result (`ci-full` with `composer audit` once per story).
- The recorded analyser (`php_static_analysis`) clean at its level on the lines the story's diff touches — a finding the story introduces is fixed in the same story; one that predates the branch (the same line red on `<base>`) is reported under *Outside the brief* (CLAUDE.md principle 9), never fixed in passing. Formatting is the post-edit hook's job.
- Reference: `.claude/docs/stack-reference/php.md`, then the framework file.
- Comments per `rules/comments.md`: a docblock only for what the signature cannot say (`array<int, Recipe>`, `@throws`, `@deprecated`) — never `@param string $name` repeating a typed parameter, never `@author`/`@package`/`@version`; the reason in the body, one paragraph; no story IDs or review history in code; `TODO(S-NNN):`/`TODO(I-NNN):` or no TODO. Slevomat `UselessFunctionDocComment`, `EmptyComment`, `ForbiddenComments`, `ForbiddenAnnotations` in `ecs.php` check the form.
