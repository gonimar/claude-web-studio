---
name: skill-test
description: "Validates Web Studio skills and agents: static (structural linter), spec (behavioural spec evaluation), category (rubric metrics), agent (agent spec evaluation), audit (coverage report). Uses the testing framework (catalog.yaml, quality-rubric.md, specs) from the kit repository or a project copy."
argument-hint: "static [name|all] | spec [name] | category [name|all] | agent [name|all] | audit"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Bash, AskUserQuestion
model: sonnet
---

# Skill Test

Tests the studio's own skills and agents (not the project). Framework directory — the first found of:
`./testing` (kit repository), `./web-studio-testing` (project copy), the plugin root's `testing/`
(from the session-start "Plugin root:" line or `claude plugin list --json`). Without a framework only `static` works.
Skill sources: `./skills/*/SKILL.md` (kit repo), `.claude/skills/*/SKILL.md` (copy mode) or the plugin root's `skills/`; agents likewise.

| Mode | What | Cost |
|---|---|---|
| `static [name\|all]` | 8 structural checks of SKILL.md | low |
| `spec [name]` | evaluate a skill against its behavioural spec | medium |
| `category [name\|all]` | category rubric metrics | low |
| `agent [name\|all]` | agent static checks + agent spec evaluation | medium |
| `audit` | coverage: who has a spec, last tested, result | low |

## Phase 1: Arguments
Parse mode and target; unknown → usage and stop. Read the framework's `catalog.yaml` (categories, spec paths, dates).

## Phase 2A: static — 8 SKILL.md checks
1. Frontmatter starts on line 1 with `---`; fields `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools` — FAIL if missing.
2. ≥ 2 phases (`## Phase N` or ≥ 2 `##`) — FAIL.
3. A verdict word (`PASS|FAIL|CONCERNS|APPROVED|ACCEPTED|PROPOSED|NEEDS REVISION|NEEDS CHANGES|BLOCKED|COMPLETE|READY|DONE|UPDATED|CLEAN|RELEASED|DEPLOYED|HARDENED|PLAYABLE|COMPLIANT|INITIALISED|RESOLVED|MITIGATED|WITHIN BUDGET|OVER BUDGET|ON TRACK|AT RISK|OFF TRACK|FIXED|IMPROVED`) — FAIL.
4. Ask-before-write: `May I write` (or an explicit gate sentence) when `Write|Edit` is in `allowed-tools` — FAIL; otherwise WARN. A gate that is not an `AskUserQuestion` with alternatives (coordination-rules, rule 7) — WARN.
5. A "Next step" at the end — WARN; one that is not offered as an `AskUserQuestion` with alternatives — WARN.
6. A reference/template/rules link (`stack-reference/`, `templates/`, `rules/`) for authoring/analysis skills — WARN.
7. `argument-hint` non-empty and consistent with the argument-parsing phase — WARN.
8. Language: body in English, no project-specific or personal references (hostnames, names, private repo names) — WARN.
Output: a table of checks, `COMPLIANT | WARNINGS | NON-COMPLIANT`; for `all` — a summary table.

## Phase 2B: spec — behavioural evaluation
Read SKILL.md and the spec `skills/<category>/<name>.md`; for every case and assertion find the instructions in the skill text that satisfy it: PASS/FAIL/PARTIAL with a quoted line. Totals per case and protocol. "May I write the result to `results/<name>-<date>.md` and update `catalog.yaml`?" as one `AskUserQuestion`: results and catalog (Recommended) · results only · do not write.

## Phase 2C: category — rubric
The category section of `quality-rubric.md` → each metric PASS/WARN/FAIL with justification.

## Phase 2D: agent
Static: the agent file exists, `name/description/model/tools`, the collaboration protocol block, a stack-reference link, domain and "never"/escalation described. Then evaluate against `agents/<tier>/<name>.md` (5 cases) as in 2B.

## Phase 2E: audit
A table of all skills/agents: category/tier, spec present?, last_static/spec/category (date, result), priority. Uncatalogued files listed separately.

Verdict: `COMPLIANT` | `WARNINGS` | `NON-COMPLIANT`. Next step — one `AskUserQuestion`: `/skill-improve <name>` for failures (Recommended) · `/skill-test spec <name>` next · stop here.
