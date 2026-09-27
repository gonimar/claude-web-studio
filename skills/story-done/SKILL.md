---
name: story-done
description: "Verifies a story is truly done: every acceptance criterion has a passing test (with output), lint/typecheck/security checks pass, review is APPROVED, docs updated; then closes it and updates roadmap/session state. Run after /code-review."
argument-hint: "[story-path or S-NNN]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Edit, AskUserQuestion
---

# Story Done

Language, `<hooks>`, agent and command namespaces, gate mechanics (record `Gate` → ask → clear; consent marker after the "write" answer) and the CI wait: `docs/coordination-rules.md` § Skill conventions. Every mutation (files, git, merge) has its own gate, asked by this session, never by a subagent.

Glossary:
- `<default>` — the default branch (`master` or `main`); `<branch>` — the story branch (`Branch:` in the session state, else `git branch --show-current`).
- `<card>` — `production/stories/S-NNN-*.md`; `<sprint>` — `production/sprints/sprint-NN.md` when a sprint's roadmap heading holds the story.
- **Three places** — the roadmap line, the roadmap's `## Docs` → *production/stories/* row, the `<sprint>` `## Stories` row (two without a sprint).
- **Re-run rule** — `/story-done S-NNN` on a story already `Done` with an open PR skips to Phase 5 and its merge question.

## Phase 1: Story and evidence
1. **Pick the story** (as `/dev-story` Phase 1):
   1. The argument (a story path or `S-NNN`), else `Task:` in `production/session-state/active.md`, else ask — one `AskUserQuestion`: the stories in `Review` (most recently started first, Recommended) · another story (say which) · stop. A story taken from the session state is named in the report's first line, so a stale `Task:` closes no wrong story.
   2. Status `Review` → continue.
   3. Status `Done` with an open PR (`gh pr list --head <branch>`) → the re-run rule: skip Phases 2–4, go to Phase 5.
   4. `Ready` or `In Progress` → `NOT DONE (story not in Review — run /dev-story S-NNN, then /code-review)`; nothing is written.
   5. Wording exception: a `Ready`/`In Progress` story whose branch carries a `feat(S-NNN)` commit (`git log origin/<default>..<branch> --oneline | grep 'S-NNN'`) and a PR (`gh pr list --head <branch>`) was implemented and never stamped → `NOT DONE (implemented but never set to Review — set it and re-run)`, naming the commit and the PR; the status is not changed here.
2. **Read** the story, the feature-spec criteria, and the latest `/code-review` report (chat history, or `production/reviews/` if kept).

## Phase 2: Run
1. Run the tests from the criteria matrix and the whole affected package.
2. Run lint/typecheck; `govulncheck` / `audit` when dependencies changed.
3. For UI: axe on new pages (if e2e exists).
4. Put the output in the report. Anything red → `NOT DONE`.

