---
paths: ["**/*.css", "**/*.scss", "**/*.sass", "**/tailwind.config.*"]
---
# Style rules
- Design tokens `--ds-*` (colour, spacing, typography, radii, shadows) are the only source of values; no magic numbers.
- Dark theme via `color-scheme` + `light-dark()`/tokens; `prefers-reduced-motion` respected.
- Layout: grid/flex, container queries for components; no fixed heights around text.
- Cascade layers `@layer reset, base, components, utilities`; low specificity; `!important` forbidden outside utilities.
- Mobile-first responsive; touch targets ≥ 24×24 px (WCAG 2.5.8); visible focus never removed.
- Fonts: subsets, `font-display: swap`, `size-adjust` for fallbacks.
- Reference: `.claude/docs/stack-reference/web-platform.md`.
