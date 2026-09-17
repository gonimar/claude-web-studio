---
updated: 2026-09-17
sources: [https://www.php.net/releases/8.4/en.php, https://php.watch/versions, https://www.php-fig.org/per/coding-style/, https://www.php-fig.org/psr/, https://phpunit.de/supported-versions.html, https://docs.phpunit.de, https://phpstan.org/user-guide/rule-levels, https://psalm.dev/docs, https://github.com/deptrac/deptrac, https://github.com/easy-coding-standard/easy-coding-standard, https://github.com/PHP-CS-Fixer/PHP-CS-Fixer, https://github.com/phparkitect/arkitect, https://webonyx.github.io/graphql-php/, packagist.org]
---
# PHP 8.5 — the language, the layers, the tests (framework-independent)

This file is about PHP itself. The framework is a separate choice recorded as `php_framework` in
technical-preferences, with its own reference file when the studio has one: `yii3.md` (Yii3 —
the only framework reference today). Symfony, Laravel, Slim and "none" are valid choices: `php-engineer`
then works from the framework's official documentation, says so in every result, and everything below
still applies — the framework is an Infrastructure detail, never the shape of the code.

## Language by version (so we do not write old-style code)
- **8.5 (2025-11-20, bug fixes until 2027-12-31)**: pipe operator `|>`; `clone()` with property updates; `#[\NoDiscard]`; `array_first()/array_last()`; the **URI** extension (`Uri\Rfc3986\Uri`, `Uri\WhatWg\Url`); closures and `static` closures in constant expressions; fatal-error backtraces; `php --ini=diff`.
- **8.4**: **property hooks** and **asymmetric visibility** (`public private(set)`) — the two features that make a rich model possible without getter/setter boilerplate; `new Foo()->m()` without parentheses; lazy objects; `#[\Deprecated]`; HTML5 DOM (`Dom\HTMLDocument`); `array_find`.
- **8.3**: typed class constants, `#[\Override]`, `json_validate()`.
- **8.6** expected 2026-11-19. 8.3 is security-only; 8.1 is EOL (2025-12-31). Minimum for new projects: **8.4**; target 8.5.

Mandatory in every file: `declare(strict_types=1)`; `readonly` classes/properties; enums; constructor promotion; `final` by default; no `mixed` without a reason; **PER Coding Style 3.1** (the current edition — it extends and replaces PSR-12; `@PER-CS` in php-cs-fixer, `perCs: true` in ECS).

## Studio default set
| Task | Choice | Why |
|---|---|---|
| Framework | `php_framework`: **yii3** (reference `yii3.md`) · symfony (`symfony.md`, stub) · laravel (`laravel.md`, stub) · slim · none — chosen in `/setup-stack` | Only Yii3 has a full studio reference and a package rule; Symfony and Laravel have stubs (versions, where the layers live) and `php-engineer` works from the official docs until a project fills them; Slim and none have no file |
| Architecture | `php_architecture`: **layered** (`src/Domain` → `src/Application` → `src/Infrastructure`, deptrac-enforced) · framework (the framework's own layout: controllers/models/services); `php_layers`: **per-context** (`src/Application/<Context>/`) · flat (one `App\Application` namespace) | See "Layered architecture"; a brownfield project keeps `framework` until `/refactor layout` |
| Static analysis | `php_static_analysis`: **PHPStan** level 9 (new projects) · Psalm level 1 (the yiisoft ecosystem's own tool) | Template `docs/templates/php/phpstan.neon` / `psalm.xml`; a brownfield project starts from a baseline and raises one level per story |
| Coding standard | `php_cs_tool`: **ECS** (`perCs: true`) · php-cs-fixer (`@PER-CS`) | Templates `ecs.php` / `.php-cs-fixer.dist.php`; ECS runs PHP_CodeSniffer and PHP-CS-Fixer rules through one config |
| Architecture check | **deptrac** (`deptrac/deptrac` — the `qossmic/deptrac-shim` package has not moved since 2022) · phparkitect (rules as PHP) · phpat (rules inside PHPStan) | Template `deptrac.yaml`: layers by directory, the framework namespaces as a layer only Infrastructure may use |
| Tests | **PHPUnit 13** (PHP ≥ 8.4; 12 in bugfix support until 2027-02, 11 out since 2026-02) · Pest 5 on top of it when the project prefers the `it()` style | Data providers for table-driven tests; `createMock` for ports; a real Postgres in compose for infrastructure |
| Coverage | pcov (fast) or xdebug; clover → `scripts/coverage-gate.php` | Per-layer thresholds as a gate, see "Tests by layer" |
| Upgrades | Rector 2 | Language and PHPUnit migrations by rule set |
| GraphQL | `webonyx/graphql-php` 15 (`BuildSchema` from the SDL at `api_contract_path`) | See `graphql.md`; root type names below |
| Runtime | PHP-FPM + nginx classically; **FrankenPHP** (worker mode, HTTP/3) for containers | |

## Idioms
- Errors: domain exceptions extend `\DomainException` (or a project base), one class per rule, a `NotFoundException` in the domain — never `\InvalidArgumentException` for a business situation; transport maps them to RFC 9457 problems in an error-handler middleware, not in every action.
- Interfaces (PSR-7/15/11/3/16/20) rather than concrete framework classes at the boundary; no static service access, no singletons, no global state; dependencies in constructors, wired in the framework's container config.
- Value objects as `final readonly class`; identities as `public readonly string $id`; state as `public private(set)`; hooks for derived values.
- Long operations through the framework's queue with re-scheduling, never `sleep()`.
- Migrations: schema changes are migration files (Yii3 `yiisoft/db-migration`, Cycle migrations, Doctrine migrations) — never DDL in a PHP class, a seed or a raw `CREATE TABLE` from a story. `rules/database.md` applies to the migrations directory of every stack.

## Layered architecture (`php_architecture: layered`)
Dependencies point inwards only. `deptrac.yaml` says who may depend on whom and `composer arch-check` fails otherwise.

| Layer | Namespace / directory | Contains | Never |
|---|---|---|---|
| Domain | `App\Domain\<Context>\` — `src/Domain/<Context>/` | Entities and aggregates as **rich models**: `readonly` identity, `public private(set)` state, a validating constructor or named constructor, operations as methods that keep the invariants and throw domain exceptions; value objects; domain events; the **ports** (`<Entity>RepositoryInterface`, gateway interfaces) | Framework, ORM attributes/annotations on entities, PSR-7, SQL, HTTP; only PHP and the value libraries in `php_domain_allow` |
| Application | `App\Application\<Context>\` — `src/Application/<Context>/` (`php_layers: per-context`, recommended) or `App\Application\` flat (`flat`) | **One class per use case** (`ActivateMembership`) with one method `execute(Input): Output` (or `__invoke`); a constructor taking the ports; orchestration, transactions through a port, calls into the domain, events | Framework, ORM, HTTP types; business rules (they belong to the entity) |
| Infrastructure | `App\Infrastructure\` — `src/Infrastructure/{Persistence,Transport/Http,Transport/GraphQL,Mail,…}/` | Adapters implementing the ports (Cycle/Doctrine/`yiisoft/db` repositories with the mapping kept here), invokable PSR-15 actions and GraphQL resolvers that call use cases, DTOs and mapping, clients | Business rules; an action or resolver that calls a repository directly |
| Composition root | the framework's config (`config/` in Yii3, `config/services.yaml` in Symfony, providers in Laravel) and `public/index.php` | Port → adapter bindings, middleware pipeline, routes | Anything the three rows above own |

**Rich model, concretely.** `public bool $isActive` with an `activate()` that checks it is half-way: any class can still write
`$m->isActive = true`. The studio form (PHP 8.4+): `public private(set) bool $isActive = false`, `public readonly string $id`,
`public private(set) int $balance`, `activate(): void` throwing `ZeroBalanceException`; reads stay plain property reads, writes
compile only inside the class. Verified on PHP 8.4.25: a write from outside throws `Error`. A rehydrating named constructor
(`Membership::fromState(...)`) lets a repository rebuild an entity without re-running the creation rules.

**GraphQL** (`webonyx/graphql-php`): the SDL lives at `api_contract_path` (default `api/schema.graphqls`), loaded with
`BuildSchema::build()` and resolvers wired to use cases; **a schema type must not be named `Query`, `Mutation` or `Subscription`**
unless it is that root — `BuildSchema` takes those names as the root operation types (verified: an entity `type Subscription`
came back from `getSubscriptionType()` as the root). REST actions return RFC 9457 problems for errors; `HTTP QUERY` is a draft
method and is not used in contracts.

**Changing the framework** is the point of this shape: Domain and Application do not import it (deptrac's `Framework` layer is
allowed only from Infrastructure), so a migration replaces `src/Infrastructure/Transport`, the persistence adapters and the
composition root, and nothing else — `/refactor framework --dry-run` inventories exactly which classes import the framework
namespaces before anyone commits to it.

### Tests by layer (`php_architecture: layered`)
| Layer | Level | Doubles | Gate |
|---|---|---|---|
| Domain | Unit, PHPUnit data providers (table-driven), no doubles at all | none — a mock in a domain test is a finding | line coverage ≥ `php_coverage_domain` (default 90 %), every domain exception has a case |
| Application | Unit, ports replaced by `createMock()`/`createStub()` or a hand-written in-memory fake | ports only | line coverage ≥ `php_coverage_application` (default 80 %); a test that boots the framework, opens a DB or touches the network is a finding |
| Infrastructure | Integration against a real Postgres (compose profile `test`), `tests/Integration/` | none | no threshold; every adapter has at least one round-trip test |
| Transport | HTTP tests through the PSR-15 pipeline (`tests/Integration/Http`), contract tests against the SDL/OpenAPI | none | |

Rules for every PHP test: `expectException(ExceptionClass::class)` — never `assertSame('message', $e->getMessage())`; test
method names in English (`testActivationFailsOnZeroBalance`); no `sleep()`/`usleep()` to wait — a clock interface with a fake
in tests, or a polling helper with a deadline for external systems; `composer ci` (`lint → stan → arch-check → tests with
coverage → coverage-gate → audit`) after every change, a red step means the change is not done. `scripts/coverage-gate.php`
(template `docs/templates/php/coverage-gate.php`) reads the clover report, prints one line per layer and fails below the
thresholds — verified on a fixture: `Domain 100.0% >= 90% OK`, `Application 83.3% < 100%` fails.

## Security (PHP-specific)
- Parameterised queries (bound params; PDO prepared); escaped output (`htmlspecialchars` or the framework's HTML helper).
- `password_hash(PASSWORD_ARGON2ID)`, `random_bytes`, `hash_equals`.
- CSRF middleware on every mutation; cookies `Secure/HttpOnly/SameSite`.
- Uploads: MIME check by content, renaming, storage outside the webroot, size limits in `php.ini` and nginx.
- Production `php.ini`: `display_errors=Off`, `expose_php=Off`, `open_basedir`, `disable_functions` as needed; `opcache.validate_timestamps=0` in containers.
- `composer audit` in CI; `composer validate --strict`; `roave/security-advisories` in require-dev.

## PHP review checklist
1. strict_types, readonly, types everywhere; 2. no logic in config, controllers or actions (thin transport); 3. boundary validation; 4. domain exceptions, RFC 9457 at the edge; 5. the configured analyser clean at the recorded level; 6. (`layered`) `deptrac` clean, rules in entities, ports in the domain, one class per use case, no framework import outside Infrastructure; 7. (`layered`) coverage gate green, domain tests without doubles, application tests without I/O; 8. tests: exception classes not messages, no `sleep()`, English names; 9. migrations as files, never DDL in code; 10. packages checked for health (abandoned, tags, dates).
