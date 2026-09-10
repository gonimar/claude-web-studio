# Web Studio playbook — what to run, and when

Situational guide for a project run with Web Studio: the full path for a new or an existing
project, the everyday build cycle, releases, session start and stop, periodic maintenance, and a
reference of what to do when something goes wrong. Written against the skill and hook texts of the
plugin; what the studio does not do yet is listed in [`roadmap.md`](roadmap.md).

Inside a project: `/help guide` prints the index of this file, `/help guide <topic>` the
matching section, `/help commands` every command with its description. Read in: English ·
[Russian](readme/PLAYBOOK.ru.md).

> Plugin mode prefixes every command: `/web-studio:help`, `/web-studio:dev-story S-003`.
> Copy mode (`install.sh`) has no prefix. The prefix is omitted below.

---

## 0. Where the studio already explains itself

| Where | What it gives | What it does not |
|---|---|---|
| `/help` (and `/help "finished X"`) | Current phase, done/missing steps of the catalog, **one** next command, open adoption-plan items, studio version drift, stack-reference age, `Attention:` lines for a red CI or a failed deploy | No diagnosis (never reads logs or `gh run`), no "what if" |
| `/help commands` | Every command with description and arguments, grouped by phase | — |
| `/help guide [topic]` | This playbook's index, or one section | — |
| `README.md` (and `docs/readme/README.*.md`) | Install, first session, coming back, the command list, three end-to-end walkthroughs | Emergencies, periodic work |
| `docs/web-studio/README.md` in the project | Twenty-line cheat sheet | The same |
| `.claude/docs/workflow-catalog.yaml` | Phases → steps → command → required? → which file proves the step | Order of actions in a crisis |
| `.claude/docs/git-workflow.md`, `review-workflow.md`, `coordination-rules.md` | Branch and PR rules, review modes, phase gates, change classes (`/impact`), the ask → draft → write protocol | Scenarios |
| `session-start` hook | Every session: three lines for **you** (branch state · stage, task, next · warnings, open gate) and the full block for **Claude** (last commits, ahead/behind origin, roadmap items, stack-reference age, version, `active.md`) | Details on screen — ask, or `/help` |

---

## 1. One-page map

```
discovery ──► specification ──► architecture ──► build ──► hardening ──► release ──► operate ─┐
 /init          /feature-spec      /threat-model*   /create-stories*  /security-audit*  /release-checklist*  /incident   │
 /start|/adopt  /ux-spec           /architecture-   /sprint-plan      /dependency-audit* /changelog*         /hotfix     │
 /setup-stack*  /design-system       decision*      /qa-plan          /harden*           /deploy*            /tech-debt  │
 /product-spec*                    /api-contract    /dev-story*       /pentest                               /stack-update
 /brainstorm                       /data-model      /code-review*     /perf-audit*                                       │
 /game-concept                     /test-setup*     /story-done*      /a11y-audit*                     ◄──── build ──────┘
                                   /architecture-review  /impact
* — required catalog step (the gate is advisory: you decide, /help keeps reminding)
```

Orchestrators (Opus — one call instead of seven): `/team-feature F-NNN`, `/team-security
pre-release`, `/team-release X.Y.Z`, `/team-game prototype`.

Ten commands that cover most days:

| Situation | Command |
|---|---|
| I don't know what's next | `/help` |
| Where is the sprint | `/sprint-status` |
| Implement a story | `/dev-story S-NNN` |
| Check the code | `/code-review --diff` |
| Close a story and merge | `/story-done S-NNN` |
| "Let's also do this…" | `/impact <the proposal in your words>` |
| Plan a sprint | `/sprint-plan NN --days 10` |
| Ship a version | `/team-release X.Y.Z` (or step by step, §6) |
| Production is broken | `/incident "<what>" --sev 1` → `/hotfix` |
| The studio behaves oddly | `/update --dry-run`, `/skill-test static all`, an issue in this repository |

---

## 2. Install and modes

### 2.1 Three ways to install

```bash
# A. Plugin (recommended). --scope: user (every project) | project (in git, for a team) | local (this checkout only)
claude plugin marketplace add gonimar/claude-web-studio
claude plugin install web-studio@claude-web-studio --scope local     # run from the project directory

# B. Vendored copy inside the project (everything in .claude/, editable, no plugin dependency)
git clone https://github.com/gonimar/claude-web-studio ~/tools/claude-web-studio
~/tools/claude-web-studio/install.sh /path/to/project [--with-testing]

# C. New project from the template: mkdir + git init + option B + a starter CLAUDE.md
~/tools/claude-web-studio/install.sh --new /path/to/new-project
```

Check what is installed: `claude plugin list` (plugin) or `cat .claude/.web-studio-version` (copy).

### 2.2 What `/init` does (once per project, right after installing)

Asks the **conversation language** and the **review mode** (`lean` — solo with gates on sensitive
paths, `full` — teams, `solo` — reviews on request), shows the plan and, after "May I write?",
creates: `CLAUDE.md` sections, `.claude/docs/` (stack reference, templates, roster, catalog),
`.claude/rules/`, `.claude/settings.json` (permissions + statusline; in plugin mode the hooks come
from the plugin), `docs/{specs,architecture,security,ops}`, `production/{sprints,stories,releases,
session-state,session-logs}`, `production/review-mode.txt`, `production/stage.txt`, `.gitignore` entries.

Variations:
- **Empty project** → `stage.txt = discovery`, then `/start`.
- **Project with code** → `/init` proposes the stage `build` (code, no release) or `operate`
  (releases, production compose, a deploy skill) and recommends `/adopt full` at the end.
- **`/init` again** on an initialised project → `ALREADY INITIALISED` and a hand-off to `/help` or
  `/update`; nothing is overwritten.
- **A `settings.json` existed before the install** → `.claude/settings.web-studio.json` is written
  next to it; `/start` and `/adopt settings` show the diff and merge (foreign hooks are kept).

---

## 3. A new project from scratch — every step

### 3.1 The sequence

```
/init                          language, review mode, scaffolding
/start                         "where are we?" → A idea / B clear product / C browser game / D existing code
/setup-stack fullstack         type, backend, frontend, API style, database, tests, CI, layout — versions from the reference
/product-spec "Name"           goals, users, scope, NFRs, risks, MVP acceptance
/feature-spec "Feature 1"      scenarios, rules, contract, states, edge cases, security, acceptance criteria  (repeatable)
/ux-spec F-001                 flows, screens, every state, copy, accessibility                                (optional)
/design-system --base taiga    tokens, themes, components                                                     (optional)
/threat-model                  STRIDE per attack surface                                                      REQUIRED
/architecture-decision "..."   an ADR for every significant decision                                          REQUIRED (≥1)
/api-contract F-001            SDL / OpenAPI before code                                                      (recommended)
/data-model F-001              tables, indexes, expand/contract migrations                                    (if there is a DB)
/test-setup --apply            test strategy + configs + CI                                                   REQUIRED
/architecture-review           PASS / CONCERNS / FAIL across the documents                                    (gate → build)
/create-stories F-001          S-001… with the criteria → test matrix (+ the "Deploy artefacts" story)
/sprint-plan 01 --days 10      goal, capacity, story selection, the Dependabot queue
/qa-plan sprint 01             test levels per story
── §5 cycle: /dev-story → /code-review --diff → /story-done ── per story
── §6 release
```

