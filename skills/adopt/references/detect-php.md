# /adopt — PHP detection (Phase 1 step 4)

Read from `SKILL.md` Phase 1 step 4 when `composer.json` exists. Record the fields named in bold; findings go into the facts table and the adoption plan. `FRAMEWORK_NAMESPACES` is defined in the SKILL.md glossary.

- PHP version from `composer.json` `require.php` and `composer show --locked`, recorded in **Language/runtime**. Below the floor in `php.md` → HIGH finding; on the floor → INFO with an upgrade story to the target.
- **`php_framework`** from `composer.json`: `yiisoft/*` → yii3; `symfony/framework-bundle` → symfony; `laravel/framework` → laravel; `slim/slim` → slim; none of them → none. A framework whose reference is a stub is recorded with the line "php-engineer works from the official documentation".
- **`php_architecture`** from the tree **and** the dependency direction. `src/Domain` + `src/Application` present and `grep -rlE 'use (FRAMEWORK_NAMESPACES|App\\Infrastructure)' src/Domain src/Application` empty (FRAMEWORK_NAMESPACES = the namespaces of the detected `php_framework`) → layered. A layered tree with framework imports inside → framework, with an INFO "layered by name — /refactor layout".
- **`php_static_analysis`** from `phpstan.neon*`/`psalm.xml`; **`php_cs_tool`** from `ecs.php`/`.php-cs-fixer*.php`; deptrac config present or not.
- PHPUnit major from `composer show --locked phpunit/phpunit`; below the major `php.md` names → MEDIUM finding.
- DDL in PHP classes outside a migrations directory → MEDIUM finding.
- Moving to `layered` or to another framework is offered as `/refactor layout` / `/refactor framework --dry-run` in the adoption plan, never done here.
