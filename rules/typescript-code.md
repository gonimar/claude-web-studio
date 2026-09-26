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
- Comments per `rules/comments.md`: TSDoc on exported symbols — summary first, details under `@remarks`, no `@param {type}` (the signature has it); the reason in the body, one paragraph; no story IDs or review history in code; `TODO(S-NNN):`/`TODO(I-NNN):` or no TODO (`unicorn/expiring-todo-comments` with `allowWarningComments: false` rejects a bare one).
