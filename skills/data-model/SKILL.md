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
Feature spec (section 4), the current schema (migrations, `schema.sql`, AR/entity classes), the API contract (which fields we expose), the threat model (PII).

## Phase 2: Entities and queries
ER (mermaid), a query table (frequency, read/write). Questions: volumes, retention, invariants. **Personal data**: every PII field classified (identity, contact, behavioural, financial, special category), its **retention period** and what ends it (account deletion, inactivity, legal term), the deletion or anonymisation method per table (hard delete, tombstone + anonymise, crypto-shredding), and what happens in backups and logs — template §6; a deletion path that does not exist becomes the "Data deletion" story (`/create-stories`).

## Phase 3: DDL and migrations
DDL with CHECK/UNIQUE/FK/indexes (each index justified by a query); migrations in the project tool (golang-migrate / yiisoft/db-migration / Drizzle) — expand/contract when changing existing tables. With a DB available (compose) — `EXPLAIN ANALYZE` on test data.

## Phase 4: Write
"May I write `docs/architecture/data-model.md` and the migration files?" — one `AskUserQuestion`: write (Recommended) · show the draft/diff first · not now. Update the backup section when valuable data is added. After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker).

Verdict: `APPROVED` | `NEEDS REVISION`. Next step — one `AskUserQuestion`: `/create-stories` (Recommended) · `/api-contract` (if the contract changes) · revise the model.
