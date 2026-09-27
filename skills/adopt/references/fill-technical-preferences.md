# /adopt — filling `technical-preferences.md` (Phase 1 steps 6–7)

Read from `SKILL.md` Phase 1 step 6. Every field the files answer is written from the facts; the draft is a table field · value · source fact, shown at the Phase 1 write gate.

Fields, by section of `.claude/docs/technical-preferences.md`:
- Project type and Rendering: from the framework and routes.
- Backend: language/runtime, framework, database and cache from compose, API style from schema/openapi/routes, authentication if visible.
- Frontend: framework, build, styles; `vanilla` or `none` when there is none.
- Tests and quality: from `phpunit.xml`, `vitest.config`, `go test`, lint configs. Go: coverage thresholds only when a gate script or CI step enforces them, else `indicator`.
- Infrastructure: containers, CI, deploy from compose/workflows/deploy skills.
  - **Deploy target and delegate** by `.claude/docs/deploy-target-contract.md`: an agent `.claude/agents/*-ops.md` with `deploy-target:` in its frontmatter, or a `scripts/deploy/*.sh`. Detection goes by the frontmatter or the script, never by a command name: a kit that only ships a slash command is noted as `none` with the reason "kit ships only a slash command — add `deploy-target:` to its agent or a `scripts/deploy/<target>.sh`". The Tier 0 row of `agent-roster.md` (Phase 3 step 4) notes the companion the same way.
  - **Infra repo / Proxy config**: asked when the host is shared.
- Layout: `backend_root`, `frontend_root`, `go_layout`, `go_architecture` and its companions, `php_framework`, `php_architecture` and its companions (`references/detect-go.md`, `references/detect-php.md`).

Unknown fields (Phase 1 step 7): `[TO BE CONFIGURED]` may remain only for fields no file answers. Ask those in one `AskUserQuestion` (project type, API style, layout — whatever is still unknown) before the write gate, never in the same message as the gate (rule 7: one turn, one gate).
