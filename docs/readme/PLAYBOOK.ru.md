# Web Studio — ситуационная инструкция («что делать, если…»)

Что запускать в каждой ситуации: полный путь для нового и для существующего проекта, ежедневный
цикл разработки, релиз, начало и конец сессии, периодические проверки и справочник «если что-то
пошло не так». Написано по текстам скилов и хуков плагина; там, где команды ещё нет, стоит пометка
**Планируется** со ссылкой на [`roadmap.md`](../roadmap.md).

Внутри проекта: `/help guide` печатает оглавление этого файла, `/help guide <тема>` — нужный раздел,
`/help commands` — все команды с описанием. Читать на: [English](../playbook.md) · Русский.

> В plugin-режиме каждая команда имеет префикс: `/web-studio:help`, `/web-studio:dev-story S-003`.
> В copy-режиме (install.sh) — без префикса. Ниже префикс опущен.

---

## 0. Что уже есть в студии как справка

| Где | Что даёт | Чего не даёт |
|---|---|---|
| `/help` (и `/help "закончил X"`) | Текущая фаза, галочки по шагам каталога, **один** следующий шаг, открытый план адопции, версия студии, дрейф справочника стека, `Attention:` о красном CI/деплое | Не диагностирует (не читает логи, не ходит в `gh run`), не объясняет «что делать, если» |
| `README.md` / `docs/readme/README.ru.md` плагина | Установка, первая сессия, возвращение в сессию, список 44 команд, три сквозных примера (SaaS на Go+Angular, контент-сайт PHP/Nuxt, игра three.js) | Внештатные ситуации, периодика |
| `docs/web-studio/README.md` в проекте (из `docs/PROJECT-README.md`) | Шпаргалка на 20 строк: quick start, возвращение, пайплайн, обновление | То же |
| `.claude/docs/workflow-catalog.yaml` | Фазы → шаги → команда → обязательный ли → какой файл считается доказательством | Порядок действий в кризис |
| `.claude/docs/git-workflow.md`, `review-workflow.md`, `coordination-rules.md` | Правила веток/PR, режимы ревью, гейты фаз, классы изменений (`/impact`), протокол «спросить → показать → записать» | Сценарии |
| `/help commands` | Все команды с описанием и аргументами, по фазам | — |
| `/help guide [тема]` | Оглавление этой инструкции или один её раздел | — |
| Хук `session-start.sh` | При каждом старте: три строки **вам** (ветка · стадия, задача, следующий шаг · предупреждения, открытый гейт) и полный блок **Claude** (5 коммитов, отставание от origin, roadmap, возраст справочника, версия, `active.md`) | Детали на экране — спросить или `/help` |

**Чего нет**: единого документа «ситуация → команды». Это он.

---

## 1. Карта на одну страницу

```
discovery ──► specification ──► architecture ──► build ──► hardening ──► release ──► operate ─┐
 /init          /feature-spec      /threat-model*   /create-stories*  /security-audit*  /release-checklist*  /incident   │
 /start|/adopt  /ux-spec           /architecture-   /sprint-plan      /dependency-audit* /changelog*         /hotfix     │
 /setup-stack*  /design-system       decision*      /qa-plan          /harden*           /deploy*            /tech-debt  │
 /product-spec*                    /api-contract    /dev-story*       /pentest                               /stack-update
 /brainstorm                       /data-model      /code-review*     /perf-audit*                                       │
 /game-concept                     /test-setup*     /story-done*      /a11y-audit*                     ◄──── build ──────┘
                                   /architecture-review  /impact
* — обязательный шаг каталога (гейт совещательный: решает владелец, но /help будет напоминать)
```

Оркестраторы (Opus, дорого, но один вызов вместо семи): `/team-feature F-NNN`, `/team-security
pre-release`, `/team-release X.Y.Z`, `/team-game prototype`.

Десять команд, которые покрывают 90 % дней:

| Ситуация | Команда |
|---|---|
| Не знаю, что дальше | `/help` |
| Где спринт | `/sprint-status` |
| Делать историю | `/dev-story S-NNN` |
| Проверить код | `/code-review --diff` |
| Закрыть историю и смёржить | `/story-done S-NNN` |
| «А давай ещё вот это» | `/impact <предложение своими словами>` |
| Спланировать спринт | `/sprint-plan NN --days 10` |
| Выпустить версию | `/team-release X.Y.Z` (или по шагам, §6) |
| Прод сломан | `/incident "<что>" --sev 1` → `/hotfix` |
| Студия ведёт себя странно | `/update --dry-run`, `/skill-test static all`, issue в репозитории плагина |

---

## 2. Установка и режимы

### 2.1 Три способа установить

```bash
# A. Плагин (рекомендуется). --scope: user (всем проектам) | project (в git, для команды) | local (только мне, в этом репо)
claude plugin marketplace add gonimar/claude-web-studio
claude plugin install web-studio@claude-web-studio --scope local        # запускать из каталога проекта

# B. Копия внутри проекта (всё в .claude/, редактируемо, без зависимости от плагина)
git clone https://github.com/gonimar/claude-web-studio ~/tools/claude-web-studio
~/tools/claude-web-studio/install.sh /path/to/project [--with-testing]

# C. Новый проект из шаблона: mkdir + git init + вариант B + стартовый CLAUDE.md
~/tools/claude-web-studio/install.sh --new /path/to/new-project
```

Проверить, что установлено: `claude plugin list` (плагин) или `cat .claude/.web-studio-version` (копия).

### 2.2 Что делает `/init` (обязательно после установки, один раз на проект)

Спрашивает **язык общения** и **режим ревью** (`lean` — соло с гейтами на чувствительных путях,
`full` — команда, `solo` — ревью по запросу), затем показывает план и после «May I write?» создаёт:
секции в `CLAUDE.md`, `.claude/docs/` (справочник стека, шаблоны, roster, каталог), `.claude/rules/`,
`.claude/settings.json` (permissions + statusline; в plugin-режиме хуки даёт плагин), `docs/{specs,
architecture,security,ops}`, `production/{sprints,stories,releases,session-state,session-logs}`,
`production/review-mode.txt`, `production/stage.txt`, записи в `.gitignore`.

Вариации:
- **Проект пустой** → `stage.txt = discovery`, дальше `/start`.
- **Проект с кодом** → `/init` сам предложит стадию `build` (есть код, нет релиза) или `operate`
  (есть релизы, compose.prod, deploy-скил) и в конце рекомендует `/adopt full`.
- **`/init` повторно** на инициализированном проекте → вердикт `ALREADY INITIALISED` и хенд-офф на
  `/help` или `/update`; ничего не перезаписывает.
- **Был свой `settings.json` до установки** → рядом ляжет `.claude/settings.web-studio.json`; `/start`
  и `/adopt settings` предложат диф и слияние (чужие хуки не выбрасываются).

---

## 3. Новый проект с нуля — все шаги

### 3.1 Общая последовательность

```
/init                          язык, режим ревью, каркас
/start                         «где мы?» → A идея / B понятный продукт / C игра / D уже есть код
/setup-stack fullstack         тип, backend, frontend, API, БД, тесты, CI, layout — версии из справочника
/product-spec "Название"       цели, пользователи, scope, NFR, риски, критерии MVP
/feature-spec "Фича 1"         сценарии, правила, контракт, состояния, edge cases, security, AC   (повторяемо)
/ux-spec F-001                 потоки, экраны, все состояния, тексты, a11y                          (по желанию)
/design-system --base taiga    токены, темы, компоненты                                              (по желанию)
/threat-model                  STRIDE по поверхностям атаки                                          ОБЯЗАТЕЛЬНО
/architecture-decision "..."   ADR на каждое значимое решение                                        ОБЯЗАТЕЛЬНО (≥1)
/api-contract F-001            SDL / OpenAPI до кода                                                  (рекомендуется)
/data-model F-001              таблицы, индексы, миграции expand/contract                           (если есть БД)
/test-setup --apply            стратегия тестов + конфиги + CI                                       ОБЯЗАТЕЛЬНО
/architecture-review           PASS / CONCERNS / FAIL по всем документам                             (гейт → build)
/create-stories F-001          S-001… с матрицей критерий → тест (+ история «Deploy artefacts»)
/sprint-plan 01 --days 10      цель, capacity, выбор историй, очередь Dependabot
/qa-plan sprint 01             уровни тестов на каждую историю
── цикл §5: /dev-story → /code-review --diff → /story-done ── на каждую историю
── релиз §6
```

