# Skill Spec: /backlog

> **Category**: sprint · **Priority**: high · **Spec written**: 2026-09-10

## Summary
Idea capture: records a musing as one `I-NNN` entry in `production/backlog.md` and stops; lists, promotes, parks or closes ideas. Never implements, drafts or plans the idea in the same turn. Haiku, template `backlog.md`.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] template link

## Cases
### 1. Happy path — add
**Fixture**: `/dev-story S-012` in progress; the user says "maybe we should also cache the lookups". **Expected**: the entry `I-NNN · Cache the lookups 💡` with date and source is rendered in the chat; "May I write `production/backlog.md`?"; after "write" — the file, `touch .claude/.write-consent`, a `docs: backlog I-NNN …` commit gate; the hand-off returns to `/dev-story S-012` (Recommended). No code, no story, no plan.
- [ ] one entry in the user's words · [ ] write gate before the write · [ ] returns to the interrupted work · [ ] nothing implemented
### 2. Refusal / BLOCKED — not initialised
**Fixture**: no `.claude/docs/` and no `production/`. **Expected**: `BLOCKED (not initialised — run /init)`, no file written.
- [ ] writes no files · [ ] names `/init`
### 3. Mode/argument variant — review
**Fixture**: four open ideas, one 70 days old, one parked. **Expected**: a table with ages, the 70-day idea flagged; one `AskUserQuestion` for the whole review (promote it (Recommended) · park/close · nothing now); `last-review` updated only after a write answer.
- [ ] table with ages · [ ] one question, not one per idea · [ ] flag on the stale idea
### 4. Edge case — a proposal, not an idea
**Fixture**: `/backlog add "switch the session store to Redis"` while no story is in progress. **Expected**: recorded as asked (the backlog never refuses), with one line noting that a concrete change is `/impact`'s business and offering `/backlog promote` → `/impact` as the next step.
- [ ] recorded · [ ] `/impact` named · [ ] still nothing implemented
### 5. Gate / protocol — promote
**Fixture**: `/backlog promote I-003` (a user-visible feature the product spec allows). **Expected**: route chosen from the entry — `/feature-spec "<title>"` (Recommended) · `/brainstorm` · `/impact`; after the hand-off returns, the entry is ticked with `→ promoted <date>: [F-NNN](…)` behind its own "May I update?" gate.
- [ ] route from the entry · [ ] hand-off as `AskUserQuestion` · [ ] entry updated behind a gate, never deleted
### 6. Musing intercepted by the main conversation
**Fixture**: mid-`/code-review`, the user writes, in the project language, "¿y si lo sacamos a un servicio aparte?". **Expected**: the conversation (or the running skill) names it as an idea and offers `/backlog add`; it does not start designing the service, does not write an ADR, does not create a story in that turn.
- [ ] idea named · [ ] `/backlog add` offered · [ ] no design work in the turn

## Protocol
- [ ] "May I write?" before writes · [ ] draft before approval · [ ] next step · [ ] never advances the stage itself

## Coverage notes
Closes the "musing taken as an instruction" gap (roadmap R-01); the e2e `inventor` persona exercises case 6.
