# Skill Spec: /sprint-status

> **Category**: sprint · **Priority**: high · **Spec written**: 2026-09-05

## Summary
Sprint status from artefacts; read-only.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path
**Fixture**: sprint in progress. **Expected**: Done/In Progress/Blocked summary; goal risk.
- [ ] phase order followed · [ ] output matches the expectation · [ ] writes only after consent
### 2. Refusal / BLOCKED
**Fixture**: no sprint. **Expected**: reports it.
- [ ] stops or explicitly flags the limitation · [ ] names the command/reason · [ ] writes no files
### 3. Mode/argument variant
**Fixture**: gh unavailable → no CI. **Expected**: behaviour differs from case 1 according to the argument.
- [ ] argument parsed · [ ] the difference matches the skill description
### 4. Edge case
**Fixture**: Done without a test → discrepancy. **Expected**: handled explicitly, never silently skipped.
- [ ] the case is mentioned in the instructions · [ ] correct message/action
### 5. Gate / protocol
**Fixture**: no writes. **Expected**: the user decides; stage/statuses never change automatically; the hand-off is an `AskUserQuestion` with a Recommended option and alternatives.
- [ ] no self-advancing · [ ] verdict from the skill's vocabulary · [ ] hand-off is an `AskUserQuestion`, not text

### 6. Dependency queue
**Fixture**: three open Dependabot PRs, one older than the sprint start, one with a failing check. **Expected**: the `Dependency PRs:` line with counts and the oldest date; the stale and the red PR under *Risk to the goal* with `/sprint-plan` named as the fix; nothing merged.
- [ ] line present with counts · [ ] stale/red under risk · [ ] no mutation

### 7. Burn
**Fixture**: sprint of 10 days, day 6; five stories planned with `~Nh` on their roadmap lines (40 h); two Done, their `docs: close S-NNN` commits on day 2 and day 4 (16 h) — the day-4 one still sits on `feat/S-*` after a declined merge; a third story marked Done by hand with no close commit, its roadmap line ticked in a commit on day 5. **Expected**: `Burn: 16 h of 40 h closed (2 of 5 stories) · day 6 of 10 · on a straight line 24 h would be closed by now` (with the third story's hours on day 5 when it has an estimate), a cumulative per-day line (`day 1: 0 · day 2: 8 h · … · day 6: 16 h`), and a *Risk to the goal* line because 16 h is more than one day's share (4 h) behind 24 h; the close date is the author date of the `docs: close S-NNN` commit found with `git log --all` (the branch-only commit counts), the fallback is the roadmap tick/`Updated:` date, and the story card's `Actual:` line — a duration — is never read as a date; one story without an estimate → the line counts stories, never an invented number.
- [ ] closed vs planned computed from artefacts · [ ] per day since the sprint start · [ ] risk line when behind · [ ] close commit found across all refs · [ ] `Actual:` never used as a date

### 8. Parent-write under risk
**Fixture**: `agent-stats.sh` reports `3 code file(s) written by the session itself (parent-write)`. **Expected**: the count is printed in the Agents block and repeated under *Risk to the goal* as `parent-write: 3 file(s) — engineer rule bypassed`; zero → no risk line.
- [ ] count printed · [ ] under risk when not zero · [ ] silent when zero

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
