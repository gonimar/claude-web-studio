# /code-review — PHP checks (Phase 3)

Read when the diff contains `*.php`. Every check's output goes into the report; the finding strings are the
contract (`severity | file:line | what | risk | fix`) and are used as written.

**PHP tests**, on every `*Test.php` in the diff:
- `grep -nE '(^|[^>[:alnum:]_])u?sleep\(' <files>` → WARNING `TEST-SLEEP`.
- An `assertSame`/`assertEquals`/`assertStringContainsString` on `getMessage()` → WARNING `TEST-ERRSTR | file:line | exception asserted by message | breaks on a wording change | expectException(Class::class)`.
- A `TestCase` with several `test*` methods that differ only in data → INFO `TEST-TABLE (data provider)`.

**PHP layered** (`php_architecture: layered`). The numbers go into the report even when clean.
- `composer arch-check` (deptrac): a violation is BLOCKING `LAYER | file:line | <layer> depends on <layer> | the rule the architecture rests on | move the code; a value library the domain genuinely needs goes into php_domain_allow through technical-preferences and /test-setup, never into deptrac.yaml by hand`.
- No `deptrac.yaml` or no `arch-check` composer script → the grep `/refactor` uses instead: `grep -rlE 'use (FRAMEWORK_NAMESPACES|App\\Infrastructure)\\' src/Domain src/Application` with the namespaces of the recorded `php_framework` (`FRAMEWORK_NAMESPACES` is the value the framework's stack-reference names — `docs/stack-reference/{symfony,laravel,yii3}.md`, `docs/templates/php/deptrac.yaml`). A hit is the same BLOCKING `LAYER`; the report says the grep ran because deptrac is not installed.
- When the diff touches `src/Domain/` or `src/Application/`, run the tests with coverage first (`composer test:coverage` writes the clover report `composer coverage-gate` reads); other classes run their tests without it.
- `composer coverage-gate` on the clover report of the tests already run (`composer test:coverage` writes it), only when the diff touches `src/Domain/` or `src/Application/`: a layer below its threshold is BLOCKING `COVERAGE`.
- A class changed under `src/Domain` or `src/Application` with no test change in the diff → WARNING `TEST-LAYER`.
- A `*Test.php` under `tests/Unit/Domain` that creates a mock, or one under `tests/Unit/Application` that boots the framework or opens a connection → WARNING `TEST-LAYER`.
- An entity with public writable state and its rules in a use case or action → WARNING `RICH-MODEL`.
- An action or resolver that injects a repository instead of a use case → WARNING `LAYER`.
- A framework namespace (the `FRAMEWORK_NAMESPACES` of the recorded `php_framework`) imported outside `src/Infrastructure` → BLOCKING `LAYER`.

**PHP framework checks** (by the recorded `php_framework`; the finding strings above apply):
- `symfony` (`docs/stack-reference/symfony.md` "Symfony review checklist"): `#[AsMessage` on a class under `src/Application`, or `extends AbstractController` under `src/Infrastructure/Transport` in a `layered` project → WARNING `LAYER`; `#[ORM\` on a class under `src/Domain` → BLOCKING `LAYER` (the XML mapping belongs in `config/doctrine/`); a `#[MapRequestPayload]` argument typed with a class from `src/Domain` → WARNING `RICH-MODEL`; `getenv(`/`$_ENV[` in `src/` → WARNING `CONFIG | file:line | env read outside config | breaks under dump-env and the vault | %env()% in config/packages`.
- `laravel` (`docs/stack-reference/laravel.md` "deptrac", "Security"): `grep -rnE '(^|[^>:\w$])(app|config|now|collect|dispatch|resolve|event|cache|request|auth)\(' app/Domain app/Application` hit → BLOCKING `LAYER` (a helper is a framework import deptrac cannot see); `env(` outside `config/` → WARNING `CONFIG`; `$request->all()` passed to `create(`/`fill(`/`update(`, `Model::unguard(`, or `#[Unguarded]` outside `database/seeders` → WARNING `MASS-ASSIGN | file:line | unfiltered input reaches a model | mass assignment | validated() into the Input DTO, #[Fillable]`; `DB::unprepared(` or a `*Raw(` call with an interpolated variable → BLOCKING `SQL | file:line | user value in raw SQL | injection | bindings, allow-listed column names`.
