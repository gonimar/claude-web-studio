# Web Studio for Claude Code

**Read in:** English · [Русский](docs/readme/README.ru.md) · [Español](docs/readme/README.es.md) · [Deutsch](docs/readme/README.de.md) · [中文](docs/readme/README.zh.md)

Web Studio turns Claude Code into a full web development studio: 30 specialised agents in
three tiers, 44 slash commands that form a pipeline from idea to production, hooks that guard
secrets and commit hygiene, path-scoped coding rules, document templates, a **dated reference of
current stack versions and best practices**, and a framework for testing the agents themselves.
It covers web applications and browser games alike.¹

Stack: Go 1.27 · PHP 8.5 / Yii3 · TypeScript 7 / Node 24 · Angular 22 (Material, Taiga UI) ·
Vue 3.5 / Nuxt 4 · Vite 8 · GraphQL first, REST where it fits · PostgreSQL 18 · three.js r185 /
PixiJS 8 / Phaser · Vitest 4 / Playwright · Docker / GitHub Actions · OWASP Top 10:2025 · WCAG 2.2 AA.

The conversation language is chosen per project (`/init` asks); code, identifiers and commit
messages stay in English.

---

## 1. Install

### Option A — Claude Code plugin (recommended)
```bash
claude plugin marketplace add <owner>/claude-web-studio   # private repo: gh auth login && gh auth setup-git
claude plugin install web-studio@claude-web-studio        # --scope user (default) | project | local
```
Agents, skills and hooks are now available in every project. Skills are namespaced:
`/web-studio:init`, `/web-studio:help`, … Update with `claude plugin update web-studio`.

### Option B — vendored copy inside the project
```bash
git clone <this repo> ~/tools/claude-web-studio
~/tools/claude-web-studio/install.sh /path/to/project            # add --with-testing for the agent test framework
```
Everything lives in the project's `.claude/` directory, no plugin dependency, skills without a
prefix (`/init`, `/help`). Update by re-running the installer or with `/update`.

### Option C — new project from the template
```bash
~/tools/claude-web-studio/install.sh --new /path/to/new-project
```
Creates the directory, runs `git init`, installs option B and writes a starter `CLAUDE.md`.

Options A and B coexist: a plugin gives central updates, a copy is fully editable per project.

---

## 2. First session
1. Open Claude Code in the project and run **`/init`** (plugin: `/web-studio:init`). It asks the
   conversation language and the review mode (`lean` for solo work, `full` for teams, `solo` for
   no gates), then creates the project files: `CLAUDE.md` sections, `.claude/docs/` (stack
   reference, templates, roster), `.claude/rules/`, `docs/`, `production/`.
2. **New idea?** run `/start` — it asks where you are (idea / clear product / browser game /
   existing code) and routes you.
   **Existing code?** run `/adopt` — it detects the stack from lockfiles, audits what documents
   exist, merges settings and writes a numbered adoption plan.
3. Follow the pipeline. `/help` always tells you the current phase and the single next command.

Pipeline: **discovery → specification → architecture → build → hardening → release → operate**
(`.claude/docs/workflow-catalog.yaml`). Phase gates are advisory — you decide.

## 3. Coming back in a new session
Nothing needs to be re-explained. When a session starts, the hook prints the branch, recent
commits, the current stage, the stack-reference age and — if you left work unfinished — the
contents of `production/session-state/active.md` (`Task:`, `Branch:`, `Next:`, `Blocked:`).
`CLAUDE.md` is loaded automatically, so the language, stack and principles are known.

Typical return: read the session summary → `/help` → continue with the command it names
(usually `/dev-story S-NNN` or `/code-review --diff`). Before context compaction the hook dumps
the same state, and `/dev-story` keeps `active.md` updated as it works. The plan of record is
`production/roadmap.md` (a checkbox list); sprints and stories live in `production/`.

## 4. How the studio works
- **Agents** are tiered: two directors (Opus) decide, seven leads (Sonnet) design and review,
  twenty-one specialists implement. Skills route work to the right agents automatically.
- **One protocol for every agent**: ask when the spec is unclear → offer 2–3 options with costs →
  you decide → show a draft → "May I write?" → verify by running tests and commands.
- **Nothing is claimed done without evidence**: acceptance criteria map to tests, and
  `/story-done` runs them.
- **Security is built in**: hooks block secrets in commits and files and force-pushes; every
  sensitive path gets an application-security review; the release gate requires clean audits.
- **The stack reference is the source of truth for versions**: agents read
  `.claude/docs/stack-reference/<technology>.md` before working and warn when it is older than
  60 days. `/stack-update` refreshes it from official sources.

---

## 5. All commands
Plugin mode prefixes each with `web-studio:`.

