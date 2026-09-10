# Web Studio — roadmap

What the studio does not do yet, in the order it is likely to land. Each item names the gap a
real project showed, the command or component it will add, and the playbook section that
currently describes the manual workaround (`docs/playbook.md`). Items become issues and pull
requests in this repository; the entry moves to `CHANGELOG.md` when it ships.

Statuses: `planned` · `in progress` · `shipped vX.Y.Z`.

| # | Item | Gap observed | What ships | Playbook | Status |
|---|---|---|---|---|---|
| R-01 | **`/backlog` — idea capture** | A musing in the conversation ("what if we…", "maybe we should…") is taken as an instruction and implemented in the same turn, bypassing spec, ADR and stories. Rule 11 (`/impact`) covers change *proposals*; nothing catches an *idea*. | Skill `/backlog add "<idea>"` writes one line to `production/backlog.md` (roadmap v3.1 `F-NNN`/`I-NNN` format) and stops; `/backlog review` lists ideas weekly and hands each to `/brainstorm`, `/impact` or `/feature-spec`; templates `backlog.md` and `decisions.md`; CLAUDE.md principle: *a musing is an idea, never a task — record it, then ask*; spec cases and the `inventor` persona in e2e. | §5.5 Feature requests, §10.3 | shipped (unreleased) |
| R-02 | **`/migrate` — documents to the current templates** | Projects adopted before a template change keep old formats (roadmap without inline links, ADRs without verification, stories without a criteria matrix); `/help` and `/sprint-plan` misread them. | Skill `/migrate [roadmap\|stories\|adrs\|specs\|all] [--dry-run]`: detects the format, converts while keeping IDs and history, writes a report before the write gate. `/adopt` Phase 4 offers it for every HIGH format finding. | §4.1 table | shipped (unreleased) |
| R-03 | **Strict templates via `/update`** | Templates are re-seeded with `docs/`, but nothing checks a project document against its template and `/update` never says which documents drifted. | `/update` seeds `docs/templates/` and lists documents that no longer match, offering `/migrate`; rule `docs-format.md`; `post-edit-check` warns when a pipeline document misses a required section. | §10.15 | shipped (unreleased) |
| R-04 | **Brownfield architecture audit** | `/architecture-review` cross-checks documents with each other; on an adopted project the question is whether the *code* matches the ADRs, contracts and threat model. | `/architecture-review code`: module boundaries, dependencies and entry points from the tree vs the ADRs and contract; drift findings with file:line into `production/findings.md`. | §4.2, §5.5 Refactoring | shipped (unreleased) |
| R-05 | **`/docs` — documentation for people** | README, API reference, user guide and runbooks are written ad hoc; `/story-done` only checks that "docs were updated". | Skill `/docs [readme\|api\|guide\|runbook]` through `tech-writer`: README from `technical-preferences` and the product spec, API reference generated from the contract, runbook from `docs/ops/deploy.md`; a doc checklist per story type. | §5.5 Documentation | shipped (unreleased) |
| R-06 | **Observability and backup stories** | Health checks, structured logs, alerts and a *tested* restore are added after the first incident, not before the first release. | `/create-stories` adds "Observability" and "Backup & restore drill" stories when a Deploy target is set (as it does for "Deploy artefacts"); `/release-checklist` requires evidence of a restore drill for the first release. | §5.5 Observability | shipped (unreleased) |
| R-07 | **Estimation calibration** | Story estimates are human-hours; agent-driven delivery is many times faster and the ratio is never measured, so sprint capacity is planned on wrong numbers. | `/story-done` records wall-clock ⏱ from `/dev-story` start; `/sprint-plan` shows the observed ratio and scales the next sprint by it; a retrospective section in the sprint file. | §5.5 Deadlines | shipped (unreleased) |
| R-08 | **`/retrospective`** | `/sprint-plan` reads "retro actions" of the last sprint, but no command writes them. | Skill `/retrospective NN`: what shipped vs planned, blockers, process actions → the sprint file and the roadmap. | §5.4 | shipped (unreleased) |
| R-09 | **Secret rotation checklist** | Rotating secrets after a leak or a departure is done from memory; where each secret lives is known only to the deploy contract. | `/harden secrets`: inventory of secrets from the deploy contract, `.env.example` and CI, rotation steps per provider, verification that no old value remains in the repository or images. | §5.5 Secret rotation, §10.6 | shipped (unreleased) |
| R-10 | **Data retention and deletion** | PII classification exists in `/data-model`, but retention periods, deletion/anonymisation and the "delete my account" flow are not first-class. | `data-model.md` template gains a retention & deletion section; `/threat-model` gets an "export/deletion" surface; `/create-stories` proposes the deletion story when PII is present. | §10.38 | shipped (unreleased) |
| R-11 | **i18n, SEO and product analytics guidance** | No skill or template section covers localisation, SEO or product events; they are rediscovered per project. | Sections in the `product-spec` (NFR) and `feature-spec` (events, copy keys) templates; `seo-specialist` routing in `/dev-story` for content sites; a `web-platform` reference section on i18n and SEO. | §5.5 Localisation | shipped (unreleased) |
| R-12 | **`/help guide <topic>` search** | `/help guide` lists the playbook's situations; finding the right one by keyword is manual. | Keyword match over the playbook's headings and the first line of each section; the best matching section printed inline. | §0 | shipped (unreleased) |
| R-13 | **Contract deprecation workflow** | Breaking API changes with external consumers are handled by hand: versioning, deprecation dates, coexistence, removal. | `/api-contract --deprecate <operation>`: marks the field/route with a date, adds the CI check for removal after the date, a CHANGELOG `BREAKING` entry and the removal story. | §10.29 | shipped (unreleased) |
| R-14 | **Session context visible to the user** | The session-start hook prints its block as plain stdout, which Claude Code adds to Claude's context only: neither the VS Code extension nor the terminal shows it, so users never see the branch warnings, the stack-reference age or the open gate the README promises them. | `session-start.sh` emits JSON: the full block as `hookSpecificOutput.additionalContext` and a three-line `systemMessage` (branch state · stage and active task · warnings/open gate) that Claude Code shows to the user on every platform; hook tests assert both channels. | §8 | shipped v0.9.0 |
| R-15 | **Pre-compaction state that reaches someone** | `pre-compact.sh` prints the session state to stdout, but `PreCompact` stdout goes to the debug log only and the event discards `systemMessage`; only the `compaction.log` line has an effect. Recovery actually comes from `SessionStart:compact`. | Trim `pre-compact.sh` to the log line; make `session-start.sh` on `source: compact` print the whole `active.md` and the modified files (the "after compaction" block); README and playbook describe the real mechanism. | §8 | shipped v0.9.0 |

