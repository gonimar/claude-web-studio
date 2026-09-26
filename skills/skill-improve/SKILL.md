---
name: skill-improve
description: "Improves a skill or agent with a test → fix → retest loop: runs /skill-test static (+category/spec), proposes targeted edits, applies them with approval, re-tests, keeps or reverts by score. Use after a failed /skill-test or after editing skills or agents."
argument-hint: "[skill-name | agent:<name>] [--max-iterations N]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, AskUserQuestion
model: sonnet
---

# Skill Improve

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

## Phase 1: Target
`<name>` → the skill's `SKILL.md` (kit `skills/<name>/`, copy mode `.claude/skills/<name>/`); `agent:<name>` → the agent file. Missing → stop.

## Phase 2: Baseline
`/skill-test static <name>` (or `agent <name>`), then `category`/`spec` when a spec exists. Record the score: FAIL/WARN per check and metric.

## Phase 3: Edits
For every FAIL/WARN — a targeted change (add "May I write?", a phase, a verdict, a reference link, a next step, refine `argument-hint`, add a missing frontmatter field). Never rewrite the whole skill. Show the diff; "May I write?" as one `AskUserQuestion`: apply (Recommended) · apply part (say which) · skip. After the "write" answer: `touch .claude/.write-consent` (rule 7).

## Phase 4: Retest
Repeat the checks; score improved → keep, otherwise revert this iteration's edit with an explanation: apply the reverse of the Phase 3 diff, or `git checkout -- <file>` only when the file had no uncommitted changes before this run and this is the first iteration (otherwise it also discards the kept iterations and the user's own edits). Up to `--max-iterations` (default 2).

## Phase 5: Catalog
Update `last_*` in `testing/catalog.yaml` (with consent); if no spec exists — offer to create one from the template (`testing/templates/skill-test-spec.md`, for an agent `agent-test-spec.md`).

Verdict: `IMPROVED (a→b)` | `NO CHANGE` | `REVERTED`. Next step — one `AskUserQuestion`: `/skill-test audit` (Recommended) · `/skill-improve <next name>` · stop here.
