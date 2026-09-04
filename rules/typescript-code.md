---
paths: ["**/*.ts", "**/*.tsx", "**/*.mts", "**/*.js", "**/*.mjs"]
---
# TypeScript/JS rules
- `strict`; no `any` (except an explicitly justified `// eslint-disable-next-line` with a reason); types come from schemas (zod / GraphQL codegen / OpenAPI), never duplicated by hand.
- ESM; named exports; no import cycles; kebab-case files.
- Promises handled (`no-floating-promises`); typed errors; `AbortController` for cancellable requests.
- No secrets or env values in the client bundle except explicitly public ones (`VITE_*`/`NG_APP_*` are reviewed).
- Vitest test next to the module (`*.spec.ts`), behaviour over implementation.
- Reference: `.claude/docs/stack-reference/typescript.md`.
