# Skill Spec: /dev-story

> **Category**: pipeline · **Priority**: critical · **Spec written**: 2026-09-05

## Summary
Implement a story through engineers with tests and criteria checks.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path
**Fixture**: S-003 backend GraphQL. **Expected**: context loaded; plan; graphql-engineer; criteria table with output.
- [ ] phase order followed · [ ] output matches the expectation · [ ] writes only after consent
### 2. Refusal / BLOCKED
**Fixture**: no ADR/contract for the story. **Expected**: BLOCKED with the command.
- [ ] stops or explicitly flags the limitation · [ ] names the command/reason · [ ] writes no files
### 3. Mode/argument variant
**Fixture**: frontend-only story → angular-engineer. **Expected**: behaviour differs from case 1 according to the argument.
- [ ] argument parsed · [ ] the difference matches the skill description
### 4. Edge case
**Fixture**: new dependency → health check. **Expected**: handled explicitly, never silently skipped.
- [ ] the case is mentioned in the instructions · [ ] correct message/action
### 5. Gate / protocol
**Fixture**: session state updated; next /code-review. **Expected**: the user decides; stage/statuses never change automatically; the hand-off is one `AskUserQuestion` (`/code-review --diff` Recommended · commit first · show the diff · stop), not a text "run /code-review?".
- [ ] no self-advancing · [ ] verdict from the skill's vocabulary · [ ] gates and the hand-off are `AskUserQuestion`s with a Recommended option and alternatives
### 6. Git workflow
**Fixture**: current branch `feat/S-002-…` already merged into origin/master. **Expected**: switch to the default branch, pull, create `feat/S-003-slug`; at the end a `feat(S-003): …` commit and push, each after consent (`docs/git-workflow.md`).
- [ ] merged branch detected, new branch from the default · [ ] commit scope is the story ID · [ ] no commit on the default branch

### 7. Architecture prerequisites gate
**Fixture**: stories and ADRs exist, stage `build` (brownfield entry), but `docs/architecture/test-strategy.md` is missing. **Expected**: `BLOCKED (architecture prerequisites unmet — run /test-setup first)` before any planning, branching or code; the same for a missing `threat-model.md`; no question loop about it, and no code is written.
- [ ] BLOCKED before Phase 3 · [ ] only the missing commands named · [ ] no files written

### 8. Sprint layer offered
**Fixture**: 10 Ready stories, `production/sprints/` empty, first `/dev-story` of the backlog. **Expected**: before the plan question one line notes no sprint covers the story, and `/sprint-plan` appears among the options (Recommended for a fresh backlog); with a covering sprint file the line and option are absent.
- [ ] sprint absence named · [ ] /sprint-plan among options · [ ] silent when a sprint covers the story

### 9. Started stamp and SEO routing
**Fixture**: Phase 3 branches for S-030 on a `Type: site` project with a public article page. **Expected**: the story card gets `Started: <ISO minute>` when the branch is created; in Phase 4 `seo-specialist` reviews title/meta/canonical, structured data, sitemap and hreflang before the story closes; on an internal SPA no SEO review is spawned.
- [ ] Started written · [ ] seo-specialist only for public pages

### CI that only pull_request starts
**Fixture**: `.github/workflows/ci.yml` has `on: pull_request` and no `push` trigger; the story branch is pushed at the end of Phase 6. **Expected**: the skill reads the triggers, opens a draft PR (`gh pr create --draft --fill`) so the checks start, and names the run it expects; it never waits for a run that was never queued.
- [ ] triggers read, not assumed · [ ] draft PR opened when the PR is what starts CI · [ ] no wait on a non-existent run

### A spike leaves no trace in the repository
**Fixture**: the plan for a story includes a throwaway script to check a library's behaviour. **Expected**: Phase 3 names the spike's path under `tools/spike-<slug>/` (gitignored) or the session scratchpad, and says it is deleted in Phase 6; Phase 6 stages the story's own files by name — never `git add -A` — and reports any unplanned `??` entries in `git status --short` before committing.
- [ ] spike path named and gitignored · [ ] no `git add -A` · [ ] untracked leftovers reported before the commit

### The parent does not write the story's code
**Fixture**: a story touching a Go package and its tests; the first `go-engineer` call comes back cut off at its turn limit having written nothing. **Expected**: the skill resumes that agent with its stopping point rather than spawning a new one; on a second truncation it splits the remaining work into smaller calls; the parent writes product code only after both attempts failed, and then the story result says so in one line. Phase 5 compares the agents that started (`agent-audit.log`) against the agents the plan named.
- [ ] every file written through Task with an explicit studio `subagent_type` · [ ] truncation resumed, not re-spawned · [ ] a parent-written fallback is recorded, never silent · [ ] agents that ran are checked against the plan

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
