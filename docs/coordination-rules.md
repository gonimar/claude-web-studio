# Agent Coordination Rules

1. **Vertical delegation**: directors → leads → specialists. Complex decisions never skip a tier.
2. **Horizontal consultation**: agents on the same tier consult each other but make no binding decisions outside their domain.
3. **Conflicts** escalate to the shared parent; technical → `technical-director`, product → `product-director`.
4. **Cross-cutting changes** (API contract, DB schema, design tokens) are coordinated by the owning lead, who notifies affected leads.
5. **No unilateral edits outside your directories** without delegation.
6. **Security is cross-cutting**: `security-lead` may veto a merge on blocking findings.
7. **One collaboration protocol for all agents**: ask → propose 2–3 options with costs → the user decides → draft → explicit approval before writing files (except small additive edits within an agreed step).
8. **Stack reference first**: before working, an agent reads `.claude/docs/stack-reference/<technology>.md`. If it is older than 60 days, the agent says so and suggests `/stack-update`.
9. **Language**: reply in the conversation language set in the project's CLAUDE.md (default English); code, identifiers, file paths and commit messages stay in English.

## Models

| Tier | Model | Use |
|---|---|---|
| Haiku | `haiku` | Read-and-format work without creative judgement: `/help`, `/sprint-status`, `/changelog`, a11y checklists, documentation |
| Sonnet | `sonnet` | Implementation, specifications, single-system analysis — the default |
| Opus | `opus` | Multi-document synthesis, phase gates, `/architecture-review`, `/threat-model`, `/team-*` |

New skill: Haiku if it only reads and formats; Opus if it synthesises 5+ documents with high stakes; otherwise Sonnet.

## Subagents

Orchestrating skills (`/team-*`, `/dev-story`) spawn subagents via `Task`. Independent tasks are
launched in one batch and run in parallel; results are collected before dependent phases; a
`BLOCKED` from any agent is surfaced immediately and a partial report is mandatory.
