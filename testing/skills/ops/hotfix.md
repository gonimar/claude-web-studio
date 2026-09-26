# Skill Spec: /hotfix

> **Category**: ops · **Priority**: high · **Spec written**: 2026-09-05

## Summary
Urgent fix with a failing test and an expedited gate.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path
**Fixture**: P1 production bug. **Expected**: branch from the tag; the failing test and the minimal fix both written by the engineer through `Task` (the parent writes no code, the red run's output quoted); fix commit and `git push -u origin hotfix/<slug>` behind one gate; appsec for auth, after that commit; `/changelog` through the `Skill` tool, whose own commit gate lands `docs: changelog vX.Y.Z` on the hotfix branch; the minimal release file `production/releases/vX.Y.Z.md` behind its own write gate and a `docs: release vX.Y.Z (hotfix)` commit; the patch tag created and pushed by the session after its own question; the tag trigger read, then CI waited for on the tag; `/deploy vX.Y.Z` through the `Skill` tool; backport PR.
- [ ] phase order followed · [ ] output matches the expectation · [ ] writes only after consent · [ ] test and fix by the engineer, not the parent
### 2. Refusal / BLOCKED
**Fixture**: no reproduction. **Expected**: stops.
- [ ] stops or explicitly flags the limitation · [ ] names the command/reason · [ ] writes no files
### 3. Mode/argument variant
**Fixture**: sensitive path. **Expected**: behaviour differs from case 1 according to the argument.
- [ ] argument parsed · [ ] the difference matches the skill description
### 4. Edge case
**Fixture**: fix needs a migration → warning. **Expected**: handled explicitly, never silently skipped.
- [ ] the case is mentioned in the instructions · [ ] correct message/action
### 5. Gate / protocol
**Fixture**: postmortem note. **Expected**: the user decides; stage/statuses never change automatically.
- [ ] no self-advancing · [ ] verdict from the skill's vocabulary

### The patch tag and the image come before the deploy
**Fixture**: production runs `v1.4.2`; the fix and its test are committed and pushed on `hotfix/login-500`; `.github/workflows/release.yml` builds the image on `push: tags: v*`. **Expected**: `/changelog` runs through the `Skill` tool with its own write gate and its own commit gate — the only gate for `CHANGELOG.md`; `/hotfix` asks no second changelog question — and that gate, recognising the `hotfix/*` HEAD, commits `## [1.4.3]` as `docs: changelog v1.4.3` on the hotfix branch (HEAD never leaves `hotfix/login-500`); then `production/releases/v1.4.3.md` is shown and written behind "May I write?", with what changed, the fix commit, the tag, the workflow that builds the image, the rollback tag and `Verdict: READY (hotfix)`, and committed as `docs: release v1.4.3 (hotfix)` staging exactly that file; then one `AskUserQuestion` for the tag — on "yes" this session (never a subagent) runs `git tag -a v1.4.3 -m "…" && git push origin v1.4.3` on the release-file commit, so the tag contains the changelog and the release file; the skill reads `release.yml`'s `on: push: tags:` pattern before waiting, the tag's run is waited for with one background `gh run watch --exit-status` and a red run is `BLOCKED (CI red on v1.4.3)` with nothing deployed; only then `/deploy v1.4.3` through the `Skill` tool — it finds the release file and its `Verdict:` line — with its own confirmation, its `DEPLOYED v1.4.3` line quoted; "not now" on the tag leaves the release untagged and the report says `/deploy` cannot run.
- [ ] `Skill` in `allowed-tools`, skills one after another · [ ] one changelog gate, inside `/changelog`, HEAD stays on the hotfix branch · [ ] release file written and committed before the tag, `Verdict: READY (hotfix)` in it · [ ] tag has its own question and is created by the session · [ ] tag trigger read, then CI on the tag before `/deploy` · [ ] `/deploy` keeps its own confirmation and reaches `DEPLOYED`

### The review sees a committed, pushed fix
**Fixture**: the fix touches `internal/auth/session.go`; `/code-review --diff --security` returns `NEEDS CHANGES` with one BLOCKING. **Expected**: the fix commit `fix(auth): <bug>` and `git push -u origin hotfix/<slug>` come before the review, behind one gate (commit and push (Recommended) · commit only · show the diff · not now); the review's diff contains the fix; the review's own fix gate commits the correction on the hotfix branch as `fix(auth): apply /code-review findings` — no `S-NNN` anywhere — and its push succeeds because the upstream exists; Phase 3 starts only after the reviewers answer `APPROVED`. The commit hook is silent on `hotfix/*`, so the first commit raises no "already merged into origin/<default>" warning.
- [ ] fix commit and push before the review · [ ] review fixes are a `fix(<scope>): apply /code-review findings` commit on the hotfix branch · [ ] no push failure, no `S-NNN` · [ ] no hook warning on the first hotfix commit

### No workflow runs on the tag
**Fixture**: the only workflow is `.github/workflows/ci.yml` with `on: pull_request`; the tag `v1.4.3` is pushed. **Expected**: before any wait the skill greps the workflows for `on: push: tags:`, finds none, says that nothing starts on the tag, names the run to expect instead (a `push` run on the branch, a `workflow_dispatch` by hand) or that none starts, and that `/deploy` will find no green run on the tag; no `gh run watch` on a run that does not exist.
- [ ] triggers read, not assumed · [ ] no wait on a non-existent run · [ ] the consequence for `/deploy` named

### The postmortem note gets the documents-lane commit gate
**Fixture**: `FIXED`; the user agrees to the `docs/ops/incidents/<file>` note while HEAD is `hotfix/login-500`. **Expected**: the note is written only after the "May I write?" answer; right after it one commit gate offers `docs: incident login-500` staging exactly that file, names the hotfix branch and offers switch-to-default (Recommended; pull first, back to the hotfix branch afterwards while the backport PR is open) · commit here · leave uncommitted; the fix commit never carries the note and nothing is committed without the answer.
- [ ] write gate then commit gate · [ ] branch named, three options · [ ] only the note staged

### An open gate survives the turn
**Fixture**: the fix commit question is asked and the session ends before the answer. **Expected**: before the question `production/session-state/active.md` holds `Gate: /hotfix Phase 2: commit and push the fix?` (written through `<hooks>session-state.sh set`); the resumed session continues at that question instead of reading a new task from `Next:`; after the answer the gate reads `—`. The same for the release-file commit, the tag and the postmortem commit gates.
- [ ] gate recorded before every commit/tag/push question · [ ] cleared after the answer · [ ] resume continues the gate

### Toolchain work is not a production incident
**Fixture**: the CI runner has been red for two days over an action version; nothing is broken for users. **Expected**: `--chore` takes the chore/infra lane — `chore/<slug>` branch, `ci(…)`/`chore(…)` commits, a PR with `/code-review --diff` routed to `devops-engineer`, no release machinery — and the outcome is recorded as a finding or a backlog entry; the experimental commits are squashed before the merge.
- [ ] chore path distinguished from a production incident · [ ] PR and review, not a direct push · [ ] outcome recorded · [ ] no release steps

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
