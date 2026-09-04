# Web Studio Testing Framework

Quality-assurance infrastructure for **the studio itself**: it tests the skills and agents
(`skills/`, `agents/`), not the project built with them.¹

> Self-contained and optional. In the kit repository it is always present (`testing/`); into a
> project it is copied with `install.sh <project> --with-testing` (as `web-studio-testing/`).
> Removing it breaks nothing — `/skill-test static` works without it.

## Layout
```
testing/
├── README.md              ← this file
├── CLAUDE.md              ← instructions for Claude when using the framework
├── catalog.yaml           ← registry: every skill and agent, category/tier, spec path, last-test dates
├── quality-rubric.md      ← PASS/FAIL metrics per skill category and agent tier
├── skills/<category>/     ← behavioural specs for skills (5 cases + protocol)
├── agents/<tier>/         ← behavioural specs for agents (5 cases + protocol)
├── templates/             ← templates for new specs
└── results/               ← run outputs (/skill-test spec), gitignored
```

## Usage
```
/skill-test static all             # structural linter for every skill (8 checks)
/skill-test static dev-story       # one skill
/skill-test spec security-audit    # evaluate a skill against its behavioural spec
/skill-test category all           # rubric metrics per category
/skill-test agent graphql-engineer # agent: static + spec
/skill-test agent all
/skill-test audit                  # coverage and last-run dates
/skill-improve dev-story           # test → fix → retest loop
/skill-improve agent:backend-lead
```
(Plugin mode: `/web-studio:skill-test …`.)

## Skill categories
| Category | Skills | Key metrics |
|---|---|---|
| `onboarding` | init, start, help, adopt, setup-stack, stack-update, update, skill-test, skill-improve | state detection before questions; one next step; project data never overwritten; language chosen by the user |
| `authoring` | brainstorm, product-spec, feature-spec, ux-spec, design-system, game-concept, architecture-decision, api-contract, data-model, threat-model, test-setup | template from `templates/`; section by section; "May I write?"; security/accessibility sections |
| `review` | architecture-review, code-review | read-only; routing to specialists; BLOCKING/WARNING/INFO; ADR conformance |
| `pipeline` | create-stories, dev-story, story-done | input checks (spec/contract/ADR); criterion ↔ test; BLOCKED on missing inputs |
| `sprint` | sprint-plan, sprint-status, changelog, release-checklist, qa-plan | status from artefacts; verdict word; no self-advancing gates |
| `analysis` | security-audit, dependency-audit, perf-audit, a11y-audit, tech-debt, pentest, harden | tools with output; findings with file:line/severity/fix; templated report; pentest only on the project's own systems |
| `team` | team-feature, team-security, team-release, team-game | parallel independent Tasks; BLOCKED surfaced; partial report |
| `ops` | deploy, hotfix, incident | every production mutation confirmed; rollback described; delegation to a deploy skill |

## Agent tiers
| Tier | Agents |
|---|---|
| `directors` | technical-director, product-director |
| `leads` | backend-lead, frontend-lead, design-lead, security-lead, qa-lead, devops-lead, game-lead |
| `backend` | go-engineer, php-engineer, node-engineer, database-engineer, api-designer, graphql-engineer |
| `frontend` | angular-engineer, vue-engineer, typescript-engineer, css-engineer, accessibility-specialist, seo-specialist |
| `game` | threejs-engineer, web-game-engineer, multiplayer-engineer |
| `security` | appsec-engineer, network-security-engineer |
| `quality-ops` | test-engineer, performance-engineer, devops-engineer, tech-writer |

## Writing a spec
Copy a template from `templates/`, fill in 5 cases (happy path, refusal/BLOCKED, mode variant,
edge case, gate/escalation) with verifiable assertions, add the path to `catalog.yaml`.
A spec describes the **expected behaviour according to the skill/agent text** — `/skill-test spec`
looks for instructions confirming each assertion and quotes the line.

## When to run
- After editing any file in `skills/` or `agents/` (the hook reminds you).
- After `/update` — `static all` + `audit`.
- Before releasing a new kit version — `category all`, `agent all`.

---
¹ Inspired by the skill testing framework of the Claude Code Game Studios template.
