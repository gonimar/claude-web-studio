---
paths: ["**/migrations/**", "**/*.sql", "**/schema.prisma", "**/drizzle/**", "**/db/**"]
---
# Database and migration rules
- Forward-only, idempotent migrations in git, applied before the app starts; destructive changes as expand → migrate → contract.
- `timestamptz`; PK `bigint identity` or `uuidv7`; FKs with indexes; CHECK constraints for invariants.
- Every index is justified by a query with `EXPLAIN ANALYZE` in the PR; uniqueness by index, not code.
- No `SELECT *` in code; short transactions; `FOR UPDATE SKIP LOCKED` for queues.
- A backup and a tested restore are part of the definition of done for new tables holding valuable data.
- Reference: `.claude/docs/stack-reference/database.md`.
