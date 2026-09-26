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

Templates (`.claude/docs/templates/`): `story.md`, `roadmap.md`, `deploy-runbook.md`, `findings.md`. Files are written only after "May I write?" (Phase 4).

## Phase 1: Context
1. **The feature spec**: the argument (`F-NNN` → `docs/specs/features/F-NNN-*.md`, or a path); none → ask. Acceptance criteria are mandatory. A spec without them → stop with `BLOCKED (no acceptance criteria — complete the spec with /feature-spec F-NNN)` and write nothing.
2. **Read**: the API contract, the data model, ADRs, the test strategy, and the existing stories (for numbering).
3. **Findings**: read `production/findings.md`. Every open BLOCKING finding that touches this feature (area, file, API operation) becomes an acceptance criterion of the affected story or a dedicated story. Never skip one silently; the matrix in Phase 3 shows `finding → story`.
4. **Deploy target**: `technical-preferences.md` → Deploy target, for the platform stories in Phase 2 step 3.

## Phase 2: Slicing
1. **Slice** into vertical slices (a working end-to-end path) before layers. Every story is ≤ M (≈ one day). Typical order: contract+codegen → migration+repository → service/resolvers → UI → e2e. Games: simulation → rendering → UI → saves.
2. **Per story**: goal, tasks, criteria (from the feature spec, none lost — the "criterion → story" matrix proves it), test level per criterion, security/accessibility, ADR, size, dependencies on other stories.
3. **Platform stories.** Add each one whose trigger holds; add none when the evidence already exists in the repository.
   - **Deploy artefacts** — technical-preferences has a Deploy target and the repository has no `docs/ops/deploy.md` (or no Dockerfile / production compose / release workflow). The first feature gets a story "Deploy artefacts": Dockerfile(s), `compose.prod.yaml`, release workflow, `/healthz`, `docs/ops/deploy.md` from `templates/deploy-runbook.md`. Criteria: "image builds in CI", "stack starts with healthchecks", "runbook checklist complete". Without it the feature is not deployable and `/release-checklist` will fail later.
   - **Observability** — the same trigger (a Deploy target set) and no evidence of it in the repository (no `/healthz` route, no structured logging, no alert rule / uptime check in compose, workflows or the runbook). The first feature also gets "Observability" (`devops-engineer`): `/healthz` with dependency checks, structured JSON logs with request ids, error-rate and disk-space alerts, the runbook's "where to look" section. Criteria: "healthz reports each dependency", "a 5xx burst raises the alert on staging", "the runbook names the log location".
   - **Backup & restore drill** — the data model has tables (or the compose file a database) and `docs/architecture/data-model.md` §7 has no tested-restore date. Story "Backup & restore drill": scheduled backup, off-host copy, **a restore performed on staging with the date recorded in data-model.md §7 and the runbook**. Criteria: "backup job runs on schedule", "restore on staging completes and the smoke journey passes", "restore date recorded". `/release-checklist` asks for that date on the first release.
   - **Account deletion** — the data model classifies personal data (§6) and no story or code implements deletion/anonymisation. Story "Data deletion" with the criteria "a deletion request removes or anonymises every PII field listed in §6", "backups older than the retention period expire", "logs carry no PII after deletion". The threat model's export/deletion surface is its security section.

## Phase 3: Agreement
1. Render in the chat message, as tables (rule 7): the story list (ID, title, size, dependencies) and the coverage matrix (`criterion → story`, `finding → story`).
2. Take the user's edits and show the changed rows before moving on.

## Phase 4: Write
1. **Gate**, one `AskUserQuestion`: "May I write `production/stories/F-NNN/S-NNN-<slug>.md` (N files), add lines to `production/roadmap.md` and set `story: S-NNN` on the findings covered in `production/findings.md`?" — write (Recommended) · show the draft/diff first · not now.
2. After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker).
3. **Story files** from `story.md`.
4. **Roadmap**, per `templates/roadmap.md`:
   - One line per story: `- [ ] [S-NNN](stories/F-NNN/S-NNN-<slug>.md) · Title ⛔ [S-NNN](path), [S-NNN](path) ~Nh 🏷 layer`.
   - The ID is always an inline link, file-relative to `production/roadmap.md` itself. Never a reference-style definition under a `## Links` section: those stop resolving once other sections are folded into `<details>`.
   - Dependencies, estimate and layer inline, in the legend's order.
   - No prose ordering paragraph below the list; the order is derivable from ⛔.
   - Sprints are subheadings; the new stories go under Backlog.
   - Refresh the `Updated:` line.
   - In the roadmap's `## Docs` → *production/stories/* block, add a row per new story (⬜, the story link, a one-line summary, `Ready`) and refresh the block's `<summary>` count.
5. **Findings**: set `story: S-NNN` on each finding the stories cover.

Verdict: `READY (N stories)`.

Next step — one `AskUserQuestion`: `/sprint-plan` (Recommended) · `/dev-story S-NNN` directly · revise the stories. When `docs/architecture/test-strategy.md` or `docs/architecture/threat-model.md` is missing, the Recommended option becomes the missing command (`/test-setup` / `/threat-model`) and `/dev-story` is not offered: the stories are ready, but development is not.