Что даёт каждый шаг как доказательство (по этому `/help` ставит ✅): `technical-preferences.md`
без `[TO BE CONFIGURED]`, `docs/specs/product-spec.md`, `docs/specs/features/F-*.md`,
`docs/architecture/threat-model.md`, `docs/architecture/adr-*.md`, `docs/architecture/test-strategy.md`,
`production/stories/**`, `production/sprints/*.md`.

### 3.2 Вариации старта

**A. Только идея.** `/start` → «A) just an idea» → `/brainstorm "<тема>"` даёт concept brief
(аудитория, боль, конкуренты, гипотезы, кандидаты MVP) → затем `/setup-stack` → `/product-spec`.
Не пишите код «пока идея свежая»: принцип 7 CLAUDE.md — первый код появляется через пайплайн, не
после `/init`.

**B. Продукт понятен.** `/start` → B → сразу `/setup-stack` → `/product-spec`. Если продукт маленький
(лендинг, утилита) — `/setup-stack site --quick`, `/product-spec` всё равно нужен (короткий),
одна фича, одна ADR (стек), `/threat-model` (коротко: форма, статика), `/test-setup`.

**C. Браузерная игра.** `/start` → C → `/setup-stack game` (или `game+backend`) →
`/game-concept "Название"` (core loop, MDA, бюджеты кадра/памяти/загрузки, план прототипа) →
`/product-spec` (лёгкий) → `/architecture-decision "Engine and netcode"` → `/api-contract --style ws`
(если мультиплеер) → `/team-game prototype` → **`/game-concept gate`** — go/no-go по критерию
«весело» до вложений в бэкенд; `/help` сам поставит гейт в NEXT, когда истории первой фичи Done.

**D. Есть код или документы** → это §4, а не `/start` (`/start` сам перенаправит).

**Соло-разработчик.** Режим `lean`. `solo` отключает только ревью, **не** пайплайн: `/threat-model`,
`/test-setup`, спеки всё равно обязательны, PR всё равно открывается (CI бежит на нём).

**Команда.** Режим `full`: каждый значимый артефакт проходит директора/лида + security.
`--scope project` для плагина, чтобы у всех была одна версия.

### 3.3 Как выглядит любой шаг изнутри (правило 7)

Каждый скил: задаёт уточняющие вопросы → предлагает 2–3 варианта с ценой → вы выбираете →
**показывает черновик в чате** (таблицы как таблицы) → спрашивает «May I write `<path>`?» одной
`AskUserQuestion` (рекомендуемое первым) → пишет только после «write» → предлагает **отдельный**
коммит `docs: …` на default-ветке. Вердикт в конце (`READY`, `COMPLETE`, `BLOCKED (…)`) и один
вопрос о следующем шаге. Ответ «Other» с другой задачей — не согласие: скил сначала закроет свой гейт.

---

## 4. Существующий проект — встроить студию (brownfield)

### 4.1 Последовательность

```
claude plugin install … --scope local        (или install.sh <project>)
/init                    язык, режим; стадия build|operate по фактам; НЕ пишет discovery поверх живого проекта
/adopt full              (1) стек из lockfiles → technical-preferences.md заполняется ФАКТАМИ в этом же прогоне
                         (2) аудит артефактов: product spec, feature specs, ADR, контракт, threat model,
                             test strategy, roadmap/stories, CLAUDE.md — BLOCKING/HIGH/MEDIUM/INFO
                         (3) settings/CLAUDE.md/.gitignore слияние
                         (4) docs/adoption-plan-<дата>.md — чекбоксы «- [ ] N. <приоритет> — <команда> → <артефакт>»
                         в конце спросит ВАШУ цель — план перестраивается вокруг неё
/help                    читает первый открытый пункт плана и предлагает его
```

Дальше — пункты плана по одному, обычно в таком порядке:

| Пробел | Команда | Заметка |
|---|---|---|
| Нет ADR / есть старые в своём формате | `/architecture-decision retrofit docs/adr/old.md` | Не переписывать решение, только формат + верификация |
| Нет threat model | `/threat-model` | Обязателен до первой истории; `/dev-story` иначе `BLOCKED` |
| Нет test strategy | `/test-setup --apply` | То же; `/create-stories` не предложит `/dev-story`, пока нет |
| Нет контракта, но есть API | `/api-contract --style rest` (или graphql) | Снимает контракт с кода, добавляет diff-check в CI |
| Нет спеки продукта | `/product-spec` (режим retrofit) | Стадия остаётся `build`/`operate`, назад не откатывает |
| Roadmap в чужом формате | INFO «не мигрирован» — по решению; формат v3.1 см. `templates/roadmap.md` | **Планируется:** `/migrate` (roadmap R-02); пока — конвертировать живой сессией |
| Нет деплой-артефактов, но есть deploy target | `/create-stories` добавит историю «Deploy artefacts» | Dockerfile, compose.prod, release workflow, `/healthz`, `docs/ops/deploy.md` |
| Старые мажоры | `/stack-update --check-only` → `/dependency-audit` → истории апгрейда | Таблица «сейчас → актуально → путь» уже в adopt |

### 4.2 Вариации

- **Проект уже в проде (стадия `operate`).** У фазы нет обязательных шагов, поэтому `/help`
  ориентируется на план адопции. Приоритет: `/threat-model` → `/security-audit quick` →
  `/harden --apply` (для живого хоста) → `/test-setup`. Первое изменение кода — только через
  `/create-stories` → `/dev-story`, а не «поправлю по-быстрому».
- **Не git-репозиторий.** `/adopt` спросит «git init сейчас?» — без git адопция `BLOCKED`.
- **Есть deploy-кит / ops-агент.** `/adopt` найдёт `deploy-target:` во фронтматтере агента или
  `scripts/deploy/*.sh` и запишет делегата; кит, у которого только слэш-команда, записывается
  как `none` с причиной — `/deploy` тогда выдаст runbook вместо выполнения.
- **Только документы, кода нет.** `/adopt docs` → план; потом `/setup-stack` не нужен, если
  `/adopt` заполнил стек; если стек не выбран — `/start` (B).
- **Чужой проект на время (аудит, консультация).** `/adopt docs` + `/architecture-review full`
  + `/security-audit quick` + `/tech-debt full` — всё read-only, отчёты в `docs/`.
  **Планируется:** аудит расхождения кода с ADR (roadmap R-04).
- **Хочу только одну фичу, без «наведения порядка».** На вопрос `/adopt` о цели — ответить целью;
  план перестроится: сначала `/feature-spec` этой фичи, минимальные threat-model/test-setup, затем
  истории. Остальные пункты остаются открытыми, `/help` их не навязывает, если вердикт `COMPLIANT`.

---

## 5. Основной цикл разработки (build)

### 5.1 Одна история

