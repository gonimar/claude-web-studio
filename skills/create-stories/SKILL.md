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
**Observability story** — same trigger (a Deploy target set) and no evidence of it in the repository (no `/healthz` route, no structured logging, no alert rule / uptime check in compose, workflows or the runbook): the first feature also gets "Observability" (`devops-engineer`): `/healthz` with dependency checks, structured JSON logs with request ids, error-rate and disk-space alerts, the runbook's "where to look" section; criteria "healthz reports each dependency", "a 5xx burst raises the alert on staging", "the runbook names the log location".
**Backup & restore drill story** — when the data model has tables (or the compose file a database) and `docs/architecture/data-model.md` §7 has no tested-restore date: "Backup & restore drill": scheduled backup, off-host copy, **a restore performed on staging with the date recorded in data-model.md §7 and the runbook**; criteria "backup job runs on schedule", "restore on staging completes and the smoke journey passes", "restore date recorded". `/release-checklist` asks for that date on the first release.
**Account deletion story** — when the data model classifies personal data (§6) and no story or code implements deletion/anonymisation: "Data deletion" with the criteria "a deletion request removes or anonymises every PII field listed in §6", "backups older than the retention period expire", "logs carry no PII after deletion" — the threat model's export/deletion surface is its security section.

## Phase 3: Agreement
Show the list (ID, title, size, dependencies) and the criteria-coverage matrix; edits.

## Phase 4: Write
"May I write `production/stories/F-NNN/S-NNN-<slug>.md` (N files), add lines to `production/roadmap.md` and set `story: S-NNN` on the findings covered in `production/findings.md`?" — one `AskUserQuestion`: write (Recommended) · show the draft/diff first · not now (roadmap format per `templates/roadmap.md`: `- [ ] [S-NNN](stories/F-NNN/S-NNN-<slug>.md) · Title ⛔ [S-NNN](path), [S-NNN](path) ~Nh 🏷 layer` — the ID is always an inline link, file-relative to `production/roadmap.md` itself, never a reference-style definition under a `## Links` section (those stop resolving once other sections are folded into `<details>`); dependencies, estimate and layer inline in the legend's order; never a prose ordering paragraph below the list, the order is derivable from ⛔; sprints are subheadings, the rest lives under Backlog; refresh the `Updated:` line; add each new story as a row — ⬜, the story link, one-line summary, `Ready` — to the roadmap's `## Docs` → *production/stories/* block and refresh its `<summary>` count). After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker).

Verdict: `READY (N stories)`. Next step — one `AskUserQuestion`: `/sprint-plan` (Recommended) · `/dev-story S-NNN` directly · revise the stories. When `docs/architecture/test-strategy.md` or `docs/architecture/threat-model.md` is missing, the Recommended option becomes the missing command (`/test-setup` / `/threat-model`) and `/dev-story` is not offered — stories are ready, but development is not.
