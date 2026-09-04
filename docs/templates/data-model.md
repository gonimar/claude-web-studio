# Data Model: [Project]

> Database: PostgreSQL 18 · Migrations: [tool] · Date:

## 1. Entities and relations
ER (mermaid `erDiagram`) plus data ownership per module.

## 2. Tables
For each: columns (type, null, default, constraints), PK/UK/FK, indexes (for which queries), volumes/growth, retention.

## 3. Key queries
Table "query → frequency → index → plan (EXPLAIN)".

## 4. Invariants and transactions
What CHECK/UNIQUE guarantees, what code guarantees; transaction boundaries; locks/queues.

## 5. Migrations
Expand/contract strategy; order; backward compatibility with the running version.

## 6. Personal data and security
Field classification, encryption/masking, deletion on request, access.

## 7. Backups and restore
Schedule, PITR, restore test (date of the last one).
