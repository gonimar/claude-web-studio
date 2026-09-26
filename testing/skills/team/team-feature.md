# Skill Spec: /team-feature

> **Category**: team · **Priority**: critical · **Spec written**: 2026-09-05

## Summary
Vertical feature slice through leads and engineers.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path
**Fixture**: F-002, GraphQL, Angular. **Expected**: branch `feat/F-002-<slug>` with consent; contract ‖ data; backend → frontend; parallel checks; commit and push; summary; hand-off to `/code-review --diff`.
- [ ] phase order followed · [ ] output matches the expectation · [ ] writes only after consent
### 2. Refusal / BLOCKED
**Fixture**: no feature spec. **Expected**: runs /feature-spec through the `Skill` tool (all of its gates), then continues.
- [ ] stops or explicitly flags the limitation · [ ] names the command/reason · [ ] writes no files
### 3. Mode/argument variant
**Fixture**: --review solo → no review gates. **Expected**: Phase 5 runs only the check the user picks (or none); nothing blocks the slice; `appsec-engineer` still runs on security-sensitive paths; the branch, "Proceed?", write and commit gates are asked as in case 1.
- [ ] argument parsed · [ ] the difference matches the skill description · [ ] consent gates unchanged
### 4. Edge case
**Fixture**: database-engineer BLOCKED → partial report. **Expected**: handled explicitly, never silently skipped.
- [ ] the case is mentioned in the instructions · [ ] correct message/action
### 5. Gate / protocol
**Fixture**: user approves writes. **Expected**: the user decides; stage/statuses never change automatically.
- [ ] no self-advancing · [ ] verdict from the skill's vocabulary

### 6. Git workflow
**Fixture**: session on the default branch; the slice is one story S-014. **Expected**: Phase 2 asks before branching, `git fetch origin`, pull `--ff-only` from `origin/<default>`, `git switch -c feat/S-014-<slug>`; a merged story branch is never continued; Phase 6 asks before committing, stages by name (never `git add -A`), commits `feat(S-014): …`, pushes, and opens a draft PR when only `pull_request` starts CI; no commit on the default branch.
- [ ] branch with consent, from an up-to-date default branch · [ ] commit scope is the story/feature ID · [ ] draft PR when the PR starts CI · [ ] no commit on the default branch

### 7. Skills run one after another
**Fixture**: /feature-spec missing in Phase 1. **Expected**: `Skill` is in `allowed-tools`; the skill is run through the `Skill` tool and keeps its own gates; `‖` in the body only ever joins agents of one `Task` batch, never two skills.
- [ ] `Skill` listed · [ ] called skill keeps its gates · [ ] no two skills at once

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
