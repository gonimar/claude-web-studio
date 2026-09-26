# A security-relevant item outside the brief

Read from `/dev-story` Phase 6 step 5 for an item a specialist reported under *Outside the brief* that is security-relevant. It becomes a `production/findings.md` row instead of a `/backlog add`, under its own write gate and its own `docs:` commit gate — right after the story's commit and push, before any CI wait.

1. Show the row in the chat message (rule 7, readable rendering), then ask "May I write `production/findings.md`?" as one `AskUserQuestion`; `Write`/`Edit` only after the answer, then `touch .claude/.write-consent`.
2. Right after such a row is written, one commit gate (rule 7 (4), `git-workflow.md` § Documents), recorded first as `Gate "/dev-story Phase 6: commit findings <ID>?"` and cleared after the answer, one `AskUserQuestion`: `docs: findings <ID>` staging exactly `production/findings.md`. HEAD is the story branch here, so name it and offer: switch to the default branch and commit there (Recommended — a findings row is a pipeline-wide document) · commit here (the finding belongs to this story) · leave uncommitted.
3. On "switch": `git switch <default> && git pull --ff-only origin <default>`, the commit, then `git switch feat/S-NNN-slug` back — the hand-off `/code-review --diff` diffs HEAD against the default branch, and on HEAD = `<default>` that diff is empty.
4. Nothing is committed without the answer, and code never rides the `docs:` commit.
