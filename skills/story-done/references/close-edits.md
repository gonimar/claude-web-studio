# /story-done — the close edits (Phase 4 step 4)

Read after the close answer and once the PR number is known (Phase 4 steps 1–3). Four edits, each one
`Edit` of the line or row it names — never a Bash heredoc, never a rewrite of the file. The values were
shown in the draft before the close gate; the edits write exactly those values.

1. **Actual time**: `⏱ Nh` on the roadmap line and `Actual: Nh` in the card — wall-clock from the card's
   `Started:` line (written by `/dev-story` or `/refactor --apply` at branch time) to now, rounded to 0.5 h.
   **Both ends in the same clock**: `Started:` carries its offset (`YYYY-MM-DDTHH:MM±HHMM`; a card without
   one is local time) and "now" is `date +%FT%H:%M%z` on the same machine — never the UTC stamp of a CI run,
   a GitHub timestamp or a log line (a stamp in another zone is off by hours). No `Started:` → `⏱ ?` and one
   line naming the omission, never a number reconstructed from `git reflog` or commit dates.
2. **Roadmap line** (`production/roadmap.md`): tick `[x]`, add `🔗 [PR #N](url)` inline (same rule as the
   ID: a file-relative link, not a `## Links` reference-definition), and refresh the `Updated:` line.
   Without a PR ("close without the PR"): no `🔗`.
3. **`## Docs` → *production/stories/* block** (in `production/roadmap.md`): the story's row becomes
   `✅ … Done · PR #N` (without a PR: `✅ … Done`).
4. **Sprint file**, when a sprint's roadmap heading holds the story: its row in that sprint file's
   `## Stories` table (`production/sprints/sprint-NN.md`) becomes `Done · ⏱ Nh · PR #N`, with an Edit of
   that row, never a rewrite of the file; a story taken from the Backlog has no sprint row. `/sprint-status`
   and `/retrospective` read this table, so a row left at `Ready` misreports the whole sprint.

## Without a PR

"Close without the PR" (or no `gh` and no PR opened by hand): no PR number anywhere — the roadmap line
gets no `🔗`, the `## Docs` row reads `✅ … Done`, the sprint row `Done · ⏱ Nh`, and the commit is
`docs: close S-NNN — Done`. With a PR, `gh pr create --fill` needs only the pushed branch; the draft PR
`/dev-story` opened, or one opened by hand, is read with `gh pr view --json number,url`.