```
/sprint-status                       (утро; где мы, что блокирует, очередь Dependabot)
/dev-story S-012                     Phase 1 история → 2 контекст (спека, контракт, ADR, правила, stack-reference)
                                     → 3 план-таблица + ветка feat/S-012-slug от свежего master (с согласия)
                                     → 4 реализация через инженеров → 5 проверка каждого AC тестом
                                     → 6 статус Review, коммит feat(S-012): …, push -u
/code-review --diff production/stories/F-003/S-012-*.md
                                     лид + специалист по типам файлов + appsec для чувствительных путей;
                                     BLOCKING/WARNING/INFO; правки по «yes» → fix(S-012): apply /code-review findings
/story-done S-012                    Phase 3 DoD: критерий→тест→результат ТАБЛИЦЕЙ, lint/typecheck, appsec, docs,
                                     ветка запушена, CI зелёный → Phase 4 «закрыть + открыть PR?» (docs: close S-012)
                                     → Phase 5 ОТДЕЛЬНЫЙ вопрос «смёржить?» → gh pr merge --merge --delete-branch,
                                     switch master, pull, удалить ветку, очистить active.md
→ /dev-story S-013 со свежего master
```

Ключевые правила git (хуки напоминают):
- Одна история = одна ветка = один PR. Код на `master`/`main` не коммитится (предупреждение).
- `docs:`-коммиты, трогающие только `docs/**`, `production/**`, `CLAUDE.md`, `.claude/docs/**` —
  разрешённая «полоса документов» на default-ветке.
- Force-push и удаление удалённых веток **блокируются** (exit 2). Обход «удалить и запушить
  заново» тоже заблокирован — новая ветка или спросить владельца.
- Ветка, уже слитая в origin/master, не продолжается: старт печатает «no commits beyond».

### 5.2 Целая фича одним вызовом

`/team-feature F-003` — проверка спеки → контракт → data model → backend → frontend/game → тесты →
security review → code review; независимые части параллельно. Подходит, когда фича ясна и
истории мелкие. Всё равно заканчивайте `/story-done` на каждую историю (мерж и roadmap).

### 5.3 Вариации внутри цикла

| Ситуация | Что делать |
|---|---|
| `/dev-story` вернул `BLOCKED (architecture prerequisites unmet)` | Запустить названное: `/threat-model` или `/test-setup`. Это не обход, это обязательные шаги |
| В ходе истории просите то, чего нет в AC | Скил остановится и предложит `/impact`. Если это правда часть истории — `/feature-spec` обновить AC, потом продолжить |
| `/code-review` дал BLOCKING | Правки по «yes» в той же ветке; `/story-done` не пройдёт без APPROVED. Если BLOCKING — нарушение ADR, а ADR устарела → `/architecture-decision` (новая, supersedes) |
| CI красный после push | Скил ждёт одним `gh run watch` в фоне; если упало — прочитать лог `gh run view <id> --log-failed`, исправить в ветке, `fix(S-NNN): …`. Не мёржить с красным CI |
| PR не хотите мёржить сейчас | Ответить «leave the PR open»; `Branch:` остаётся в `active.md`; позже `/story-done S-NNN` снова — сразу к Phase 5 |
| Хотите squash | Только если это записано в `CLAUDE.md` проекта; по умолчанию merge-commit |
| История оказалась слишком большой | Остановить (`/dev-story` → stop), `/create-stories F-NNN` заново с разбиением; старую пометить ❌ в roadmap |
| Нужно переключиться на другую историю | Закоммитить текущее (`feat(S-NNN): wip …` допустимо на ветке), обновить `active.md` (`Task/Branch/Next`), затем `/dev-story S-другая` — он сам сделает `switch master && pull` и новую ветку |
| Две истории зависят друг от друга (⛔ в roadmap) | `/sprint-plan` не возьмёт зависимую до мержа первой; при необходимости ветка второй — от ветки первой, но PR всё равно в master после мержа первой |
| Dependabot/Renovate PR накопились | Не мёржить руками по одному: `/sprint-plan` Phase 2 показывает очередь таблицей и мёржит зелёные patch/minor одним ответом, мажоры делает историями |

### 5.4 Спринт

```
/sprint-plan 02 --days 10     capacity спрашивается ДО гейта; очередь зависимостей; выбор историй; production/sprints/sprint-02.md
/qa-plan sprint 02            уровни тестов, данные, регрессия, риски → production/sprints/qa-plan-02.md
… истории …
/sprint-status 02             ON TRACK | AT RISK | OFF TRACK; «Done без теста/PR» отдельной строкой
/sprint-plan 03               незакрытое переносится, retro-actions читаются
```

Без спринтов работать можно: `/create-stories` → `/dev-story` напрямую; `/help` будет
предлагать следующую открытую историю roadmap. **Планируется:** `/retrospective` (roadmap R-08),
калибровка оценок (R-07).

### 5.5 Другие основные процессы (не «одна история»)

**Мажорный апгрейд стека** (Angular 21→22, PHP 8.4→8.5, PostgreSQL 17→18):
```
/stack-update <tech> --check-only     что нового, что сломано, EOL-даты
/dependency-audit                     что тянет за собой
/impact "upgrade Angular to 22"      → NEEDS ADR
/architecture-decision "Angular 22 upgrade"   с планом отката
/create-stories                       по одной истории на шаг миграции; каждый шаг — зелёный CI
/dev-story … (в ветке feat/S-NNN-angular-22; при большом апгрейде — одна длинная ветка, PR в конце)
/perf-audit + /a11y-audit             регрессия после апгрейда
```
Не смешивать апгрейд с фичами в одной истории.

**Крупный рефакторинг / переписать модуль.** `/tech-debt <area>` (инвентарь с оценкой) → `/impact`
→ ADR «почему и границы» → `/api-contract` если меняется контракт → истории, где первая — «зафиксировать
поведение тестами» (characterization tests), только потом переписывание. `/architecture-review` в конце.

**Новая чувствительная поверхность** (логин/OAuth, платежи, загрузка файлов, webhooks, WebSocket,
админка, e-mail): `/feature-spec` с обязательной секцией Security → `/threat-model <surface>` →
`/api-contract` → `/data-model` (PII-классификация) → истории → после реализации `/team-security full`
(для платежей — `--pentest` на staging). Хук `IMPACT:` будет срабатывать на этих путях — это норма.

**Интеграция с внешним API / провайдером** (платёжка, карты, почта, ИИ-API): ADR (вендор,
запасной вариант, стоимость) → `/api-contract --style events` для входящих webhook'ов → threat-model
(подпись webhook, replay, таймауты) → история с contract-тестами на замоканный провайдер + один
живой smoke на sandbox-ключах; ключи только в окружении (`.env.example` в репо).

**Изменение схемы БД в проде без даунтайма.** `/data-model F-NNN` даёт expand/contract: история 1 —
expand (новая колонка/таблица, код пишет в обе), релиз; история 2 — backfill; история 3 — contract
(удалить старое), отдельный релиз. `/release-checklist` проверяет обратимость каждой миграции.

**Импорт/миграция унаследованных данных** (переезд со старой системы): `/data-model` (маппинг,
PII) → история «импорт с прогоном на копии прод-дампа» с критерием «сверка количеств и контрольных
сумм» → отдельная история «откат импорта». Никогда на живой базе без бэкапа (`/deploy` Phase 2).

**Документация для людей** (README, API-доки, руководство пользователя, runbook): скила нет —
это история с агентом `tech-writer` (`/create-stories` с критерием «страница X существует и
проверена по чек-листу»); API-доки генерируются из контракта (`/api-contract`); runbook — из
`docs/ops/deploy.md` (история «Deploy artefacts»). `/story-done` проверяет, что docs обновлены. **Планируется:** `/docs`
(roadmap R-05).

**Наблюдаемость, алерты, бэкапы** (обычно забывают до первого инцидента): история «Observability»
с `devops-engineer` — `/healthz`, структурные логи, метрики, алерт на 5xx и на место на диске;
история «Backup & restore drill» — бэкап по расписанию и **проверенное восстановление** на
staging. `/incident` без логов бесполезен, `/release-checklist` требует бэкап. **Планируется:** обе
истории предлагаются автоматически (roadmap R-06).