**Onboarding and maintenance**
- `/init` — scaffolds the studio files in the project, asks the conversation language and review mode, merges settings.
- `/start` — onboarding for a new project: asks where you are and routes to the right first steps.
- `/help` — shows the current phase, which steps are done and the single next command.
- `/adopt` — attaches the studio to an existing project: detects the stack, audits documents, produces an adoption plan.
- `/setup-stack` — chooses and pins the stack (backend, frontend, API style, engine, database, tests, CI) with exact versions.
- `/stack-update` — refreshes the stack reference from official sources with dates and proposes an upgrade plan for the project.
- `/update` — updates the studio itself in the project (plugin update or copy-mode reinstall) while keeping local edits.
- `/skill-test` — lints skills and agents, evaluates them against behavioural specs and reports coverage.
- `/skill-improve` — runs a test → fix → retest loop on one skill or agent.

**Product and design**
- `/brainstorm` — explores a vague idea into a concept brief with audience, differentiation and hypotheses.
- `/product-spec` — writes the product specification section by section with goals, users, scope, NFRs and risks.
- `/feature-spec` — writes one feature's specification with scenarios, rules, contract, states, edge cases, security and acceptance criteria.
- `/ux-spec` — specifies a flow or screen with every state, copy, accessibility and responsive behaviour.
- `/design-system` — defines design tokens, themes and the component inventory, mapped onto Material, Taiga or a Vue kit.
- `/game-concept` — writes a browser-game concept with core loop, mechanics, economy, feasibility budgets and a prototype plan.

**Architecture**
- `/architecture-decision` — creates or retrofits an ADR with options, decision, consequences and verification.
- `/architecture-review` — cross-checks ADRs, contracts, data model, threat model and specs for consistency (read-only).
- `/api-contract` — designs the API contract before code: GraphQL SDL by default, or OpenAPI/AsyncAPI/WebSocket protocols.
- `/data-model` — designs entities, PostgreSQL DDL with justified indexes and expand/contract migrations.
- `/threat-model` — builds the STRIDE threat model per attack surface with mitigations and priorities.
- `/test-setup` — sets up the test strategy and configuration for the chosen stack, from unit to e2e and security.

**Build**
- `/create-stories` — slices a feature spec into vertical-slice stories with a criteria-to-test matrix.
- `/dev-story` — implements one story end to end through the right engineers, with tests and a criteria check.
- `/code-review` — reviews files or the current diff for correctness, standards, ADR conformance, security and performance.
- `/story-done` — verifies a story is truly done (tests run, checks green, review approved) and closes it.
- `/sprint-plan` — plans a sprint from ready stories, capacity and dependencies.
- `/sprint-status` — reports sprint progress from artefacts, blockers and risk to the goal.
- `/qa-plan` — maps every story's acceptance criteria to test levels, tools and files for a sprint.
- `/tech-debt` — inventories technical debt and proposes prioritised stories.

**Hardening**
- `/security-audit` — audits code and configuration against OWASP Top 10:2025 with tools, CVSS-scored findings and fixes.
- `/dependency-audit` — audits the supply chain: vulnerabilities, abandoned packages, outdated majors, licences, pinning.
- `/harden` — hardens headers, TLS, proxy, containers and CI, verifying with live requests.
- `/pentest` — runs authorised dynamic testing against the project's own application within a recorded scope.
- `/perf-audit` — measures Core Web Vitals, bundles, API latency, queries or game frames against budgets and ranks fixes.
- `/a11y-audit` — audits accessibility against WCAG 2.2 AA with axe and a manual keyboard checklist.

**Release and operations**
- `/changelog` — generates the changelog from Conventional Commits and proposes the version bump.
- `/release-checklist` — runs the release gate from evidence and writes the release file with rollback steps.
- `/deploy` — plans and executes a deployment with confirmations, smoke checks and rollback, delegating to a deploy skill if one is installed.
- `/hotfix` — fast-tracks an urgent production fix from a failing test to deploy and backport.
- `/incident` — coordinates incident response and writes a blameless postmortem.

**Teams (orchestration)**
- `/team-feature` — delivers a whole feature: contract → data → backend → frontend/game → tests → security and code review.
- `/team-security` — runs the full security cycle: threat model, audits, hardening, optional pentest, consolidated report.
- `/team-release` — ships a version: parallel audits → changelog → checklist → deploy → verification.
- `/team-game` — builds a playable game slice: simulation, rendering, UI overlay, optional multiplayer, measurements.

---

## 6. Three walkthroughs

### A. A SaaS dashboard on Go + GraphQL + Angular
```
/init                      → language: English, review mode: lean
/start                     → "B) clear product", type: fullstack
/setup-stack               → Go 1.27, GraphQL (gqlgen), Angular 22 + Taiga UI 5, PostgreSQL 18, Playwright
/product-spec "Team analytics"
/feature-spec "Workspace members"
/api-contract F-001        → schema.graphql with Relay connections and payload errors
/data-model F-001          → tables, indexes, migration
/threat-model              → surfaces: auth, GraphQL, invites
/test-setup --apply
/create-stories F-001      → S-001 contract+codegen, S-002 resolvers, S-003 Angular page, S-004 e2e
/dev-story S-001 … /code-review --diff … /story-done S-001   (repeat per story)
/team-security pre-release → /release-checklist 0.1.0 → /deploy 0.1.0
```

