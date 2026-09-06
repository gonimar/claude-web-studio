---
name: skill-improve
description: "Improves a skill or agent with a test → fix → retest loop: runs /skill-test static (+category/spec), proposes targeted edits, applies them with approval, re-tests, keeps or reverts by score. Use after a failed /skill-test or after editing skills or agents."
argument-hint: "[skill-name | agent:<name>] [--max-iterations N]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, AskUserQuestion
model: sonnet
---

# Skill Improve

## Phase 1: Target
`<name>` → the skill's `SKILL.md` (kit `skills/<name>/`, copy mode `.claude/skills/<name>/`); `agent:<name>` → the agent file. Missing → stop.

## Phase 2: Baseline
`/skill-test static <name>` (or `agent <name>`), then `category`/`spec` when a spec exists. Record the score: FAIL/WARN per check and metric.

## Phase 3: Edits
For every FAIL/WARN — a targeted change (add "May I write?", a phase, a verdict, a reference link, a next step, refine `argument-hint`, add a missing frontmatter field). Never rewrite the whole skill. Show the diff; "May I write?" as one `AskUserQuestion`: apply (Recommended) · apply part (say which) · skip.

## Phase 4: Retest
Repeat the checks; score improved → keep, otherwise revert (`git checkout -- <file>` or show the reverse diff) with an explanation. Up to `--max-iterations` (default 2).

## Phase 5: Catalog
Update `last_*` in the framework's `catalog.yaml` (with consent); if no spec exists — offer to create one from the template.

Verdict: `IMPROVED (a→b)` | `NO CHANGE` | `REVERTED`. Next step — one `AskUserQuestion`: `/skill-test audit` (Recommended) · `/skill-improve <next name>` · stop here.
