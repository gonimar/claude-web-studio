# claude-web-studio — rules for developing the kit itself

- The repository root is the plugin root: `agents/`, `skills/`, `hooks/`, `docs/`, `rules/`,
  `templates/`, `testing/`, `tests/`, `evals/`; `.claude-plugin/` holds `plugin.json` and `marketplace.json`
  (this repository is its own marketplace). Commit gate: `bash tests/run-all.sh` (syntax, structure linter,
  hook smoke tests, installer tests, then `claude plugin validate .` and `claude plugin validate
  .claude-plugin/plugin.json` — the first checks the marketplace manifest, the second the plugin; both must pass).
- Path mapping: the kit's `docs/` and `rules/` become the project's `.claude/docs/` and `.claude/rules/`
  (`install.sh`, `/init`); skills, agents and rules are written against the project paths, so
  `.claude/docs/stack-reference/go.md` in a skill is `docs/stack-reference/go.md` here.
- Three test trees: `tests/` — the kit's own bash/python tests (run-all); `testing/` — behavioural specs for
  skills and agents (`/skill-test`, `catalog.yaml`); `evals/` — behavioural evals (`claude plugin eval`).
- Local dev loop: `claude --plugin-dir .` from a scratch project (`install.sh --new /tmp/x --with-testing` for
  copy mode; the marketplace route is in `CONTRIBUTING.md` § 1).
- Hooks: no `jq` (the `jget` helper); a warning that must reach the model is JSON via `warn`, never
  `permissionDecision`; exit 2 blocks on PreToolUse only; every hook is registered in both `hooks/hooks.json`
  and `templates/settings.json` and gets a case in `tests/hooks.sh`.
- Talk to the maintainer in whatever language they use; tracked files stay in English (README
  translations in `docs/readme/`). Nothing personal or project-specific goes into tracked files (no real hosts, names, home paths,
  private project names). Local notes and development history live in `dev/` (gitignored).
- Facts about stack versions belong only in `docs/stack-reference/*.md` with `updated:` and
  `sources:`; refresh with `/stack-update` run here.
- Every new skill/agent gets a spec in `testing/` (from `testing/templates/`) and a `catalog.yaml` entry; run
  `/skill-test static all` after editing skills or agents. Critical skills also have eval cases in
  `evals/` (`claude plugin eval`, see `testing/README.md` § Evals); a changed rule gets a case. A new
  command is added to the command lists of `README.md` and every `docs/readme/README.*.md` (run-all
  fails with "commands not documented" otherwise).
- The principles in `templates/CLAUDE.md.template` are cited by number from rules, skills and the playbook:
  extend the list, never renumber it; a cut principle stays as a one-line pointer with its number.
- Release: bump `version` in `.claude-plugin/plugin.json`, add a `CHANGELOG.md` entry,
  commit `chore(release): vX.Y.Z`. The installer must never touch project data — check
  `install.sh <scratch-repo> --dry-run` after changing it. Extension guides: `CONTRIBUTING.md`.
