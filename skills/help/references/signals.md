# /help — signal lines (Phase 4)

Read from `SKILL.md` Phase 4 when a signal's condition holds: the exact line to print and the command it names. Each signal is one line in the report; a signal whose condition does not hold prints nothing (silent when equal, silent when absent). Commands carry their namespace as SKILL.md says (`/web-studio:<name>` in plugin mode).

| Signal | Condition | Line to print | Command named |
|---|---|---|---|
| Stack reference | `updated:` of `.claude/docs/stack-reference/index.md` (Phase 1 read) older than 60 days | `Stack reference is N days old → /stack-update` | `/stack-update` |
| Version drift, plugin mode | `diff -rq <plugin root>/docs .claude/docs` and `diff -rq <plugin root>/rules .claude/rules` (ignoring `technical-preferences.md` and `local-overrides/`) report N differing files | `Seeded docs differ from plugin vY (N files) — /update re-seeds changed docs/rules`; `/update` joins the closing question's options | `/update` |
| Version drift, session vs installed | `claude plugin list --json` reports an installed version other than the plugin root's (`vX` from the plugin root path or its `.claude-plugin/plugin.json`) | `session runs vX, vZ is installed — restart the session` | none |
| Version drift, copy mode | `.claude/.web-studio-version` (what seeded this project) is older than `<kit>/.claude-plugin/plugin.json`, when the session-start context names a kit path; otherwise skip the check | the same `/update` line as plugin mode | `/update` |
| Session state | `production/session-state/active.md` exists | its `Task:` and `Next:` lines | the `Next:` one |
| Backlog | `production/backlog.md` has open ideas (`### I-NNN` without `[x]`); a reminder when the oldest passes 30 days or `last-review` is older than 7 days | `Backlog: N ideas, oldest N days → /backlog review` | `/backlog review` (never an option in the closing question) |
| Findings | open BLOCKING findings in `production/findings.md` without a story | `Open BLOCKING findings: N without a story → /create-stories` (Phase 2 rank 1 made it NEXT) | `/create-stories` |
| External signal | a red CI, a failed deploy, a billing or access problem seen in `session-state`, a tech-debt CRITICAL | `Attention: <signal> — <command or place that fixes it>`, one line each | the fixing command or place |
| Sprint over and not closed | see the three-line rule below | `Attention: sprint NN is over and not closed — /web-studio:retrospective NN` | `/retrospective NN` |
| Deploy artefacts | build phase, a Deploy target in technical-preferences, no `docs/ops/deploy.md` | `Deploy artefacts story missing (no docs/ops/deploy.md) → /create-stories adds it` | `/create-stories` |
| Session-start signals | the session-start context printed a merged branch, a template placeholder left in CLAUDE.md, a stack reference older than 60 days or an open `Gate:` | each repeated as its own line — the context is data, not decoration; the user reads this answer, not the startup block a second time | the one the context names, if any |

Version drift is evidence, never a stamp in plugin mode: a `.claude/.web-studio-version` found in plugin mode is a copy-mode leftover (`/update` removes it), not a version to compare.

`Attention:` lines (external signals, the sprint) are never the subject of the closing question and never investigated here: no `gh run`, no log reading; help is orientation, not diagnosis.

## Sprint over and not closed — the rule
1. Take the latest `production/sprints/sprint-NN.md` and read its header only; a `Status: closed` line means closed, stop.
2. A file with no `Status:` line counts as closed when its roadmap block is folded in `<details>` (as `/sprint-status` and `/sprint-plan` read it); otherwise it is active.
3. An active sprint is over when its roadmap block has no `- [ ]` line left or its heading's end date is in the past → print the `Attention:` line; nothing else of the file is read.