**Локализация, SEO, аналитика.** Отдельных скилов нет: i18n — секция в `/product-spec` (NFR) и
`/ux-spec` (тексты); SEO — агент `seo-specialist` в историях контентного сайта (`/setup-stack site`,
рендеринг SSR/SSG); аналитика/метрики продукта — в `/product-spec` (метрики успеха) и `/feature-spec`
(события), затем история. **Планируется:** секции шаблонов и маршрутизация (roadmap R-11).

**Монорепозиторий / несколько приложений.** `technical-preferences` знает `backend_root` и
`frontend_root`; один roadmap, префиксы фич по приложениям, CI-стадии по путям (`/test-setup`).
Два независимых продукта — два проекта и две установки студии.

**MVP за выходные (минимальный путь).** `/init` (solo) → `/start` B → `/setup-stack --quick` →
`/product-spec` (30 минут, только цели/scope/NFR) → одна `/feature-spec` → `/threat-model`
(короткий) → `/test-setup --apply` → `/create-stories` → `/team-feature F-001` → `/release-checklist
0.1.0` → `/deploy --env staging`. Пропускать threat-model и test-setup не выйдет — `/dev-story`
заблокируется; это осознанно.

**Передача проекта / онбординг нового человека.** Что читать: `CLAUDE.md`, `docs/web-studio/README.md`,
`docs/specs/product-spec.md`, `docs/architecture/adr-*.md`, `production/roadmap.md`, `docs/ops/deploy.md`.
Что запустить: `claude plugin install … --scope local` на своей машине, `/help`, `/sprint-status`.
Перед передачей: `/adopt docs` (аудит документов покажет, чего нет), `/tech-debt full`, все ветки
запушены, `active.md` не передаётся (gitignore). Клиенту при завершении — плюс `/release-checklist`
последней версии и runbook.

**Сроки, оценки, «когда будет готово».** Оценки живут в roadmap (`~8h`, `⏱ 6h`, `📅`), их ставит
`/create-stories` и уточняет `/sprint-plan` по capacity; `/sprint-status` считает burn и риск цели.
Ответ на «когда» = `/sprint-status` + открытые истории с оценками. Нужно урезать scope —
в roadmap `🅿` (отложено) / `❌` (отменено) через `/sprint-plan`, а не тихо.
**Планируется:** калибровка оценок по измеренному времени поставки (roadmap R-07).

**Пожелания пользователей и триаж багов.** Идеи — в `production/backlog.md` (формат v3.1,
`F-NNN` одной строкой до спеки); баги с прод — `/incident` (sev 1–2) или история; находки аудитов —
`production/findings.md`. Раз в спринт `/sprint-plan` читает findings первыми, backlog — по вашему
выбору. Решение «делаем/не делаем» большого пожелания — `/impact` → product-director.
**Планируется:** `/backlog` с перехватом идей — «а может…» записывается, а не делается в том же
ходе (roadmap R-01).

**Переезд на другой хостинг / смена топологии.** `/impact "move to Hetzner"` → architecture →
ADR → обновить Deploy target/delegate (`/setup-stack` или правка technical-preferences) → история
«Deploy artefacts» под новую цель → `/harden full --apply` на новом хосте → `/deploy --env staging`
→ переключение DNS как отдельный шаг с откатом → `/deploy --env prod`.

**Плановая ротация секретов** (раз в квартал или при уходе человека): процесс вне студии, но
`/harden ci` проверяет permissions и secrets hygiene, `/security-audit quick` — что ничего не
захардкожено; `docs/ops/deploy.md` должен перечислять, где какой секрет живёт (раздел
Prerequisites & secrets в deploy-контракте). **Планируется:** `/harden secrets` (roadmap R-09).

**Ревью чужого кода** (подрядчик, другой ИИ-инструмент, старый PR): `/code-review <paths>` или
переключиться на ветку PR и `/code-review --diff`; для скопированного кода — плюс `/dependency-audit`
(лицензии) и `/security-audit <path>`. Принимать в master только через PR и `/story-done`
(история создаётся задним числом через `/create-stories`, если её не было).

**Демо / превью для заказчика.** `/deploy X.Y.Z --env staging` с тегом-кандидатом (`1.2.0-rc.1`),
`/perf-audit web <staging-url>` накануне; данные — сиды из `/qa-plan` (test data), не прод.

**Пауза проекта на месяцы и возобновление.** Перед паузой: §9 «перед отпуском» + `/tech-debt`
(снимок). После: `/update` (студия ушла вперёд) → `/stack-update all` → `/dependency-audit
--fix-safe` (CVE накопились) → `/adopt docs` (документы vs шаблоны) → `/help`.

**Спор с рекомендацией агента.** Решаете вы; агент обязан предложить варианты с ценой, а не
настаивать. Несогласие с техническим решением фиксируется ADR (`/architecture-decision`, вариант
«отклонено — почему»), чтобы следующий агент не предложил то же самое снова.

---

## 6. Релиз

### 6.1 Полный путь (первый релиз или мажор)

```
/sprint-status                      всё ли Done; открытые BLOCKING findings без истории → /create-stories
/team-security pre-release          threat-model refresh → /security-audit → /dependency-audit → /harden → (--pentest) → отчёт + истории
   — или по одному: /security-audit full · /dependency-audit --fix-safe · /harden full --apply · /pentest https://staging… --scope staging
/perf-audit full https://staging…   Core Web Vitals, бандл, p95 API, EXPLAIN, кадры (игра) — против бюджетов
/a11y-audit all                     WCAG 2.2 AA: axe + ручной чеклист клавиатуры
/changelog 1.0.0                    из Conventional Commits с последнего тега; предложит bump
/release-checklist 1.0.0            гейт по доказательствам: истории Done, аудиты без BLOCKING, миграции совместимы,
                                    changelog, secrets/env, бэкап → production/releases/v1.0.0.md + git tag -a (с согласия)
/deploy 1.0.0 --env staging         readiness → план (бэкап → миграции → redeploy → smoke → 30 мин) → выполнение через делегата
/deploy 1.0.0 --env prod            КАЖДАЯ мутация прода — после явного «yes»; smoke проверяет сам скил
```

Короткий путь для регулярного минора: **`/team-release 1.1.0`** — perf + a11y + security quick
параллельно → changelog → checklist → deploy → post-deploy verification. Вердикт `RELEASED` или
`ABORTED (stage …)`.

### 6.2 Вариации

- **Первый релиз, деплоя ещё нет.** Сначала история «Deploy artefacts» (`/create-stories` добавит
  её сам, если в technical-preferences есть Deploy target и нет `docs/ops/deploy.md`): Dockerfile,
  `compose.prod.yaml`, release workflow, `/healthz`, runbook. Без неё `/deploy` даст только runbook.
- **Делегат не найден** (`BLOCKED (delegate … not found)`): проверить `Deploy target / delegate` в
  `technical-preferences.md` (`agent <name>` с `deploy-target:` во фронтматтере или `script <path>`);
  `/setup-stack` переспросит. Слэш-команда чужого кита делегатом быть не может.
- **Только посмотреть план**: `/deploy 1.1.0 --plan-only`.
- **Релиз только staging**: `/deploy 1.1.0 --env staging`, потом `/deploy 1.1.0 --env prod` отдельно.
- **Smoke упал после деплоя**: скил обязан спросить — `rollback` (рекомендуется) · сначала логи ·
  оставить. Ответить rollback; потом `/incident "post-deploy smoke failed" --sev 2`.
- **`NOT READY (…)` от чеклиста**: выполнить названные пункты (часто: аудит старше релиза, BLOCKING
  finding без истории, changelog не обновлён, миграция необратима), затем `/release-checklist` ещё раз.
