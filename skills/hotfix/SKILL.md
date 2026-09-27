---
name: hotfix
description: "Fast path for an urgent production fix — reproduce with a failing test, minimal fix on a hotfix branch from the release tag, mandatory security review for sensitive paths, expedited checklist, deploy and backport to main. Use for P1 production bugs."
argument-hint: "[issue description or bug id] | --chore <what>"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, Skill, AskUserQuestion
---

# Hotfix

Language, `<hooks>`, `<default>`, agent and command namespaces, gate mechanics (draft → "May I write?" → `Write`/`Edit` → `touch .claude/.write-consent`), subagent consent, the `Skill` tool and the CI wait: `docs/coordination-rules.md` § Skill conventions (engineers and reviewers: § Subagents).

**The parent writes no code** — neither the fix nor the failing test: both through the relevant engineer via `Task` with a studio `subagent_type`; a cut-off engineer is resumed from its `Checkpoint:`, never replaced. Every commit, tag, push and deploy has its own `AskUserQuestion`; the branch of step 1.1 and the engineer's edits on it leave the working tree only through the fix-commit gate of step 2.4.

**Through the `Skill` tool** (namespaced): `/code-review --diff` (step 2.5, `--chore`), `/changelog` and `/deploy` (Phase 3) — each with all its own phases and gates, one after another once the running `Task` has returned, its verdict quoted. `/incident` is a hand-off in the closing question, never run here.

Glossary:
- `<tag>` — the release currently deployed (the newest `production/releases/vX.Y.Z.md` whose `Result:` line reads `DEPLOYED` (what `/deploy` Phase 4 writes), else the newest `v*` tag after `git fetch origin --tags`; none → `BLOCKED (no release tag — nothing is deployed)`); `vX.Y.Z` — its patch number + 1.
- `<slug>` — the bug in a few words (`hotfix/<slug>`); `<scope>` — the scope of the fix commit `fix(<scope>): <bug>`, which `/code-review` uses where a story would give `S-NNN`.
- **Gate recording** — before every commit, tag or push question (each step below names its `Gate "…"` string): `<hooks>session-state.sh set Task "/hotfix <slug>" Gate "/hotfix Phase N: <question>"`; after the answer `<hooks>session-state.sh set Gate "—"`. An open gate survives the turn: a resumed session continues at that question, never at `Next:` (rule 7).

**Two kinds of urgent, one skill.** `production` (default): broken for users — Phases 1–4. `--chore`: the toolchain is broken or in the way (a red runner, a blocking linter, a dependency that must move now) — read and follow `references/chore-lane.md`; Phases 1–4 do not run, verdict `DONE (chore — PR open)`. Neither path is a place for a feature: what changes the product's behaviour is a story, however small it looks.

## Phase 1: Reproduce
1. **Branch** `hotfix/<slug>` from `<tag>`: `git fetch origin --tags`, then `git switch -c hotfix/<slug> <tag>`. The commit hook (`validate-commit.sh`) is silent on `hotfix/*`: no "already merged into origin/<default>" warning on the first commit.
2. **A failing test** that reproduces the bug (mandatory), by the relevant engineer through `Task` — the brief names the bug, the test file and the command that must go red; the red run's output is quoted in the report. No reproduction → `BLOCKED (cannot reproduce — …)`: no fix without a failing test, nothing written.
3. **Impact**: data or security involved → one `Task` to `security-lead` with the bug and the files; its answer goes into the engineer's brief (step 2.1) and, with the `paths:` rule of step 2.5, decides whether the security review runs: a "review" from security-lead makes step 2.5 apply whatever the paths say.

## Phase 2: Minimal fix
1. **Through the relevant engineer**: `Task` with the studio `subagent_type`; the brief holds the test of step 1.2 and the impact of step 1.3.
2. **Only what is needed.** A fix that needs a DB migration is not written straight away: the engineer reports it and the parent warns the user first — a rollback restores the image, not the data, so the migration must be reversible or the hotfix goes forward only.
3. **Checks**: test green; lint/typecheck.
4. **Fix commit and push** — `Gate "/hotfix Phase 2: commit and push the fix?"`, one `AskUserQuestion`: commit and push (Recommended) · commit only · show the diff · not now. On "yes": `git commit -m "fix(<scope>): <bug>"` staging the fix and its test by name, on the hotfix branch, then `git push -u origin hotfix/<slug>` — the upstream exists before any review, so a review fix can be pushed. "Commit only" → the push happens at step 3.7 with its own consent; the report says the branch is local until then.
5. **Sensitive paths** (the `paths:` of `rules/security-sensitive.md`: auth, security, middleware, proxy config, payments, uploads, webhooks):
   1. Sensitive by the `paths:` rule on the files of the fix commit **or** flagged "review" by security-lead in step 1.3; neither → Phase 3.
   2. `/web-studio:code-review --diff --security` (copy mode `/code-review --diff --security`) through the `Skill` tool, after the commit of step 2.4, so the review sees the fix and its `appsec-engineer` run is in the audit log; its verdict is quoted.
   3. `NEEDS CHANGES` → the fixes go through the engineer inside `/code-review`'s own fix gate, which commits `fix(<scope>): apply /code-review findings` (no `S-NNN`) on the hotfix branch and pushes to the upstream of step 2.4 — after "commit only" it commits locally and says so.
   4. Phase 3 starts only when the reviewers answer `APPROVED`.

