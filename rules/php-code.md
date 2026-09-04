---
paths: ["**/*.php"]
---
# PHP code rules
- `declare(strict_types=1)`; types everywhere; `readonly`, `final`, enums, constructor promotion.
- PSR-12/PER-CS; PSR-7/15/11/3 interfaces rather than concrete classes.
- Yii3: config only via `yiisoft/config`; invokable actions; `yiisoft/validator`; maximum health-checked `yiisoft/*` packages.
- Layers: Domain (pure PHP) ← Application ← Infrastructure ← Web/Console; no logic in controllers or config.
- Parameterised SQL; escaped output; CSRF on mutations; argon2id passwords.
- Psalm/PHPStan clean; PHPUnit on domain and handlers; `composer audit` clean.
- Reference: `.claude/docs/stack-reference/php-yii3.md`.
