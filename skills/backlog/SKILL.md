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

Template `.claude/docs/templates/backlog.md`; the roadmap format (`.claude/docs/templates/roadmap.md`) reserves
`production/backlog.md` for ideas before their spec and `production/decisions.md` for owner decisions.

**Write gate** (every mode below that changes the file): render the new or changed entry in the chat, then
"May I write `production/backlog.md`?" — one `AskUserQuestion`: write (Recommended) · adjust the wording · not now.
After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker), then
write. Then one commit gate: `docs: backlog <what>` staging exactly that file, on the branch git-workflow's
documents lane prescribes.

**Not initialised** — no `.claude/docs/` and no `production/` → `BLOCKED (not initialised — run /init)`, nothing
written. An initialised project without `production/backlog.md` gets it created from the template at the first write.

## Phase 0: What is an idea (rule for every skill and the main conversation)
A **musing** — "what if we…", "maybe we should…", "it would be nice…", or their equivalents in the conversation language, said while
something else is in progress — is an idea, not an instruction. Nobody has decided anything yet, so nothing
is implemented, drafted or planned in the same turn (CLAUDE.md principle 2; coordination-rules rule 11). The
main conversation names it ("that is an idea, not part of the current story") and offers exactly this skill:
`/backlog add "<the idea in the user's words>"`. A **proposal** with a decision behind it ("add Redis for the
session store") is `/impact`'s business, not the backlog's; when unsure, record it here — promoting later costs
one command, implementing an undecided idea costs a story.

## Phase 1: `add "<idea>"`
1. Read `production/backlog.md` and take the next `I-NNN`.
2. Draft one entry: `### I-NNN · <title in ≤ 8 words> 💡`, one line *recorded YYYY-MM-DD, source: <conversation |
   user | incident INC-NNN | audit>*, and the idea in one or two sentences **in the user's words**. Add the area
   (`🏷 backend/frontend/game/infra/docs`) when it is obvious. No analysis, no options, no estimate: that is what
   promotion is for.
3. **A proposal passed to `add`** (a concrete change with a decision behind it) is recorded as asked — the backlog
   never refuses — with one line saying that a concrete change is `/impact`'s business; the next step then offers
   `/backlog promote I-NNN` → `/impact`.
4. Write gate and commit gate (`docs: backlog I-NNN <title>`).
5. **Stop here.** The recorded idea never becomes a task in this turn. If a story or skill was in progress, the
   hand-off returns to it ("back to /dev-story S-NNN (Recommended)").

## Phase 2: `review` (weekly, or when `/help` shows `Backlog: N ideas, oldest N days`)
1. Render a table of open ideas: ID · title · recorded · age · area · marker (`🅿` parked). Flag ideas older than 60
   days without a decision.
2. **Ideas that left sideways.** An idea can leave the backlog without `promote` — the user ran `/impact` or
   `/feature-spec` on it directly — and the entry then stays open for weeks while the work is already done. An open
   entry whose text matches a spec, ADR or impact verdict written later is that case: name it and offer to close it
   with the link.
3. One `AskUserQuestion` per review, never per idea: promote one (name it) (Recommended when something is older than
   30 days) · park/close some · nothing now.
4. Apply the answer through the matching mode below. With a write answer, also set `last-review` and **Reviewed:**
   to today (the template header; `/help` reads `last-review`), behind the write gate.

Ideas are never silently deleted: `close` keeps the line with `[x]` and the reason.

## Phase 3: `promote I-NNN` · `park I-NNN` · `close I-NNN <reason>`
**`promote I-NNN`** — the idea goes through the pipeline it skipped.
1. Decide the route from the entry, not from its wording:
   - vague, no clear user or scope → `/brainstorm "<title>"`;
   - a concrete change to code, architecture, security or deployment → `/impact "<idea>"` (its verifiers decide);
   - a user-visible feature the product spec allows → `/feature-spec "<title>"`, it receives `F-NNN`;
   - a technical choice → `/architecture-decision "<title>"`.
2. Hand off with one `AskUserQuestion`: the route chosen in step 1 (Recommended) · the other plausible routes · not now.
3. After the hand-off returns, mark the entry `→ promoted YYYY-MM-DD: [F-NNN](../docs/specs/features/…)` (or the
   ADR / impact verdict) and tick it `[x]`, behind the write gate ("May I update `production/backlog.md`?") and the
   commit gate. The promotion counts only once that line exists.

**`park I-NNN`** adds `🅿` and a date (and the reason, when given). **`close I-NNN <reason>`** ticks it `[x]` with
the reason. Both go through the write gate and the commit gate.

Nothing here ever creates a story or writes code.

Verdict: `COMPLETE (I-NNN recorded)` | `COMPLETE (review: N open, M promoted)` | `COMPLETE (I-NNN promoted → …)` |
`BLOCKED (not initialised — run /init)`. Next step — one `AskUserQuestion`: return to the interrupted work
(Recommended when something was in progress) · `/backlog promote I-NNN` (Recommended when a proposal was just
recorded and nothing was in progress) · `/backlog review` · stop here.
