# Git workflow for stories

One story = one branch = one pull request. The pipeline skills drive it; every git mutation
(branch, commit, push, merge) runs only after the user's explicit "yes". Hooks warn when the
workflow is broken (commit on the default branch, commit on an already-merged branch) and block
force-pushes.

| Step | Skill / phase | Git actions |
|---|---|---|
| Start | `/dev-story` Phase 3 | `git fetch origin`; switch to the default branch (`master` or `main`) and `git pull --ff-only`; `git switch -c feat/S-NNN-slug`. Never start on a branch that is already merged into the default branch — the session-start hook prints "no commits beyond origin/<default>" for such a branch. |
| Implement | `/dev-story` Phase 6 | Stage the story's files; `git commit -m "feat(S-NNN): <story title>"`; `git push -u origin feat/S-NNN-slug`. Session state keeps `Branch:` current. |
| Review | `/code-review` Phase 5 | Review itself never commits. Fixes applied on "yes" → checks re-run → `git commit -m "fix(S-NNN): apply /code-review findings"` → `git push`. |
| Close | `/story-done` Phase 4 | `git commit -m "docs: close S-NNN — Done, PR #N"` (story status, roadmap `[x]`); `gh pr create` when no PR exists yet. |
| Merge | `/story-done` Phase 5 | Only on `DONE`: `gh pr merge --merge --delete-branch` (merge commit; `--squash` only when the project's CLAUDE.md says so); `git switch <default> && git pull --ff-only`; delete the local branch; clear `session-state/active.md`. |

## Rules
- Conventional Commits with the story ID as scope: `feat(S-012): …`, `fix(S-012): …`, `docs: close S-012 …`.
- No commits on the default branch (the commit hook warns). No force-push (the push hook blocks).
- No work on a branch that is already merged: the commit hook warns "already merged into origin/<default>", the session-start hook prints ahead/behind.
- Solo projects still open the PR: CI runs on it and the merge records the review; `story-done` merges it.
- Hotfixes follow `/hotfix` (branch from the release tag, backport to the default branch).
- Releases are tags on the default branch (`/release-checklist`, `/deploy`); never deploy from a story branch.

## Session state
`production/session-state/active.md` → `Branch:` is the story branch from Phase 3 until Phase 5;
`/story-done` clears the file after the merge so the next session starts from the default branch.
