---
name: code-review
description: "Reviews the branch's diff (`--diff`, the PR's changes) or given files for correctness, standards, ADR adherence, OWASP security, performance and testability, routing files to the studio's lead and specialist and to appsec-engineer for sensitive paths. Read-only BLOCKING/WARNING/INFO. The studio's review, not Claude Code's built-in: use for 'review my changes', 'review the diff', 'review this PR'."
argument-hint: "[paths | --diff] [story-path] [--security]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Task, SendMessage, AskUserQuestion
---

# Code Review

Language, `<hooks>`, agent and command namespaces, gate mechanics and the built-in `/code-review` collision in plugin mode: `docs/coordination-rules.md` § Skill conventions (reviewers: § Subagents).

The review itself writes nothing; fixes, commit and push happen only after the Phase 5 fix and commit gates.

Glossary:
- `<default>` — the default branch (`master` or `main`).
- `<base>` — `$(git merge-base origin/<default> HEAD)`, taken after `git fetch origin`.
- `<id>` — the story ID (`S-NNN`); without a story, the scope of the branch's own fix commit when there is one (a `hotfix/<slug>` branch: the `<scope>` of its `fix(<scope>): …` commit), else the branch name.
- `$TMPDIR` — `/tmp` when unset.

## Phase 1: Target
1. **Target files.** The argument's paths, or with `--diff` the changed files: `git diff --name-only <base>` (committed, staged and unstaged changes since the branch left `<default>`).
2. **Nothing to review.** An empty list → report it with the command that produced it and stop. No reviewers are spawned.
3. **Story.** With a story path, extract its ADRs and criteria.
4. **Read** CLAUDE.md, technical-preferences, the applicable `.claude/rules/*.md` and the story's ADRs.

## Phase 2: Routing (in parallel via Task)
1. **Map files to reviewers** by extension/path — the specialist plus the lead that owns the stack (`docs/agent-roster.md`): `*.go` → `go-engineer` + `backend-lead`; `*.php` → `php-engineer` + `backend-lead`; `*.graphql`/resolvers → `graphql-engineer` + `backend-lead`; Node server code → `node-engineer` + `backend-lead`; TS tooling and shared packages → `typescript-engineer` + `frontend-lead`; Angular → `angular-engineer` + `frontend-lead`; `*.vue` → `vue-engineer` + `frontend-lead`; `*.css/scss` → `css-engineer` + `frontend-lead`; `game/`, three.js → `threejs-engineer`/`web-game-engineer` + `game-lead`; migrations/SQL → `database-engineer`; workflows/Docker/`Makefile` → `devops-engineer`; tests → `test-engineer`.
2. **Security.** Sensitive paths (`auth`, `security`, `payments`, `upload`, `webhook`, proxy configs) or `--security` → `appsec-engineer` is mandatory.
3. **Write the diff once**: `git diff <base> > "$TMPDIR/review-<id>.diff"`, plus `git diff -M --name-status <base>` for the file list. A reviewer that reads the diff in pieces through `sed -n` runs out of turns and returns a verdict about the part it reached.
4. **Print the routing table** before the reviewers run: extension or path in the diff → the reviewer this list requires → spawned yes/no. A required reviewer may be skipped, but only as a line saying so and why; routing chosen by eye shrinks to one reviewer.
5. **Spawn the reviewers** in one parallel batch. Every brief contains:
   - the diff path and the file list;
   - the ADRs, the story's acceptance criteria (when there is a story) and the rules read in Phase 1;
   - with a story, the Scope rules of `references/checks-scope-comments.md`: the reviewers judge the hunks (WARNING `SCOPE` / `SCOPE-SPEC`, INFO `SCOPE-STYLE`), and a behaviour the new code exposes keeps the severity the reviewer gives it, never downgraded to INFO as "pre-existing";
   - the answer format: first line `Read: N/M files` (step 6), then findings as `severity | file:line | what | risk | fix`.
6. **The first line of every verdict is `Read: N/M files`** — the diff files the reviewer actually opened. `N < M` makes that verdict `PARTIAL`, printed as such in the routing table, and a `PARTIAL` reviewer never contributes to `APPROVED`.

