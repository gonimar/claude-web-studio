# Skill Spec: /docs

> **Category**: authoring · **Priority**: medium · **Spec written**: 2026-09-10

## Summary
Documentation for people through `tech-writer`: README, API reference generated from the contract, user guide from Done feature specs, runbook from the deploy contract and incidents. Inventory (`--check`) → draft with every command run → write gate per target → commit gate. Sonnet.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] template/reference link

## Cases
### 1. Happy path — readme
**Fixture**: `technical-preferences.md` configured, product spec present, `.env.example` with six variables, no README. **Expected**: README draft with quick start commands **run in the session with their output**, an env table naming all six variables without values, a deploy link to the runbook; "May I write `README.md`?"; `docs: readme from …` commit gate.
- [ ] commands run · [ ] env table complete, no values · [ ] write gate · [ ] no duplication of CLAUDE.md
### 2. Refusal / BLOCKED — no sources
**Fixture**: `/docs api` with no `docs/architecture/api/*`. **Expected**: `BLOCKED (no contract — run /api-contract first)`, nothing written, no hand-written reference invented.
- [ ] writes no files · [ ] names `/api-contract`
### 3. Mode/argument variant — `--check`
**Fixture**: README older than the last change of `.env.example`; guide missing for two Done features. **Expected**: the inventory table with "stale vs" and gaps, `COMPLETE (check only: 2 targets stale)`, stop.
- [ ] argument parsed · [ ] staleness by git dates · [ ] nothing written
### 4. Edge case — a fact missing from the spec
**Fixture**: the guide needs the behaviour of an edge case the feature spec does not cover. **Expected**: the gap is named as a spec finding with the command (`/feature-spec F-NNN`), never invented in the docs.
- [ ] gap named · [ ] no invented behaviour
### 5. Gate / protocol — runbook on a story branch
**Fixture**: `/docs runbook` while `feat/S-020-deploy-artefacts` is checked out. **Expected**: the runbook is drafted from `docs/ops/deploy.md`, the deploy contract's Prerequisites & secrets (names and locations only) and the incidents; the commit gate names the story branch as the target because the docs belong to that story.
- [ ] secrets by name only · [ ] rollback per failure · [ ] commit gate names the branch

## Protocol
- [ ] "May I write?" before writes · [ ] draft before approval · [ ] next step · [ ] never advances the stage itself

## Coverage notes
Closes roadmap R-05; `/story-done` still checks that docs were updated — this skill is how they get updated.