## Toward 1.0

1.0 is not a feature release. Functionally the studio is complete (49 commands, R-01..R-15 shipped); what 1.0 adds is
**evidence that the studio does what its texts promise, on real projects, without an observer behind it**. Five conditions;
each is ticked only with the artefact named next to it. The release that ticks the last one is 1.0, and its changelog says
"nothing changed — everything verified".

- [ ] **1. Verified, not "fixed".** Every defect closed since 0.5 has either a live confirmation in a session trace or a
  behavioural spec case that fails without the fix and runs in CI. No entry left as "fixed — verify on the next run".
  *Evidence:* the defect register of the observing lab shows zero `fixed` rows without `verified`; `testing/catalog.yaml`
  carries a `last_spec_result: PASS` for every skill and agent.
- [ ] **2. Three live runs without intervention.** Greenfield from `/init` to `/deploy`; brownfield from `/adopt` and
  `/migrate` to the first release; a browser game to `/game-concept gate`. Pass criteria for each: no required catalog step
  skipped, no pipeline document authored inline past its command, no false-positive hook warning, and no moment where the
  owner says "that is not what I asked". The e2e personas (agreeable, hasty, refusenik, inventor, clueless) walk the same
  paths headless with the same criteria.
  *Evidence:* three trace reports with the checklist above, archived under `testing/results/`; persona runs green in
  `testing/e2e/`.
- [ ] **3. Document formats frozen.** Roadmap v3.1, story, ADR, spec, sprint, backlog and decisions templates change only
  together with a `/migrate` path from the previous version; a template change without one fails the structure linter.
  *Evidence:* `tests/validate-structure.py` check "template changed → migrate rule present"; one release cycle without a
  format change on the observed projects.
- [ ] **4. The user sees what the model sees.** Every channel that carries a message to a person — the session-start
  summary, hook warnings and blocks, the stop reminder, gate questions, `Attention:` lines — is verified in the terminal
  and in the VS Code extension, not assumed from documentation.
  *Evidence:* a channel matrix in `testing/e2e/` (channel × client → observed on date) with a hook test per row; the
  0.9.0 lesson (SessionStart stdout reached nobody for three months) never repeats.
- [ ] **5. The studio can repair itself.** `/skill-test spec` passes for all skills and agents; `/skill-improve` closes a
  deliberately broken case in a demo; a user who finds a defect has a documented path from symptom to an issue with
  evidence (playbook §10.16); the plugin's CI runs the static specs, not only the linter and the hook tests.
  *Evidence:* CI job "specs"; one issue filed by the documented path and fixed through `/skill-improve`.

Out of scope for 1.0: new skills, new technologies in the stack reference, further playbook translations — all of these
can land after 1.0 without breaking a promise. Suggested cadence: 0.11 — conditions 3 and 4; 0.12 and 0.13 — the live runs
with their fixes; 0.14 — the remaining verifications; 1.0 — the release with nothing to change.