## Phase 3: Expedited gate
1. **Tests**: package tests and the e2e smoke, with the commands `docs/architecture/test-strategy.md` names per level (else `technical-preferences.md` or the `Makefile`). Red → `BLOCKED (tests red — <command>)`, nothing released.
2. **`/changelog`** through the `Skill` tool for `vX.Y.Z`, with its own "May I write `CHANGELOG.md`?" gate and its own commit gate — the only gate for `CHANGELOG.md`; this skill asks no second one. That gate offers the `hotfix/*` HEAD (Recommended — the tag must contain it): `docs: changelog vX.Y.Z` lands on the hotfix branch, HEAD never leaves it. A changelog uncommitted or committed elsewhere is named in the report, and the tag question waits until that is put right.
3. **Release file** `production/releases/vX.Y.Z.md` — the minimal one `/deploy` reads (without it: `BLOCKED (no release file — …)`); `/release-checklist` is not run for a hotfix.
   1. Content: what changed (the bug and the fix in one paragraph); the fix commit (its hash, plus the review-fix commit when there is one); the tag `vX.Y.Z`; the CI run that builds the image (the workflow file; the run id in the report once the tag is pushed); the rollback tag (`<tag>`); the line `Verdict: READY (hotfix)`; the `/release-checklist` gates a hotfix skips, listed as skipped, never ticked.
   2. Show the draft, then "May I write `production/releases/vX.Y.Z.md`?" — one `AskUserQuestion`: write (Recommended) · show the draft/diff first · not now; after the "write" answer `touch .claude/.write-consent`.
   3. Right after the write, one commit gate — `Gate "/hotfix Phase 3: commit the release file?"`: `docs: release vX.Y.Z (hotfix)` staging exactly that file, on the hotfix branch (commit (Recommended — the tag must contain it) · leave uncommitted). Uncommitted → no tag; say why.
4. **Patch tag**, created and pushed by this session, never by a subagent, as its own `AskUserQuestion` — `Gate "/hotfix Phase 3: tag vX.Y.Z and push it?"`: tag `vX.Y.Z` on the hotfix branch and push it now (Recommended) · not now. On "yes": `git tag -a vX.Y.Z -m "Hotfix vX.Y.Z: <bug>" && git push origin vX.Y.Z` (without `-m`, `git tag -a` opens an editor the session cannot use) on the release-file commit, so the tag contains the changelog and the release file — the documented exception to "tags on the default branch" (git-workflow.md). "Not now" → the report says the release is untagged and `/deploy` cannot run.
5. **CI on the tag**: read `references/ci-on-tag.md` and follow it — triggers read first, only an existing run waited for. Green → step 3.6; red → `BLOCKED (CI red on vX.Y.Z)`, nothing deployed; no tag trigger → name what runs instead and that `/deploy` will find no green run on the tag.
6. **`/deploy vX.Y.Z`** through the `Skill` tool, with its own confirmation before the production mutation (delegate contract: `.claude/docs/deploy-target-contract.md`); it reads the release file's `Verdict:` line and verifies the tag, the green run and the image. Its verdict line (`DEPLOYED vX.Y.Z` | `FAILED (…)`) is quoted in the report.
7. **Backport PR** to `<default>`. The branch is on origin when step 2.4 pushed it; otherwise `git push -u origin hotfix/<slug>` now, behind its own question — `Gate "/hotfix Phase 3: push hotfix/<slug>?"`. Then `gh pr create --fill --base <default>`; the merge follows the PR's review, never a direct push. Skipped on "not now" to that push or without `gh` (name the PR to open by hand); the closing question then offers the backport.

## Phase 4: Postmortem note
A short entry in `docs/ops/incidents/<file>`; the root-cause analysis is `/incident`'s, offered in the closing question.
1. Show the draft, then "May I write `docs/ops/incidents/<file>`?" — one `AskUserQuestion`: write (Recommended) · show the draft first · not now.
2. After the "write" answer: `touch .claude/.write-consent`, then `Write`.
3. Record the commit gate: `Gate "/hotfix Phase 4: commit the postmortem note?"`.
4. Ask, one `AskUserQuestion` (rule 7 (4), `git-workflow.md` § Documents): `docs: incident <slug>` staging exactly that file. HEAD is the hotfix branch, so name it and offer: switch to `<default>` and commit there (Recommended — a postmortem is a pipeline-wide document) · commit here (it rides the backport PR) · leave uncommitted. Nothing is committed without the answer; the fix never rides the `docs:` commit.
5. On "switch": `git switch <default> && git pull --ff-only origin <default>`, commit, then `git switch hotfix/<slug>` back while the backport PR is open.
6. Clear the gate: `<hooks>session-state.sh set Gate "—"`.

Verdict: `FIXED` | `BLOCKED` | `DONE (chore — PR open)` | `DONE (chore — PR not opened)`. Next step — one `AskUserQuestion`. Production: `/web-studio:incident` (copy mode `/incident`) for root-cause analysis (Recommended) · backport to `<default>` (when step 3.7 was skipped) · stop here. `--chore`: open the PR (Recommended) · stop here — no `/incident` after a chore.
