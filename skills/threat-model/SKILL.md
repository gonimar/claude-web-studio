---
name: threat-model
description: "Builds or updates the STRIDE threat model — assets, trust boundaries, attack surfaces (auth, GraphQL/REST, WebSocket, uploads, webhooks, admin, CI/CD, dependencies, infra), threats with likelihood/impact/mitigation, verification. Produces docs/architecture/threat-model.md. Required before build and when a new surface appears."
argument-hint: "[full | <surface>]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, AskUserQuestion, Task
model: opus
agent: security-lead
---

# Threat Model

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

Template `.claude/docs/templates/threat-model.md`; `security-baseline.md`, `security-standards.md`, `graphql.md` (security). In the commands below, `<hooks>` is `.claude/hooks/` in copy mode and `${CLAUDE_PLUGIN_ROOT}/hooks/` in plugin mode.

## Phase 1: System
1. **Scope** from the argument: `full` (default) walks every surface; `<surface>` analyses only that surface and updates its rows in the existing model.
2. **Read** the product spec (data, jurisdiction), technical-preferences (including Deploy target, Infra repo and Proxy config — proxy requirements need an owner and a file), the API contract, compose/infra, the existing threat model. No product spec → continue from technical-preferences and the code, and say so in the model.
3. **Draw** the DFD (mermaid) with trust boundaries; ask about the non-obvious (external integrations, admin access, payments).

## Phase 2: Surfaces and threats
1. Per surface: STRIDE threats with likelihood/impact; mitigations referencing the baseline; status (exists/planned/none).
2. Surfaces that need their own rows:
   - **Data export / deletion**, when the data model classifies personal data: who may request, how identity is verified, what is exported (and what must not be), how deletion propagates to replicas, backups and logs, and the evidence kept.
   - **GraphQL**: introspection, complexity, batching, field authorisation, persisted ops.
   - **Games**: anti-cheat, modified clients, chat spam, room DoS.
3. `appsec-engineer` and `network-security-engineer` via Task in parallel complete their areas.

## Phase 3: Priorities
Top 5 unmitigated threats → proposed stories (`/create-stories`) or ADRs (`/architecture-decision`); residual risks explicitly accepted by the user.

## Phase 4: Write
The gate follows coordination-rules rule 7's exact order: the draft (or a tight summary of it) in the chat message first, then "May I write `docs/architecture/threat-model.md`?" — one `AskUserQuestion`: write (Recommended) · show the draft/diff first · not now — and `Write` only after that answer, never write-then-ask. Add a "Security" section to affected feature specs with consent. After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker).

## Phase 5: Commit (documents lane)
Right after the write, one commit gate (rule 7 (4), `.claude/docs/git-workflow.md` § Documents): `docs: threat model` (or `docs: threat model — <surface>` for a single-surface update), staging exactly the written files — `docs/architecture/threat-model.md` and the feature specs whose "Security" section was added with consent. Record the gate before asking — `<hooks>session-state.sh set Gate "/threat-model Phase 5: commit?"` — and clear it after the answer (`<hooks>session-state.sh set Gate "—"`).
- On the default branch when no story work is in progress: one `AskUserQuestion` — commit (Recommended) · leave uncommitted.
- When HEAD is a story branch, name it and ask one `AskUserQuestion`: switch to the default branch and commit there (Recommended — a pipeline-wide document) · commit here (the document belongs to this story) · leave uncommitted.
- This skill writes no code; should a mitigation snippet have been written on request, it is not a document and never rides the `docs:` commit — name it and offer the chore lane (git-workflow.md § Chore / infra) or the story it belongs to.

Nothing is committed without the answer.

Verdict: `COMPLETE` | `HIGH RISK (N unmitigated)`. Next step — one `AskUserQuestion`: `/create-stories` for the mitigations (Recommended) · `/security-audit` after implementation · revise the model.
