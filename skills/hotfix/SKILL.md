---
name: hotfix
description: "Fast path for an urgent production fix — reproduce with a failing test, minimal fix on a hotfix branch from the release tag, mandatory security review for sensitive paths, expedited checklist, deploy and backport to main. Use for P1 production bugs."
argument-hint: "[issue description or bug id]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, AskUserQuestion
model: sonnet
---

# Hotfix

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

File writes and any mutation (git, deploy) happen only after an explicit "May I write?" / "Proceed?" — each one `AskUserQuestion` (proceed (Recommended) · show the draft/diff first · not now) → "yes". After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker). Subagents spawned through `Task` cannot ask the user: the consent is collected here, and an engineer that needs more than its brief reports back so the parent asks.

**Two kinds of urgent, one skill.**
- `production` (the default): something is broken for users. Phases 1–4 below: reproduce with a failing test, minimal fix on a hotfix branch from the release tag, expedited security gate, release.
- `--chore`: the toolchain is broken or in the way — a red runner, a linter that blocks every commit, a dependency that must move now. It skips the release machinery and follows the chore/infra lane of `git-workflow.md`:
  1. branch `chore/<slug>` (`git fetch origin`, then `git switch -c chore/<slug> origin/<default>`);
  2. commits `ci(…)` / `chore(…)`;
  3. a PR with `/web-studio:code-review --diff` (copy mode `/code-review --diff`; workflow files → `devops-engineer`); experimental commits are squashed or rebased away before the merge;
  4. the outcome recorded as a finding (`production/findings.md`) or a backlog entry (`production/backlog.md`).

Neither path is a place for a feature: work that changes what the product does is a story, however small it looks at the moment it is asked for.

## Phase 1: Reproduce
1. **Branch** `hotfix/<slug>` from the production tag (the release currently deployed): `git fetch origin --tags`, then `git switch -c hotfix/<slug> <tag>`.
2. **A failing test** that reproduces the bug (mandatory). No reproduction → stop with `BLOCKED (cannot reproduce — …)`: no fix is written without a failing test.
3. **Impact assessment**: data? security? → `security-lead` via Task.

## Phase 2: Minimal fix
1. **Through the relevant engineer**: `Task` with the studio `subagent_type`. The parent writes no code; a cut-off engineer is resumed from its `Checkpoint:` (coordination-rules § Subagents).
2. **Only what is needed.** A fix that needs a DB migration is not written straight away: the engineer reports it back, and the parent warns the user before it is written — a rollback restores the image, not the data, so the migration must be reversible or the hotfix goes forward only.
3. **Checks**: test green; lint/typecheck.
4. **Sensitive paths** (the `paths:` of `rules/security-sensitive.md`: auth, security, middleware, proxy config, payments, uploads, webhooks): `appsec-engineer` review.

## Phase 3: Expedited gate
1. Package tests + e2e smoke.
2. `/changelog` patch version.
3. `/deploy` with confirmation (delegate verbs `deploy`/`rollback` by `.claude/docs/deploy-target-contract.md`).
4. Backport to the default branch (`<default>`, `master`/`main`) through a PR.

## Phase 4: Postmortem note
A short entry in `docs/ops/incidents/` (or `/incident` if there was an incident), behind "May I write `docs/ops/incidents/<file>`?".

Verdict: `FIXED` | `BLOCKED`. Next step — one `AskUserQuestion`: `/incident` for root-cause analysis (Recommended) · backport to the default branch (when step 3.4 was skipped) · stop here.