- **Релиз из story-ветки**: нельзя, теги только на default-ветке. Сначала `/story-done`.
- **Игра**: перед первым публичным релизом — `/game-concept gate` (go/no-go прототипа), `/perf-audit game`,
  `/a11y-audit` (ремап, субтитры, режим для дальтоников).

---

## 7. Периодика: что запускать когда

| Когда | Команда | Зачем |
|---|---|---|
| Каждая сессия (старт) | читать вывод хука → `/help` | ориентация; открытый гейт; ветка/отставание |
| Каждая сессия (конец) | коммит на ветке + `active.md` | см. §9 |
| Каждый день в спринте | `/sprint-status` | блокеры, «Done без теста», очередь зависимостей |
| Начало спринта | `/sprint-plan NN` → `/qa-plan sprint NN` | план + триаж Dependabot |
| Каждая история | `/dev-story` → `/code-review --diff` → `/story-done` | §5 |
| Любое предложение вне истории | `/impact "<…>"` | класс изменения до кода |
| Новая поверхность (auth, платежи, загрузки, webhook, WebSocket) | `/threat-model <surface>` → `/team-security full` | STRIDE на новую поверхность |
| Каждые ≤60 дней (хук напомнит «Stack reference is N days old») | `/stack-update --check-only` → `/stack-update all` | агенты читают справочник, а не память |
| Каждые 1–2 спринта | `/dependency-audit` | CVE, брошенные пакеты, лицензии, pin |
| Раз в квартал или перед большим апгрейдом | `/tech-debt full` → истории | инвентарь долга с оценкой |
| Раз в квартал | `/architecture-review full` | ADR ↔ код ↔ контракт ↔ threat model |
| Перед каждым релизом | `/security-audit` (quick для минора) · `/perf-audit` · `/a11y-audit` | обязательные шаги hardening |
| После релиза | 30 мин мониторинга, `/incident` при проблеме; `/sprint-plan` следующего | |
| При выходе новой версии плагина (хук: «seeded by vX, plugin is vY») | `/update --dry-run` → `/update` | новые правила/шаблоны в проект |
| После правки собственных скилов/агентов в проекте | `/skill-test static all` → `/skill-improve <name>` | не сломать студию |

---

## 8. Начало сессии

1. **Прочитать три строки**, которые хук старта показывает вам (и в терминале, и в VS Code):
   ```
   Web Studio · feat/S-012-slug · 3 uncommitted · 2 behind origin/master
   Stage build · Task: /dev-story S-012 Phase 4 · Next: /code-review --diff
   OPEN GATE: /sprint-plan Phase 2: merge #13 #14? · stack reference 71 days old → /stack-update
   ```
   Полный блок `=== Web Studio — session context ===` уходит только в контекст Claude (терминал хранит
   его в transcript-режиме, VS Code не показывает); когда нужны детали — спросите «что напечатал хук
   старта?». Что в блоке:
   - `Branch:` + `Recent commits` + `Uncommitted changes: N`.
   - `Branch 'master' is N commits behind` → `git pull --ff-only` до любой работы.
   - `Branch 'feat/…' has no commits beyond origin/master (merged or empty)` → эта ветка слита,
     начинать новую: `git switch master && git pull --ff-only && git switch -c feat/S-NNN-slug`
     (это сделает `/dev-story` сам).
   - `Local branches with unpushed commits: …` → есть брошенные ветки (§10.14).
   - `Stack reference is N days old` → `/stack-update` (не срочно, но в этот спринт).
   - `Web Studio vX` против «Plugin root: …/vY» → `/update`.
   - `=== ACTIVE SESSION STATE ===` — `Task:`, `Branch:`, `Next:`, `Gate:`, `Blocked:`.
   - `OPEN GATE (rule 7): /sprint-plan Phase 2: merge #13 #14?` — **следующий ответ продолжает тот
     скил**, а не начинает задачу из `Next:`. Ответьте на вопрос гейта (или «stop»), потом всё остальное.
2. **`/help`** — фаза, шаги, один NEXT, план адопции, `Attention:` (красный CI, упавший деплой, биллинг).
3. **Продолжить**: обычно `/dev-story S-NNN` (из `Next:`) или `/code-review --diff`, если история в
   статусе Review, или `/story-done S-NNN`, если ревью APPROVED.

Вариации:
- **Вернулись после долгого перерыва (недели).** `/help` → `/sprint-status` → `/stack-update
  --check-only` → `/dependency-audit` (накопились CVE/Dependabot) → потом истории.
- **Сессия после компакции контекста.** Хук старта отрабатывает заново (`SessionStart:compact`) и
  отдаёт Claude весь `active.md` и изменённые файлы; ваша сводка начинается с `context compacted`.
  Хук `pre-compact` только пишет момент в `production/session-logs/compaction.log`. Попросите Claude
  перечитать `production/session-state/active.md` и перечисленные там файлы, потом продолжать.
- **Открыли не тот каталог / подкаталог.** Хуки сами переходят в корень репозитория; но `claude`
  лучше запускать из корня — иначе `--scope local` плагина может не подхватиться.
- **Claude на старте не знает ветку и активную задачу.** Хук не отработал: плагин не установлен в этой
  области (`claude plugin list` из корня проекта) или это copy-режим без хуков в `settings.json` —
  `/update` или `install.sh` заново.

---

## 9. Остановка

| Момент | Что сделать перед выходом |
|---|---|
| Середина истории | Коммит на ветке (`feat(S-NNN): wip <что сделано>` допустимо), `git push`; обновить `production/session-state/active.md`: `Task: /dev-story S-NNN Phase 4`, `Branch: feat/…`, `Next: <конкретно>`, `Blocked:`, `Files:`; хук Stop сам напомнит, если есть незакоммиченное и нет `active.md` |
| После `/dev-story` (COMPLETE) | Ответить «commit and push»; `Next: /code-review --diff …` скил запишет сам |
| После `/story-done` с мержем | Ничего: `active.md` очищен, вы на свежем master |
| Посреди вопроса скила (гейт) | Ответить «stop here / not now» — гейт закроется; либо просто выйти: `Gate:` записан, следующая сессия продолжит с него |
| Перед отпуском / передачей | `/sprint-status` (снимок), убедиться, что все ветки запушены (хук старта покажет «unpushed»), `active.md` с `Notes:` датированными решениями |
| Хотите бросить историю | Статус ❌ в roadmap и в карточке истории через `docs:`-коммит, ветку оставить (или удалить локально), `active.md` очистить |

`active.md` в `.gitignore` — он ваш локальный; передавать коллеге состояние надо через roadmap/story
и PR-описание, не через этот файл.

---

## 10. Внештатные ситуации — справочник «если…»

### 10.1 Прод упал / деградация
```
/incident "API returns 500 on login" --sev 1
   Phase 1 containment (откат/фича-флаг/лимиты) → 2 диагностика (логи, контейнеры через deploy-делегата)
   → 3 fix (сам скил или → /hotfix) → 4 постмортем docs/ops/incidents/INC-NNN.md, действия → roadmap
/hotfix "login 500 after 1.2.0"
   воспроизвести падающим тестом → минимальный фикс в hotfix/… от тега релиза → security review для чувствительных путей
   → /changelog patch → /deploy с подтверждением → backport в master (PR)
```
Severity: 1 — прод недоступен/утечка; 2 — ключевой сценарий сломан; 3 — деградация с обходом; 4 — косметика.
Для sev 3–4 без `/incident`: `/create-stories` (баг как история) или `/hotfix`, если ждать спринта нельзя.
Откат без разбора: `/deploy rollback` (через делегата на предыдущий тег), потом `/incident`.

