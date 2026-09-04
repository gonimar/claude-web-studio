# Web Studio — how this project uses the studio

This project is run with the Web Studio plugin for Claude Code: agents, skills, hooks,
path-scoped rules and a dated stack reference (`.claude/docs/stack-reference/`).

## Quick start
- `/init` — one-time scaffolding: conversation language, review mode, studio files.
- `/start` — new project: interview → stack → product spec.
- `/adopt` — existing project: detect the stack, audit artefacts, migration plan.
- `/help` — where you are in the pipeline and what comes next.
- `/team-feature <feature>` — a full vertical slice: spec → contract → backend → frontend → tests → review.
(Plugin mode: prefix skills with `web-studio:` if a bare name is ambiguous, e.g. `/web-studio:help`.)

## Coming back in a new session
The session-start hook prints the branch, stage, stack-reference age and `production/session-state/active.md`
(`Task:`/`Next:`) if work was left unfinished; `CLAUDE.md` is loaded automatically. Then `/help` names the next command.

## Pipeline
discovery → specification → architecture → build → hardening → release → operate
(details: `.claude/docs/workflow-catalog.yaml`).

## Keeping it current
- `/stack-update` — refresh version/practice references from official sources (llms.txt, release pages).
- `/update` — update the studio itself (plugin update or copy-mode reinstall); project data is never touched.

Studio version in this project: `.claude/.web-studio-version` (copy mode) or `claude plugin list`.
