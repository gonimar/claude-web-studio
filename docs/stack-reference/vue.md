---
updated: 2026-09-05
sources: [https://vuejs.org/llms.txt, https://nuxt.com/llms.txt, https://pinia.vuejs.org, https://vite.dev/llms.txt, https://github.com/vuejs/core/releases]
---
# Vue 3.5 / 3.6, Nuxt 4, Pinia, Vite 8

## Versions
- **Vue 3.5.42** (2026-08-27) — stable. 3.5: props destructure with defaults (`const { a = 1 } = defineProps()`), `useTemplateRef`, `useId`, `onWatcherCleanup`, lazy hydration, `Teleport defer`.
- **Vue 3.6 RC** (2026-08): reactivity on **alien-signals** (faster, less memory), **Vapor mode** (`<script setup vapor>` — no Virtual DOM, opt-in per component; up to 97 % faster renders, 20–50 % smaller bundles). Remaining gap before stable: Suspense in Vapor. Production after stable; write new components Vapor-compatible (no `$slots` hacks, no direct VNode manipulation).
- **Nuxt 4.5** (2026-07-18): Vite 8, Rspack 2, SSR streaming (experimental), `useLayout`, named views; `app/` directory; **Nuxt 3 EOL 2026-07-31**. Nuxt 5 in preparation.
- **Pinia 3** (requires Vue 3.5+), **Vue Router 4.5+**, **Vite 8** (Rolldown), **Vitest 4**, `vue-tsc` 3 for SFC type checking.
- UI kits: PrimeVue 4 (unstyled + tokens), Vuetify 3.9, Naive UI, Element Plus, shadcn-vue (Reka UI). The choice is recorded in technical-preferences.

## Modern Vue (write only this way)
- `<script setup lang="ts">`; `defineProps<{…}>()` with destructure defaults; `defineEmits<{…}>()`; `defineModel()`; `defineSlots`/`defineExpose` when needed.
- State: local — `ref/reactive/computed`; shared — **Pinia setup stores** (`defineStore('x', () => {...})`); never mutate props.
- Composables `useX()` are the unit of logic reuse; VueUse for common tasks (not for a single function).
- `shallowRef`/`markRaw` for large objects and **mandatory for three.js / Pixi / map objects** — otherwise the Proxy kills performance.
- `watch` with explicit sources; `watchEffect` rarely; cleanup via `onWatcherCleanup`.
- Async: `defineAsyncComponent` + `<Suspense>`; Nuxt — `useFetch`/`useAsyncData` (SSR-aware), `$fetch` in handlers.
- Routing: lazy route components, typed routes (`unplugin-vue-router` / Nuxt typed pages), guards in `router.beforeEach`.
- Nuxt structure: `app/` (pages, components, composables, layouts, middleware), `server/` (Nitro routes, `defineEventHandler`, h3), `nuxt.config.ts`; runtime config for server-side secrets.

## Tests
Vitest 4 + `@vue/test-utils` 2 / Testing Library Vue; `@nuxt/test-utils` 4 (requires Vitest 4); Playwright for e2e; Storybook 9/10 for components when needed.

## Performance
Lazy routes and components; `v-once`/`v-memo` sparingly; list virtualisation (`vue-virtual-scroller`/`@tanstack/vue-virtual`); Nuxt `<NuxtImg>`, `<NuxtLink prefetch>`; analyse with `nuxi analyze` / `rollup-plugin-visualizer`.

## Security
Templates are escaped; `v-html` only with a sanitiser (DOMPurify) and a review; Nuxt server routes — validation (`h3` + zod, `readValidatedBody`); secrets only in `runtimeConfig` (not `public`); CSP via `nuxt-security` or the proxy.

## Review checklist
1. script setup + TS; 2. Pinia instead of ad-hoc globals; 3. no prop mutation, no heavy objects in reactive state; 4. SSR safety (no `window` on the server without `import.meta.client`); 5. a11y in components; 6. behaviour tests.
