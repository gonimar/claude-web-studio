# /refactor — PHP: baseline commands (Phase 2) and choices (Phase 3)

Read from `SKILL.md` Phase 2 step 1 and Phase 3 step 3. `FRAMEWORK_NAMESPACES` is the regex alternative
`docs/stack-reference/<framework>.md` names for the recorded `php_framework` (the value
`docs/templates/php/deptrac.yaml` takes).

## Baseline — from the PHP root
Run every command and tabulate its output (metric · value · rule it is measured against).
1. `composer ci` once when the composer scripts exist. It prints validate, the analyser, the standard tool, deptrac, phpunit with coverage and the gate in one run.
2. Without the scripts, the same commands one by one:
   - `composer validate --strict`;
   - the recorded analyser;
   - the recorded standard tool in check mode;
   - `vendor/bin/deptrac analyse` when a `deptrac.yaml` exists, else `grep -rlE 'use (FRAMEWORK_NAMESPACES|App\\Infrastructure)\\' src/Domain src/Application` with the namespaces of the recorded `php_framework`;
   - `vendor/bin/phpunit`, with `--coverage-clover` when pcov/xdebug is available, and `composer coverage-gate` on it.
3. Class sizes: `wc -l` per `src/**/*.php`, classes over 400 lines.
4. Framework dependencies by layer: `grep -rcE 'use (FRAMEWORK_NAMESPACES)' src/Domain src/Application src/Infrastructure`.
5. Test smells: `grep -rnE '\b(u?sleep)\(' tests`, `grep -rn 'getMessage()' tests`, `TestCase`s without data providers whose methods differ only in data, mocks under `tests/Unit/Domain`, a booted framework under `tests/Unit/Application`.
6. DDL outside migration files: `grep -rln 'CREATE TABLE\|ALTER TABLE' src`.

## Choices — the fields Phase 3 asks (current value first, "keep", Recommended)
- `php_architecture`: layered | framework. Keeping `framework` ends the `layout` mode with `PLANNED (no migration — framework confirmed)`.
- Use-case shape: per context | flat (the layout ADR's tree; a change is an ADR step).
- `php_static_analysis`: phpstan | psalm. `php_cs_tool`: ecs | php-cs-fixer. `php_domain_allow`. Coverage thresholds.