### 10.2 Баг найден, прод не горит
Баг в текущей истории → правится в ней. Баг в старом коде → `/impact "bug: …"` (обычно ROUTINE) →
`/create-stories` (история-баг с падающим тестом как AC) → обычный цикл. Не «поправлю на master».

### 10.3 «Давай ещё вот это» посреди работы
`/impact "<предложение>"` классифицирует по доказательствам (ADR, поверхность threat model, путь):
- architecture → technical-director: `NEEDS ADR` → `/architecture-decision` → `/api-contract`/`/data-model` → `/create-stories`;
- security → security-lead (вето): `/threat-model <surface>` → security-секция спеки → `/create-stories`;
- product → product-director: `/feature-spec` → `/create-stories`;
- routine → `/dev-story` сразу. Тривиальные правки (комментарий, опечатка, лог) — без триажа.
Отклонили (`BLOCKED`) — либо переформулировать, либо записать отказ как ADR.
Хук `IMPACT:` при записи в `auth/`, `migrations/`, `Dockerfile`, `go.mod`, `package.json`, workflows —
это напоминание (warn-only): изменение вне истории и без `/impact`.

**Размышление вслух** («а может, сделаем…», «было бы неплохо…») — это идея, а не поручение: агент
обязан сказать это и предложить записать, а не делать в том же ходе. **Планируется:** `/backlog add`
как точка перехвата (roadmap R-01); пока — записать в `production/backlog.md` руками, дальше
`/impact` или `/brainstorm`.

### 10.4 Новая зависимость / новая технология в стеке
1. `/impact "add <package> for <why>"` — новая runtime-зависимость = класс architecture.
2. `/architecture-decision "<lib> for <need>"` — с проверкой здоровья пакета (последний релиз, CVE, брошен ли).
3. Если технология новая для проекта (например, добавили Go к PHP): `/setup-stack` заново (обновит
   technical-preferences), `/stack-update <tech>` (справочник по ней), `/test-setup` (уровни тестов).
4. Хук `validate-deps` при правке манифеста прогоняет резолвер «всухую» и скажет, если версии нет.
5. Коммит манифеста без lockfile → предупреждение `DEPS:` — добавьте lockfile в тот же коммит.

### 10.5 Уведомление о CVE / Dependabot alert / письмо «ваш пакет уязвим»
`/dependency-audit` (с `--fix-safe` — безопасные патчи применит) → если затронут прод, `/hotfix` с
bump'ом → `/security-audit <path>` для кода вокруг → BLOCKING findings попадают в `production/findings.md`,
`/create-stories` и `/sprint-plan` их читают первыми.

### 10.6 Утёк секрет (в коммит, в чат, в лог)
1. **Немедленно перевыпустить** секрет у провайдера; старый отозвать.
2. Хуки: `secret-guard` не даёт агенту писать `.env`/`*.pem`/ключи и блокирует токено-подобные
   строки; `validate-commit` блокирует staged `.env`/ключи и секрето-подобный diff. Если секрет
   всё же в истории — `/incident "secret leaked" --sev 1`; чистка истории (`git filter-repo`) — вне
   студии, руками, force-push хук блокирует: договоритесь с владельцем репозитория явно.
3. `/security-audit quick` + `gitleaks` через него; `/harden ci` (permissions в workflows).
4. Правило на будущее: секреты только в окружении; значения не пишутся в командную строку.
**Планируется:** чеклист ротации `/harden secrets` (roadmap R-09).

### 10.7 Хук сказал BLOCKED
| Сообщение | Причина | Действие |
|---|---|---|
| `BLOCKED: secret files are staged` | `.env`, `*.pem`, `id_rsa` в индексе | `git restore --staged <file>`, добавить в `.gitignore`, оставить `.env.example` |
| `BLOCKED: staged changes contain a secret-like string` | токен/пароль в diff | Вынести в переменную окружения; если это тестовый фейк — сделать его явно фейковым (короче 12 символов или другой формат) |
| `BLOCKED: force-push is not allowed` | `--force`, `-f`, `--force-with-lease` | Не обходить. Новый коммит поверх (`git revert`) или новая ветка |
| `BLOCKED: deleting a remote branch is not allowed` | `push --delete`, `:branch` | Ветки удаляет `/story-done` через `gh pr merge --delete-branch`; иначе — владелец руками |
| `BLOCKED: writing the secrets file` | агент пытался записать `.env` | Отредактируйте файл сами в редакторе |

### 10.8 Хук предупредил (warn-only, работа продолжается)
| Предупреждение | Смысл | Правильная реакция |
|---|---|---|
| `CONSENT: writing a pipeline document without a fresh consent marker` | документ пишется без ответа «write» на «May I write?» | Если вопрос был — `touch .claude/.write-consent`; если нет — остановить, показать черновик, спросить |
| `IMPACT: … architecture/security surface and no fresh impact verdict` | правка чувствительного пути вне истории | `/impact` или продолжить, если это внутри одобренной истории (`/dev-story` ставит маркер на 4 ч) |
| `COMMIT: … on the default branch` | код-коммит на master | `git stash` → `git switch -c feat/S-NNN-slug` → `git stash pop` → коммит там |
| `BRANCH: … already merged into origin/master` | работа на слитой ветке | новая ветка от master |
| `DEPS: manifest changed but no lockfile staged` | | добавить lockfile |
| `=== post-edit (file) ===` с ошибками | lint/typecheck/format после правки | исправить до коммита |
| Сообщение о формате коммита | не Conventional Commits | `type(scope): subject`; типы: feat fix perf refactor docs test build ci chore style revert |

### 10.9 CI красный
- На story-ветке: `gh run view --log-failed`, исправить, `fix(S-NNN): …`, push. Мержить нельзя (`/story-done` покажет NOT DONE).
- На master после мержа: это инцидент процесса — `/hotfix`, если сломан прод-путь; иначе ветка `fix/…` → PR.
- Флаки: `/test-setup` (retry-политика, изоляция, testcontainers) + история на стабилизацию через `/tech-debt`.
- Нет runner'ов / билинг: `/help` покажет `Attention:`; это внешняя проблема, студия её не чинит.

### 10.10 Оказался на master с незакоммиченными правками
```
git stash -u
git switch -c feat/S-NNN-slug        # или fix/…, docs/… по типу
git stash pop
```
Если это документы пайплайна (`docs/**`, `production/**`) — можно коммитить `docs: …` прямо на master.

### 10.11 Merge-конфликт / ветка отстала
`git fetch origin && git merge origin/master` (или `rebase`, если PR ещё не смотрели) в ветке истории,
разрешить, прогнать тесты, `fix(S-NNN): merge master`. Никогда `--force` после rebase запушенной ветки —
хук заблокирует; если rebase уже сделан локально, а ветка запушена: создайте новую ветку с другим именем
и откройте новый PR (старый закройте).

### 10.12 Две сессии Claude на одном репозитории (одна автономная, одна ваша)
Опасно: обе видят одну рабочую копию и `active.md`. Правила:
- Разные ветки и разные истории; вторую сессию — в `git worktree add ../proj-S-013 -b feat/S-013-…`.
- `active.md` один на репозиторий: пишет только одна сессия; второй — не доверять `Task:`.
- Не запускать `/story-done` (мерж, `switch master`) пока другая сессия работает в этой же копии.

### 10.13 Потерялся контекст: «что вообще происходило?»
1. `production/session-state/active.md`, `production/session-logs/compaction.log`, `git log --oneline -20`,
   `git status`, `gh pr list`.
2. `/help` → `/sprint-status`.
3. Если roadmap не совпадает с реальностью (истории Done без PR, PR без историй) — `/sprint-status`
   покажет «Done without a test/PR»; исправлять `docs:`-коммитом через `/story-done` для каждой.

