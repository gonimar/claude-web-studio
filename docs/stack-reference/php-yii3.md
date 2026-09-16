---
updated: 2026-09-17
sources: [https://php.watch/versions, https://www.php.net/releases, https://www.yiiframework.com/news/777/yii3-is-released, https://github.com/yiisoft, https://www.php-fig.org/psr/, https://phpunit.de/supported-versions.html]
---
# Yii3 — the framework reference (`php_framework: yii3`)

The language, the layers, the tests and the tooling live in `php.md` and apply to every PHP project; this
file is only what is specific to Yii3. Under `php_architecture: layered`, Yii3 is an Infrastructure detail:
actions, `yiisoft/db`/Cycle adapters and the `config/` composition root; `App\Domain` and `App\Application`
import nothing from `Yiisoft\` (deptrac layer `Framework`).

## PHP (summary — the full section is in `php.md`)
Minimum 8.4, target 8.5; `declare(strict_types=1)`, `readonly`, enums, `final`, property hooks and `public private(set)`;
PER-CS 3.1; PHPUnit 13; the analyser, the coding-standard tool, deptrac and the per-layer coverage gate are recorded in
technical-preferences and described in `php.md`.

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
- Static analysis — the tool recorded as `php_static_analysis` (`php.md`): PHPStan level 9 by default, Psalm level 1 when the project follows the yiisoft ecosystem's own choice; coding standard **PER-CS 3.1** through `php_cs_tool` (ECS `perCs: true` or php-cs-fixer `@PER-CS`); PHPUnit **13**; Rector for upgrades.
- DI bindings of ports to adapters live in `config/common/di/*.php` (or `config/web/di/*.php` for web-only), merged by `yiisoft/config` — not in a hand-named `config/di-web.php`.
- Schema changes only as `yiisoft/db-migration` (or Cycle) migration files; a `CREATE TABLE` in a PHP class, a seed or a story is a finding (`rules/database.md`).

### For comparison (non-Yii projects)
Symfony 7.4 LTS / 8.0 (2025-11), Laravel 13 (2026-02), Slim 4, Mezzio. Runtime: PHP-FPM + nginx classically; **FrankenPHP** (worker mode, HTTP/3) is the modern option for containers.

## Security (Yii3-specific — the PHP list is in `php.md`)
- `yiisoft/db` bound params; `yiisoft/html` for output; `yiisoft/csrf` middleware on every mutation; `yiisoft/security` for passwords (argon2id), random and crypt; `yiisoft/auth`/`yiisoft/user`/`yiisoft/rbac` instead of hand-rolled auth; `yiisoft/rate-limiter` on public endpoints.

## Yii3 review checklist (in addition to `php.md`)
1. config only through `yiisoft/config`, DI bindings in `config/common/di/*.php`; 2. invokable PSR-15 actions, no base-controller inheritance; 3. `yiisoft/validator` at the boundary, `yiisoft/hydrator` for DTOs; 4. `FriendlyException` for user-facing errors; 5. `yiisoft/queue` for long work; 6. migrations as `yiisoft/db-migration` files; 7. every `yiisoft/*` package health-checked (abandoned, tags, `dev-*` actually run).
