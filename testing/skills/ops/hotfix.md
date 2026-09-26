# Skill Spec: /hotfix

> **Category**: ops · **Priority**: high · **Spec written**: 2026-09-05

## Summary
Urgent fix with a failing test and an expedited gate.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path
**Fixture**: P1 production bug. **Expected**: branch from the tag; the failing test and the minimal fix both written by the engineer through `Task` (the parent writes no code, the red run's output quoted); appsec for auth; fix commit; `/changelog` through the `Skill` tool and a `docs: changelog vX.Y.Z` commit; the patch tag created and pushed by the session after its own question; CI waited for on the tag; `/deploy vX.Y.Z` through the `Skill` tool; backport PR.
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
**Fixture**: production runs `v1.4.2`; the fix and its test are committed on `hotfix/login-500`; `.github/workflows/release.yml` builds the image on `push: tags: v*`. **Expected**: `/changelog` runs through the `Skill` tool with its own write gate and the `## [1.4.3]` section is committed as `docs: changelog v1.4.3` on the hotfix branch; then one `AskUserQuestion` for the tag — on "yes" this session (never a subagent) runs `git tag -a v1.4.3 -m "…" && git push origin v1.4.3` on the changelog commit; the tag's run is waited for with one background `gh run watch --exit-status` and a red run is `BLOCKED (CI red on v1.4.3)` with nothing deployed; only then `/deploy v1.4.3` through the `Skill` tool with its own confirmation, its `DEPLOYED v1.4.3` line quoted; "not now" on the tag leaves the release untagged and the report says `/deploy` cannot run.
- [ ] `Skill` in `allowed-tools`, skills one after another · [ ] tag has its own question and is created by the session · [ ] CI on the tag before `/deploy` · [ ] `/deploy` keeps its own confirmation

### The postmortem note gets the documents-lane commit gate
**Fixture**: `FIXED`; the user agrees to the `docs/ops/incidents/<file>` note while HEAD is `hotfix/login-500`. **Expected**: the note is written only after the "May I write?" answer; right after it one commit gate offers `docs: incident login-500` staging exactly that file, names the hotfix branch and offers switch-to-default (Recommended) · commit here · leave uncommitted; the fix commit never carries the note and nothing is committed without the answer.
- [ ] write gate then commit gate · [ ] branch named, three options · [ ] only the note staged

### Toolchain work is not a production incident
**Fixture**: the CI runner has been red for two days over an action version; nothing is broken for users. **Expected**: `--chore` takes the chore/infra lane — `chore/<slug>` branch, `ci(…)`/`chore(…)` commits, a PR with `/code-review --diff` routed to `devops-engineer`, no release machinery — and the outcome is recorded as a finding or a backlog entry; the experimental commits are squashed before the merge.
- [ ] chore path distinguished from a production incident · [ ] PR and review, not a direct push · [ ] outcome recorded · [ ] no release steps

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