### 10.14 Брошенные ветки, забытые PR
Хук старта печатает `Local branches with unpushed commits`. По каждой: `git log master..<branch>` →
либо доделать (`/dev-story S-NNN` на ней — он спросит про ветку), либо `git branch -D` после
решения ❌ в roadmap. Открытые PR: `gh pr list` → `/story-done S-NNN` для готовых.

### 10.15 Студия обновилась / ведёт себя иначе
- Хук: «Studio files seeded by vX, plugin is vY» → `/update --dry-run` (что изменится, локальные
  правки списком) → `/update` (копии локальных правок в `.claude/local-overrides/` по выбору).
- `RESTART REQUIRED` от `/update` — плагин обновился, пока сессия шла: перезапустить `claude`.
- Плагин обновить руками: `claude plugin update web-studio` (в области, где установлен; для local —
  из каталога проекта, `--scope local -y`). Затем всё равно `/update` — он досеивает `docs/` и `rules/`.
- Новая версия сломала привычку (другой вопрос, другой порядок) — читать `CHANGELOG.md` плагина
  (`/update` показывает дельту).
**Планируется:** `/update` досеивает шаблоны документов и настаивает на миграции (roadmap R-03).

### 10.16 Скил делает не то, что обещает
1. Убедиться, что это не режим: `production/review-mode.txt`, `stage.txt`, язык в `CLAUDE.md`.
2. `/skill-test static <skill>` и `/skill-test spec <skill>` (в репозитории плагина или проекте с
   `--with-testing`), `/skill-improve <skill>` для локальной копии.
3. Доказательство: `production/session-logs/agent-audit.log` (какие агенты запускались), транскрипт.
4. Issue в репозитории плагина: имя скила, ожидаемое поведение, наблюдённое, доказательство.
Временный обход: правило в `CLAUDE.md` проекта (принцип 6: инструкции, противоречащие фактам,
не исполняются слепо — можно уточнить поведение в секции «Working principles»).

### 10.17 Агент пишет файлы без вопроса / просит «подтвердить уже записанное»
Это нарушение правила 7. Ответить «revert», потребовать черновик в чате и вопрос «May I write?».
Если повторяется — §10.16. Хук `CONSENT:` должен был предупредить; отсутствие предупреждения =
дефект (copy-режим без хуков — `/update`).

### 10.18 Хочу поменять язык общения / режим ревью / стадию
- Язык: секция `## Language` в `CLAUDE.md`.
- Режим ревью: `production/review-mode.txt` (`full|lean|solo`), `docs:`-коммит.
- Стадия: `production/stage.txt`; вперёд её двигают скилы (`/product-spec`, `/create-stories`,
  `/release-checklist`); назад — руками, редко нужно.
- Стек изменился (мажорный апгрейд, новый фреймворк): `/setup-stack` заново + ADR.

### 10.19 Производительность просела / жалоба на доступность
`/perf-audit web https://staging…` (или `api`, `db`, `game`) — ранжированные фиксы → истории.
`/a11y-audit /route` — WCAG-критерии с фиксами. Бюджеты лежат в product-spec (NFR) и game-concept.

### 10.20 Миграция БД пошла не так
Остановить деплой; `/deploy rollback` откатывает образ, **но не данные** — миграции expand/contract
(из `/data-model`) должны быть обратимы; проверить `down`-шаг из `production/releases/vX.Y.Z.md`
(раздел rollback), восстановить из бэкапа, сделанного `/deploy` Phase 2. Затем `/incident`.

### 10.21 Игра: прототип не «заходит»
`/game-concept gate` — фиксирует no-go с причинами; дальше `/brainstorm` по core loop или
`/game-concept` заново; истории бэкенда/мультиплеера не начинать до go.

### 10.22 Продукт разворачивается (pivot) / сильно меняется scope
`/impact "<новое направление>"` → product-director → `/product-spec` (retrofit, секции scope/цели) →
`/feature-spec` затронутых фич → старые истории ❌ в roadmap → `/create-stories` → `/threat-model`
для новых поверхностей → `/architecture-review`.

### 10.23 Хочу временно «без студии» (быстрый эксперимент)
Ветка `spike/…`, без `/dev-story`; хуки безопасности всё равно работают. Результат спайка — либо ADR
(`/architecture-decision` с итогом эксперимента), либо удалить ветку. В master спайк не мёржится.

### 10.24 Удалить студию из проекта
`claude plugin uninstall web-studio` (в той же области). Файлы проекта (`docs/`, `production/`,
`CLAUDE.md`) остаются — это ваши документы. `.claude/docs`, `.claude/rules`, `.claude/settings.json`
блок студии — удалить руками при желании; copy-режим: удалить `.claude/agents`, `.claude/skills`,
хуки из `settings.json`.

### 10.25 Лимиты / деньги / медленно
- `/team-*` и `/architecture-review`, `/threat-model` идут на Opus — самые дорогие; по шагам
  (`/feature-spec` → `/api-contract` → …) дешевле и контролируемее.
- `/help`, `/sprint-status`, `/changelog`, `/a11y-audit` — Haiku, дёшево, можно часто.
- Длинная сессия → компакция; лучше завершать историю и начинать новую сессию с `/dev-story`.
- Квота кончилась посреди истории: код на ветке уже закоммичен по фазам? Если нет — `git commit`
  руками (`feat(S-NNN): wip`), `active.md` заполнить руками по шаблону
  `.claude/docs/templates/session-state.md`; следующая сессия продолжит с `Task:`.

### 10.26 Срочный hotfix, пока история в работе
```
git stash -u  (или wip-коммит на ветке истории)          — сохранить текущее
/hotfix "<bug>"                                          — ветка от тега релиза, тест, фикс, deploy, backport-PR в master
git switch feat/S-NNN-… && git merge origin/master       — после мержа backport подтянуть фикс в историю
git stash pop
```
`active.md`: `Blocked:` на время hotfix'а укажите «hotfix INC-NNN», `Next:` — вернуться к истории.

### 10.27 Регрессия обнаружена через несколько дней после релиза
`/incident "<что>" --sev 2` (пользователи уже пострадали — нужен постмортем даже при быстром фиксе)
→ решение: откат (`/deploy rollback` на предыдущий тег, если миграции обратимы) или `/hotfix`
вперёд (если после релиза уже накопились данные в новой схеме — только вперёд) → действие в
постмортеме: какой тест/аудит должен был поймать → история на этот тест.

### 10.28 Внешний исследователь сообщил об уязвимости
1. Не спорить в публичном канале; поблагодарить, попросить детали приватно.
2. `/incident "<report>" --sev 1|2` — containment (отключить endpoint, лимиты) до фикса.
3. Воспроизвести: `/security-audit <path>` или `/pentest <staging-url> --scope staging --quick`.
4. `/hotfix` → `/threat-model <surface>` (почему поверхность не была учтена) → `/harden`.
5. Ответ исследователю после деплоя; при утечке данных — уведомление пользователей (юридический
   вопрос вне студии).

### 10.29 Ломающее изменение контракта API (есть внешние потребители)
`/impact` → architecture → ADR о версионировании → `/api-contract` (новая версия рядом со старой,
deprecation-даты в SDL/OpenAPI; diff-check в CI покажет breaking) → `/changelog` с секцией
BREAKING → мажорный bump → период сосуществования → история на удаление старой версии.
GraphQL: `@deprecated(reason:)` вместо удаления; REST: `/v2`. **Планируется:** `/api-contract
--deprecate` (roadmap R-13).

### 10.30 Слишком много запросов разрешений от Claude Code
Это не хуки студии, а `permissions` в `.claude/settings.json`. `/init` кладёт базовый allow-список
(`settings.plugin-mode.json`); добавляйте свои команды в `permissions.allow` (`Bash(go test:*)`,
`Bash(pnpm:*)`). Не давайте `Bash(*)` и не снимайте deny с `.env`.

