---
paths: ["**/*.php"]
---
# PHP code rules
- `declare(strict_types=1)`; types everywhere; `readonly`, `final`, enums, constructor promotion.
- PER Coding Style 3.1 through the recorded tool (`php_cs_tool`: ECS `perCs` or php-cs-fixer `@PER-CS`), formatted after every write; PSR-7/15/11/3 interfaces rather than concrete classes.
- Framework per `php_framework` (Yii3: config only via `yiisoft/config`; invokable actions; `yiisoft/validator`; maximum health-checked `yiisoft/*` packages — `yii3.md`); another framework → its official docs, named in the result.
- Architecture per `php_architecture`. `layered`: `src/Domain` → `src/Application` → `src/Infrastructure`, dependencies inwards only (`deptrac.yaml`, `composer arch-check`); ports in the domain; one class per use case with `execute`; rich models (`public private(set)` state, `readonly` identity, invariants in methods, domain exceptions incl. `NotFoundException`); the framework namespaces only in Infrastructure; actions/resolvers call use cases, never repositories. Reference: `php.md` "Layered architecture".
- No logic in controllers, actions or config; schema changes only as migration files (`rules/database.md`), never DDL in a class or a story.
- Parameterised SQL; escaped output; CSRF on mutations; argon2id passwords.
- The recorded analyser clean at the recorded level (`php_static_analysis`); PHPUnit 13 with data providers — domain without doubles, application with mocked ports and no I/O, infrastructure against a real Postgres; `composer coverage-gate` green at the thresholds technical-preferences records (`php_coverage_domain` / `php_coverage_application`); `composer ci` green; `composer audit` clean.
- Reference: `.claude/docs/stack-reference/php.md`, then the framework file (`yii3.md`).
