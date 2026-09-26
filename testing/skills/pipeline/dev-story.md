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
**Fixture**: no ADR/contract for the story; separately a story whose criteria change `schema.graphql`. **Expected**: BLOCKED with the command (`/architecture-decision` · `/api-contract`); the contract change is `BLOCKED (contract change — run /api-contract first)` — `/api-contract` is not run from inside the story, nothing is planned or branched.
- [ ] stops or explicitly flags the limitation · [ ] names the command/reason · [ ] writes no files · [ ] no mid-story `/api-contract` run
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
**Fixture**: Phase 3 branches for S-030 on a `Type: site` project with a public article page. **Expected**: the story card gets `Status: In Progress` and `Started: <ISO minute>` when the branch is created, and the card rides the `feat(S-030)` commit; in Phase 4 `seo-specialist` reviews title/meta/canonical, structured data, sitemap and hreflang before the story closes; on an internal SPA no SEO review is spawned.
- [ ] Started written · [ ] status In Progress · [ ] seo-specialist only for public pages

### Another skill runs through the `Skill` tool
**Fixture**: mid-story the user asks for a rate limit the criteria do not cover; at the end two specialists reported "Outside the brief" items, one of them security-relevant. **Expected**: `/impact <the request>` runs through the `Skill` tool (`/web-studio:impact` in plugin mode) after the running `Task` batch has returned, with its own table, verifier and gates, its verdict quoted, and the story resumes with its `Next:` untouched; right after the Phase 6 commit and push (step 4) and before the CI triggers are read (steps 6–7), each plain item is `/backlog add` through the `Skill` tool, one after another, each behind `/backlog`'s own gates; the security-relevant one becomes a `production/findings.md` row behind "May I write?" and then one commit gate `docs: findings <ID>` that names the story branch and offers switch-to-default (Recommended) · commit here · leave uncommitted; on "switch" the skill pulls the default branch, commits, and runs `git switch feat/S-NNN-slug` back, so the hand-off `/code-review --diff` sees the story's diff. A slow CI queue never loses an item: they are recorded before the wait. `/refactor` is never run this way: a story that would restructure packages stops with a closing `AskUserQuestion` naming it.
- [ ] `Skill` in `allowed-tools` · [ ] the called skill keeps its gates · [ ] skills one after another, never in a `Task` batch · [ ] findings row gets the commit gate · [ ] items recorded before the CI wait · [ ] HEAD is back on the story branch after a switch-to-default commit · [ ] `/refactor` is a hand-off

### CI that only pull_request starts
**Fixture**: `.github/workflows/ci.yml` has `on: pull_request` and no `push` trigger; the story branch is pushed at the end of Phase 6. **Expected**: the skill reads the triggers, opens a draft PR (`gh pr create --draft --fill`) so the checks start, and names the run it expects; it never waits for a run that was never queued.
- [ ] triggers read, not assumed · [ ] draft PR opened when the PR is what starts CI · [ ] no wait on a non-existent run

### A spike leaves no trace in the repository
**Fixture**: the plan for a story includes a throwaway script to check a library's behaviour. **Expected**: Phase 3 names the spike's path under `tools/spike-<slug>/` (gitignored) or the session scratchpad, and says it is deleted in Phase 6; Phase 6 stages the story's own files by name — never `git add -A` — and reports any unplanned `??` entries in `git status --short` before committing.
- [ ] spike path named and gitignored · [ ] no `git add -A` · [ ] untracked leftovers reported before the commit

### The parent does not write the story's code
**Fixture**: a story touching a Go package and its tests; the first `go-engineer` call comes back cut off at its turn limit having written nothing. **Expected**: the skill resumes that agent with its stopping point rather than spawning a new one; on a second truncation it splits the remaining work into smaller calls; the parent writes product code only after both attempts failed, and then the story result says so in one line. Phase 5 compares the agents that started (`agent-audit.log`) against the agents the plan named.
- [ ] every file written through Task with an explicit studio `subagent_type` · [ ] truncation resumed, not re-spawned · [ ] a parent-written fallback is recorded, never silent · [ ] agents that ran are checked against the plan

### Context gate and the six-line brief (0.12)
**Fixture**: statusline `ctx: 62%`, a story S-012 of three files the parent read in Phase 2. **Expected**: Phase 1 offers `/clear`, then `/web-studio:dev-story S-012` (Recommended) before any plan; when the user continues, every `Task` brief carries `Story · Read` (paths **with line ranges**) `· Write · Check · Skip · Report`; a brief without `Read:` ranges is not sent.
- [ ] context gate before the plan · [ ] six-line brief · [ ] line ranges in `Read:`
### Resume without the parent's own checks (0.12)
**Fixture**: `go-engineer` cut off at its limit with `Checkpoint: done: domain · next: usecase tests · unverified: build`. **Expected**: one `SendMessage` — "continue from your Checkpoint; run git status and the step's Check yourself" — and no `git status`, build or test by the parent before it; the parent verifies once after the `SubagentStop`.
- [ ] resume first · [ ] no parent checks before resume · [ ] hand-off names `/web-studio:code-review`

### Consent is collected by the parent (0.13)
**Fixture**: a two-step plan (`go-engineer` handler + tests, `go-engineer` route) on a story whose files the plan names. **Expected**: the Phase 3 answer "continue" covers the branch, the state update, the `Started:` stamp and the planned files; no extra approval question per specialist step; a specialist that needs a file, dependency or contract change outside its brief stops and reports, and the parent asks (or detours to `/impact`). A run asks three questions: plan, commit, next step.
- [ ] no per-step approval question · [ ] out-of-brief work comes back to the parent · [ ] three gates on the happy path
### A red default branch is named before the story branches
**Fixture**: `gh` present; `gh run list --branch master --limit 1` shows the latest run `failure` (job `lint`); separately no `gh`. **Expected**: in Phase 3 step 4, before `git switch -c feat/S-NNN-slug`, the red run is named with its job and id, and the plan question of step 3 carries `/web-studio:hotfix --chore` (copy mode `/hotfix --chore`) as an option next to continue (Recommended) · change the plan · stop — the story is not blocked by it; a green run adds nothing; without `gh` one line says the check was not possible.
- [ ] `gh run list --branch <default> --limit 1` before the branch · [ ] red run named, `/hotfix --chore` offered · [ ] not blocking · [ ] no `gh` → said, not skipped silently

### An open gate survives the turn
**Fixture**: the Phase 6 commit question is asked and the session ends before the answer; separately the `docs: findings <ID>` gate. **Expected**: before each question `production/session-state/active.md` holds `Gate: /dev-story Phase 6: …` written through `<hooks>session-state.sh set Gate`, the resumed session continues at that question rather than reading `Next:` as a new task, and after the answer the gate reads `—`.
- [ ] gate recorded before the commit gate and the findings gate · [ ] cleared after the answer · [ ] resume continues the gate

### Default branch without an upstream (0.13)
**Fixture**: the session starts on a merged story branch; the local default branch has no upstream configured. **Expected**: `git pull --ff-only origin <default>` fast-forwards it before `git switch -c feat/S-NNN-slug`; the story branch never starts from a stale default branch.
- [ ] explicit remote on the pull · [ ] story branch contains origin/<default>

### Started with an offset, sprint row In Progress (0.13)
**Fixture**: branch created at 20:30 local (+0500) for S-060 in sprint 05. **Expected**: the card's metadata line gets `Started: 2026-…T20:30+0500` (from `date +%FT%H:%M%z`, not typed from memory); the S-060 row in `sprint-05.md` reads `In Progress` after one Edit.
- [ ] offset present · [ ] sprint row updated

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
