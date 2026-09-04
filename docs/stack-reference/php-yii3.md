---
updated: 2026-09-05
sources: [https://php.watch/versions, https://www.php.net/releases, https://www.yiiframework.com/news/777/yii3-is-released, https://github.com/yiisoft, https://www.php-fig.org/psr/]
---
# PHP 8.5 and Yii3 — versions, idioms, practices

## PHP
- **8.5 (2025-11-20, bug fixes until 2027-12-31)**: pipe operator `|>`; `clone()` with property updates; `#[\NoDiscard]`; `array_first()/array_last()`; the **URI** extension (`Uri\Rfc3986\Uri`, `Uri\WhatWg\Url`); closures and `static` closures in constant expressions; fatal-error backtraces; `php --ini=diff`.
- **8.4**: property hooks, asymmetric visibility `public private(set)`, `new Foo()->m()` without parentheses, lazy objects, `#[\Deprecated]`, HTML5 DOM (`Dom\HTMLDocument`), `array_find`.
- **8.3**: typed class constants, `#[\Override]`, `json_validate()`.
- **8.6** expected 2026-11-19. 8.3 is security-only; 8.1 is EOL (2025-12-31). Minimum for new projects: **8.4**; target 8.5.

Mandatory: `declare(strict_types=1)` in every file; `readonly` classes/properties; enums; constructor promotion; `final` by default; no `mixed` without a reason.

## Yii3 (stable since 2025-12-31)
Yii3 is a set of independent `yiisoft/*` packages with their own SemVer versions, built on PSR
(PSR-7/15/11/3/16/20). There is no "Yii 3.x version" — there are package versions. Templates:
`yiisoft/app` (web), `yiisoft/app-api`, `yiisoft/app-console`.

| Layer | Packages |
|---|---|
| Core/wiring | `yiisoft/config` (composer plugin merging configs), `yiisoft/di`, `yiisoft/yii-runner-http`, `yiisoft/yii-runner-console`, `yiisoft/aliases` |
| HTTP | `yiisoft/yii-http`, `yiisoft/router` + `router-fastroute`, `yiisoft/middleware-dispatcher`, `yiisoft/request-provider`, `yiisoft/data-response`, `httpsoft/http-message` |
| Views | `yiisoft/view`, `yiisoft/yii-view-renderer`, `yiisoft/html`, `yiisoft/widget`, `yiisoft/assets`, `yiisoft/form-model` |
| Data | `yiisoft/db` + `db-pgsql`/`db-mysql`, `yiisoft/db-migration`, `yiisoft/active-record`, `yiisoft/yii-cycle` (Cycle ORM), `yiisoft/data`, `yiisoft/hydrator`, `yiisoft/validator` |
| Security | `yiisoft/security` (crypt, random, password), `yiisoft/csrf`, `yiisoft/auth` (+ `auth-jwt`), `yiisoft/user`, `yiisoft/rbac`, `yiisoft/session`, `yiisoft/cookies`, `yiisoft/rate-limiter` |
| Infra | `yiisoft/cache` (+ `cache-file/redis/db`), `yiisoft/queue` (+ `queue-redis/amqp`), `yiisoft/log` (+ `log-target-file`), `yiisoft/mailer` (+ `mailer-symfony`), `yiisoft/translator`, `yiisoft/mutex`, `yiisoft/error-handler`, `yiisoft/friendly-exception` |
| Dev | `yiisoft/yii-debug`, `yiisoft/yii-gii` |

**Studio rule:** maximum ready `yiisoft/*` packages, own code only where no package exists
(domain, integrations). Before installing: check `abandoned` on Packagist, tags and release
date; a `dev-master` package is installed and *actually run*. Out-of-sync `dev-*` packages are
not patched — look for a maintained alternative and document why.

### Yii3 idioms
- Config only through `yiisoft/config` (`config/common/di/*.php`, `params.php`, `config-plugin` in composer.json); never build the container by hand.
- The application is a PSR-15 middleware chain; actions are invokable classes with constructor DI; `ResponseFactoryInterface`/`DataResponseFactory`.
- Validation — `yiisoft/validator` (rules as attributes or objects); DTO hydration — `yiisoft/hydrator`.
- Light DDD: `Domain` without framework dependencies → `Application` (use cases/handlers) → `Infrastructure` → `Web`/`Console`. No CQRS/event sourcing without a clear need.
- Long operations go through `yiisoft/queue` with re-scheduling, not `sleep()`.
- Static analysis — **Psalm** (the yiisoft ecosystem uses it) level ≤ 3, or PHPStan ≥ 8 for non-Yii projects; `php-cs-fixer` PSR-12/`@PER-CS`; PHPUnit 12; Rector for upgrades.

### For comparison (non-Yii projects)
Symfony 7.4 LTS / 8.0 (2025-11), Laravel 13 (2026-02), Slim 4, Mezzio. Runtime: PHP-FPM + nginx classically; **FrankenPHP** (worker mode, HTTP/3) is the modern option for containers.

## Security (PHP-specific)
- Parameterised queries (`yiisoft/db` bound params; PDO prepared); `htmlspecialchars` / `yiisoft/html` for output.
- `password_hash(PASSWORD_ARGON2ID)`, `random_bytes`, `hash_equals`.
- CSRF middleware on every mutation; cookies `Secure/HttpOnly/SameSite`.
- Uploads: MIME check by content, renaming, storage outside the webroot, size limits in `php.ini` and nginx.
- Production `php.ini`: `display_errors=Off`, `expose_php=Off`, `open_basedir`, `disable_functions` as needed; `opcache.validate_timestamps=0` in containers.
- `composer audit` in CI; `composer validate --strict`; `roave/security-advisories` in require-dev.

## PHP review checklist
1. strict_types, readonly, types everywhere; 2. no logic in config or controllers (thin actions); 3. boundary validation; 4. domain exceptions + `FriendlyException`; 5. Psalm clean; 6. PHPUnit on domain and handlers; 7. packages checked for health.
