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
| `pipeline` | create-stories, dev-story, story-done, refactor | input checks (spec/contract/ADR); criterion ↔ test; BLOCKED on missing inputs |
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

## Evals (`evals/`) — how they differ from specs
A **spec** (`testing/skills/…`, `/skill-test spec`) is read against the skill *text*: the checker
looks for the instruction that satisfies each assertion and quotes it. It costs one session and
never runs the skill. An **eval** (`evals/<skill>/<case>/`, `claude plugin eval`) *runs* the skill
in a fresh, isolated session on a scaffolded fixture and grades what happened: the final message
(`regex`), the tools called or not called (`tool_used`, `tool_order`), the files created
(`file_exists`). Evals prove behaviour; specs prove the text. A rule needs both: a spec line and,
for the critical skills, a case that fails without it.

- Cases come from the spec cases (`case.yaml: description` names the spec case); graders are
  deterministic — a skill-specific verdict phrase, a tool that must or must not run, a file that
  must not exist before the gate. `llm` graders only for prose quality, never for a gate.
- Prompts are the slash form (`/web-studio:dev-story S-002`), so a case tests the skill's
  behaviour, not its triggering; triggering cases (natural-language prompt + `tool_used: Skill`)
  belong to the `trigger` tag and are measured separately.
- Fixtures are scaffolded by `evals/_lib/*.sh` from `testing/e2e/fixtures/` (`--scaffold`
  required). Runs are non-interactive and the eval runtime does not expose `AskUserQuestion` (its tool
  list is `Task, Bash, Edit, Glob, Grep, NotebookEdit, Read, Skill, TaskStop, ToolSearch, Write`, verified
  on 2.1.283 with the tool in `allowed_tools` and `--allow-tools`): a skill that reaches a gate prints
  the question and its options as text and stops — the graders check that nothing was written before it.
- Run locally: `claude plugin eval . --trust-plugin --scaffold --allow-tools Bash Write Edit Agent
  --ablation none --runs 1` (Linux needs `bubblewrap` and `socat`; the shell sandbox does not
  start as root). CI: `evals` job in `.github/workflows/ci.yml` — `workflow_dispatch` (optional
  case glob) and nightly, `--max-cost-usd 25`, results as an artifact. Not part of `run-all.sh`.
- Graders: a verdict is a `regex` on the final message (`last_message`; the `trace` target also holds every
  tool input and result, so a phrase that appears in a command or a file read would match there); a gate is a
  `regex` on the final message for the option text (`Recommended`, `git init`, `May I write`) plus
  `file_exists: false` / `tool_used: Write` 0× for what must not be written. `AskUserQuestion` stays in every
  case's `allowed_tools` so the gates switch to `tool_used: AskUserQuestion` once the runtime exposes it.
- `--threshold 1.0` with `--runs 2`: the first CI run defines the baseline — a case that is red on both runs is a
  grader or skill defect to fix, not a number to lower.
- `catalog.yaml` records `last_eval` / `last_eval_result` per skill next to `last_spec`; they are maintained by
  hand after a run (`/skill-test audit` does not read them yet).

## When to run
- After editing any file in `skills/` or `agents/` (the hook reminds you).
- After `/update` — `static all` + `audit`.
- Before releasing a new kit version — `category all`, `agent all`.

---
¹ Inspired by the skill testing framework of the Claude Code Game Studios template.
