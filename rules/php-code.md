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
- Tests per `rules/tests.md` and `php.md` "Tests by layer"; `phpunit --filter` on the classes touched after each change, `composer ci` once before the result (`ci-full` with `composer audit` once per story).
- The recorded analyser (`php_static_analysis`) clean at its level; formatting is the post-edit hook's job.
- Reference: `.claude/docs/stack-reference/php.md`, then the framework file.
