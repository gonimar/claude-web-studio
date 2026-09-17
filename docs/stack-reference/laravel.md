---
updated: 2026-09-17
sources: [https://laravel.com/docs, https://laravel.com/docs/releases, https://packagist.org/packages/laravel/framework]
---
# Laravel — the framework reference (`php_framework: laravel`) — stub

The language, the layers, the tests and the tooling live in `php.md`; under `php_architecture: layered` Laravel is
an Infrastructure detail. This file is a **stub**: versions and where things go, no idioms yet — `php-engineer`
works from the official documentation and says so in every result until a project fills this file (`/stack-update laravel`).

## Versions (packagist, 2026-09-17)
- **13** (2026-02, PHP ≥ 8.3) — current; **12** (2025-02, PHP ≥ 8.2) — bug fixes until 2026-08, security until 2027-02. New projects: 13 on PHP 8.5.

## Where the layers live
| Layer | Laravel place |
|---|---|
| Composition root | `app/Providers/AppServiceProvider.php` (`$this->app->bind(RepositoryInterface::class, EloquentRepository::class)`), `bootstrap/app.php`, `routes/*.php`, `public/index.php` |
| Transport | `src/Infrastructure/Transport/Http/` (PSR-4 `App\Infrastructure` next to the framework's `app/` — or `app/Infrastructure/` when the project keeps Laravel's root) — invokable controllers, Form Requests for boundary validation, API Resources as DTOs |
| Persistence | `…/Infrastructure/Persistence/Eloquent/` — repositories implementing the domain ports and mapping Eloquent models to domain entities (Eloquent models are not domain entities); `database/migrations/` for schema |
| Errors | `bootstrap/app.php` `->withExceptions()` mapping domain exceptions to RFC 9457 responses |
| Queue | jobs in Infrastructure dispatching Application use cases; Horizon/Redis per ADR |
| Tests | Pest 5 is Laravel's default runner and is fine — recorded in technical-preferences **Unit** as `PHPUnit 13 + Pest 5`, and the composer `test`/`test:coverage` lines call `pest` instead of `phpunit`; `RefreshDatabase` only under `tests/Integration` |

## deptrac
`FRAMEWORK_NAMESPACES` = `Illuminate\\|Laravel\\` in `docs/templates/php/deptrac.yaml`; note that Laravel's root namespace is `App\` for `app/` — when the layered tree stays under `app/`, every PHP template gets `app` instead of `src` (deptrac `paths`/collectors, the analyser and standard-tool paths, `phpunit.xml` `<source>`, `coverage-gate.php --root=app`).

## Open (to fill from a real project)
Idioms, the package rule (first-party packages by default), security specifics, the review checklist.
