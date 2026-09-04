---
paths: ["**/*.vue", "**/nuxt.config.ts", "**/app/**/*.ts", "**/server/**/*.ts"]
---
# Vue / Nuxt rules
- `<script setup lang="ts">`, typed `defineProps/defineEmits/defineModel`; composables `useX`.
- Shared state in Pinia setup stores; props are never mutated.
- Heavy objects (three.js, Pixi, maps) — `markRaw`/`shallowRef`, outside deep reactivity.
- SSR: `window`/`document` only under `import.meta.client`/`onMounted`; secrets in `runtimeConfig`, not `public`.
- Nuxt server routes: validate with `readValidatedBody` (zod), errors via `createError` → problem+json.
- `v-html` only with DOMPurify and a review; a11y in components.
- Vitest + Vue Test Utils/Testing Library; Playwright e2e.
- Reference: `.claude/docs/stack-reference/vue.md`.