### 10.31 Хуки молчат или падают
- Ничего не печатается на старте → плагин не в этой области (`claude plugin list` из корня проекта)
  или copy-режим без хуков в `settings.json` → `/update` / `install.sh`.
- «jq: command not found» — хуки сами уходят на python3; если нет и его — поставить jq.
- Хук с таймаутом (`validate-deps` 60 с на большом `npm i --dry-run`) — предупреждение, не блок;
  можно временно исключить, но лучше кэш зависимостей.
- Сторонние хуки исчезли после `/init` → в `.claude/settings.web-studio.json` лежит версия студии;
  `/adopt settings` покажет диф и сольёт массивы.

### 10.32 Реестры пакетов / документация не открываются (сеть)
`/stack-update` и `validate-deps` ходят в npm/packagist/pkg.go.dev/llms.txt. При блокировке: запускать
через свой прокси либо `/stack-update --check-only` позже; не давать агенту «угадывать» версии —
хук `validate-deps` и справочник стека ровно для этого.

### 10.33 Тесты требуют данных, аккаунтов, внешних сервисов
`/qa-plan` — раздел test data / environment: сиды, фикстуры, testcontainers (`/test-setup --apply`
настраивает), моки внешних API; e2e-аккаунты только тестовые, в `.env.example` перечислены
переменные. Живые ключи в CI — только для отдельного smoke-джоба с ручным запуском.

### 10.34 Покрытие/линт упали ниже порога после мержа
Пороги заданы в `docs/architecture/test-strategy.md` и CI (`/test-setup`). Не понижать порог в
ветке фичи: история «вернуть покрытие» через `/tech-debt`, либо пересмотреть порог ADR'ом.

### 10.35 Работа с нескольких машин
Плагин `--scope local` ставится на каждой машине; `production/session-state/`, `session-logs/`,
`.claude/settings.local.json` в `.gitignore` — состояние между машинами передаётся через коммиты
на ветке и roadmap, не через `active.md`. Начинать день с `git pull --ff-only` (хук напомнит).

### 10.36 Сменили default-ветку, переименовали или перенесли репозиторий
Хук старта берёт default-ветку из `origin/HEAD`; после переноса выполнить
`git remote set-head origin -a`. `gh` переавторизовать при смене владельца. Ссылки `🔗 PR #N` в
roadmap с абсолютными URL обновить `docs:`-коммитом.

### 10.37 Копирайт-/лицензионный конфликт в зависимостях
`/dependency-audit` (licence check) → находка → ADR о замене или принятии → история замены пакета;
для копипасты кода из чужих репозиториев — `NOTICE`/атрибуция руками: студия это не проверяет,
`/code-review <paths>` смотрит только корректность и безопасность.

### 10.38 Запрос пользователя на удаление данных / GDPR / PII
`/data-model` содержит PII-классификацию и стратегию удаления/анонимизации; если её нет —
`/data-model full` (ретроспективно) → `/threat-model` (поверхность «экспорт/удаление») →
история «удаление аккаунта» с критерием «данные не находятся ни в БД, ни в бэкапах старше N
дней, ни в логах». Само юридическое требование — вне студии. **Планируется:** секции retention &
deletion в шаблонах (roadmap R-10).

### 10.39 Сертификат TLS истёк / домен не резолвится
Инцидент sev 1 (`/incident`); чинится на хосте (renew, DNS) — через deploy-делегата или руками;
затем `/harden tls` с живой проверкой `testssl`/curl и действие в постмортеме: мониторинг срока
сертификата (история Observability).

### 10.40 Читеры / злоупотребления в мультиплеере или API
`/threat-model <surface>` (anti-cheat, rate limits, origin) → `/security-audit api` → `/harden
proxy` (лимиты, WebSocket-защита) → истории; серверная авторитетность — уже в ADR netcode
(`/team-game` требует её).

### 10.41 Нужна консультация, не артефакт
Спросить напрямую: «спроси backend-lead, как лучше…» — агент ответит вариантами с ценой; это не
нарушает принцип 7, пока итог не превращается в ADR/спеку в чате. Как только разговор сошёлся на
решении — скил (`/architecture-decision`, `/feature-spec`), иначе документа не будет и `/help`
не увидит шаг.

---

## 11. Команда → артефакт → когда

| Команда | Артефакт (доказательство) | Обяз. | Когда |
|---|---|---|---|
| `/init` | `.claude/docs/technical-preferences.md`, `production/*.txt` | ✔ | один раз |
| `/start` | `review-mode.txt`, `stage.txt`, маршрут | | новый проект |
| `/adopt [full|stack|docs|settings]` | `docs/adoption-plan-<date>.md`, заполненный technical-preferences | | существующий проект |
| `/setup-stack [type] [--quick]` | technical-preferences без `[TO BE CONFIGURED]` | ✔ | старт / смена стека |
| `/brainstorm` | concept brief | | идея размыта |
| `/product-spec` | `docs/specs/product-spec.md` | ✔ | до фич |
| `/game-concept` / `gate` | `docs/specs/game-concept.md`, `production/releases/gate-prototype.md` | игры | до прототипа / после |
| `/feature-spec` | `docs/specs/features/F-NNN-*.md` | ✔ | на каждую фичу |
| `/ux-spec`, `/design-system` | `docs/specs/ux/UX-NNN-*.md`, `docs/specs/design-system.md` | | UI |
| `/threat-model [surface]` | `docs/architecture/threat-model.md` | ✔ | до кода; новая поверхность |
| `/architecture-decision` | `docs/architecture/adr-NNNN-*.md` | ✔ | каждое значимое решение |
| `/api-contract`, `/data-model` | `docs/architecture/api/*`, `data-model.md` | | до бэкенда |
| `/test-setup --apply` | `docs/architecture/test-strategy.md` + конфиги | ✔ | до кода |
| `/architecture-review` | отчёт PASS/CONCERNS/FAIL | | гейт → build, раз в квартал |
| `/create-stories F-NNN` | `production/stories/F-NNN/S-NNN-*.md`, roadmap | ✔ | после спеки |
| `/sprint-plan`, `/qa-plan`, `/sprint-status` | `production/sprints/*.md` | | спринт |
| `/impact` | вердикт + хенд-офф | | любое предложение вне истории |
| `/dev-story`, `/code-review`, `/story-done` | ветка, PR, тесты, roadmap `[x]` | ✔ | каждая история |
| `/security-audit`, `/dependency-audit`, `/harden`, `/pentest` | `docs/security/*.md`, `production/findings.md` | ✔ (кроме pentest) | hardening, периодика |
| `/perf-audit`, `/a11y-audit` | `docs/ops/perf-audit-<date>.md`, a11y-отчёт | ✔ | до релиза |
| `/changelog`, `/release-checklist`, `/deploy` | `CHANGELOG.md`, `production/releases/vX.Y.Z.md`, тег | ✔ | релиз |
| `/hotfix`, `/incident` | hotfix-ветка+PR, `docs/ops/incidents/INC-NNN.md` | | operate |
| `/tech-debt`, `/stack-update`, `/update` | `docs/ops/tech-debt-<date>.md`, `.claude/docs/stack-reference/*`, обновлённые docs/rules | | периодика |
| `/skill-test`, `/skill-improve` | отчёты тестов студии | | после правки скилов |

---

## 12. Что планируется

Всё, что помечено **Планируется**, собрано в [`roadmap.md`](../roadmap.md): перехват идей
(`/backlog`), миграция документов (`/migrate`), строгие шаблоны через `/update`, аудит архитектуры по
коду, `/docs`, истории наблюдаемости и бэкапов, калибровка оценок, `/retrospective`, чеклист ротации
секретов, retention и удаление данных, i18n/SEO/аналитика, поиск по `/help guide`, deprecation
контракта.
