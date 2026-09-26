# Skill Spec: /story-done

> **Category**: pipeline · **Priority**: critical · **Spec written**: 2026-09-05

## Summary
Acceptance: criteria ↔ tests with a run, DoD, closure.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path
**Fixture**: all tests green, review APPROVED. **Expected**: DONE; roadmap [x] after consent.
- [ ] phase order followed · [ ] output matches the expectation · [ ] writes only after consent
### 2. Refusal / BLOCKED
**Fixture**: one criterion without a test. **Expected**: NOT DONE.
- [ ] stops or explicitly flags the limitation · [ ] names the command/reason · [ ] writes no files
### 3. Mode/argument variant
**Fixture**: sensitive path without appsec review → NOT DONE. **Expected**: behaviour differs from case 1 according to the argument.
- [ ] argument parsed · [ ] the difference matches the skill description
### 4. Edge case
**Fixture**: new packages → audit. **Expected**: handled explicitly, never silently skipped.
- [ ] the case is mentioned in the instructions · [ ] correct message/action
### 5. Gate / protocol
**Fixture**: status changes with consent. **Expected**: the user decides; stage/statuses never change automatically; the Phase 4 and Phase 5 questions are `AskUserQuestion`s with a Recommended option and alternatives.
- [ ] no self-advancing · [ ] verdict from the skill's vocabulary · [ ] Phase 4/5 gates are `AskUserQuestion`s, not text yes/no
### 6. Git workflow
**Fixture**: DONE, PR #7 open, `gh` available. **Expected**: `docs: close S-NNN — Done, PR #7` commit after the Phase 4 question; then a *separate* merge question; only after its own "yes" — `gh pr merge --merge --delete-branch`, switch to the default branch and pull, session state cleared. "yes" to Phase 4 alone → no merge, PR left open, `Branch:` kept, how to merge later printed. On NOT DONE nothing is merged.
- [ ] merge only on DONE · [ ] merge has its own question (Phase 4's "yes" never merges) · [ ] declined merge: PR open, `Branch:` kept, how-to printed · [ ] default branch synced after merge · [ ] session state cleared

### 6b. Waiting for CI
**Fixture**: PR open, self-hosted runner queue slow. **Expected**: one background `gh run watch --exit-status` with a single notification; no polling `Monitor`, no `ScheduleWakeup`, no `AskUserQuestion` used as a pause; a slow queue ends the turn with one status line.
- [ ] single background wait · [ ] no placeholder question

### The story is resolved before anything is read
**Fixture**: `/story-done` without an argument; `production/session-state/active.md` has `Task: S-014 …`; separately no `Task:` line and two stories in `Review`; separately an argument naming a story still `In Progress`. **Expected**: with the `Task:` line the skill names S-014 in the first line of the report and proceeds; without it, one `AskUserQuestion` lists the `Review` stories (most recently started first, Recommended) before any test runs; the `In Progress` story ends with `NOT DONE (story not in Review — run /dev-story S-NNN, then /code-review)` and nothing is written.
- [ ] argument · `Task:` · ask, in that order · [ ] resolved story named in the report · [ ] wrong status → NOT DONE, no writes

### 7. Actual time recorded
**Fixture**: story card `Started: 2026-09-10T09:00`, closing at 11:40. **Expected**: `⏱ 2.5h` on the roadmap line and `Actual: 2.5h` in the card inside the Phase 4 gate; a card without `Started:` gets `⏱ ?` and one line naming the omission — never a guessed number.
- [ ] ⏱ computed from Started · [ ] unknown stays unknown

### The roadmap really carries the time and the PR
**Fixture**: a story being closed with an open PR; the roadmap has both the sprint block and the `## Docs` → *production/stories/* block. **Expected**: after Phase 4 the story line carries `⏱ Nh` and `🔗 [PR #N](url)` and its `## Docs` row reads `✅ … Done · PR #N`; the skill re-reads both and reports a mismatch as an open DoD item instead of claiming the close.
- [ ] both places checked after the edit · [ ] mismatch reported, not swallowed · [ ] numbers quoted in the report

### The studio's review is in the log (0.12)
**Fixture**: a security-sensitive story; the chat holds a review by Claude Code's built-in `/code-review`; `agent-audit.log` has no `appsec-engineer` stop after the branch's first commit. **Expected**: `NOT DONE (no studio review)`, naming the missing reviewer; with the studio review in the log the DoD line is ✅.
- [ ] log checked, not the chat · [ ] appsec required for security-sensitive · [ ] NOT DONE names what is missing
### The next story starts fresh (0.12)
**Fixture**: DONE and merged, statusline `ctx: 48%`. **Expected**: the closing question offers `/clear`, then `/web-studio:dev-story S-NNN` (Recommended) and names the context share; "continue the next story here" is not an option.
- [ ] `/clear` first · [ ] namespaced command · [ ] no same-session option

### PR number before the close edits; no-PR path (0.13)
**Fixture**: `gh` present, a push-triggered workflow, so `/dev-story` opened no draft PR; DONE. **Expected**: after the close answer "close and open the PR", `gh pr create --fill` runs before the roadmap, `## Docs` and commit edits, which then carry `PR #N`; with "close without the PR" nothing carries a PR number, the commit is `docs: close S-NNN — Done` and Phase 5 is skipped with the re-run line. Red CI on the close commit → `NOT DONE (CI red)`, nothing merged, the close stays and the report says "closed, not merged".
- [ ] PR created before the edits that cite it · [ ] no-PR path skips Phase 5 · [ ] red CI leaves the close and names it

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