## Phase 3: Automated checks (Bash, when tools exist)
Every check's output goes into the report.
1. **General**: `go vet`/`staticcheck`/`govulncheck`; PHP: `php -l`, the recorded analyser (`vendor/bin/phpstan analyse` or `vendor/bin/psalm`), the recorded coding-standard tool (`vendor/bin/ecs check` or `php-cs-fixer fix --dry-run`); `eslint`/`tsc --noEmit`/`vue-tsc`; `graphql-inspector diff`; tests of affected packages — with coverage (`make test` / `composer test:coverage`) when the diff touches a domain or use-case layer, so the coverage gate has a profile to read.
2. **Per language in the diff**: read `references/checks-go.md` for `*.go` (tests, layered, layout) and `references/checks-php.md` for `*.php` (tests, layered, the grep fallback when deptrac is absent); run every block that applies, with the finding strings as written there.
3. **Scope and comments**: read `references/checks-scope-comments.md`. The Scope block with a story — the parent prints `git diff --stat <base>` next to the story's files, the reviewers judge the hunks. The Comments block on the added lines of every diff (`TODO-NOID`, `COMMENT-HISTORY`, `COMMENT-LONG`; counts in the report even when zero).

## Phase 4: ADR conformance
Deviation from an accepted ADR: ARCHITECTURAL VIOLATION (BLOCKING) / DRIFT (WARNING) / MINOR (INFO).

## Phase 5: Report and fix commit
1. **Report**: the BLOCKING/WARNING/INFO summary; the routing table from Phase 2 with each reviewer's verdict next to it (`production/session-logs/agent-audit.log` names who actually ran, so a review can be audited later); the findings table; the verdict `APPROVED` / `NEEDS CHANGES`.
2. **Fix question**, one `AskUserQuestion`: fix BLOCKING now (Recommended on NEEDS CHANGES) · fix BLOCKING and WARNING · report only. No edits before that answer; after a "fix" answer `touch .claude/.write-consent`, and again before each `Task` batch of step 3 (rule 7, delegated steps), so the consent-guard sees the specialists' writes as approved.
3. **Fixes go through specialists**: the relevant engineer via `Task` for code and tests, `tech-writer` for documents. The answer covers the findings it names; a specialist that needs to go beyond them reports back and the parent asks. The parent writes no code in review rounds either (§ Subagents): a fix the parent makes is a change nobody reviewed. A fix the parent wrote anyway is named in the report ("written by the parent: <finding>").
4. **Re-run the Phase 3 checks.**
5. **Commit gate** (`.claude/docs/git-workflow.md`, step "Review"). No fixes → no commit; the review itself never commits or changes the branch.
   1. Record it: `<hooks>session-state.sh set Gate "/code-review Phase 5: commit the fixes?"`.
   2. Ask, one `AskUserQuestion`: commit and push (Recommended) · show the diff first · leave uncommitted. After the answer: `<hooks>session-state.sh set Gate "—"`.
   3. On "yes": `git commit -m "fix(<id>): apply /code-review findings"` (`fix(S-NNN): …` on a story branch, `fix(<scope>): …` on a hotfix branch), staging the fixed files and `.claude/agent-memory/` (the reviewers' and engineers' notes from this round, git-workflow § Agent memory).
   4. `git push` on the current branch — only when it has an upstream (`git rev-parse --abbrev-ref @{u}`); without one, the commit stays local and the report says so instead of a failed push.
6. **Re-review by the reviewer who raised each finding**: `SendMessage` (listed in `allowed-tools`) to that agent — its id from the Phase 2 `Task` result — with the fix diff (`git diff <fix-commit>^!`, or `git diff HEAD` when the commit was declined) and the question "closed / not closed". Where `SendMessage` is not available, or the reviewer's session is gone, spawn the same reviewer through `Task` with its finding and the fix diff. The routing table gets a `re-review` column (yes · no · PARTIAL).
7. **The verdict moves from `NEEDS CHANGES` to `APPROVED` only on the reviewers' answers**, never on a green CI or the parent's own reading.
8. **Severity belongs to the reviewer**: a BLOCKING is downgraded only by the reviewer that raised it or by `technical-director` through `/impact`. The parent records its disagreement as a line under the finding; it does not edit the severity.

Next step — one `AskUserQuestion`, never a bare "run /story-done?": `/web-studio:story-done` (copy mode `/story-done`) (Recommended on APPROVED) · re-review after manual fixes — past 50 % context in a fresh session (rule 13): `/clear`, then `/web-studio:code-review --diff <story-path>` (copy mode `/code-review --diff <story-path>`; `--diff` alone without a story) so the Scope checks keep their story · stop here.
