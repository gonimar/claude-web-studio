---
updated: 2026-09-05
sources: [https://angular.dev/llms.txt, https://angular.dev/llms-full.txt, https://angular.dev/roadmap, https://material.angular.dev, https://taiga-ui.dev/llms.txt, https://angular.dev/style-guide]
---
# Angular 22, Angular Material 22, Taiga UI 5

## Versions
- **Angular 22 (2026-06-03)**: **Signal Forms stable**; **Angular ARIA** (accessible headless components) stable; zoneless by default for new apps (since v21); Vitest is the default test runner (since v21, Karma removed); Angular CLI MCP server; active support until 2026-12, LTS until 2028-05. Majors every six months.
- **Angular Material / CDK 22.1.x**: Material 3 themes via `mat.theme()`; token-based components (`--mat-*`); versions track Angular.
- **Taiga UI 5.21**: minimum Angular 19; standalone components, signals, themes; preferred for "product" UIs with rich controls (inputs, date pickers, tables). Do not mix with Material on one screen without a design decision.

## Modern Angular (write only this way)
- **Standalone** components (NgModule is legacy); `bootstrapApplication(App, { providers })`.
- **Signals**: `signal`, `computed`, `effect`, `linkedSignal`, `resource()` / `httpResource()`; inputs/outputs — `input()`, `input.required()`, `output()`, `model()`; queries — `viewChild()`, `contentChildren()`.
- **Zoneless**: `provideZonelessChangeDetection()`; `OnPush` everywhere; RxJS only at the boundary (`toSignal`, `toObservable`, `takeUntilDestroyed`).
- **Control flow**: `@if / @for (track) / @switch / @defer (on viewport; prefetch)`; the old `*ngIf/*ngFor` are not used.
- **Signal Forms** (v22) for new forms; typed Reactive Forms are acceptable in existing code.
- `inject()` instead of constructor injection; `DestroyRef`; `provideHttpClient(withFetch(), withInterceptors([...]))`.
- Routing: lazy `loadComponent`/`loadChildren`, functional guards/resolvers, `withComponentInputBinding()`.
- SSR: `@angular/ssr` with route-level render modes (server/prerender/client) and incremental hydration (`@defer (hydrate on …)`).
- **Style guide 2025 (v20+)**: files without the `.component` suffix by default (`user-profile.ts`, class `UserProfile`); the project chooses and records it in technical-preferences.
- Tests: Vitest + `@angular/build:unit-test`; Testing Library for components; Playwright for e2e.

## Material 3 / themes
```scss
@use '@angular/material' as mat;
html { @include mat.theme((color: (primary: mat.$azure-palette, tertiary: mat.$blue-palette), typography: Roboto, density: 0)); }
```
Dark theme via `color-scheme: light dark` + `light-dark()`; project tokens `--ds-*` map onto `--mat-*`/`--tui-*`.

## Performance
`@defer` for heavy widgets; `NgOptimizedImage`; budgets in `angular.json`; analyse with `ng build --stats-json` + `esbuild-visualizer`; `track` in `@for`; avoid `effect()` for state synchronisation (use `computed`/`linkedSignal`).

## Security
Angular escapes templates; `DomSanitizer.bypass*` only with a security review; avoid `innerHTML`; CSP with nonce (`ngCspNonce`); `withXsrfConfiguration` for cookie-based auth; tokens not in `localStorage` where avoidable (HttpOnly cookie + BFF).

## Upgrades
`ng update @angular/core@22 @angular/cli@22` one major at a time; update.angular.dev; Material/Taiga after the core; Taiga: `ng update @taiga-ui/cdk` with migrations.

## Review checklist
1. standalone + signals + OnPush; 2. new control flow; 3. no subscriptions without `takeUntilDestroyed`; 4. lazy routes; 5. a11y: focus, aria, keyboard (Angular ARIA/CDK a11y); 6. component tests on behaviour, not implementation.
