---
paths: ["**/package.json", "**/package-lock.json", "**/pnpm-lock.yaml", "**/yarn.lock", "**/bun.lock", "**/bun.lockb", "**/composer.json", "**/composer.lock", "**/go.mod", "**/go.sum"]
---
# Dependency rules (CLAUDE.md principle 3)
- A new dependency is an "ask first" change (principle 2): name the package, the option of writing it, and the cost of each before the manifest is edited.
- Check the package's health before adding it: last release date, unreleased branches, maintainer activity, known CVEs (`npm audit` / `pnpm audit`, `composer audit`, `govulncheck`), licence.
- Versions come from the registry, never from memory; the `validate-deps` hook runs the resolver's dry run after a manifest edit and reports what does not resolve.
- The lockfile is in git and changes in the same commit as the manifest; pin as the stack reference says (`typescript.md`, `php.md`, `go.md`).
- `/dependency-audit` before a release and when a story adds more than one package (security-baseline A03).
- Reference: `.claude/docs/security-baseline.md` § A03; `.claude/docs/stack-reference/<technology>.md`.
