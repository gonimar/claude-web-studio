---
name: start
description: "First-time onboarding for a new web project — asks where you are, configures the stack, and routes to product-spec or game-concept. Use when starting from scratch or when technical-preferences.md is still [TO BE CONFIGURED]."
argument-hint: "[no arguments]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, AskUserQuestion
model: sonnet
---

# Start

Entry point for a new project. Assumes nothing — asks, then routes. Writes files only after "May I write?" → "yes".

## Phase 1: Silent state detection
Read (without showing): `.claude/docs/technical-preferences.md` (exists? configured?), `docs/specs/product-spec.md`,
`docs/specs/game-concept.md`, code presence (`go.mod`, `composer.json`, `package.json`, `angular.json`, `nuxt.config.*`),
`production/roadmap.md`, `CLAUDE.md` Language section. If `.claude/docs/` is missing → run `/init` first.
If code/specs already exist → suggest `/adopt` instead of `/start`.

## Phase 2: Where are you
`AskUserQuestion`: "Where are we starting from?"
- **A) Just an idea** — a theme or pain, nothing written → `/brainstorm`.
- **B) Clear product** — we know what we build → `/setup-stack` → `/product-spec`.
- **C) Browser game** — a game concept → `/setup-stack` (type game) → `/game-concept` → `/product-spec` (light).
- **D) Existing work** — code/documents already exist → `/adopt`.

## Phase 3: Project type and review mode
Second question: type (site | spa | api | fullstack | game | game+backend) and review mode
(`full` — all gates; `lean` — lead + security on sensitive work (default for solo); `solo`).
Write `production/review-mode.txt` and `production/stage.txt` = `discovery` after "May I write?".

## Phase 4: Route
Show the next 3 steps from `.claude/docs/workflow-catalog.yaml` with commands.
If `production/roadmap.md` is missing, offer to create it (checkbox list) or, if an external advisor skill is installed, suggest its init command.
If `.claude/settings.web-studio.json` exists (settings.json pre-dated the install) — offer to merge hooks/permissions (show the diff, ask).

Verdict: `READY` — stack and mode chosen, next step named. Next step: `/setup-stack`.
