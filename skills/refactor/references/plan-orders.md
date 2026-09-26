# /refactor — step order by mode (Phase 4 step 2)

Read from `SKILL.md` Phase 4 step 2. Exactly one order applies per run; its step names go into the step
table verbatim. Every step is small enough for one `<engineer>` call and green on its own.

## Go `layout`, fixed order
1. **Characterisation tests first**: pin the behaviour at the boundaries the move will cross (handlers, services, exported functions) until the touched packages reach the coverage thresholds. Without this step no move is planned.
2. Tooling: `.golangci.yml` v2 with `depguard`, `scripts/coverage-gate.sh`, the Makefile targets from `docs/templates/go/`. All fail on purpose at first and are reported so.
3. Domain extraction (entities with rules, sentinel errors, ports).
4. Use cases (one struct per scenario, `Execute`).
5. Adapters into `internal/infrastructure/…` implementing the ports.
6. The composition root (`internal/app/<app>`, one `newServices`).
7. Transport (resolvers/handlers calling use cases).

## PHP `layout`: the same order with PHP names
1. Characterisation tests through the PSR-15 pipeline and the services.
2. Tooling: `deptrac.yaml`, the analyser at its baseline, the standard tool, `phpunit.xml`, `scripts/coverage-gate.php`, composer scripts.
3. `App\Domain` extraction (entities with `public private(set)` state, domain exceptions, ports).
4. Use cases.
5. Adapters into `App\Infrastructure` with the ORM mapping — Symfony: Doctrine repositories with XML mapping in `config/doctrine/` (`symfony.md` "Where the layers live"); Laravel: Eloquent models moved under `app/Infrastructure/Persistence/Eloquent/`, facades replaced by injection first (`LARAVEL_STATIC_TO_INJECTION`, `laravel.md` "Upgrade path").
6. Composition root in the framework config (Symfony `config/services.yaml` port aliases; Laravel `AppServiceProvider` bindings).
7. Transport calling use cases (Symfony invokable controllers with `#[MapRequestPayload]`; Laravel Form Requests → `Input` DTO).

## PHP `framework`
Requires `php_architecture: layered`, else `PLANNED (layout first — run /refactor layout)`.
1. Step 1 is always "ADR: `/architecture-decision` records the move to <target>". `--apply` refuses while that ADR is not `Accepted`.
2. Step 2, the first non-ADR step, whenever the Phase 2 framework table shows a non-zero Domain or Application column: move every framework import out of `App\Domain` and `App\Application` (a port in the domain, an adapter in `App\Infrastructure`), one step per layer touched, until both columns read zero. The row names the classes from the table. Under `layered` these are also `deptrac` violations, so the step closes their `ARCH-NNN` rows. With both columns at zero the step is absent.
3. Then one step per Infrastructure sub-namespace (`Transport\Http`, `Transport\GraphQL`, `Persistence`, `Mail`, …), plus the composition root and `public/index.php`, each replacing one framework's adapters with the target's — the target's "Where the layers live" table (`symfony.md`, `laravel.md`, `yii3.md`) names the directories and the composition-root file of each step.
4. The last step switches the deptrac `Framework` layer and `php_framework` to the target, so the old framework fails the build the moment it is no longer allowed.

The plan document is written like every other mode's (SKILL.md Phase 4 step 4); the ADR is its first step, not a precondition of writing it.

## `tests`
One step per smell class: sleep → polling/synctest or a fake clock; string compare → `errors.Is` / `expectException(Class::class)`; ad-hoc → table-driven / data providers; doubles by layer; thresholds.

## `<package|namespace|file>`
The split/move of that package, namespace or file only.
