---
updated: 2026-09-26
sources: [https://laravel.com/docs/13.x (unreachable on the date — read from its source https://github.com/laravel/docs branch 13.x: releases, upgrade, structure, configuration, deployment, testing, database-testing, eloquent, eloquent-resources, validation, authorization, sanctum, fortify, queues, horizon, scout, pennant, octane, sail, csrf, database), https://github.com/laravel/framework (13.x composer.json, security advisories), https://github.com/laravel/laravel (README "Security Vulnerabilities"), https://github.com/driftingly/rector-laravel, https://repo.packagist.org/p2/laravel/framework.json (and laravel/octane, laravel/horizon, laravel/sanctum, laravel/fortify, laravel/scout, laravel/pennant, laravel/installer, laravel/boost, pestphp/pest, rector/rector)]
---
# Laravel — the framework reference (`php_framework: laravel`)

The language, the layers, the tests and the tooling live in `php.md` and apply to every PHP project; this
file is only what is specific to Laravel. Under `php_architecture: layered`, Laravel is an Infrastructure
detail: controllers, Form Requests, Eloquent adapters, jobs and the providers as composition root; `App\Domain`
and `App\Application` import nothing from `Illuminate\` or `Laravel\` (deptrac layer `Framework`, see "deptrac"
below) — no facades, no `Model`, no helpers such as `app()`/`config()`/`now()` there. Under `php_architecture:
framework` Laravel's own layout applies (`app/Http`, `app/Models`, `app/Jobs`, `app/Policies`, …) with thin
controllers and the rules of `php.md`; Laravel "imposes almost no restrictions on where any given class is
located — as long as Composer can autoload the class" (structure docs), which is what makes the layered tree possible.

## PHP (summary — the full section is in `php.md`)
Minimum 8.4, target 8.5; `declare(strict_types=1)`, `readonly`, enums, `final`, property hooks and `public private(set)`;
PER-CS 3.1; PHPUnit 13; the analyser, the coding-standard tool, deptrac and the per-layer coverage gate are recorded in
technical-preferences and described in `php.md`. Laravel 13 requires PHP ^8.3 (`laravel/framework` `composer.json`)
and is tested on 8.3–8.5 (release notes) — the studio floor (8.4) and target (8.5) both run it.

## Versions and support (release notes and packagist, 2026-09-26)
"Major framework releases are released every year (~Q1), while minor and patch releases may be released as often as
every week. Bug fixes are provided for 18 months and security fixes are provided for 2 years." (release notes)

| Version | PHP | Released | Bug fixes until | Security fixes until |
|---|---|---|---|---|
| **13** — current | 8.3–8.5 | 2026-03-17 (`laravel/framework` 13.33.0 on 2026-09-22) | Q3 2027 | 2028-03-17 |
| 12 | 8.2–8.5 | 2025-02-24 (12.69.2 on 2026-09-08) | ended 2026-08-13 | 2027-02-24 |
| 11 | 8.2–8.4 | 2024-03-12 | ended 2025-09-03 | ended 2026-03-12 |
| 14 | | expected ~Q1 2027 per the cadence — unverified — check https://laravel.com/docs/releases | | |

**New projects: 13 on PHP 8.5.** A 12 project is security-only since 2026-08-13 — the 12 → 13 story is due (the upgrade
guide estimates the core steps at "10 Minutes"); an 11 project is out of support and upgrades one major at a time.

Laravel 13 headline changes that touch the studio's rules: request forgery protection with origin verification
(`PreventRequestForgery`), class-based queue routing (`Queue::route()`), more PHP attributes on controllers, jobs and
authorization, JSON:API resources, `Cache::touch()`, the `serializable_classes` cache hardening, and the Laravel AI SDK
(not part of the studio stack — an ADR if a project wants it).

## Studio default set
| Task | Choice | Why |
|---|---|---|
| Version | **13**; `laravel/installer` 5.32 or `composer create-project laravel/laravel`; no starter kit for an API-only service, a starter kit only when the project ships Blade pages | The studio's front is Angular/Vue (`angular.md`/`vue.md`); the API talks Sanctum cookies or tokens (below) |
| Runtime | **PHP-FPM + nginx or FrankenPHP classic mode** (`php.md`); **Octane** (`laravel/octane` 2.20, FrankenPHP server) only by ADR after a measured latency need | Octane keeps the app in memory: a singleton that captured the container or the request serves stale instances, static arrays leak — every service becomes worker-safe by design, which is a review cost the ADR names |
| Local environment | The studio's `compose.yaml` (`tooling-devops.md`: Postgres, Redis, Mailpit, profile `test`) — **not Sail** | Sail is "a light-weight command-line interface for interacting with Laravel's default Docker development environment", MySQL-first and local-only; the studio runs one compose file for dev, test and CI |
| Test runner | **PHPUnit 13** (`laravel/framework` 13 tests against `^11.5.50 || ^12.5.8 || ^13.0.3`); **Pest 5** (5.2.1, PHP ≥ 8.4, PHPUnit ^13.3.4) when the project prefers the `it()` style — recorded in technical-preferences **Unit** as `PHPUnit 13 + Pest 5`, composer `test`/`test:coverage` call `pest` | Aligned with `php.md`; both runners are supported "out of the box" and `php artisan test` drives either; the upgrade guide's `phpunit ^12`/`pest ^4` are minimums, not targets |
| Persistence | **Eloquent as the Infrastructure adapter**: models under `App\Infrastructure\Persistence\Eloquent\` (`#[Table]`, `#[Fillable]`, `HasUuids` for UUIDv7 ids), repositories implementing the domain ports and mapping model ↔ entity (`Entity::fromState()`); `database/migrations/` for schema. Under `framework`: models are the model, `Model::shouldBeStrict()` in `AppServiceProvider` | An Eloquent model is Active Record — persistence, events and casts in one class — so it cannot be the rich model `php.md` asks for; the mapping costs one class per aggregate and buys a domain the framework cannot reach |
| Use cases | **One class per use case** (`App\Application`) — not "Action" packages, not `app/Services` grab-bags; under `framework`: single-action controllers (`__invoke`) delegating to one service class per scenario | The shape `php.md` defines; Laravel adds nothing here |
| Boundary validation | **Form Requests** (`make:request`): `rules()` for the shape, `authorize()` delegating to a policy, `$request->validated()`/`safe()` copied into the use case's `Input` DTO; API responses are the framework's 422 JSON | The Form Request is the transport DTO plus validation in one class; `#[StopOnFirstFailure]` only for the login form |
| Authorization | **Policies** per aggregate (`make:policy --model`, auto-discovered, `#[UsePolicy]` when the names differ) and **Gates** for non-model actions; `Gate::authorize()` in the Form Request or the controller, `can:` middleware on routes, `Response::deny('…')` with a reason | "Policies should be used when you wish to authorize an action for a particular model or resource" — one class per aggregate the review can read |
| Authentication | **Sanctum** (4.3): SPA cookie mode for the studio's Angular/Vue front on the same site (`stateful` domains, `/sanctum/csrf-cookie`, `XSRF-TOKEN`), token mode (`createToken(abilities)`, `expiration` set, `sanctum:prune-expired`) for mobile and third parties — never both for one SPA; **Fortify** (1.40) as the headless auth backend (login, registration, reset, verification, TOTP 2FA, passkeys, `EnsureLoginIsNotThrottled`) when the project owns its auth screens; Passport only for an OAuth2 server by ADR | Cookie sessions keep tokens out of JavaScript; Fortify replaces hand-rolled auth (`php.md`) without imposing a UI |
| Queues | **Redis driver + Horizon** (5.50) in production, `database` driver for a small service without Redis; jobs are Infrastructure classes calling a use case; `#[Tries]`, `#[Timeout]`, `retryUntil()`, `ShouldBeUnique`/`#[UniqueFor]`, `afterCommit()`, `WithoutOverlapping`/`RateLimited` middleware; `Queue::route()` in a provider; `queue:restart`/`horizon:terminate` on deploy | "Horizon requires that you use Redis to power your queue"; long work is re-scheduled, never `sleep()` (`php.md`) |
| Search | **Scout** (11.8) only when the story needs full-text search: `database` driver (Postgres full-text) first, Meilisearch/Typesense by ADR, `queue => true`; semantic search via `pgvector` by ADR | A driver behind the `Searchable` trait keeps the search engine an Infrastructure swap |
| Feature flags | **Pennant** (1.26) with the `database` driver, class-based features (`pennant:feature`), `EnsureFeaturesAreActive` middleware | A flag lets a story ship dark and be switched per user or team; one first-party package |
| API output | `JsonResource`/`ResourceCollection` as output DTOs (`whenLoaded`, `withoutWrapping()` decided once); `make:resource --json-api` (`JsonApiResource`) when the contract is JSON:API; errors as RFC 9457 through `withExceptions()` | A resource shapes the contract; the domain entity is never serialised directly |
| REST vs GraphQL | REST with OpenAPI at `api_contract_path`; GraphQL through `webonyx/graphql-php` with the SDL (`php.md`, `graphql.md`) — Lighthouse only by ADR | Contract-first per `graphql.md` |

## Where the layers live (`php_architecture: layered`)
Laravel's root namespace `App\` maps to `app/`, so the layered tree lives at **`app/Domain`, `app/Application`,
`app/Infrastructure`** next to the framework's own `app/Http`, `app/Providers`, `app/Console` — and every PHP template
gets `app` instead of `src` (deptrac `paths`/collectors, analyser and standard-tool paths, `phpunit.xml` `<source>`,
`coverage-gate.php --root=app`). A second PSR-4 root (`src/` → `App\Domain`) is an alternative a project may record;
`artisan make:*` and the IDE then need the extra path.

| Layer | Laravel place | Idioms |
|---|---|---|
| Domain | `app/Domain/<Context>/` | Plain PHP (`php.md`): entities with `public private(set)` state, value objects, domain exceptions, ports; no `Model`, no `Carbon` (`DateTimeImmutable`; `Carbon\` only via `php_domain_allow`), no `Str`/`Arr`/`collect()` |
| Application | `app/Application/<Context>/` | One class per use case, `execute(Input): Output`; a transaction port instead of `DB::transaction()`; an event port instead of `Event::dispatch()`; a queue port (`enqueue(Command)`) instead of `Job::dispatch()` |
| Transport | `app/Infrastructure/Transport/Http/` (or `app/Http/` under `framework`) — invokable controllers, Form Requests, Resources, middleware; `routes/api.php` with `Route::post(...)->name(...)` and `can:` middleware; `bootstrap/app.php` `->withMiddleware()`, `->withExceptions()` | A controller: Form Request → `Input` → use case → Resource; no query builder in a controller |
| Persistence | `app/Infrastructure/Persistence/Eloquent/` — models and repository adapters; `database/migrations/` (`make:migration`, reviewed; `rules/database.md`); `database/factories/` for the models (tests) | `Model::shouldBeStrict(! app()->isProduction())` — `preventLazyLoading`, `preventSilentlyDiscardingAttributes`, `preventAccessingMissingAttributes` — in `AppServiceProvider::boot()` |
| Jobs / events | `app/Infrastructure/Queue/` jobs (`ShouldQueue`, `Queueable`) implementing the queue port and calling use cases; `app/Infrastructure/Events/` listeners bridging Laravel events to domain events | Idempotent handlers keyed by business ids; `afterCommit()` for jobs dispatched inside a transaction |
| Errors | `bootstrap/app.php` `->withExceptions(fn (Exceptions $e) => $e->render(fn (DomainException $x, Request $r) => problem($x)))` — RFC 9457 `application/problem+json`; the domain `NotFoundException` → 404, `ValidationException` stays the framework's 422 | One place, not a try/catch per controller; `dontReport()` for expected domain exceptions |
| Composition root | `app/Providers/AppServiceProvider.php` (`$this->app->bind(XRepositoryInterface::class, EloquentXRepository::class)`, `singleton()` for stateless adapters), `bootstrap/app.php`, `bootstrap/providers.php`, `config/*.php`, `routes/*.php`, `public/index.php` | Bindings are explicit, one line per port; contextual binding (`when()->needs()->give()`) for a port with two adapters |
| Tests | `tests/Unit/{Domain,Application}` extend PHPUnit's `TestCase` (not Laravel's) — no application boot; `tests/Integration/` (`RefreshDatabase`, factories, `Queue::fake()`, `Http::fake()`); Laravel's `tests/Feature` name is fine when the project keeps it, the rule is the same | `php.md` "Tests by layer" |

## deptrac
`FRAMEWORK_NAMESPACES` = `Illuminate\\|Laravel\\` in `docs/templates/php/deptrac.yaml`; `paths` is `./app` for a Laravel
root, and the framework's own directories (`app/Http`, `app/Providers`, `app/Console`, `app/Models` under `framework`)
are uncovered on purpose — never `--fail-on-uncovered`. Global helpers (`app()`, `config()`, `now()`, `collect()`,
`dispatch()`) are functions, invisible to deptrac's class collectors: `grep -rnE '\b(app|config|now|collect|dispatch|resolve|event|cache|request|auth)\(' app/Domain app/Application` is part of the arch check under `layered`.

## Configuration and secrets
- `.env` is never committed, `.env.example` is; `APP_ENV`, `APP_KEY` (`key:generate`, rotated through a story), `APP_DEBUG=false` on every non-dev host — "you risk exposing sensitive configuration values to your application's end users" (configuration docs), and the 2026-09-10 advisory GHSA-jh5r-qr3c-85q8 (XSS in the debug page) is the same lesson.
- **`env()` only inside `config/*.php`**: after `config:cache` the `.env` file is not loaded and `env()` returns only real environment variables — a call in `app/` is a finding; typed reads in code through injected config objects or a settings port.
- `.env.testing` for the test run (`APP_ENV=testing` set by `phpunit.xml`); `php artisan env:encrypt`/`env:decrypt` (`LARAVEL_ENV_ENCRYPTION_KEY`, `--readable`) when an environment file must travel through git or a ticket; production values come from the host or the secret store (`tooling-devops.md`), never from a committed file.
- `php artisan down --with-secret` for maintenance; `/up` is the health route the deploy checks.

## Testing (in addition to `php.md` "Tests by layer")
- `php artisan test` (`--parallel` with `brianium/paratest`, `--coverage` with pcov/xdebug, `--min=<percent>` as a second gate next to `coverage-gate.php`, `--profile` for slow tests); `vendor/bin/pest` or `vendor/bin/phpunit` directly in `composer test`.
- Laravel's advice "most of your tests should be feature tests" is the `framework`-architecture rule; under `layered` the per-layer table of `php.md` applies: Domain and Application unit tests without the application booted (PHPUnit's `TestCase`, not `Tests\TestCase`), adapters and HTTP under `tests/Integration` (`RefreshDatabase` — a transaction per test; `DatabaseMigrations`/`DatabaseTruncation` only when a test needs a committed state, they are "significantly slower").
- Factories for Eloquent models (`Model::factory()->count()->state()->create()`, `#[Seed]` on a class that needs the seeder); a domain entity in a unit test is built through its named constructor, never a factory.
- Fakes over mocks at the framework edge: `Queue::fake()`/`Bus::fake()` (`assertPushed`), `Event::fake()`, `Http::fake()`, `Mail::fake()`, `Notification::fake()`, `Storage::fake()`, `Feature::define()` for Pennant; `$this->actingAs($user, 'sanctum')` for API tests; `assertDatabaseHas()`, `assertModelExists()`, `expectsDatabaseQueryCount()` for N+1 regressions.
- `Model::shouldBeStrict()` is on in tests (the provider's `! isProduction()`), so a lazy load fails the suite instead of shipping.

## Performance
- Deploy: `composer install --no-dev --optimize-autoloader`, `php artisan optimize` (config, events, routes, views in one — `optimize:clear` to undo), `php artisan migrate --force`, `queue:restart`/`horizon:terminate`; OPcache per `php.md` (`validate_timestamps=0` in containers).
- Eloquent: eager loading (`with()`), `preventLazyLoading` on outside prod, `chunkById()`/`lazyById()` for batches, `select()` instead of `*`, indexes in the migration that adds the query (`database.md`); `Cache::remember()` behind a cache port, `Cache::touch()` (13) to extend a TTL without rewriting.
- **Octane** (by ADR): FrankenPHP server, `octane:install`, Supervisor, nginx in front for TLS and static files; the caveats are code rules — no container or request captured in a singleton's constructor (resolve at call time), no static accumulators, `octane:reload` on deploy.
- Horizon's dashboard (behind its gate) and `--profile` are the first numbers; `performance-engineer` decides on more.

## Security (Laravel-specific — the PHP list is in `php.md`)
- **Mass assignment**: every model declares `#[Fillable([...])]` (or `$fillable`); `#[Unguarded]`/`Model::unguard()` is a finding outside seeders; JSON columns list each key (`'options->enabled'`); `preventSilentlyDiscardingAttributes()` outside prod turns a typo into an exception; the use case's `Input` DTO — not `$request->all()` — is what reaches a model.
- **Raw SQL**: "you should never allow user controlled values within an unprepared statement" — `DB::unprepared()` never with input; `whereRaw`/`selectRaw`/`orderByRaw` only with bindings and never for column or table names from the request (validate against an allow-list); the query builder and Eloquent bind everything else.
- **CSRF**: the `web` group's `PreventRequestForgery` (13) checks `Sec-Fetch-Site` first and falls back to the `_token`/`X-CSRF-TOKEN`/`X-XSRF-TOKEN` token; `@csrf` in every Blade form; `preventRequestForgery(except: [...])` only for webhooks with their own signature check; `originOnly: true` only by ADR; Sanctum's SPA mode reuses it through the `XSRF-TOKEN` cookie.
- **Deserialization**: the cache `serializable_classes` allow-list (13) is set and kept small; `unserialize()` on user data is a finding (`php.md`); signed URLs (`URL::signedRoute`, `signed` middleware) for e-mail links — GHSA-crmm-hgp2-wgrp (2026-06-08, path confusion in temporary signed URLs) means the framework stays patched.
- **Auth/authz**: Sanctum tokens hashed at rest with abilities and expiration; Fortify's login throttling on every password endpoint; a policy method for every action a controller exposes (`can:` middleware or `Gate::authorize`), `?User` only where guests are intended; passwords through `Hash::make` (bcrypt/argon2id per `config/hashing.php`).
- **Validation rules**: `email` uses the default validator — GHSA-5vg9-5847-vvmq (2026-06-01, CRLF injection in the default email rule) is fixed in current 12/13 releases; `file`/`mimes` checks by content (`php.md`).
- `composer audit` in CI, `roave/security-advisories` in require-dev; **advisories**: https://github.com/laravel/framework/security/advisories; vulnerabilities are reported privately to the maintainers as the `laravel/laravel` README "Security Vulnerabilities" section says, never as an issue.

## Upgrade path
- One major per year; the upgrade guide (`docs/upgrade`) lists changes by impact — 12 → 13: dependencies (`laravel/framework ^13.0`, `laravel/tinker ^3.0`, `laravel/boost ^2.0`, PHPUnit/Pest), the renamed CSRF middleware, `serializable_classes`, `upsert` on MySQL/MariaDB requiring `uniqueBy`.
- Order of a story: (1) the last 12.x patch, tests green, (2) constraints bumped, `composer update`, (3) the guide's high- and medium-impact items, (4) `php artisan optimize:clear`, `composer ci`, (5) the deprecation output of PHPUnit (`failOnDeprecation`) empty.
- **Rector 2** with `driftingly/rector-laravel`: `->withComposerBased(laravel: true)` (reads the installed version), `LaravelLevelSetList::UP_TO_LARAVEL_130` for a stepwise brownfield run, `LaravelSetList::LARAVEL_CODE_QUALITY`, `LARAVEL_STATIC_TO_INJECTION` (facades → constructor injection — the `layered` migration's first tool), `LARAVEL_ARRAY_STR_FUNCTION_TO_STATIC_CALL`.
- **Laravel Shift** is the paid, community-maintained upgrade service the upgrade guide names; its shift list was unverifiable on the date — check https://laravelshift.com; a Shift PR is reviewed like any other diff (`/code-review`), never merged unread.

## Laravel review checklist (in addition to `php.md`)
1. no `Illuminate\`/`Laravel\` import and no global helper (`app()`, `config()`, `now()`, `collect()`, `dispatch()`) in `app/Domain` or `app/Application`; no facade outside Infrastructure; 2. a Form Request per mutation with `rules()` and `authorize()`, the use case fed an `Input` DTO from `validated()` — never `$request->all()` into a model; 3. every model `#[Fillable]`, `shouldBeStrict()` on outside prod, no `unguard()`; Eloquent models under `layered` only inside `app/Infrastructure/Persistence`; 4. a policy method behind every exposed action (`can:` or `Gate::authorize`), Sanctum mode consistent (cookies or tokens, not both for one SPA), token expiration set; 5. jobs idempotent with `#[Tries]`/`retryUntil()`, `afterCommit()` inside transactions, `ShouldBeUnique` where a duplicate is harmful, Horizon or a worker restart in the deploy; 6. `env()` only in `config/`, `APP_DEBUG=false` in prod, `optimize` in the deploy, `.env` untracked; 7. raw SQL only with bindings, no request-driven column names, migrations reviewed (`rules/database.md`); 8. tests: no application boot under `tests/Unit`, `RefreshDatabase` only in integration tests, fakes at the edge, `expectsDatabaseQueryCount()` on list endpoints; 9. `composer audit` clean, the advisories page checked when `laravel/*` is pinned below latest.
