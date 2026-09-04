---
updated: 2026-09-05
sources: [https://www.postgresql.org/docs/18/, https://redis.io/docs/latest/, https://valkey.io, https://use-the-index-luke.com]
---
# PostgreSQL 18, Redis 8 — practices

## PostgreSQL
- **18 (2025-09)**: asynchronous I/O (`io_method`), built-in `uuidv7()` (use for PKs instead of uuid4), virtual generated columns, B-tree skip scan, OAuth authentication, faster upgrades. 19 expected autumn 2026 (check with `/stack-update`).
- Schema: `bigint identity` or `uuidv7` PKs; `timestamptz` always; `text` + CHECK instead of `varchar(n)`; enums via lookup tables or CHECK (simpler migrations); `jsonb` only for genuinely semi-structured data; composite PKs where the entity is defined by them.
- Indexes: for real queries (`EXPLAIN (ANALYZE, BUFFERS)`); partial and covering (`INCLUDE`); GIN for jsonb/arrays/FTS; unique indexes = business invariants; no "just in case" indexes.
- Migrations: forward-only, idempotent, in git, applied by CI/deploy before the app starts (a migrate service in compose); destructive changes in two steps (expand → migrate data → contract); no manual production migrations.
- Transactions: short; `SELECT … FOR UPDATE SKIP LOCKED` for queues; isolation levels chosen deliberately; retry on serialization failure.
- Connection pool: `pgx` pool / PgBouncer (transaction mode); limits per environment.
- Backups: daily `pg_dump` + WAL archiving for PITR; **restores are tested**, not assumed.
- Observability: `pg_stat_statements`, `auto_explain` for slow queries, `log_min_duration_statement`.

## Redis 8 / Valkey
- Redis 8 (2025-05) is open source again (AGPL option); Valkey 9 is the Linux Foundation fork, protocol-compatible. Use as: cache (always with TTL), queue (Streams or a queue library), rate limiting, pub/sub for realtime; **not** as a primary database.
- Namespaced keys `app:entity:id`; `maxmemory-policy allkeys-lru` for caches; separate instance/DB for queue and cache; password and bind inside the Docker network.

## ORM / access
Go — `pgx` + `sqlc`; PHP — `yiisoft/db` + Active Record or Cycle ORM (`yii-cycle`); Node — Drizzle ORM / Kysely (SQL-first). Rule: SQL is visible and reviewed; N+1 is caught by tests (query counter).
