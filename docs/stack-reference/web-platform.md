---
updated: 2026-09-10
sources: [https://developer.mozilla.org, https://web.dev/articles/vitals, https://www.w3.org/TR/WCAG22/, https://caniuse.com, https://web-platform-dx.github.io/web-features/, https://html.spec.whatwg.org, https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl, https://developers.google.com/search/docs/specialty/international/localized-versions, https://unicode.org/reports/tr35/]
---
# Web platform — the standards we treat as baseline

## Baseline (web-features): usable without polyfills (Baseline Widely available, 2026-09)
- CSS: container queries, `:has()`, cascade layers `@layer`, nesting, `color-mix()`, `light-dark()`, `@property`, subgrid, `text-wrap: balance`, view transitions (same-document), `@scope`, anchor positioning (Newly available — verify), scroll-driven animations, `popover`, `<dialog>`, `field-sizing`.
- JS: ES2025 (Set methods, iterator helpers, `Promise.try`, RegExp `v`, import attributes `with { type: 'json' }`), `structuredClone`, `AbortSignal.any`, `Array.fromAsync`, Temporal (Newly — verify), `navigator.locks`, Web Streams, `fetch` with `priority`.
- APIs: WebGPU (Chromium, Safari 26, Firefox desktop), WebTransport (no Safari — verify), WebCodecs, View Transitions API, Navigation API, `Intl.*`, Web Push (all, incl. iOS PWA), File System Access (partial), Compression Streams, Passkeys (WebAuthn).
- HTML: `<search>`, `inert`, `loading=lazy`, `fetchpriority`, `<template shadowrootmode>` (declarative shadow DOM), customizable select (Newly).
Rule: before using a Newly feature — check caniuse/web-features and provide a fallback; the project's browserslist records support (`defaults and fully supports es6-module` plus explicit versions).

## Performance — Core Web Vitals (p75, mobile)
| Metric | Good | What drives it |
|---|---|---|
| LCP | ≤ 2.5 s | server time, critical CSS, images (AVIF/WebP, `fetchpriority=high`, dimensions), fonts (`font-display: swap`, subsets, preload) |
| INP | ≤ 200 ms | long tasks (>50 ms), hydration, handlers; `scheduler.yield()`, work splitting, web workers |
| CLS | ≤ 0.1 | media dimensions, reserved space for dynamic content, fonts |
Also: TTFB ≤ 800 ms; initial JS ≤ 200 KB gzip for SPAs; `Cache-Control: immutable` for hashed assets; HTTP/2/3; `preconnect` to the API; Lighthouse CI in the pipeline with budgets.

## Accessibility — WCAG 2.2 AA (mandatory; the EU Accessibility Act applies since 2025-06)
- Semantics: landmarks, ordered headings, `<button>` for actions, `<a>` for navigation, forms with `<label>`; lists as lists.
- Keyboard: everything reachable with Tab/Enter/Space/Esc/arrows; visible focus (2.4.11 Focus Not Obscured, 2.4.13 Focus Appearance); no traps; skip link.
- ARIA only when no native element exists; live regions for dynamic content; names on icon buttons.
- Contrast 4.5:1 text, 3:1 UI/graphics; never colour alone for meaning; target size ≥ 24×24 CSS px (2.5.8).
- Motion: `prefers-reduced-motion`; autoplay with pause; no flashing > 3 Hz.
- Forms: errors as text with association (`aria-describedby`), `autocomplete`, no redundant entry (3.3.7), accessible authentication without cognitive tests (3.3.8).
- Games: settings — remapping, subtitles, UI scale, colour-blind mode, pause; the canvas is mirrored by an accessible DOM overlay for menus.
- Verification: axe-core in e2e, a manual keyboard and screen-reader pass (NVDA/VoiceOver) on key flows.

## HTTP and API conventions
- REST: plural resources, verbs as methods; `PUT` idempotent, `POST` with `Idempotency-Key` for payments; cursor pagination for large collections; explicit filter/sort parameters; version in the path `/v1` or a header (ADR decision).
- Errors — RFC 9457 `application/problem+json` (`type`, `title`, `status`, `detail`, `instance`, `errors[]`).
- Cache: `ETag`/`If-None-Match`, explicit `Cache-Control`; `Vary` with content negotiation.
- CORS: exact origins, no `*` with credentials; preflight cache `Access-Control-Max-Age`.
- Realtime: SSE for one-way streams (simple, HTTP/2-friendly), WebSocket for two-way; reconnect with backoff and a resume cursor.

## SEO and sharing
SSR/prerender for public pages; unique `<title>`/`meta description`; canonical; Open Graph + Twitter cards; JSON-LD (schema.org) for entities; `sitemap.xml`, `robots.txt`; `hreflang` with i18n; Core Web Vitals are a ranking factor. Per feature: the public pages name their title/meta, structured data and canonical in the feature spec §6; `seo-specialist` reviews them in `/dev-story` for `Type: site` projects.

## Internationalisation (i18n)
- **Platform first**: `Intl` (`DateTimeFormat`, `NumberFormat`, `RelativeTimeFormat`, `PluralRules`, `ListFormat`, `Segmenter`, `DisplayNames`) is Baseline — no date/number formatting libraries for formatting alone; ICU MessageFormat (`Intl.MessageFormat` is still a proposal — use a library: `@formatjs/intl`, `i18next`, Angular `$localize`, Vue `vue-i18n`) for plural/gender-aware messages, never string concatenation.
- **Locale negotiation**: URL path or subdomain for public pages (`/de/…`, indexable, one `hreflang` per variant plus `x-default`), `Accept-Language` only as the first guess, the user's explicit choice persisted; `<html lang>` always set, `dir="rtl"` for RTL locales with logical CSS properties (`margin-inline-start`) so layouts flip without duplicated styles.
- **Copy keys, not sentences, in code**: every user-facing string is a key in a catalogue (per locale file, ICU syntax); the feature spec §6 lists the keys; the CI fails on missing keys for a shipped locale (`i18next-parser`/`@angular/localize` extract + a completeness check); pseudo-localisation in dev catches concatenation and truncation.
- **Data**: store timestamps in UTC with the user's time zone alongside, currency as integer minor units with the ISO code, names as one field unless the product needs the split; collation per locale in PostgreSQL (`ICU` collations) for sorted lists.
- **Games**: fonts with the glyph coverage of the shipped locales (CJK fallback), text expansion budget ~30 % in HUD layouts, subtitles and remappable controls as accessibility settings (WCAG 2.2 / game accessibility guidelines).

## PWA
`manifest.webmanifest`, service worker (Workbox) with an explicit cache strategy, offline page, `beforeinstallprompt`; Web Push (VAPID); for games — asset caching keyed by manifest version.
