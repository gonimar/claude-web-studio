---
updated: 2026-09-17
sources: [https://symfony.com/releases, https://symfony.com/doc/current/index.html, https://packagist.org/packages/symfony/framework-bundle]
---
# Symfony — the framework reference (`php_framework: symfony`) — stub

The language, the layers, the tests and the tooling live in `php.md`; under `php_architecture: layered` Symfony is
an Infrastructure detail. This file is a **stub**: versions and where things go, no idioms yet — `php-engineer`
works from the official documentation and says so in every result until a project fills this file (`/stack-update symfony`).

## Versions (packagist, 2026-09-17)
- **8.1** (2026-09, PHP ≥ 8.4) — current; **8.0** (2025-11); **7.4 LTS** (2025-11, PHP ≥ 8.2, supported until 2028-11). New projects: 8.x on PHP 8.5; an existing 7.4 project stays on the LTS until its own upgrade story.

## Where the layers live
| Layer | Symfony place |
|---|---|
| Composition root | `config/services.yaml` (autowire + `App\Domain\*RepositoryInterface: '@App\Infrastructure\…'` aliases), `config/packages/*`, `public/index.php`, `src/Kernel.php` |
| Transport | `src/Infrastructure/Transport/Http/` — invokable controllers (`#[Route]`, `#[AsController]`), no `AbstractController` inheritance in a layered project; API Platform only via an ADR |
| Persistence | `src/Infrastructure/Persistence/Doctrine/` — repositories implementing the domain ports, mapping in XML/PHP (`config/doctrine/`), never attributes on domain entities; Doctrine Migrations for schema |
| Errors | an `ExceptionListener`/`kernel.exception` subscriber mapping domain exceptions to RFC 9457 (`symfony/http-kernel` problem responses) |
| Queue | Messenger with a transport (Doctrine/AMQP/Redis), handlers in Application, transport config in Infrastructure |
| Tests | `symfony/phpunit-bridge` not required with PHPUnit 13; `KernelTestCase`/`WebTestCase` only under `tests/Integration` |

## deptrac
`FRAMEWORK_NAMESPACES` = `Symfony\\(?!Component\\Uid)|Doctrine\\|Twig\\` in `docs/templates/php/deptrac.yaml` — the negative look-ahead keeps `Symfony\Component\Uid` out of the Framework layer so it can be listed in `php_domain_allow` (a class in both layers would still violate).

## Open (to fill from a real project)
Idioms, the package rule (which bundles by default), security specifics, the review checklist.
