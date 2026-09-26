---
name: hotfix
description: "Fast path for an urgent production fix — reproduce with a failing test, minimal fix on a hotfix branch from the release tag, mandatory security review for sensitive paths, expedited checklist, deploy and backport to main. Use for P1 production bugs."
argument-hint: "[issue description or bug id]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, Skill, AskUserQuestion
model: sonnet
---

# Hotfix

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

File writes and any mutation (git, deploy) happen only after an explicit "May I write?" / "Proceed?" — each one `AskUserQuestion` (proceed (Recommended) · show the draft/diff first · not now) → "yes". After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker). Subagents spawned through `Task` cannot ask the user: the consent is collected here, and an engineer that needs more than its brief reports back so the parent asks.

**The parent writes no code** — not the fix and not the failing test either: both go through the relevant engineer via `Task` with a studio `subagent_type` (`web-studio:<name>` in plugin mode, `<name>` in copy mode; coordination-rules § Subagents). A cut-off engineer is resumed from its `Checkpoint:`, never replaced.

**Other studio skills run through the `Skill` tool** (`/web-studio:<name>` in plugin mode, `/<name>` in copy mode): `/code-review --diff` (Phase 2 and `--chore`), `/changelog` and `/deploy` (Phase 3). Each keeps all of its own phases and gates — its write gate, its confirmation before a production mutation — and its verdict comes back as text this skill quotes. They run one after another, after the running `Task` has returned, never two at once. `/incident` is a hand-off in the closing `AskUserQuestion`, not run from here.

**Two kinds of urgent, one skill.**
- `production` (the default): something is broken for users. Phases 1–4 below: reproduce with a failing test, minimal fix on a hotfix branch from the release tag, expedited security gate, release.
- `--chore`: the toolchain is broken or in the way — a red runner, a linter that blocks every commit, a dependency that must move now. It skips the release machinery and follows the chore/infra lane of `git-workflow.md`:
  1. branch `chore/<slug>` (`git fetch origin`, then `git switch -c chore/<slug> origin/<default>`);
  2. commits `ci(…)` / `chore(…)`;
  3. a PR with `/web-studio:code-review --diff` (copy mode `/code-review --diff`) run through the `Skill` tool before the merge (workflow files → `devops-engineer`); experimental commits are squashed or rebased away before the merge;
  4. the outcome recorded as a finding (`production/findings.md`) or a backlog entry (`production/backlog.md`).

Neither path is a place for a feature: work that changes what the product does is a story, however small it looks at the moment it is asked for.

## Phase 1: Reproduce
1. **Branch** `hotfix/<slug>` from the production tag (the release currently deployed): `git fetch origin --tags`, then `git switch -c hotfix/<slug> <tag>`.
2. **A failing test** that reproduces the bug (mandatory), written by the relevant engineer through `Task` — the brief names the bug, the file the test goes into and the command that must go red; the parent writes no test itself (protocol). The engineer reports the red run's output, quoted in the report. No reproduction → stop with `BLOCKED (cannot reproduce — …)`: no fix is written without a failing test.
3. **Impact assessment**: data? security? → `security-lead` via Task.

## Phase 2: Minimal fix
1. **Through the relevant engineer**: `Task` with the studio `subagent_type`. The parent writes no code; a cut-off engineer is resumed from its `Checkpoint:` (coordination-rules § Subagents).
2. **Only what is needed.** A fix that needs a DB migration is not written straight away: the engineer reports it back, and the parent warns the user before it is written — a rollback restores the image, not the data, so the migration must be reversible or the hotfix goes forward only.
3. **Checks**: test green; lint/typecheck.
4. **Sensitive paths** (the `paths:` of `rules/security-sensitive.md`: auth, security, middleware, proxy config, payments, uploads, webhooks): `appsec-engineer` review — `/web-studio:code-review --diff --security` (copy mode `/code-review --diff --security`) through the `Skill` tool, so the review and its `appsec-engineer` run are in the audit log; its verdict is quoted. `NEEDS CHANGES` → the fixes go back through the engineer (inside `/code-review`'s own fix gate) before Phase 3.
5. **Fix commit**, one `AskUserQuestion` (commit (Recommended) · show the diff · not now): `git commit -m "fix(<scope>): <bug>"` staging the fix and its test by name, on the hotfix branch.

## Phase 3: Expedited gate
1. Package tests + e2e smoke.
2. **`/changelog`** through the `Skill` tool: the patch version `vX.Y.Z` (the deployed tag's patch number + 1) with its own "May I write `CHANGELOG.md`?" gate; then a commit gate here: `docs: changelog vX.Y.Z` staging exactly `CHANGELOG.md`, on the hotfix branch (the tag below must contain it).
3. **Patch tag**, created and pushed by this session, never by a subagent, and as its own `AskUserQuestion`: tag `vX.Y.Z` on the hotfix branch and push it now (Recommended) · not now. On "yes": `git tag -a vX.Y.Z -m "Hotfix vX.Y.Z: <bug>" && git push origin vX.Y.Z` (without `-m`, `git tag -a` opens an editor the session cannot use). A hotfix tag is the documented exception to "tags on the default branch" (git-workflow: a hotfix branches from the release tag and is backported afterwards); the tag sits on the changelog commit, which sits on the fix commit. "Not now" → the report says the release is untagged and `/deploy` cannot run.
4. **CI builds the image from the tag.** Wait for the tag's run before deploying — one background `gh run watch <run-id> --exit-status` (as `/story-done`), only for a run that exists; no polling, no `AskUserQuestion` as a pause. Red → `BLOCKED (CI red on vX.Y.Z)`, nothing deployed. Without `gh`, name the run to check by hand.
5. **`/deploy vX.Y.Z`** through the `Skill` tool, with its own confirmation before the production mutation (delegate verbs `deploy`/`rollback` by `.claude/docs/deploy-target-contract.md`); it verifies the tag, the green run and the image itself. Its verdict line (`DEPLOYED vX.Y.Z` | `FAILED (…)`) is quoted in the report.
6. **Backport** to the default branch (`<default>`, `master`/`main`) through a PR: `git push -u origin hotfix/<slug>` with consent, then `gh pr create --fill --base <default>`; the merge follows the PR's review, never a direct push.

## Phase 4: Postmortem note
A short entry in `docs/ops/incidents/` (or `/incident` if there was an incident), behind "May I write `docs/ops/incidents/<file>`?" — one `AskUserQuestion`: write (Recommended) · show the draft first · not now; after the "write" answer `touch .claude/.write-consent`. Right after the write, one commit gate (rule 7 (4), `git-workflow.md` § Documents): `docs: incident <slug>` staging exactly that file. HEAD is the hotfix branch here, so name it and offer: switch to the default branch and commit there (Recommended — a postmortem is a pipeline-wide document) · commit here (it rides the backport PR) · leave uncommitted. Nothing is committed without the answer; the fix never rides the `docs:` commit.

Verdict: `FIXED` | `BLOCKED`. Next step — one `AskUserQuestion`: `/web-studio:incident` (copy mode `/incident`) for root-cause analysis (Recommended) · backport to the default branch (when step 3.6 was skipped) · stop here.
