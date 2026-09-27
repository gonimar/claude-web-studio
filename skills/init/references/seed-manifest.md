# /init — Seed manifest (Phase 3)

Read from Phase 3 step 2: the plan shows every path below, marking existing files that differ. `<root>` exists in plugin mode only (SKILL.md glossary); in copy mode install.sh has already seeded the studio files, so the plan lists what is missing (CLAUDE.md sections, folders, `.gitignore` lines, `production/*.txt`) and names existing files that differ from the seed.

## Seed layout (plugin mode)
`<root>/docs` → `.claude/docs`, `<root>/rules` → `.claude/rules`,
`<root>/templates/CLAUDE.md.template`, `<root>/templates/settings.plugin-mode.json`, `<root>/templates/statusline.sh`,
`<root>/docs/PROJECT-README.md` → `docs/web-studio/README.md`.

## What will be created or changed
- `CLAUDE.md`: create from the template with the language filled in, or (if it exists) insert the
  `## Language`, `## Studio (Web Studio)`, `## Stack` and `## Working principles` sections without
  touching other content — show the exact insertion.
- `.claude/docs/` (stack-reference, templates, roster, coordination, workflow catalog, `playbook.md` with its `readme/PLAYBOOK.*.md` translations and `roadmap.md` — what `/help guide` reads, technical-preferences with `[TO BE CONFIGURED]`) — copy only files that do not exist; list existing ones that differ.
- `.claude/rules/` — same policy.
- `.claude/settings.json`: when missing, create it from the template of the mode — plugin mode `<root>/templates/settings.plugin-mode.json` (permissions + statusline; hooks are provided by the plugin); copy mode the kit's `templates/settings.json` (hooks + permissions + statusline), which install.sh applies — a missing file in copy mode means install.sh did not run: copy `.claude/settings.web-studio.json` when present, else name `install.sh` as the fix. When it exists, show a diff of `permissions.allow/deny` and `statusLine` to merge (copy mode: hooks already in `settings.json`).
- `.claude/statusline.sh`, `docs/web-studio/README.md`, `docs/{specs,architecture,security,ops}`, `production/{sprints,stories,releases,session-state,session-logs}`, `production/review-mode.txt`, `.gitignore` entries (`production/session-state/`, `production/session-logs/`, `.claude/settings.local.json`, `.claude/agent-memory-local/`).
- `production/stage.txt`: the value decided in Phase 3 step 1 (§ Stage).

## Stage (Phase 1 step 2, Phase 3 step 1)
Brownfield: code already exists when there is a manifest with sources (`composer.json`, `go.mod`, `package.json`), deploy files (`compose*.yaml`, `Dockerfile*`, `.github/workflows/*`) or a git history with more than a handful of commits.
`discovery` for an empty project. For brownfield, propose the stage from the facts — `build` (code, no release) or `operate` (deployed: release files, compose.prod, a deploy skill) — and confirm it in the "May I write?" question. Never write `discovery` over a project that is already running.
`operate` needs deploy artefacts **in the repository**. A README claiming a live URL alone is a signal to ask ("is it actually live, and is this working copy connected to that deployment?"), never to propose `operate` on its own: a detached copy of a deployed service is still `build`.
