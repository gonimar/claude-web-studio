# PHP interview — read from Phase 2 when PHP is the backend

Ask the questions in order, one `AskUserQuestion` each, recommendation first. Every version number is read from `stack-reference/php.md` at question time.

## Version and framework (Phase 2 step 2)
For PHP, two more questions:
- The version: the studio target per `php.md` (Recommended) | the floor per `php.md` (only when the hosting cannot run the target yet — recorded in **Language/runtime** with the reason and an upgrade story). Both numbers are read from `php.md` at question time.
- `php_framework`: **Yii3** (Recommended — `yii3.md`: PSR-15 `yiisoft/*` packages, the smallest framework surface) | Symfony (`symfony.md`: the current major on the studio PHP target, Flex, Doctrine ORM 3 with XML mapping, Messenger, Security bundle; API Platform by ADR) | Laravel (`laravel.md`: the current major on the studio PHP target, Eloquent as an Infrastructure adapter, Form Requests + policies, Sanctum, Redis queues + Horizon; PHPUnit 13 with Pest 5 optional) | Slim | none (PSR-15 pipeline only). The version numbers in the options are read from the framework file at question time. Slim and none are recorded with the line "php-engineer works from the official documentation; the studio has no reference for this framework".

## Architecture (Phase 2 step 9)
**PHP architecture** (`php.md`), one `AskUserQuestion` each, recommendation first:
- `php_architecture`: **layered** (`src/Domain` → `src/Application` → `src/Infrastructure`, deptrac-enforced, the framework only in Infrastructure — Recommended for a service with business rules or one that may change framework) | framework (the framework's own layout).
- When layered, the directory shape: **use cases per context** (Recommended) | flat. It is shown as the tree and recorded in the layout ADR that Phase 5 proposes, not as a field.
- `php_static_analysis`: **PHPStan level 9** (Recommended) | Psalm level 1 (the yiisoft ecosystem's own tool).
- `php_cs_tool`: **ECS** (`perCs: true`, Recommended) | php-cs-fixer (`@PER-CS`).
- `php_domain_allow`: vendor namespaces the domain may use (default `none`).
- Coverage gate: **Domain 90 % / Application 80 %** (Recommended) | other numbers.
- Show the resulting tree. The `deptrac.yaml`, analyser config, coding-standard config, `phpunit.xml`, `scripts/coverage-gate.php` and composer scripts come from `.claude/docs/templates/php/` in `/test-setup`.
