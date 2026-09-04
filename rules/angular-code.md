---
paths: ["**/src/app/**", "**/*.component.ts", "**/*.component.html", "**/angular.json"]
---
# Angular rules
- Standalone, signals (`input()/output()/model()/computed/linkedSignal/resource`), `inject()`, OnPush, zoneless.
- Control flow `@if/@for(track)/@switch/@defer`; no `*ngIf/*ngFor`, NgModule or constructor injection in new code.
- RxJS only at the boundary (`toSignal`, `takeUntilDestroyed`); `effect()` is not for state synchronisation.
- Lazy routes, functional guards; SSR safety (`isPlatformBrowser`/`afterNextRender`).
- Material 3 via `mat.theme()` / Taiga via tokens; a11y — Angular ARIA/CDK, focus and keyboard mandatory.
- `bypassSecurityTrust*` and `innerHTML` only with a security review.
- Vitest + Testing Library tests; budgets in angular.json.
- Reference: `.claude/docs/stack-reference/angular.md`.
