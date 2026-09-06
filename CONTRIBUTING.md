# Contributing and extending Web Studio

This guide covers local development, adding agents, skills, technologies, rules, hooks and
templates, the pull-request process and releases. Tracked files are written in English;
README translations live in `docs/readme/` and are updated together with `README.md`.

## 1. Local development

```bash
git clone <your fork> ~/src/claude-web-studio && cd ~/src/claude-web-studio
git checkout -b feat/<topic>
```

Try your changes in two ways:

- **As a plugin from the local checkout** — Claude Code reloads plugin files within seconds:
  ```bash
  claude plugin marketplace add ./                     # registers this directory as a marketplace
  claude plugin install web-studio@claude-web-studio --scope local
  ```
  Open Claude Code in any scratch project and call `/web-studio:help`, `/web-studio:init`, …
- **In copy mode inside a scratch project** — closest to what users of `install.sh` get:
  ```bash
  ./install.sh --new /tmp/scratch-project --with-testing
  ```

Run the whole test suite before every commit:
```bash
tests/run-all.sh            # syntax, structure linter, hook smoke tests, installer tests, claude plugin validate
```
Individual parts: `python3 tests/validate-structure.py`, `bash tests/hooks.sh`, `bash tests/installer.sh`,
`claude plugin validate .`. Inside a Claude Code session in this repository you can also run
`/skill-test static all`, `/skill-test agent all` and `/skill-test audit` (see `testing/README.md`).

Local notes and history belong in `dev/` (gitignored). Never commit personal data, real hosts,
tokens or references to private projects.

## 2. Adding an agent

1. Create `agents/<name>.md`. Frontmatter (all required): `name` (must equal the file name),
   `description` (when Claude should delegate to it — this is what routing relies on), `tools`,
   `model` (`opus` directors, `sonnet` default, `haiku` for read-and-format roles), optional
   `maxTurns`, `skills` (preloaded skills), `memory: project`.
2. Body structure used by every agent: a one-paragraph role statement naming the lead it reports to
   and the stack-reference file it reads first; `## How you work` (numbered: spec → questions →
   sketch → code → tests → run with output) or `## Responsibilities` for leads; `## Never` with
   stack-specific prohibitions; and the shared **Collaboration protocol** block copied verbatim
   from any existing agent (the structure linter requires it).
3. Register it: a row in `docs/agent-roster.md`; mention it in the lead that delegates to it and in
   the skills that route to it (`/dev-story`, `/code-review`, `/team-*`); add it to the README agent
   tables (all languages).
4. Add a behavioural spec `testing/agents/<tier>/<name>.md` from `testing/templates/agent-test-spec.md`
   and an entry in `testing/catalog.yaml`.
5. `tests/run-all.sh` must pass.

## 3. Adding a skill

1. Create `skills/<name>/SKILL.md`. Frontmatter: `name` (equals the directory), `description`
   (what and when; the first sentence matters most), `argument-hint`, `user-invocable: true`,
   `allowed-tools`, `model`, optional `agent` (which agent runs it) and `context: fork`.
2. Body conventions the linter checks: at least two `## Phase N` sections; a verdict line with a
   word from the vocabulary (`PASS`, `FAIL`, `CONCERNS`, `APPROVED`, `BLOCKED`, `COMPLETE`, `READY`,
   `DONE`, …); an explicit "May I write …?" gate whenever `Write` or `Edit` is allowed; a closing
   `Next step:` naming the following command; references to the templates, rules or stack-reference
   files it relies on. Read-only skills say so in the first lines.
3. Register it: `docs/workflow-catalog.yaml` if it belongs to a phase; the one-sentence command
   lists in `README.md` and every `docs/readme/README.*.md`; `docs/PROJECT-README.md` if it is an
   entry point; the `skills:` preload list of an agent if it should be loaded with that agent.
4. Add a spec `testing/skills/<category>/<name>.md` from `testing/templates/skill-test-spec.md`,
   an entry in `testing/catalog.yaml`, and — if it is a new category — a section in
   `testing/quality-rubric.md`.
