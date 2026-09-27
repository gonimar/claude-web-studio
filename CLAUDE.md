# claude-web-studio — rules for developing the kit itself

- The repository root is the plugin root: `agents/`, `skills/`, `hooks/`, `docs/`, `rules/`,
  `templates/`, `testing/`. `claude plugin validate .` and `claude plugin validate .claude-plugin/plugin.json` must
  pass before every commit (the first checks the marketplace manifest, the second the plugin).
- Talk to the maintainer in whatever language they use; tracked files stay in English (README
  translations in `docs/readme/`). Nothing personal or project-specific goes into tracked files (no real hosts, names, home paths,
  private project names). Local notes and development history live in `dev/` (gitignored).
- Facts about stack versions belong only in `docs/stack-reference/*.md` with `updated:` and
  `sources:`; refresh with `/stack-update` run here.
- Every new skill/agent gets a spec in `testing/` and a `catalog.yaml` entry; run
  `/skill-test static all` after editing skills or agents. Critical skills also have eval cases in
  `evals/` (`claude plugin eval`, see `testing/README.md` § Evals); a changed rule gets a case.
- Release: bump `version` in `.claude-plugin/plugin.json`, add a `CHANGELOG.md` entry,
  commit `chore(release): vX.Y.Z`. The installer must never touch project data — check
  `install.sh <scratch-repo> --dry-run` after changing it.
