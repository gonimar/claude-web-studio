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

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

Templates `story.md`, `deploy-runbook.md`, `findings.md`. Writes after "May I write?".

## Phase 1: Context
The feature spec (acceptance criteria are mandatory; none → suggest completing `/feature-spec`), the API contract, the data model, ADRs, the test strategy, existing stories (numbering), and `production/findings.md`: every open BLOCKING finding that touches this feature (area, file, API operation) becomes an acceptance criterion of the affected story or a dedicated story — never skipped silently; the matrix shows `finding → story`. `technical-preferences.md` → Deploy target (see Phase 2).

## Phase 2: Slicing
Vertical slices (a working end-to-end path) before layers; every story ≤ M (≈ one day). Typical order: contract+codegen → migration+repository → service/resolvers → UI → e2e. Games: simulation → rendering → UI → saves.
Per story: goal, tasks, criteria (from the feature spec, none lost — show the "criterion → story" matrix), test level per criterion, security/accessibility, ADR, size, dependencies.
**Deploy artefacts story** — when technical-preferences has a Deploy target and the repository has no `docs/ops/deploy.md` (or no Dockerfile / production compose / release workflow), the first feature gets a story "Deploy artefacts": Dockerfile(s), `compose.prod.yaml`, release workflow, `/healthz`, `docs/ops/deploy.md` from `templates/deploy-runbook.md`; criteria "image builds in CI", "stack starts with healthchecks", "runbook checklist complete". Without it the feature is not deployable and `/release-checklist` will fail later.

## Phase 3: Agreement
Show the list (ID, title, size, dependencies) and the criteria-coverage matrix; edits.

## Phase 4: Write
"May I write `production/stories/F-NNN/S-NNN-<slug>.md` (N files), add lines to `production/roadmap.md` and set `story: S-NNN` on the findings covered in `production/findings.md`?" — one `AskUserQuestion`: write (Recommended) · show the draft/diff first · not now (roadmap format: `- [ ] S-NNN · Title`).

Verdict: `READY (N stories)`. Next step — one `AskUserQuestion`: `/sprint-plan` (Recommended) · `/dev-story S-NNN` directly · revise the stories. When `docs/architecture/test-strategy.md` or `docs/architecture/threat-model.md` is missing, the Recommended option becomes the missing command (`/test-setup` / `/threat-model`) and `/dev-story` is not offered — stories are ready, but development is not.
