---
name: data-model
description: "Designs or extends the data model — entities/relations, PostgreSQL DDL with constraints and indexes justified by queries, migration strategy (expand/contract), PII classification, backup/restore. Produces docs/architecture/data-model.md and migration drafts."
argument-hint: "[feature F-NNN or 'full']"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, AskUserQuestion, Task
model: sonnet
agent: database-engineer
---

# Data Model

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

Template `.claude/docs/templates/data-model.md`; reference `database.md`; rules `database.md`.

## Phase 1: Context
1. **Scope** from the argument: `F-NNN` → that feature spec's section 4. No such feature spec → verdict `BLOCKED (no feature spec — run /feature-spec first)`; write nothing. `full` → every feature spec and the whole schema.
2. **Read** the current schema (migrations, `schema.sql`, AR/entity classes), the API contract (which fields we expose), the threat model (PII).

## Phase 2: Entities and queries
1. ER (mermaid) and a query table (frequency, read/write).
2. Questions: volumes, retention, invariants.
3. **Personal data** (template §6), per PII field:
   - its class (identity, contact, behavioural, financial, special category);
   - its **retention period** and what ends it (account deletion, inactivity, legal term);
   - the deletion or anonymisation method per table (hard delete, tombstone + anonymise, crypto-shredding), and what happens in backups and logs.
   Export on request is described as the template asks (what is included, format, identity check). A deletion path that does not exist becomes the "Data deletion" story (`/create-stories`).

## Phase 3: DDL and migrations
1. DDL with CHECK/UNIQUE/FK/indexes, each index justified by a query from the Phase 2 table.
2. Migrations in the project's tool (the stack reference names it: e.g. golang-migrate, yiisoft/db-migration, Doctrine Migrations, Drizzle); expand/contract when changing existing tables.
3. With a DB available (compose): `EXPLAIN ANALYZE` on test data.

## Phase 4: Write
1. When valuable data is added, the draft includes the updated backup section (template §7).
2. "May I write `docs/architecture/data-model.md` and the migration files?" — one `AskUserQuestion`: write (Recommended) · show the draft/diff first · not now. After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker).

Verdict: `APPROVED` | `NEEDS REVISION` | `BLOCKED`. Next step — one `AskUserQuestion`: `/create-stories` (Recommended) · `/api-contract` (if the contract changes) · revise the model; on `BLOCKED`: `/feature-spec` (Recommended) · stop here.
