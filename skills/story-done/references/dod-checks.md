# /story-done — DoD check recipes (Phase 3)

Read at Phase 3. Each block is the exact command behind one checklist item; the item in SKILL.md carries
the verdict, the recipe produces the evidence the report quotes (artefacts over claims).

## Item 2 — the studio's review ran
- A reviewer of record is the agent the `/code-review` routing table (its Phase 2 step 1) requires for
  the diff's files — the stack's `*-engineer` plus its `*-lead`, `appsec-engineer` on sensitive paths;
  no other Stop counts (a `tech-writer` or engineer Stop from a fix round is a fixer, not a reviewer).
  The log records `web-studio:<name>` in plugin mode and `<name>` in copy mode.
- The branch's first commit: `FIRST=$(git log --reverse --format=%ci origin/<default>..HEAD | head -1)`
  (`YYYY-MM-DD HH:MM:SS ±HHMM`).
- The stops:
  `grep -E 'SubagentStop \| (web-studio:)?[a-z-]+-(lead|engineer)' production/session-logs/agent-audit.log`, then
  keep the lines whose agent the routing row required
  — a log line starts with `date '+%F %T'` in the machine's local time; compare it with `$FIRST` read in
  the same zone. A Stop later than the first commit counts; earlier Stops belong to the implementation.
- `security-sensitive` story (the paths of `rules/security-sensitive.md`: `auth`, `security`, `middleware`,
  `nginx`/`Caddyfile`/`*.conf`, `payments`, `upload*`, `webhook*`): `appsec-engineer` must be among those
  Stops; otherwise `NOT DONE (no studio review)` naming `appsec-engineer`.
- No matching Stop at all → `NOT DONE (no studio review)` naming the reviewer the routing table required.
  A review in the chat only — Claude Code's built-in `/code-review`, a parent's own reading — is not
  evidence: the chat can claim an appsec review the log never recorded.

## Item 4 — findings recorded
`grep -c '<ID>' production/findings.md` for every `ARCH-NNN`/`SEC-NNN` the card names; `0` → open item.

## Item 6 — TODOs carry an id
- Added TODOs: `git diff <default>...HEAD | grep -nE '^\+.*(TODO|FIXME|HACK)'`.
- Per id: `grep -c '<ID>' production/roadmap.md production/backlog.md` prints one count per file; either
  count ≥ 1 → ✅. A bare TODO or an unknown id → open item whose fix is `/backlog add` and the id; the
  TODO stays.

## Items 7–9 — branch, stash, agent memory
- `git status --short` must be empty; a ` M`/`??` line under `.claude/agent-memory/` counts as an
  uncommitted change and is quoted in the report.
- `git stash list` must be empty; an entry is quoted and stays an open item until the user applies or drops
  it (never the skill).
- Pushed: `git rev-parse --abbrev-ref @{u}` names an upstream and `git status -sb` shows no `ahead`.
- Uncommitted memory files → the memory-commit gate (item 9), then
  `git add .claude/agent-memory/ && git commit -m "feat(S-NNN): agent memory"` (`fix(S-NNN): …` after a
  review round) on the branch and `git push`; never `git stash push -u`, never
  `git checkout -- .claude/agent-memory/`.

## Item 10 — CI on the branch
- `gh run list --branch <branch> --limit 5` when `gh` exists; the latest run's `status` and `conclusion`.
- In progress → § CI wait: one background `gh run watch <run-id> --exit-status`.
- No run: `grep -l pull_request .github/workflows/*.yml` — when the workflows trigger on `pull_request` and
  `gh pr list --head <branch>` is empty, the item reads `pending (the PR opened in Phase 4 starts it)`, not
  open; Phase 5 step 1 waits for that run.