5. `tests/run-all.sh` must pass; a failing "commands not documented" check means a README list is missing the skill.

## 4. Adding or updating a technology

1. Add or edit `docs/stack-reference/<technology>.md` with the header
   ```
   ---
   updated: YYYY-MM-DD
   sources: [official docs, release notes, llms.txt …]
   ---
   ```
   Sections that every reference has: versions and support dates, the studio's default choices
   with reasons, idioms, security notes, a review checklist. Facts only from official sources;
   outdated statements are replaced, not kept beside new ones.
2. Add a row to `docs/stack-reference/index.md` (version on the date, file, llms.txt if any).
3. Wire it in: options in `docs/technical-preferences.md`; the interview in `skills/setup-stack`;
   the source table in `skills/stack-update`; a `rules/<technology>.md` with `paths:` globs if the
   technology has files of its own; the agents that should read the file first; `/adopt` detection
   (lockfile or config file names); the stack line in the README if it is a headline technology.
4. If the technology needs a specialist, follow section 2.

## 5. Rules, hooks, templates

- **Rules** (`rules/*.md`): frontmatter `paths:` with globs, then short imperative bullets and a
  link to the relevant stack reference. Rules are copied into projects by `/init` and `install.sh`.
- **Hooks** (`hooks/*.sh`): must work without `jq` (use the `jget` helper), exit `0` to allow,
  `2` to block with the reason on stderr, never block on `PostToolUse`. Register in both
  `hooks/hooks.json` (plugin mode, `${CLAUDE_PLUGIN_ROOT}` paths) and `templates/settings.json`
  (copy mode). Add a case to `tests/hooks.sh`.
- **Templates** (`docs/templates/*.md`): referenced by the authoring skill that fills them and by
  `rules/specs-docs.md`.

## 6. Pull requests

1. Branch from `master`: `feat/…`, `fix/…`, `docs/…`, `chore/…`.
2. Commits follow Conventional Commits (`feat(skills): add /example`); the repository's own
   `validate-commit` hook enforces this when you work through Claude Code.
3. `tests/run-all.sh` passes locally; CI runs the same suite plus shellcheck and `claude plugin validate`.
4. Update `CHANGELOG.md` under an "Unreleased" heading; do not bump the version in a feature PR.
5. Keep PRs focused: one agent, one skill or one technology per PR where possible. Describe what a
   user gains and which README lists you touched.
6. By opening a PR you agree that your contribution is licensed under the MIT licence of this repository.

## 7. Releases

1. Bump `version` in `.claude-plugin/plugin.json`, move the "Unreleased" changelog section under
   the new version with the date, commit `chore(release): vX.Y.Z`, tag `vX.Y.Z`, push with `--tags`.
2. Create the GitHub release on that tag — the tag alone is invisible on the Releases page:
   `gh release create vX.Y.Z --title vX.Y.Z --notes-file <the CHANGELOG section for X.Y.Z> --verify-tag`.
3. Plugin users receive the update only when the version changes (`claude plugin update web-studio`);
   copy-mode users re-run `install.sh` or `/update`.
4. Refresh the stack reference (`/stack-update` in this repository) at least every 60 days or before a release.

## 8. Licences

- This repository is licensed under the **MIT licence** (`LICENSE`). Contributions are accepted under the same terms.
- The studio's structure is inspired by the Claude Code Game Studios template (MIT); no code or text is copied from it.
- `docs/stack-reference/` summarises publicly available documentation and standards in the
  authors' own words and links to the originals; those originals remain under their own licences
  (e.g. OWASP materials under CC BY-SA 4.0, W3C documents under the W3C Document Licence, MDN
  content under CC BY-SA 2.5 / MIT for code samples). Do not paste substantial verbatim excerpts.
- Third-party tools referenced by name (Go, PHP, Angular, Vue, three.js, PostgreSQL, OWASP ZAP …)
  are used by projects under their respective licences; the kit ships no third-party code.
- `NOTICE` lists attributions; extend it when you add material that requires one.