### B. A content site on PHP/Yii3 + Nuxt with SEO, adopted from existing code
```
/init                      → language: Español, review mode: solo
/adopt                     → detects PHP 8.5 / yiisoft/* and Nuxt 4 from lockfiles, finds no ADRs, writes docs/adoption-plan-<date>.md
/architecture-decision retrofit docs/adr/old-decision.md
/api-contract --style rest → OpenAPI for the public content API and webhooks
/ux-spec "Article page"    → states, copy, accessibility
/dev-story S-012           → Nuxt SSR page + Yii3 endpoint, tests included
/a11y-audit /articles      → WCAG findings fixed
/perf-audit web https://staging.example → LCP/INP within budget
/harden --apply            → CSP with nonce, HSTS, Caddy limits
/team-release 2.3.0
```

### C. A multiplayer browser game on three.js with a Go server
```
/init                      → language: Chinese, review mode: lean
/start                     → "C) browser game"
/setup-stack game+backend  → three.js r185 (WebGPU + fallback), Go WebSocket server, PostgreSQL for profiles
/game-concept "Orbital Drift"   → core loop, budgets (16.6 ms, ≤150 draw calls), spikes
/architecture-decision "Engine and netcode"  → three.js + server-authoritative simulation at 30 Hz
/api-contract --style ws   → versioned binary protocol
/team-game prototype       → simulation, rendering, UI overlay and server built in parallel, frame measurements
/perf-audit game           → draw calls, memory, 4G load time
/a11y-audit                → remapping, subtitles, colour-blind mode, keyboard menus
/security-audit api        → WebSocket origin, rate limits, anti-cheat checks
/release-checklist 0.1.0 → /deploy
```

A fourth, everyday case — returning after a break: open the project, read the session summary,
`/help`, `/sprint-status`, then `/dev-story` for the story it names.

---

## 7. Keeping it current
- `/stack-update` pulls the latest versions and practices from official sources (llms.txt of
  Angular, Vue, Vite, Nuxt, Vitest, Taiga, three.js, Pixi, Babylon, Hono, NestJS; release pages of
  Go, PHP, Yii3, TypeScript, GraphQL; endoflife.date), rewrites `docs/stack-reference/` with dates
  and links and compares them with the project's lockfiles.
- `/update` updates the studio in a project and preserves local edits; project data
  (`docs/specs`, `docs/architecture`, `production/`, a configured `technical-preferences.md`,
  `CLAUDE.md`) is never overwritten.
- Kit releases: bump `version` in `.claude-plugin/plugin.json` and add a `CHANGELOG.md` entry —
  plugin users receive an update only when the version changes.

## 8. Testing the studio itself
`testing/` holds a catalog, a quality rubric and 74 behavioural specs. Run `/skill-test static all`,
`/skill-test spec <skill>`, `/skill-test agent <agent>`, `/skill-test audit`, or `/skill-improve <name>`
in this repository or in a project installed with `--with-testing`. Details: [testing/README.md](testing/README.md).

## 9. Repository layout
```
.claude-plugin/   plugin.json + marketplace.json (this repository is both the marketplace and the plugin)
agents/           30 agents        skills/     44 skills        hooks/      hooks.json + 10 scripts
rules/            13 path-scoped rules          docs/       stack-reference/, templates/, roster, workflow catalog, security baseline
templates/        CLAUDE.md, settings.json, settings.plugin-mode.json, statusline.sh
testing/          agent and skill testing framework      install.sh  copy-mode / new-project installer
```

## 10. Agents
| Tier | Agents |
|---|---|
| Directors (Opus) | `technical-director`, `product-director` |
| Leads (Sonnet) | `backend-lead`, `frontend-lead`, `design-lead`, `security-lead`, `qa-lead`, `devops-lead`, `game-lead` |
| Backend | `go-engineer`, `php-engineer`, `node-engineer`, `database-engineer`, `api-designer`, `graphql-engineer` |
| Frontend | `angular-engineer`, `vue-engineer`, `typescript-engineer`, `css-engineer`, `accessibility-specialist`, `seo-specialist` |
| Games | `threejs-engineer`, `web-game-engineer`, `multiplayer-engineer` |
| Security | `appsec-engineer`, `network-security-engineer` |
| Quality and operations | `test-engineer`, `performance-engineer`, `devops-engineer`, `tech-writer` |

Companion skills — an external strategic advisor or a deployment operator — are detected when
installed and used by `/start`, `/deploy` and the roster; they are not required.

## Contributing, requirements and licence
Want to add an agent, a skill or a technology, or fix something? See [CONTRIBUTING.md](CONTRIBUTING.md)
(local development, extension guides, pull requests, releases). Requirements: Claude Code with access
to `opus`, `sonnet` and `haiku`; `jq` optional (hooks fall back to python3); stack tools per project.
MIT licence; attributions in [NOTICE](NOTICE).

---
¹ The studio's structure is inspired by the [Claude Code Game Studios](https://github.com/Donchitos/Claude-Code-Game-Studios) template.
