---
name: stack-update
description: "Refreshes the stack knowledge base — checks the latest versions of every technology in stack-reference (official llms.txt, release pages, endoflife.date, npm/packagist/pkg.go.dev), rewrites the reference files with dated facts and sources, compares with the project's lockfiles, and proposes an upgrade plan. Run when references are older than 60 days or before planning upgrades."
argument-hint: "[project | all | <tech: go|php|yii3|symfony|laravel|typescript|angular|vue|graphql|threejs|database|testing|security|web-platform|tooling>] [--check-only]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, WebFetch, WebSearch, AskUserQuestion, Task
model: sonnet
---

# Stack Update

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

Web technology moves fast; the reference is a dated snapshot. This skill refreshes it on request:
facts only from official sources, with a date and a link.

## Phase 1: Scope and current state
`stack-reference/` below is `.claude/docs/stack-reference/` in a project and `docs/stack-reference/` in the plugin repository.
1. **Scope** from the argument: `project`, `all`, or one technology. **Without an argument the default depends on where the skill runs**, and the chosen scope is printed in one line before anything else:
   - **In a project** (a filled `technical-preferences.md` exists) the default is `project`: only the technologies the project uses (the stack section of `technical-preferences.md` and the lockfiles).
   - **In the plugin repository** (`docs/stack-reference/index.md` at the root and no `.claude/docs/technical-preferences.md`) the default is `all`.
   - **Anywhere else** — a project whose `technical-preferences.md` is still `[TO BE CONFIGURED]`, or no reference at all — there is no default: ask one `AskUserQuestion` (`all` (Recommended) · one technology · stop) instead of guessing the stack; no reference directory at all → `BLOCKED (no stack-reference found — run /init)`.
   - `all` refreshes every reference file and is meant for the plugin repository. In a project, say in one line that the copy will diverge from the plugin and be overwritten by the next `/update`.
   - One technology → only its reference file (and its `index.md` row).
2. **Print the list of files in scope** before collecting.
3. **Read** `stack-reference/index.md` and the target files; list current versions and `updated:`.
4. **Read the project lockfiles** (`go.mod`, `composer.lock`, `pnpm-lock.yaml`/`package-lock.json`) for the actual project versions.

## Phase 2: Collect current data (in parallel, independent sources)
| Technology | Source |
|---|---|
| Angular / Material / Taiga | `https://angular.dev/llms.txt`, `https://angular.dev/roadmap`, npm `@angular/core`, `@angular/material`, `taiga-ui.dev/llms.txt` |
| Vue / Nuxt / Vite / Vitest | `vuejs.org/llms.txt`, `nuxt.com/llms.txt`, `vite.dev/llms.txt`, `vitest.dev/llms.txt`, GitHub releases |
| Go | `go.dev/doc/devel/release`, `go.dev/doc/go1.NN` |
| PHP / Yii3 / Symfony / Laravel | `php.watch/versions`, `php-fig.org` (PER-CS), `phpunit.de/supported-versions`, `yiiframework.com/news`, `symfony.com/releases`, `laravel.com/docs/releases`, packagist `yiisoft/*`, `symfony/framework-bundle`, `laravel/framework`, `phpstan/phpstan`, `vimeo/psalm`, `deptrac/deptrac`, `symplify/easy-coding-standard`, `friendsofphp/php-cs-fixer` |
| TypeScript / Node | `devblogs.microsoft.com/typescript`, `nodejs.org/en/about/previous-releases`, `endoflife.date/nodejs` |
| GraphQL | `spec.graphql.org`, GraphQL.js releases, gqlgen/Yoga/graphql-php releases |
| three.js / Pixi / Babylon | GitHub releases + Migration Guide wiki, `pixijs.com/llms.txt`, `doc.babylonjs.com/llms.txt` |
| PostgreSQL / Redis | `postgresql.org/docs`, `endoflife.date/postgresql`, `redis.io` |
| Security | `owasp.org/Top10`, ASVS releases, Mozilla guidelines |
| Web platform | `web-features` Baseline, `web.dev` CWV, W3C WCAG |
For each: latest stable version and date, next expected, EOL, key changes (breaking!), new best practices.
**Registry check, mandatory for packages**: `npm view <pkg> dist-tags` (and `version`), packagist `https://repo.packagist.org/p2/<vendor>/<pkg>.json` (highest stable), `go list -m -versions <module>` — the registry's `latest` on the date is recorded next to the recommended version; when the recommendation is a major behind `latest`, the reference states why (LTS, breaking changes, ecosystem support) — never an unexplained older version.
`WebSearch` only to clarify, never as the primary source.
**A source that cannot be reached** (no network, `WebFetch` denied, registry error) is reported by name and its row stays `not verified`; never fill a version from memory. When no source in scope could be reached, stop with `BLOCKED (sources unreachable: …)` and write nothing.

## Phase 3: Diff and proposal
Table "technology → in the reference → latest (registry, date) → recommended (why) → in the project → action (update reference / propose upgrade / none)".
For upgrades: path (e.g. `ng update`, three.js Migration Guide rNNN→rMMM, Go toolchain), risks, order.
`--check-only` — stop here.

## Phase 4: Write
1. **Show the reference changes**: updated lines, `updated:` and `sources:` in the header, new practices in the right section. Outdated statements are removed, not left beside new ones.
2. **Write gate**: "May I write [files] and their `index.md` rows?" — one `AskUserQuestion`: write (Recommended) · show the draft/diff first · not now.
3. After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker).
4. Write the reference files, then update `index.md`: each row's "latest on date" and its `Verified` column (the file's new `updated:` date); the header `updated:` of the index is the date of this table edit.
5. **Commit gate** (rule 7, `git-workflow.md` § Documents), right after the write: one `AskUserQuestion` offering `docs: refresh stack-reference (<scope>)`, staging exactly the written files (the reference files and `index.md`).
   - On the default branch when no story work is in progress.
   - When HEAD is a story branch, name it and ask: switch to the default branch and commit there (Recommended — a pipeline-wide document) · commit here (the document belongs to this story) · leave uncommitted.
   - Nothing is committed without the answer, and the files are never left uncommitted silently: a "leave uncommitted" answer is repeated in the result.

## Phase 5: Project upgrade plan (optional)
If upgrades exist — propose stories (`/create-stories`) or ADRs for majors; for each — how to verify (tests, build). Do not perform upgrades in this skill.

Verdict: `UPDATED (N files)` | `UP TO DATE` | `CHECK ONLY` | `BLOCKED (sources unreachable: …)` | `BLOCKED (no stack-reference found — run /init)`. Next step — one `AskUserQuestion`: `/help` (Recommended) · upgrade stories for the outdated majors · stop here.