Evidence each step leaves (`/help` ticks ✅ by it): `technical-preferences.md` without
`[TO BE CONFIGURED]`, `docs/specs/product-spec.md`, `docs/specs/features/F-*.md`,
`docs/architecture/threat-model.md`, `docs/architecture/adr-*.md`, `docs/architecture/test-strategy.md`,
`production/stories/**`, `production/sprints/*.md`.

### 3.2 Variations of the start

**A. Only an idea.** `/start` → "A) just an idea" → `/brainstorm "<topic>"` produces a concept brief
(audience, pain, competitors, hypotheses, MVP candidates) → then `/setup-stack` → `/product-spec`.
Do not write code "while the idea is fresh": CLAUDE.md principle 7 — the first code is reached
through the pipeline, not right after `/init`.

**B. The product is clear.** `/start` → B → `/setup-stack` → `/product-spec`. A small product
(landing page, utility): `/setup-stack site --quick`; `/product-spec` is still needed (short), one
feature, one ADR (the stack), `/threat-model` (short: forms, static hosting), `/test-setup`.

**C. Browser game.** `/start` → C → `/setup-stack game` (or `game+backend`) → `/game-concept "Title"`
(core loop, MDA, frame/memory/load budgets, prototype plan) → `/product-spec` (light) →
`/architecture-decision "Engine and netcode"` → `/api-contract --style ws` (multiplayer) →
`/team-game prototype` → **`/game-concept gate`** — go/no-go on the fun criterion before any backend
or multiplayer investment; `/help` makes the gate NEXT once the first feature's stories are Done.

**D. Code or documents exist** → §4, not `/start` (`/start` redirects anyway).

**Solo developer.** Mode `lean`. `solo` switches off reviews only, **not** the pipeline:
`/threat-model`, `/test-setup` and the specs stay required, the PR is still opened (CI runs on it).

**Team.** Mode `full`: every significant artefact passes a director/lead plus security. Install the
plugin with `--scope project` so everyone runs the same version.

### 3.3 What every step looks like from inside (rule 7)

Each skill: asks what is unclear → offers 2–3 options with costs → you decide → **shows the draft
in the chat** (tables as tables) → asks "May I write `<path>`?" as one `AskUserQuestion`
(recommended option first) → writes only after "write" → offers a **separate** `docs:` commit on the
default branch. A verdict at the end (`READY`, `COMPLETE`, `BLOCKED (…)`) and one question about the
next step. An "Other" answer naming a different task is not consent: the skill closes its own gate first.

---

## 4. An existing project — attaching the studio (brownfield)

### 4.1 The sequence

```
claude plugin install … --scope local        (or install.sh <project>)
/init                    language, mode; stage build|operate from the facts; never writes discovery over a live project
/adopt full              (1) stack from lockfiles → technical-preferences.md filled with FACTS in the same run
                         (2) artefact audit: product spec, feature specs, ADRs, contract, threat model,
                             test strategy, roadmap/stories, CLAUDE.md — BLOCKING/HIGH/MEDIUM/INFO
                         (3) settings / CLAUDE.md / .gitignore merge
                         (4) docs/adoption-plan-<date>.md — checkboxes "- [ ] N. <priority> — <command> → <artefact>"
                         at the end it asks YOUR goal — the plan is reordered around it
/help                    reads the first open plan item and offers it
```

Then the plan items one by one, usually in this order:

| Gap | Command | Note |
|---|---|---|
| No ADRs / old ones in their own format | `/architecture-decision retrofit docs/adr/old.md` | Keeps the decision, fixes the format, adds verification |
| No threat model | `/threat-model` | Required before the first story; `/dev-story` is `BLOCKED` otherwise |
| No test strategy | `/test-setup --apply` | Same; `/create-stories` will not offer `/dev-story` without it |
| No contract, but an API exists | `/api-contract --style rest` (or graphql) | Captures the contract from the code, adds a diff check in CI |
| No product spec | `/product-spec` (retrofit mode) | The stage stays `build`/`operate`, never moves back |
| Roadmap or documents in a foreign format | `/migrate roadmap --dry-run` → `/migrate roadmap` (stories, ADRs, specs, sprints the same way) | IDs and history kept; `/adopt` names the types |
| No deploy artefacts but a Deploy target | `/create-stories` adds the "Deploy artefacts" story | Dockerfile, production compose, release workflow, `/healthz`, `docs/ops/deploy.md` |
| Old majors | `/stack-update --check-only` → `/dependency-audit` → upgrade stories | The "now → current → path" table is already in the adoption plan |

### 4.2 Variations

- **Already in production (stage `operate`).** The phase has no required steps, so `/help` follows
  the adoption plan. Priority: `/threat-model` → `/security-audit quick` → `/harden --apply` (live
  host) → `/test-setup`. The first code change goes through `/create-stories` → `/dev-story`, never
  "a quick fix".
- **Not a git repository.** `/adopt` asks "git init now?" — without git adoption is `BLOCKED`.
- **A deploy kit / ops agent exists.** `/adopt` finds `deploy-target:` in an agent's frontmatter or
  `scripts/deploy/*.sh` and records the delegate; a kit that ships only a slash command is recorded
  as `none` with the reason — `/deploy` then produces a runbook instead of executing.
- **Documents only, no code.** `/adopt docs` → plan; `/setup-stack` is not needed if `/adopt` filled
  the stack; if the stack is not chosen — `/start` (B).
- **Someone else's project for a while (audit, consulting).** `/adopt docs` + `/architecture-review
  full` + `/security-audit quick` + `/tech-debt full` — all read-only, reports in `docs/`.
  Code against the documents: `/architecture-review code` (drift findings with `file:line`).
- **Just one feature, no "tidying up".** Answer `/adopt`'s goal question with the goal; the plan is
  reordered: `/feature-spec` of that feature first, minimal threat model and test strategy, then
  stories. The other items stay open; `/help` does not push them when the verdict is `COMPLIANT`.

---

## 5. The build cycle

### 5.1 One story

```
/sprint-status                       (morning: where we are, blockers, the Dependabot queue)
/dev-story S-012                     Phase 1 story → 2 context (spec, contract, ADRs, rules, stack reference)
                                     → 3 plan table + branch feat/S-012-slug from a fresh default branch (with consent)
                                     → 4 implementation through the engineers → 5 every criterion checked by a test
                                     → 6 status Review, commit feat(S-012): …, push -u
/code-review --diff production/stories/F-003/S-012-*.md
                                     lead + specialist by file type + appsec for sensitive paths;
                                     BLOCKING/WARNING/INFO; fixes on "yes" → fix(S-012): apply /code-review findings
/story-done S-012                    Phase 3 DoD: criterion → test → result AS A TABLE, lint/typecheck, appsec, docs,
                                     branch pushed, CI green → Phase 4 "close + open the PR?" (docs: close S-012)
                                     → Phase 5 a SEPARATE "merge?" → gh pr merge --merge --delete-branch,
                                     switch to the default branch, pull, delete the branch, clear active.md
