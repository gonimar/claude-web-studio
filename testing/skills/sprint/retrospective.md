# Skill Spec: /retrospective

> **Category**: sprint · **Priority**: medium · **Spec written**: 2026-09-10

## Summary
Sprint retrospective from artefacts: planned vs shipped, estimate vs actual with the calibration ratio, blockers, incidents and findings of the period, at most five actions with owners; writes the sprint file's `## Retrospective` section and the actions into the roadmap. Blameless. Sonnet.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] template link

## Cases
### 1. Happy path — sprint with data
**Fixture**: sprint 02 with five stories: four Done with `~Nh` and `⏱ Nh` on the roadmap, one carried over with `Blocked: spec gap`. **Expected**: the planned-vs-shipped table, Σ estimate, Σ actual and the ratio exactly as computed; goal verdict with evidence; the carried-over story's cause named; actions ≤ 5 each with owner, place and date; "May I write the `## Retrospective` section … and the actions to the roadmap?"; `docs: retrospective sprint 02` commit gate.
- [ ] ratio computed, not rounded to a story · [ ] causes from the artefacts · [ ] actions with owner and place · [ ] write gate
### 2. Refusal / BLOCKED — no sprint file
**Fixture**: `production/sprints/` empty. **Expected**: `BLOCKED (no sprint file — run /sprint-plan NN first)`, nothing written.
- [ ] writes no files · [ ] names `/sprint-plan`
### 3. Mode/argument variant — insufficient data
**Fixture**: two Done stories, only one with `⏱`. **Expected**: the table still shown; ratio line reads "insufficient data, ratio not applied"; the missing `⏱` is named as a `/story-done` omission; verdict `COMPLETE (insufficient data for the ratio)`.
- [ ] no ratio applied · [ ] omission named
### 4. Edge case — blameless
**Fixture**: a story slipped because an engineer agent rewrote a module twice. **Expected**: the cause is written as a system/process cause (spec ambiguity, missing ADR, review too late), never as an agent or person; a studio issue is suggested only with evidence a `/skill-test spec` could check.
- [ ] no names · [ ] evidence for a studio issue
### 5. Gate / protocol — actions accepted before the write
**Fixture**: the user edits two of the five actions. **Expected**: actions are accepted in their own `AskUserQuestion` before the write gate; the write gate is a separate message with the rendered section; the next step offers `/sprint-plan 03` (Recommended).
- [ ] two gates, two messages · [ ] rendered before the write · [ ] next step is the next sprint plan

## Protocol
- [ ] "May I write?" before writes · [ ] draft before approval · [ ] next step · [ ] never advances the stage itself

## Coverage notes
Closes roadmap R-08 and, with `/story-done` (⏱) and `/sprint-plan` (ratio applied), R-07.
