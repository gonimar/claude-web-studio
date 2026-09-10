---
name: backlog
description: "Idea capture and review — records a musing from the conversation ('what if we…', 'maybe we should…', 'it would be nice to…') as one line in production/backlog.md and stops, without implementing anything; lists the open ideas, promotes one to /brainstorm, /impact or /feature-spec, parks or closes it. Use the moment an idea appears that nobody has decided on, and for the weekly review."
argument-hint: "add \"<idea>\" | review | promote I-NNN | park I-NNN | close I-NNN [reason]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, AskUserQuestion
model: haiku
---

# Backlog — ideas are recorded, not executed

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

Template `.claude/docs/templates/backlog.md`; the roadmap format (`templates/roadmap.md`) reserves `production/backlog.md`
for ideas before their spec and `production/decisions.md` for owner decisions. Writes only after "May I write?".

## Phase 0: What is an idea (rule for every skill and the main conversation)
A **musing** — "what if we…", "maybe we should…", "it would be nice…", or their equivalents in the conversation language, said while
something else is in progress — is an idea, not an instruction. Nobody has decided anything yet, so nothing
is implemented, drafted or planned in the same turn (CLAUDE.md principle 2; coordination-rules rule 11). The
main conversation names it ("that is an idea, not part of the current story") and offers exactly this skill:
`/backlog add "<the idea in the user's words>"`. A **proposal** with a decision behind it ("add Redis for the
session store") is `/impact`'s business, not the backlog's; when unsure, record it here — promoting later costs
one command, implementing an undecided idea costs a story.

## Phase 1: `add "<idea>"`
Read `production/backlog.md` (create from the template when missing) and take the next `I-NNN`. Draft one
entry: `### I-NNN · <title in ≤ 8 words> 💡` + one line *recorded YYYY-MM-DD, source: <conversation | user |
incident INC-NNN | audit>* + the idea in one or two sentences **in the user's words**, plus, when obvious, the
area (`🏷 backend/frontend/game/infra/docs`) — no analysis, no options, no estimate: that is what promotion is for.
Render the entry in the chat, then "May I write `production/backlog.md`?" — one `AskUserQuestion`: write
(Recommended) · adjust the wording · not now. After the "write" answer: `touch .claude/.write-consent` (rule 7 —
the consent-guard hook checks the marker). Then one commit gate: `docs: backlog I-NNN <title>` staging exactly
that file, on the branch git-workflow's documents lane prescribes. **Stop here** — the recorded idea never
becomes a task in this turn; if a story or skill was in progress, the hand-off returns to it ("back to
/dev-story S-NNN (Recommended)").

## Phase 2: `review` (weekly, or when `/help` shows `Backlog: N ideas, oldest N days`)
Table of open ideas: ID · title · recorded · age · area · marker (`🅿` parked). Older than 60 days without a
decision → flagged. One `AskUserQuestion` per review, never per idea: promote one (name it) (Recommended when
something is older than 30 days) · park/close some · nothing now. Ideas are never silently deleted — `close`
keeps the line with `[x]` and the reason.

## Phase 3: `promote I-NNN` (the idea goes through the pipeline it skipped)
Decide the route from the entry, not from its wording, and hand off with one `AskUserQuestion`:
- vague, no clear user or scope → `/brainstorm "<title>"` (Recommended);
- a concrete change to code, architecture, security or deployment → `/impact "<idea>"` (its verifiers decide);
- a user-visible feature the product spec allows → `/feature-spec "<title>"`, it receives `F-NNN`;
- a technical choice → `/architecture-decision "<title>"`.
After the hand-off returns, mark the entry `→ promoted YYYY-MM-DD: [F-NNN](../docs/specs/features/…)` (or the
ADR / impact verdict) and tick it `[x]` — "May I update `production/backlog.md`?" with the same gate and commit.
`park I-NNN` adds `🅿` and a date; `close I-NNN <reason>` ticks it with the reason. Nothing here ever creates a
story or writes code.

Verdict: `COMPLETE (I-NNN recorded)` | `COMPLETE (review: N open, M promoted)` | `COMPLETE (I-NNN promoted → …)` |
`BLOCKED (not initialised — run /init)`. Next step — one `AskUserQuestion`: return to the interrupted work
(Recommended when something was in progress) · `/backlog review` · stop here.