## Phase 3: DoD checklist
Each item is ✅ or an open item named in the report; recipe (exact commands): `references/dod-checks.md`, read here.
1. **Criteria ↔ tests**: the criterion → test → result table **rendered in the chat message** (rule 7), not just written to the story file.
2. **The studio's review ran**: a studio reviewer's `SubagentStop` in `production/session-logs/agent-audit.log` after the branch's first commit — the log, not the chat; `security-sensitive` → `appsec-engineer` among them. Missing → `NOT DONE (no studio review)`, naming the reviewer.
3. **Review APPROVED**: the reviewers' own verdict after the last fix (`/code-review` Phase 5), not the parent's summary of it.
4. **Findings recorded**: every `ARCH-NNN`/`SEC-NNN` in the card has a row in `production/findings.md`; an ID without a row is an open item, not a formality.
5. **Docs** (README/API/runbook) updated; contract and codegen in sync.
6. **TODOs carry an id** (`rules/comments.md`): every added `TODO`/`FIXME`/`HACK` names an id present in the roadmap or the backlog; a bare TODO or an unknown id is an open item, fixed by `/backlog add` and the id, never by deleting the TODO.
7. **Branch pushed, tree clean**: `git status --short` empty, `.claude/agent-memory/**` included (memory rides the story's commits, git-workflow § Agent memory).
8. **No stash**: `git stash list` empty; an entry is an open item until the user applies or drops it, never a place to park memory files.
9. **Memory commit** for uncommitted memory files: one more `feat(S-NNN)`/`fix(S-NNN)` commit of `.claude/agent-memory/` on the branch, behind `<hooks>session-state.sh set Gate "/story-done Phase 3: commit agent memory?"` → one `AskUserQuestion` → `<hooks>session-state.sh set Gate "—"`; never `git stash`, never a discard.
10. **CI green on the branch**: `gh run list --branch <branch>` when `gh` exists; in progress → the CI wait. No run because the workflows trigger on `pull_request` and no PR exists yet → `pending (the PR opened in Phase 4 starts it)`, not open: DONE proceeds, Phase 5 step 1 waits for it.

**Verdict point**: every item ✅ (item 10 may read `pending`) → `DONE`, continue; otherwise `NOT DONE (items)` and stop — nothing written, nothing merged.

## Phase 4: Close
Only on `DONE`.
1. **Close gate**: show the draft as the resulting rows (`Actual: Nh`/`⏱ Nh`, roadmap line, `## Docs` row, `<sprint>` row; `PR #N` is a placeholder until step 3 knows the number); `<hooks>session-state.sh set Gate "/story-done Phase 4: close S-NNN?"`; one `AskUserQuestion`: "May I write `<card>`, `production/roadmap.md` and `<sprint>` as shown, commit `docs: close S-NNN — Done, PR #N`, push, and open the PR if none exists?" — close and open the PR (Recommended) · close without the PR · not now. Then `<hooks>session-state.sh set Gate "—"`. The answer covers the close only, never the merge; "not now" ends with the verdict.
2. **Count before editing**: `grep -c "⏱" production/roadmap.md` and `grep -c "🔗 \[PR #" production/roadmap.md`.
3. After the "yes": `touch .claude/.write-consent`, then **the PR number before any edit** (the roadmap link, `## Docs` row and commit carry it): a PR exists → `gh pr view --json number,url`; none and "close and open the PR" → `gh pr create --fill` now, then read its number and URL; "close without the PR" → no PR number anywhere (`references/close-edits.md` § Without a PR).
4. **The edits**: read `references/close-edits.md` and apply its four edits — actual time (`Actual:`, `⏱ Nh`, both ends in one clock), roadmap line (`[x]`, `🔗 PR`, `Updated:`), `## Docs` row, `<sprint>` row — one `Edit` per row, never a heredoc or a file rewrite.
5. **Prove the edit, never assume it**: run the two counts again, re-read the `## Docs` row, and `grep -E "^\| S-NNN .*Done" <sprint>` when there is a sprint row. `⏱` or `🔗 PR` missing from any of the three places → an unfinished DoD item in the report, numbers quoted: an answer can carry numbers that never reached the file.
6. **Commit and push**: stage exactly `<card>`, `production/roadmap.md` (its story line and `## Docs` block) and `<sprint>` when its row changed; `git commit -m "docs: close S-NNN — Done, PR #N"` (no PR: `docs: close S-NNN — Done`); `git push`, so the PR carries the close commit.

## Phase 5: Merge (`.claude/docs/git-workflow.md`, step "Merge")
Only on `DONE`, after Phase 4 or through the re-run rule. No PR ("close without the PR", or no `gh` and none opened by hand) → skipped; say how to finish: open the PR, then re-run `/story-done S-NNN` (re-run rule).
1. **Wait for CI** on the PR's latest commit: one background `gh run watch <run-id> --exit-status` (or `gh pr checks <n> --watch`), § CI wait. Red → `NOT DONE (CI red)`, nothing merged, the Phase 4 close stays (the DoD held on green CI in Phase 3; a red close commit is a new branch failure, not a reopened story); one report line "closed, not merged: CI red on <commit>"; after the fix, re-run `/story-done S-NNN` (re-run rule).
2. **Merge gate**: `<hooks>session-state.sh set Gate "/story-done Phase 5: merge PR #N?"`; a separate `AskUserQuestion`: "PR #N is open and CI is green. Merge it into `<default>` and delete the branch now?" — merge now (Recommended when CI is green) · leave the PR open. Then `<hooks>session-state.sh set Gate "—"`.
3. "yes":
   1. A draft PR (opened by `/dev-story` Phase 6) → `gh pr ready <n>` first.
   2. `gh pr merge --merge --delete-branch` (`--squash` only when the project's CLAUDE.md says so).
   3. `git switch <default> && git pull --ff-only origin <default>`; delete the local story branch.
   4. `<hooks>session-state.sh clear` (the same writer `/dev-story` used, so the file keeps its shape).
4. "no" (or no answer) → the PR stays open, `Branch:` stays in the session state; how to merge later: re-run `/story-done S-NNN` (re-run rule), or merge on GitHub and `git switch <default> && git pull --ff-only origin <default>`.
5. Without `gh`: the same, by hand. `NOT DONE` → nothing is merged.

Verdict: `DONE` | `NOT DONE (reasons)`.

Next step — one `AskUserQuestion`:
- **Sprint over** (no `- [ ]` line left under its roadmap heading after this close, or the heading's end date — its second ISO date — has passed) → `/web-studio:retrospective NN` (copy mode `/retrospective NN`) (Recommended): nothing else closes a sprint, and the next story would start in one that no longer exists · `/web-studio:sprint-status` · stop. No `/clear` + `dev-story` option.
- **Otherwise** → `/clear`, then `/web-studio:dev-story S-NNN` (copy mode `/dev-story S-NNN`) (Recommended): a fresh session on the fresh default branch (rule 13); quote the statusline `ctx:` share when known · `/web-studio:sprint-status` · stop.
- Continuing the next story here is an "Other" the user types, never an option offered.
