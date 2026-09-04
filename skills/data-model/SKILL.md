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

Template `.claude/docs/templates/data-model.md`; reference `database.md`; rules `database.md`.

## Phase 1: Context
Feature spec (section 4), the current schema (migrations, `schema.sql`, AR/entity classes), the API contract (which fields we expose), the threat model (PII).

## Phase 2: Entities and queries
ER (mermaid), a query table (frequency, read/write). Questions: volumes, retention, invariants.

## Phase 3: DDL and migrations
DDL with CHECK/UNIQUE/FK/indexes (each index justified by a query); migrations in the project tool (golang-migrate / yiisoft/db-migration / Drizzle) — expand/contract when changing existing tables. With a DB available (compose) — `EXPLAIN ANALYZE` on test data.

## Phase 4: Write
"May I write `docs/architecture/data-model.md` and the migration files?" Update the backup section when valuable data is added.

Verdict: `APPROVED` | `NEEDS REVISION`. Next step: `/create-stories` (repository implementation).
