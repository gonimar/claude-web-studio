---
name: create-stories
description: "Breaks a feature spec into implementable stories (vertical slices: contract → backend → frontend/game → tests) with acceptance criteria mapped to tests, size, layer, ADR links. Produces production/stories/F-NNN/S-NNN-*.md."
argument-hint: "[F-NNN or feature-spec path]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion, Task
model: sonnet
agent: product-director
---

# Create Stories

Template `story.md`. Writes after "May I write?".

## Phase 1: Context
The feature spec (acceptance criteria are mandatory; none → suggest completing `/feature-spec`), the API contract, the data model, ADRs, the test strategy, existing stories (numbering).

## Phase 2: Slicing
Vertical slices (a working end-to-end path) before layers; every story ≤ M (≈ one day). Typical order: contract+codegen → migration+repository → service/resolvers → UI → e2e. Games: simulation → rendering → UI → saves.
Per story: goal, tasks, criteria (from the feature spec, none lost — show the "criterion → story" matrix), test level per criterion, security/accessibility, ADR, size, dependencies.

## Phase 3: Agreement
Show the list (ID, title, size, dependencies) and the criteria-coverage matrix; edits.

## Phase 4: Write
"May I write `production/stories/F-NNN/S-NNN-<slug>.md` (N files) and add lines to `production/roadmap.md`?" (roadmap format: `- [ ] S-NNN · Title`).

Verdict: `READY (N stories)`. Next step: `/sprint-plan` or directly `/dev-story S-NNN`.
