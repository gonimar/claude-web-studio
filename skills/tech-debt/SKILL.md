---
name: tech-debt
description: "Inventories technical debt — outdated dependencies vs the stack reference, TODO/FIXME, skipped tests, lint suppressions, ADR drift, missing docs, security/perf shortcuts; scores by impact/effort and proposes stories. Read-only report in docs/ops/tech-debt-<date>.md on approval."
argument-hint: "[area or 'full']"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Write, AskUserQuestion
---

# Tech Debt

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

References `stack-reference/index.md` (and `php.md` / `go.md` for the code-shape numbers). This skill delegates nothing: the inventory is command and grep output, the scoring is the director's own, so no `Task` — the stories it proposes are `/create-stories`' work, not a subagent's. In the commands below, `<hooks>` is `.claude/hooks/` in copy mode and `${CLAUDE_PLUGIN_ROOT}/hooks/` in plugin mode.

## Phase 1: Collect (Bash + Grep)
1. **Scope**: the argument names an area (a package, a directory, a layer); `full` or no argument scans the whole repository. An area limits every search below to that subset.
2. **No code** to scan → say so and report an empty inventory; nothing is written.
3. **Collect**:
   - dependencies: `go list -m -u all` / `composer outdated` / `pnpm outdated` vs `stack-reference/index.md`;
   - TODOs by `rules/comments.md` — `git grep -nE 'TODO|FIXME|HACK'` split into: with an id whose card is Done or missing (`grep -c '<ID>' production/roadmap.md production/backlog.md`, the line's `[x]`) → a row each; with an open id → listed by story; without an id → one row with the count (each is a `/backlog add`);
   - comment history — `git grep -nE '^\s*(//|#|\*) .*(\b(S|OPS|ARCH|SEC)-[0-9]+\b|pre-S-|used to|previously)' -- ':!*_test.go' ':!*Test.php' ':!*.spec.ts' ':!*.test.ts' | grep -vE '(TODO|FIXME|HACK)\((S|I)-[0-9]+\)' | cut -d: -f1 | sort | uniq -c` (the well-formed TODOs of the previous item are not history) summed per package, and for Go `go doc -all ./... 2>/dev/null | grep -cE '\b(S|ARCH|OPS)-[0-9]+\b|used to'` (what the rendered API documentation carries) — a row per package over 20 lines, proposed story `chore(<package>): comments per rules/comments.md` (never a drive-by in a feature story);
   - skipped tests `skip|xit|@group skip|t.Skip`; lint suppressions `eslint-disable|@psalm-suppress|nolint`;
   - ADRs in Proposed older than 30 days; feature specs without stories; Done stories without tests; missing runbooks;
   - open findings from the last audits (security/perf/a11y).
4. **Code shape is measured, not felt** — each item a row with its number:
   - PHP: classes over 400 lines, a PHPUnit major out of support, `sleep()` in tests, exception messages asserted, framework namespaces imported under `src/Domain`/`src/Application` in a `layered` project, DDL outside migrations, a `php_static_analysis` level below the recorded one. Proposed story: `/refactor <namespace>` / `/refactor layout` / `/refactor tests` / `/refactor framework`.
   - Go: packages over 1 500 lines, files over 500, a `.golangci.yml` in v1 format, `time.Sleep` in tests, error strings compared, a `go_architecture: layered` project whose tree or `depguard` block does not match. Proposed story: `/refactor <package>` / `/refactor layout` / `/refactor tests`, rather than a rewrite.

## Phase 2: Score
Table "debt → impact (security/velocity/risk) → effort → priority → proposed story". A dependency a major behind the stack reference gets `/stack-update` as its proposed action.

## Phase 3: Report
1. Show the table in the chat.
2. "May I write `docs/ops/tech-debt-<date>.md` and add the top 5 to the roadmap?" as one `AskUserQuestion`: report and roadmap (Recommended) · report only · not now.
3. After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker), then write.

## Phase 4: Commit (documents lane)
Right after the write, one commit gate (rule 7 (4), `.claude/docs/git-workflow.md` § Documents): `docs: tech debt <date>`, staging exactly the written files — `docs/ops/tech-debt-<date>.md` and `production/roadmap.md` when the top 5 were added to it. Record the gate before asking — `<hooks>session-state.sh set Gate "/tech-debt Phase 4: commit?"` — and clear it after the answer (`<hooks>session-state.sh set Gate "—"`).
- On the default branch when no story work is in progress: one `AskUserQuestion` — commit (Recommended) · leave uncommitted.
- When HEAD is a story branch, name it and ask one `AskUserQuestion`: switch to the default branch and commit there (Recommended — a pipeline-wide document) · commit here (the document belongs to this story) · leave uncommitted.
- The inventory is read-only: no code changes exist to stage; a debt item fixed on the way would be a story or the chore lane (git-workflow.md § Chore / infra), never part of the `docs:` commit.

Nothing is committed without the answer.

Verdict: `COMPLETE (N items, M critical)`. Next step — one `AskUserQuestion`: `/create-stories` for critical items (Recommended when any) · `/refactor --dry-run` for code-shape items · `/stack-update` for outdated majors · stop here.