→ /dev-story S-013 from the fresh default branch
```

Git rules the hooks remind you of:
- One story = one branch = one PR. Code is never committed on `master`/`main` (a warning).
- `docs:` commits touching only `docs/**`, `production/**`, `CLAUDE.md`, `.claude/docs/**` are the
  allowed "documents lane" on the default branch.
- Force-push and remote-branch deletion are **blocked** (exit 2). "Delete and push again" is blocked
  too — a new branch name, or ask the owner.
- A branch already merged into the default branch is not continued: session start prints "no commits beyond".

### 5.2 A whole feature in one call

`/team-feature F-003` — spec check → contract → data model → backend → frontend/game → tests →
security review → code review; independent parts in parallel. Good when the feature is clear and
the stories are small. Still finish with `/story-done` per story (merge and roadmap).

### 5.3 Variations inside the cycle

| Situation | What to do |
|---|---|
| `/dev-story` says `BLOCKED (architecture prerequisites unmet)` | Run what it names: `/threat-model` or `/test-setup`. Not a workaround — the required steps |
| Mid-story you ask for something outside the criteria | The skill stops and offers `/impact`. If it truly belongs to the story — `/feature-spec` updates the criteria, then continue |
| `/code-review` returns BLOCKING | Fixes on "yes" in the same branch; `/story-done` fails without APPROVED. If the BLOCKING is an ADR violation and the ADR is outdated → `/architecture-decision` (a new one that supersedes) |
| CI red after the push | The skill waits with one background `gh run watch`; on failure read `gh run view <id> --log-failed`, fix in the branch, `fix(S-NNN): …`. Never merge red |
| You do not want to merge now | Answer "leave the PR open"; `Branch:` stays in `active.md`; later `/story-done S-NNN` again jumps to Phase 5 |
| Squash merges | Only if the project's CLAUDE.md says so; the default is a merge commit |
| The story turned out too big | Stop (`/dev-story` → stop), `/create-stories F-NNN` again with a split; mark the old one ❌ in the roadmap |
| Switching to another story | Commit the current work (`feat(S-NNN): wip …` is fine on the branch), update `active.md` (`Task/Branch/Next`), then `/dev-story S-other` — it switches to the default branch, pulls and branches |
| Two stories depend on each other (⛔ in the roadmap) | `/sprint-plan` will not pick the dependent one before the first merges; if needed branch the second from the first, but its PR still targets the default branch after the first merge |
| Dependabot/Renovate PRs pile up | Do not merge them by hand one by one: `/sprint-plan` Phase 2 shows the queue as a table, merges green patch/minor behind one answer and turns majors into stories |

### 5.4 Sprints

```
/sprint-plan 02 --days 10     capacity is asked BEFORE the gate; dependency queue; story selection; production/sprints/sprint-02.md
/qa-plan sprint 02            test levels, data, regression set, risks → production/sprints/qa-plan-02.md
… stories …
/sprint-status 02             ON TRACK | AT RISK | OFF TRACK; "Done without a test/PR" on its own line
/sprint-plan 03               unfinished work carried over, retro actions read
```

Sprints are optional: `/create-stories` → `/dev-story` directly works; `/help` offers the next open
roadmap story. Sprint end: `/retrospective NN` (planned vs shipped, the calibration ratio the next `/sprint-plan` applies).

### 5.5 Other core processes (not "one story")

**Major stack upgrade** (Angular 21→22, PHP 8.4→8.5, PostgreSQL 17→18):
```
/stack-update <tech> --check-only     what is new, what breaks, EOL dates
/dependency-audit                     what it drags along
/impact "upgrade Angular to 22"      → NEEDS ADR
/architecture-decision "Angular 22 upgrade"   with a rollback plan
/create-stories                       one story per migration step; every step keeps CI green
/dev-story … (in feat/S-NNN-angular-22; a big upgrade may be one long branch with the PR at the end)
/perf-audit + /a11y-audit             regression after the upgrade
```
Never mix an upgrade with features in one story.

**Large refactoring / rewriting a module.** `/tech-debt <area>` (inventory with estimates) → `/impact`
→ an ADR "why and where the boundary is" → `/api-contract` if the contract changes → stories, the
first of which is "pin the behaviour with tests" (characterisation tests), only then the rewrite.
`/architecture-review` at the end.

**A new sensitive surface** (login/OAuth, payments, file uploads, webhooks, WebSocket, admin,
e-mail): `/feature-spec` with its mandatory Security section → `/threat-model <surface>` →
`/api-contract` → `/data-model` (PII classification) → stories → after implementation `/team-security
full` (payments: `--pentest` on staging). The `IMPACT:` hook fires on these paths — that is expected.

**Integrating an external API / provider** (payments, maps, mail, an AI API): an ADR (vendor,
fallback, cost) → `/api-contract --style events` for incoming webhooks → threat model (webhook
signature, replay, timeouts) → a story with contract tests against a mocked provider plus one live
smoke on sandbox keys; keys only in the environment (`.env.example` in the repository).

**Schema change in production without downtime.** `/data-model F-NNN` gives expand/contract:
story 1 — expand (new column/table, code writes to both), release; story 2 — backfill; story 3 —
contract (drop the old), a separate release. `/release-checklist` checks every migration is reversible.

**Importing legacy data** (moving off an old system): `/data-model` (mapping, PII) → a story "import
rehearsed on a copy of the production dump" with the criterion "row counts and checksums match" →
a separate "undo the import" story. Never on the live database without the backup `/deploy` Phase 2 takes.

**Documentation for people** (README, API docs, user guide, runbook): no skill yet — a story with
the `tech-writer` agent (`/create-stories` with the criterion "page X exists and passes the
checklist"); API docs come from the contract (`/api-contract`); the runbook from `docs/ops/deploy.md`
(the "Deploy artefacts" story). `/story-done` checks that docs were updated; `/docs readme|api|guide|runbook`
writes them through `tech-writer`, running every command first; `/docs --check` reports what is stale.

**Observability, alerts, backups** (usually forgotten until the first incident): an "Observability"
story with `devops-engineer` — `/healthz`, structured logs, metrics, alerts on 5xx and disk space; a
"Backup & restore drill" story — scheduled backup and a **verified restore** on staging. `/incident`
is useless without logs; `/release-checklist` requires a backup. `/create-stories` proposes both stories
automatically when a Deploy target is set, and the first release gates on the recorded restore date.

**Localisation, SEO, analytics.** No dedicated skills: i18n — a section in `/product-spec` (NFRs) and
`/ux-spec` (copy); SEO — the `seo-specialist` agent in content-site stories (`/setup-stack site`,
SSR/SSG rendering); product analytics — success metrics in `/product-spec`, events in `/feature-spec`,
then a story. The product spec §6 answers i18n, SEO and analytics explicitly, the feature spec §6 lists events
and copy keys, and `seo-specialist` reviews public pages in `/dev-story`; reference: `web-platform.md` § i18n.

**Monorepo / several applications.** `technical-preferences` knows `backend_root` and
`frontend_root`; one roadmap, feature prefixes per application, CI stages by path (`/test-setup`).
Two independent products — two projects and two installs.

**An MVP in a weekend (the minimal path).** `/init` (solo) → `/start` B → `/setup-stack --quick` →
`/product-spec` (30 minutes: goals, scope, NFRs) → one `/feature-spec` → `/threat-model` (short) →
`/test-setup --apply` → `/create-stories` → `/team-feature F-001` → `/release-checklist 0.1.0` →
`/deploy --env staging`. Skipping the threat model and the test strategy does not work — `/dev-story`
blocks; that is deliberate.

**Handing over a project / onboarding a colleague.** What to read: `CLAUDE.md`,
`docs/web-studio/README.md`, `docs/specs/product-spec.md`, `docs/architecture/adr-*.md`,
`production/roadmap.md`, `docs/ops/deploy.md`. What to run: `claude plugin install … --scope local`
on their machine, `/help`, `/sprint-status`. Before the hand-over: `/adopt docs` (the document audit
shows what is missing), `/tech-debt full`, every branch pushed; `active.md` is not handed over
(gitignored). For a client at project end — plus `/release-checklist` of the last version and the runbook.

**Deadlines, estimates, "when will it be ready".** Estimates live in the roadmap (`~8h`, `⏱ 6h`,
`📅`), set by `/create-stories` and refined by `/sprint-plan` from capacity; `/sprint-status` computes
burn and risk to the goal. The answer to "when" = `/sprint-status` + the open stories with estimates.
Cutting scope — `🅿` (deferred) / `❌` (cancelled) in the roadmap through `/sprint-plan`, never silently.
`/retrospective` computes the calibration ratio (actual ⏱ over estimate) and `/sprint-plan` scales the next sprint by it.

**Feature requests and bug triage.** Ideas → `production/backlog.md` (format v3.1, `F-NNN` as one line
before its spec); production bugs → `/incident` (sev 1–2) or a story; audit findings →
`production/findings.md`. Every sprint `/sprint-plan` reads findings first, the backlog by your choice.
"Do we build it?" for a big request — `/impact` → product-director. `/backlog add "<idea>"` records a musing
without acting on it; `/backlog review` weekly; `/backlog promote I-NNN` sends it to `/brainstorm`, `/impact` or `/feature-spec`.

**Moving to another host / changing the topology.** `/impact "move to <provider>"` → architecture →
ADR → update the Deploy target/delegate (`/setup-stack` or edit technical-preferences) → a "Deploy
artefacts" story for the new target → `/harden full --apply` on the new host → `/deploy --env staging`
→ DNS switch as a separate step with a rollback → `/deploy --env prod`.

**Scheduled secret rotation** (quarterly or when someone leaves): a process outside the studio, but
`/harden ci` checks permissions and secrets hygiene, `/security-audit quick` that nothing is
hard-coded; `docs/ops/deploy.md` must list where each secret lives (the Prerequisites & secrets
section of the deploy contract). `/harden secrets` builds the rotation checklist: every secret, where it lives,
who reads it, the rotation order and the verification — never the values.

**Reviewing someone else's code** (a contractor, another AI tool, an old PR): `/code-review <paths>`,
or switch to the PR branch and `/code-review --diff`; for copied code add `/dependency-audit`
(licences) and `/security-audit <path>`. Into the default branch only through a PR and `/story-done`
(create the story retroactively with `/create-stories` if there was none).

**Demo / preview for a client.** `/deploy X.Y.Z --env staging` with a candidate tag (`1.2.0-rc.1`),
`/perf-audit web <staging-url>` the day before; data from `/qa-plan` seeds, never production.

**Pausing for months and resuming.** Before: §9 "before a holiday" + `/tech-debt` (a snapshot).
After: `/update` (the studio moved on) → `/stack-update all` → `/dependency-audit --fix-safe` (CVEs
accumulated) → `/adopt docs` (documents vs templates) → `/help`.

**Disagreeing with an agent's recommendation.** You decide; the agent must offer options with
costs, not insist. Disagreement with a technical decision is recorded as an ADR
(`/architecture-decision`, "rejected — why") so the next agent does not propose it again.

---

## 6. Release

### 6.1 The full path (first release or a major)

```
/sprint-status                      everything Done? open BLOCKING findings without a story → /create-stories
/team-security pre-release          threat-model refresh → /security-audit → /dependency-audit → /harden → (--pentest) → report + stories
   — or one by one: /security-audit full · /dependency-audit --fix-safe · /harden full --apply · /pentest https://staging… --scope staging
/perf-audit full https://staging…   Core Web Vitals, bundle, API p95, EXPLAIN, frames (game) — against budgets
/a11y-audit all                     WCAG 2.2 AA: axe + the manual keyboard checklist
/changelog 1.0.0                    from Conventional Commits since the last tag; proposes the bump
/release-checklist 1.0.0            the gate from evidence: stories Done, audits without BLOCKING, migrations compatible,
                                    changelog, secrets/env, backup → production/releases/v1.0.0.md + git tag -a (with consent)
/deploy 1.0.0 --env staging         readiness → plan (backup → migrations → redeploy → smoke → 30 min) → execution via the delegate
/deploy 1.0.0 --env prod            EVERY production mutation after an explicit "yes"; the skill runs the smoke checks itself
```

Short path for a regular minor: **`/team-release 1.1.0`** — perf + a11y + security quick in parallel →
changelog → checklist → deploy → post-deploy verification. Verdict `RELEASED` or `ABORTED (stage …)`.

### 6.2 Variations

- **First release, no deployment yet.** The "Deploy artefacts" story first (`/create-stories` adds it
  when technical-preferences has a Deploy target and `docs/ops/deploy.md` is missing): Dockerfile,
  `compose.prod.yaml`, release workflow, `/healthz`, runbook. Without it `/deploy` only produces a runbook.
- **Delegate not found** (`BLOCKED (delegate … not found)`): check `Deploy target / delegate` in
  `technical-preferences.md` (`agent <name>` with `deploy-target:` in its frontmatter, or `script <path>`);
  `/setup-stack` asks again. A foreign kit's slash command cannot be a delegate.
- **Just the plan**: `/deploy 1.1.0 --plan-only`.
- **Staging only**: `/deploy 1.1.0 --env staging`, then `/deploy 1.1.0 --env prod` separately.
- **Smoke failed after the deploy**: the skill must ask — `rollback` (recommended) · logs first ·
  keep. Answer rollback; then `/incident "post-deploy smoke failed" --sev 2`.
- **`NOT READY (…)` from the checklist**: do the named items (typically an audit older than the
  release, a BLOCKING finding without a story, changelog not updated, an irreversible migration),
  then `/release-checklist` again.
- **Release from a story branch**: not allowed, tags live on the default branch. `/story-done` first.
- **Game**: before the first public release — `/game-concept gate`, `/perf-audit game`, `/a11y-audit`
  (remapping, subtitles, colour-blind mode).

---

## 7. Periodic work: what to run when

| When | Command | Why |
|---|---|---|
| Every session (start) | read the hook output → `/help` | orientation; open gate; branch state |
| Every session (end) | commit on the branch + `active.md` | §9 |
| Every day in a sprint | `/sprint-status` | blockers, "Done without a test", dependency queue |
| Sprint start | `/sprint-plan NN` → `/qa-plan sprint NN` | plan + Dependabot triage |
| Every story | `/dev-story` → `/code-review --diff` → `/story-done` | §5 |
| Any proposal outside a story | `/impact "<…>"` | change class before code |
| A new surface (auth, payments, uploads, webhooks, WebSocket) | `/threat-model <surface>` → `/team-security full` | STRIDE on the new surface |
| Every ≤60 days (the hook says "Stack reference is N days old") | `/stack-update --check-only` → `/stack-update` | agents read the reference, not memory |
| Every 1–2 sprints | `/dependency-audit` | CVEs, abandoned packages, licences, pinning |
| Quarterly, or before a big upgrade | `/tech-debt full` → stories | debt inventory with estimates |
| Quarterly | `/architecture-review full` | ADRs ↔ code ↔ contract ↔ threat model |
| Before every release | `/security-audit` (quick for a minor) · `/perf-audit` · `/a11y-audit` | required hardening steps |
| After a release | 30 minutes of monitoring, `/incident` on trouble; `/sprint-plan` for the next cycle | |
| A new plugin version (hook: "seeded by vX, plugin is vY") | `/update --dry-run` → `/update` | new rules/templates into the project |
| After editing your own skills/agents in the project | `/skill-test static all` → `/skill-improve <name>` | keep the studio working |

---

## 8. Session start

1. **Read the three-line summary** the session-start hook shows you (terminal and VS Code alike):
   ```
   Web Studio · feat/S-012-slug · 3 uncommitted · 2 behind origin/master
   Stage build · Task: /dev-story S-012 Phase 4 · Next: /code-review --diff
   OPEN GATE: /sprint-plan Phase 2: merge #13 #14? · stack reference 71 days old → /stack-update
   ```
   The full block `=== Web Studio — session context ===` goes to Claude's context only (the terminal
   keeps it in the transcript view, VS Code does not show it); ask "what did the session hook print?"
   when you need the details. What the block contains:
   - `Branch:` + `Recent commits` + `Uncommitted changes: N`.
   - `Branch 'master' is N commits behind` → `git pull --ff-only` before any work.
   - `Branch 'feat/…' has no commits beyond origin/master (merged or empty)` → the branch is merged;
     start a new one: `git switch master && git pull --ff-only && git switch -c feat/S-NNN-slug`
     (`/dev-story` does this itself).
   - `Local branches with unpushed commits: …` → stranded branches (§10.14).
   - `Stack reference is N days old` → `/stack-update` (not urgent, but this sprint).
   - `Web Studio vX` vs `Plugin root: …/vY` → `/update`.
   - `=== ACTIVE SESSION STATE ===` — `Task:`, `Branch:`, `Next:`, `Gate:`, `Blocked:`.
   - `OPEN GATE (rule 7): /sprint-plan Phase 2: merge #13 #14?` — **the next answer continues that
     skill**, not the task from `Next:`. Answer the gate (or "stop"), then everything else.
2. **`/help`** — phase, steps, one NEXT, the adoption plan, `Attention:` lines (red CI, failed deploy, billing).
3. **Continue**: usually `/dev-story S-NNN` (from `Next:`), or `/code-review --diff` when the story is in
   Review, or `/story-done S-NNN` when the review is APPROVED.

Variations:
- **Back after weeks.** `/help` → `/sprint-status` → `/stack-update --check-only` → `/dependency-audit`
  (CVEs/Dependabot accumulated) → then stories.
- **After context compaction.** The session-start hook runs again (`SessionStart:compact`) and hands
  Claude the whole `active.md` and the modified files; your summary starts with `context compacted`.
  The `pre-compact` hook only logs the moment to `production/session-logs/compaction.log`. Ask Claude to
  re-read `production/session-state/active.md` and the files it lists before continuing.
- **Opened the wrong directory / a subdirectory.** The hooks change to the repository root themselves,
  but start `claude` from the root — a `--scope local` plugin may not be picked up otherwise.
- **Claude does not know the branch or the active task at session start.** The hook did not run: the
  plugin is not installed in this scope (`claude plugin list` from the project root), or it is copy mode
  without hooks in `settings.json` — `/update` or `install.sh` again.

---

## 9. Stopping

| Moment | Before you leave |
|---|---|
| Mid-story | Commit on the branch (`feat(S-NNN): wip <what>` is fine), `git push`; update `production/session-state/active.md`: `Task: /dev-story S-NNN Phase 4`, `Branch: feat/…`, `Next: <concrete>`, `Blocked:`, `Files:`; the Stop hook reminds you when there are uncommitted changes and no `active.md` |
| After `/dev-story` (COMPLETE) | Answer "commit and push"; the skill writes `Next: /code-review --diff …` itself |
| After `/story-done` with a merge | Nothing: `active.md` is cleared, you are on a fresh default branch |
| In the middle of a skill's question (a gate) | Answer "stop here / not now" — the gate closes; or just leave: `Gate:` is recorded, the next session continues there |
| Before a holiday / hand-over | `/sprint-status` (snapshot), every branch pushed (the start hook shows "unpushed"), `active.md` with dated `Notes:` |
| Abandoning a story | ❌ in the roadmap and the story card via a `docs:` commit, keep or delete the branch locally, clear `active.md` |

`active.md` is gitignored — it is yours; hand state to a colleague through the roadmap, the story and the
PR description, not through this file.

---

## 10. When something goes wrong — the "if…" reference

### 10.1 Production is down / degraded
```
/incident "API returns 500 on login" --sev 1
   Phase 1 containment (rollback / feature flag / limits) → 2 diagnosis (logs, containers via the deploy delegate)
   → 3 fix (the skill itself or → /hotfix) → 4 postmortem docs/ops/incidents/INC-NNN.md, actions → roadmap
/hotfix "login 500 after 1.2.0"
   reproduce with a failing test → minimal fix on hotfix/… from the release tag → security review for sensitive paths
   → /changelog patch → /deploy with confirmation → backport to the default branch (PR)
```
Severity: 1 — production unavailable or a leak; 2 — a key journey broken; 3 — degradation with a
workaround; 4 — cosmetic. Sev 3–4 without `/incident`: `/create-stories` (the bug as a story) or
`/hotfix` when it cannot wait for the sprint. Rollback without analysis: `/deploy rollback` (via the
delegate to the previous tag), then `/incident`.

### 10.2 A bug, production not burning
A bug in the current story → fixed in it. A bug in old code → `/impact "bug: …"` (usually ROUTINE) →
`/create-stories` (a bug story with the failing test as a criterion) → the normal cycle. Not "a quick
fix on master".

### 10.3 "Let's also do this…" in the middle of work
`/impact "<proposal>"` classifies from evidence (ADR, threat-model surface, path):
- architecture → technical-director: `NEEDS ADR` → `/architecture-decision` → `/api-contract`/`/data-model` → `/create-stories`;
- security → security-lead (veto): `/threat-model <surface>` → the spec's Security section → `/create-stories`;
- product → product-director: `/feature-spec` → `/create-stories`;
- routine → `/dev-story` right away. Trivial edits (a comment, a typo, a log line) need no triage.
Rejected (`BLOCKED`) — rephrase, or record the rejection as an ADR.
The `IMPACT:` hook on writes to `auth/`, `migrations/`, `Dockerfile`, `go.mod`, `package.json`,
workflows is a warn-only reminder: a change outside a story and without `/impact`.

A **musing** ("what if we…", "maybe we should…") is an idea, not an instruction: `/backlog add "<idea>"`
records it and the conversation returns to the current work; nothing is implemented in that turn. Later
`/backlog promote I-NNN` sends it through `/brainstorm`, `/impact` or `/feature-spec`.

### 10.4 A new dependency / a new technology in the stack
1. `/impact "add <package> for <why>"` — a new runtime dependency is the architecture class.
2. `/architecture-decision "<lib> for <need>"` — with the package health check (last release, CVEs, abandoned?).
3. A technology new to the project (say, Go next to PHP): `/setup-stack` again (updates
   technical-preferences), `/stack-update <tech>` (its reference), `/test-setup` (test levels).
4. The `validate-deps` hook dry-runs the resolver on manifest edits and tells you when a version does not exist.
5. A manifest commit without its lockfile → the `DEPS:` warning — add the lockfile to the same commit.

### 10.5 A CVE notice / Dependabot alert / "your package is vulnerable"
`/dependency-audit` (with `--fix-safe` the safe patches are applied) → if production is affected,
`/hotfix` with the bump → `/security-audit <path>` for the surrounding code → BLOCKING findings go to
`production/findings.md`; `/create-stories` and `/sprint-plan` read them first.

### 10.6 A secret leaked (into a commit, the chat, a log)
1. **Rotate it immediately** at the provider; revoke the old one.
2. Hooks: `secret-guard` stops the agent writing `.env`/`*.pem`/keys and blocks token-like strings;
   `validate-commit` blocks staged `.env`/keys and secret-like diffs. If the secret is already in
   history — `/incident "secret leaked" --sev 1`; history rewriting (`git filter-repo`) is outside
   the studio and by hand, the force-push hook blocks it: agree it explicitly with the repository owner.
3. `/security-audit quick` (runs gitleaks) + `/harden ci` (workflow permissions).
4. Rule for the future: secrets only in the environment; values never on a command line.
5. `/harden secrets` — the rotation checklist for everything else that shares the leak's blast radius.

### 10.7 A hook said BLOCKED
| Message | Cause | Action |
|---|---|---|
| `BLOCKED: secret files are staged` | `.env`, `*.pem`, `id_rsa` in the index | `git restore --staged <file>`, add to `.gitignore`, keep `.env.example` |
| `BLOCKED: staged changes contain a secret-like string` | a token/password in the diff | Move it to an environment variable; a test fake must look fake (shorter than 12 characters or another shape) |
| `BLOCKED: force-push is not allowed` | `--force`, `-f`, `--force-with-lease` | Do not work around it. A new commit on top (`git revert`) or a new branch |
| `BLOCKED: deleting a remote branch is not allowed` | `push --delete`, `:branch` | `/story-done` deletes branches through `gh pr merge --delete-branch`; otherwise the owner by hand |
| `BLOCKED: writing the secrets file` | the agent tried to write `.env` | Edit the file yourself in the editor |

### 10.8 A hook warned (warn-only, work continues)
| Warning | Meaning | Right reaction |
|---|---|---|
| `CONSENT: writing a pipeline document without a fresh consent marker` | a document is being written without a "write" answer to "May I write?" | If the question happened — `touch .claude/.write-consent`; if not — stop, show the draft, ask |
| `IMPACT: … architecture/security surface and no fresh impact verdict` | a sensitive path edited outside a story | `/impact`, or continue if it is inside an approved story (`/dev-story` sets the marker for 4 hours) |
| `COMMIT: … on the default branch` | a code commit on master | `git stash` → `git switch -c feat/S-NNN-slug` → `git stash pop` → commit there |
| `BRANCH: … already merged into origin/master` | work on a merged branch | a new branch from the default branch |
| `DEPS: manifest changed but no lockfile staged` | | add the lockfile |
| `=== post-edit (file) ===` with errors | lint/typecheck/format after the edit | fix before committing |
| a commit-format message | not Conventional Commits | `type(scope): subject`; types: feat fix perf refactor docs test build ci chore style revert |

### 10.9 CI is red
- On a story branch: `gh run view --log-failed`, fix, `fix(S-NNN): …`, push. No merge (`/story-done` says NOT DONE).
- On the default branch after a merge: a process incident — `/hotfix` if a production path is broken; otherwise a `fix/…` branch → PR.
- Flaky tests: `/test-setup` (retry policy, isolation, testcontainers) + a stabilisation story via `/tech-debt`.
- No runners / billing: `/help` shows `Attention:`; an external problem, the studio does not fix it.

### 10.10 On the default branch with uncommitted changes
```
git stash -u
git switch -c feat/S-NNN-slug        # or fix/…, docs/… by type
git stash pop
```
Pipeline documents (`docs/**`, `production/**`) may be committed as `docs: …` directly on the default branch.

### 10.11 Merge conflict / the branch fell behind
`git fetch origin && git merge origin/master` (or `rebase` if nobody has reviewed the PR yet) in the
story branch, resolve, run the tests, `fix(S-NNN): merge master`. Never `--force` after rebasing a
pushed branch — the hook blocks it; if the rebase is already done locally and the branch is pushed:
create a branch with a new name and open a new PR (close the old one).

### 10.12 Two Claude sessions on one repository (one autonomous, one yours)
Dangerous: both see one working copy and one `active.md`. Rules:
- Different branches and different stories; put the second session in `git worktree add ../proj-S-013 -b feat/S-013-…`.
- One `active.md` per repository: only one session writes it; the other must not trust `Task:`.
- Do not run `/story-done` (merge, `switch master`) while the other session works in the same copy.

### 10.13 Lost context: "what was going on?"
1. `production/session-state/active.md`, `production/session-logs/compaction.log`, `git log --oneline -20`,
   `git status`, `gh pr list`.
2. `/help` → `/sprint-status`.
3. Roadmap out of sync with reality (stories Done without a PR, PRs without stories) — `/sprint-status`
   shows "Done without a test/PR"; fix with `docs:` commits through `/story-done` for each.

### 10.14 Stranded branches, forgotten PRs
The start hook prints `Local branches with unpushed commits`. For each: `git log master..<branch>` →
finish it (`/dev-story S-NNN` on it — it asks about the branch) or `git branch -D` after a ❌ decision
in the roadmap. Open PRs: `gh pr list` → `/story-done S-NNN` for the ready ones.

### 10.15 The studio updated / behaves differently
- Hook: "Studio files seeded by vX, plugin is vY" → `/update --dry-run` (what changes, locally edited
  files listed) → `/update` (copies of local edits in `.claude/local-overrides/` on request).
- `RESTART REQUIRED` from `/update` — the plugin was updated while the session ran: restart `claude`.
- Update the plugin by hand: `claude plugin update web-studio` (in the scope where it is installed;
  for local — from the project directory). Then still `/update` — it seeds `docs/` and `rules/`.
- A new version changed a habit (a different question, a different order) — read the plugin's
  `CHANGELOG.md` (`/update` shows the delta).
- `UPDATED (N documents need /migrate)` — a template changed and N project documents predate it: run
  `/migrate all --dry-run`, then `/migrate <type>`; until then `/help` may misread them.

### 10.16 A skill does not do what it promises
1. Make sure it is not a mode: `production/review-mode.txt`, `stage.txt`, the language in `CLAUDE.md`.
2. `/skill-test static <skill>` and `/skill-test spec <skill>` (in the plugin repository or a project
   installed with `--with-testing`), `/skill-improve <skill>` for a local copy.
3. Evidence: `production/session-logs/agent-audit.log` (which agents ran), the transcript.
4. An issue in this repository with the skill name, expected behaviour, observed behaviour and the evidence.
Temporary workaround: a rule in the project's `CLAUDE.md` (principle 6 lets you refine behaviour in
"Working principles").

### 10.17 An agent writes files without asking / asks to "confirm what is already written"
A rule 7 violation. Answer "revert", require the draft in the chat and the "May I write?" question. If it
repeats — §10.16. The `CONSENT:` hook should have warned; no warning = a defect (copy mode without
hooks — `/update`).

### 10.18 Changing the conversation language / review mode / stage
- Language: the `## Language` section in `CLAUDE.md`.
- Review mode: `production/review-mode.txt` (`full|lean|solo`), a `docs:` commit.
- Stage: `production/stage.txt`; skills move it forward (`/product-spec`, `/create-stories`,
  `/release-checklist`); backwards — by hand, rarely needed.
- The stack changed (a major upgrade, a new framework): `/setup-stack` again + an ADR.

### 10.19 Performance dropped / an accessibility complaint
`/perf-audit web https://staging…` (or `api`, `db`, `game`) — ranked fixes → stories.
`/a11y-audit /route` — WCAG criteria with fixes. Budgets live in the product spec (NFRs) and the game concept.

### 10.20 A database migration went wrong
Stop the deploy; `/deploy rollback` rolls back the image, **not the data** — expand/contract
migrations (from `/data-model`) must be reversible; check the `down` step in
`production/releases/vX.Y.Z.md` (rollback section), restore from the backup `/deploy` Phase 2 took.
Then `/incident`.

### 10.21 Game: the prototype is not fun
`/game-concept gate` — records the no-go with reasons; then `/brainstorm` on the core loop or
`/game-concept` again; no backend/multiplayer stories before a go.

### 10.22 A pivot / the scope changes a lot
`/impact "<new direction>"` → product-director → `/product-spec` (retrofit, scope/goal sections) →
`/feature-spec` of the affected features → old stories ❌ in the roadmap → `/create-stories` →
`/threat-model` for new surfaces → `/architecture-review`.

### 10.23 "Without the studio for a moment" (a quick experiment)
A `spike/…` branch, no `/dev-story`; the security hooks still run. The spike ends as an ADR
(`/architecture-decision` with the outcome) or a deleted branch. A spike never merges into the default branch.

### 10.24 Removing the studio from a project
`claude plugin uninstall web-studio` (same scope). Project files (`docs/`, `production/`, `CLAUDE.md`)
stay — they are your documents. `.claude/docs`, `.claude/rules`, the studio block in
`.claude/settings.json` — delete by hand if you want; copy mode: delete `.claude/agents`,
`.claude/skills` and the hooks from `settings.json`.

### 10.25 Limits / cost / slow
- `/team-*`, `/architecture-review`, `/threat-model` run on Opus — the most expensive; step by step
  (`/feature-spec` → `/api-contract` → …) is cheaper and more controllable.
- `/help`, `/sprint-status`, `/changelog`, `/a11y-audit` — Haiku, cheap, run them often.
- A long session → compaction; better to finish the story and start a new session with `/dev-story`.
- Quota ran out mid-story: is the code committed on the branch by phase? If not — `git commit` by hand
  (`feat(S-NNN): wip`), fill `active.md` by hand from `.claude/docs/templates/session-state.md`; the
  next session continues from `Task:`.

### 10.26 An urgent hotfix while a story is in progress
```
git stash -u  (or a wip commit on the story branch)       — keep the current work
/hotfix "<bug>"                                          — branch from the release tag, test, fix, deploy, backport PR to the default branch
git switch feat/S-NNN-… && git merge origin/master       — after the backport merges, bring the fix into the story
git stash pop
```
`active.md`: put "hotfix INC-NNN" under `Blocked:` for the duration, `Next:` — back to the story.

### 10.27 A regression found days after the release
`/incident "<what>" --sev 2` (users were affected — a postmortem even for a quick fix) → decide:
rollback (`/deploy rollback` to the previous tag if the migrations are reversible) or `/hotfix`
forward (data has accumulated in the new schema — forward only) → a postmortem action: which test or
audit should have caught it → a story for that test.

### 10.28 An outside researcher reported a vulnerability
1. Do not argue in public; thank them, ask for details privately.
2. `/incident "<report>" --sev 1|2` — containment (disable the endpoint, limits) until the fix.
3. Reproduce: `/security-audit <path>` or `/pentest <staging-url> --scope staging --quick`.
4. `/hotfix` → `/threat-model <surface>` (why the surface was missing) → `/harden`.
5. Reply to the researcher after the deploy; a data leak means notifying users (a legal matter outside the studio).

### 10.29 A breaking API change with external consumers
`/impact` → architecture → an ADR on versioning → `/api-contract` (the new version next to the old,
deprecation dates in the SDL/OpenAPI; the CI diff check flags breaking changes) → `/changelog` with a
BREAKING section → a major bump → coexistence period → a story to remove the old version.
GraphQL: `@deprecated(reason:)` instead of removal; REST: `/v2`. `/api-contract --deprecate <field> --remove-after
<date>` does all of it: the mark, the CI date rule, the BREAKING entry and the removal story.

### 10.30 Too many permission prompts from Claude Code
Not the studio's hooks but `permissions` in `.claude/settings.json`. `/init` writes a base allow list
(`settings.plugin-mode.json`); add your commands to `permissions.allow` (`Bash(go test:*)`,
`Bash(pnpm:*)`). Never allow `Bash(*)` and never drop the deny on `.env`.

### 10.31 Hooks are silent or failing
- Nothing printed at start → the plugin is not in this scope (`claude plugin list` from the project
  root) or copy mode without hooks in `settings.json` → `/update` / `install.sh`.
- "jq: command not found" — the hooks fall back to python3; without that too, install jq.
- A hook timing out (`validate-deps`, 60 s on a large `npm i --dry-run`) — a warning, not a block;
  a dependency cache helps more than disabling it.
- Foreign hooks disappeared after `/init` → the studio's version is in `.claude/settings.web-studio.json`;
  `/adopt settings` shows the diff and merges the arrays.

### 10.32 Package registries / documentation unreachable (network)
`/stack-update` and `validate-deps` reach npm, packagist, pkg.go.dev and llms.txt files. When
blocked: run through your proxy, or `/stack-update --check-only` later; never let an agent "guess"
versions — the `validate-deps` hook and the stack reference exist for exactly that.

### 10.33 Tests need data, accounts, external services
`/qa-plan` — the test data / environment section: seeds, fixtures, testcontainers (`/test-setup --apply`
configures them), mocks for external APIs; e2e accounts are test-only, listed in `.env.example`. Live
keys in CI only for a separate, manually triggered smoke job.

### 10.34 Coverage / lint fell below the threshold after a merge
Thresholds live in `docs/architecture/test-strategy.md` and CI (`/test-setup`). Do not lower the
threshold in a feature branch: a "restore coverage" story via `/tech-debt`, or revisit the threshold in an ADR.

### 10.35 Working from several machines
A `--scope local` plugin is installed per machine; `production/session-state/`, `session-logs/` and
`.claude/settings.local.json` are gitignored — state travels between machines through commits on the
branch and the roadmap, not `active.md`. Start the day with `git pull --ff-only` (the hook reminds you).

### 10.36 Renamed the default branch, the repository, or moved it
The start hook takes the default branch from `origin/HEAD`; after a move run
`git remote set-head origin -a`. Re-authorise `gh` when the owner changes. Update absolute `🔗 PR #N`
links in the roadmap with a `docs:` commit.

### 10.37 A licence conflict in the dependencies
`/dependency-audit` (licence check) → a finding → an ADR on replacing or accepting → a replacement
story; for code copied from other repositories — `NOTICE`/attribution by hand: the studio does not check
it, `/code-review <paths>` looks at correctness and security only.

### 10.38 A user asks for data deletion / GDPR / PII
`/data-model` holds the PII classification and the deletion/anonymisation strategy; if missing —
`/data-model full` (retroactively) → `/threat-model` (the "export/deletion" surface) → an "account
deletion" story with the criterion "no data left in the database, in backups older than N days, or in
logs". The legal requirement itself is outside the studio. The data model §6 table (field · class · retention ·
deletion method) and the threat model's export/deletion surface are where the answers live; `/create-stories`
proposes the "Data deletion" story when they are missing.

### 10.39 The TLS certificate expired / the domain does not resolve
A sev 1 incident (`/incident`); fixed on the host (renew, DNS) — through the deploy delegate or by
hand; then `/harden tls` with a live `testssl`/curl check and a postmortem action: certificate-expiry
monitoring (the Observability story).

### 10.40 Cheaters / abuse in multiplayer or the API
`/threat-model <surface>` (anti-cheat, rate limits, origin) → `/security-audit api` → `/harden proxy`
(limits, WebSocket protections) → stories; server authority is already in the netcode ADR
(`/team-game` requires it).

### 10.41 You need advice, not an artefact
Ask directly: "ask backend-lead how best to…" — the agent answers with options and costs; that does
not break principle 7 as long as the outcome does not turn into an ADR or a spec in the chat. Once the
conversation converges on a decision — the skill (`/architecture-decision`, `/feature-spec`), otherwise
there is no document and `/help` never sees the step.

---

## 11. Command → artefact → when

| Command | Artefact (evidence) | Required | When |
|---|---|---|---|
| `/init` | `.claude/docs/technical-preferences.md`, `production/*.txt` | ✔ | once |
| `/start` | `review-mode.txt`, `stage.txt`, the route | | new project |
| `/adopt [full\|stack\|docs\|settings]` | `docs/adoption-plan-<date>.md`, filled technical-preferences | | existing project |
| `/setup-stack [type] [--quick]` | technical-preferences without `[TO BE CONFIGURED]` | ✔ | start / stack change |
| `/brainstorm` | concept brief | | vague idea |
| `/product-spec` | `docs/specs/product-spec.md` | ✔ | before features |
| `/game-concept` / `gate` | `docs/specs/game-concept.md`, `production/releases/gate-prototype.md` | games | before / after the prototype |
| `/feature-spec` | `docs/specs/features/F-NNN-*.md` | ✔ | per feature |
| `/ux-spec`, `/design-system` | `docs/specs/ux/UX-NNN-*.md`, `docs/specs/design-system.md` | | UI |
| `/threat-model [surface]` | `docs/architecture/threat-model.md` | ✔ | before code; a new surface |
| `/architecture-decision` | `docs/architecture/adr-NNNN-*.md` | ✔ | every significant decision |
| `/api-contract`, `/data-model` | `docs/architecture/api/*`, `data-model.md` | | before the backend |
| `/test-setup --apply` | `docs/architecture/test-strategy.md` + configs | ✔ | before code |
| `/architecture-review` | PASS/CONCERNS/FAIL report | | gate → build, quarterly |
| `/create-stories F-NNN` | `production/stories/F-NNN/S-NNN-*.md`, roadmap | ✔ | after the spec |
| `/sprint-plan`, `/qa-plan`, `/sprint-status` | `production/sprints/*.md` | | sprint |
| `/impact` | verdict + hand-off | | any proposal outside a story |
| `/dev-story`, `/code-review`, `/story-done` | branch, PR, tests, roadmap `[x]` | ✔ | every story |
| `/security-audit`, `/dependency-audit`, `/harden`, `/pentest` | `docs/security/*.md`, `production/findings.md` | ✔ (pentest optional) | hardening, periodic |
| `/perf-audit`, `/a11y-audit` | `docs/ops/perf-audit-<date>.md`, a11y report | ✔ | before a release |
| `/changelog`, `/release-checklist`, `/deploy` | `CHANGELOG.md`, `production/releases/vX.Y.Z.md`, tag | ✔ | release |
| `/hotfix`, `/incident` | hotfix branch + PR, `docs/ops/incidents/INC-NNN.md` | | operate |
| `/tech-debt`, `/stack-update`, `/update` | `docs/ops/tech-debt-<date>.md`, `.claude/docs/stack-reference/*`, refreshed docs/rules | | periodic |
| `/skill-test`, `/skill-improve` | studio test reports | | after editing skills |
| `/backlog add\|review\|promote` | `production/backlog.md` (`I-NNN`) | | any musing; weekly |
| `/migrate [type] [--dry-run]` | documents converted to the current templates | | after `/adopt`, after template drift |
| `/docs [readme\|api\|guide\|runbook]` | `README.md`, API reference, guide pages, `docs/ops/deploy.md` | | before a hand-over or release |
| `/retrospective NN` | `## Retrospective` in the sprint file, actions in the roadmap | | sprint end |
| `/architecture-review code`, `/harden secrets`, `/api-contract --deprecate` | drift findings, rotation checklist, deprecation in the contract | | brownfield / leak / breaking change |

---

## 12. What the studio does not do (yet)

Everything the playbook names has a command as of this version. Gaps still open are tracked in
[`roadmap.md`](roadmap.md); when a situation here has no command, that file says whether one is planned.
