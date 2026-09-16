---
name: architecture-decision
description: "Creates an Architecture Decision Record (context, ≥2 options with costs, decision, consequences, verification) or retrofits an existing ADR to the template. Every significant technical choice (stack, API style, auth, data, engine, deployment) gets an ADR before code."
argument-hint: "[title] | retrofit [path] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, WebFetch, AskUserQuestion, Task
model: sonnet
agent: technical-director
---

# Architecture Decision Record

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

Versions come from `stack-reference/`; when the recommended version there is a major behind the registry's "latest on the date", the ADR states why the older one is chosen (or proposes `/stack-update` first).

Template `.claude/docs/templates/adr.md`; files `docs/architecture/adr-NNNN-<slug>.md`.

## Phase 0: Mode
`retrofit <path>` — read the existing ADR, find missing sections (Status — BLOCKING; Options/Consequences/Verification — HIGH), propose adding them without changing existing text; "May I write?".

## Phase 1: Context
Read technical-preferences, the product spec, related feature specs, existing ADRs (dependencies, contradictions), the relevant `stack-reference/` file (version facts come from there; when in doubt `WebFetch` the official source).

## Phase 2: Options
≥ 2 options (including "do nothing" where relevant) with pros/cons/cost/risk/maturity. For the studio's typical forks use the known arguments: GraphQL vs REST (see `graphql.md`), Go vs PHP vs Node, Angular vs Vue, three.js vs Pixi vs Phaser, sessions vs JWT, monolith vs services, Caddy vs nginx. Give an explicit recommendation.

## Phase 3: Decision and consequences
Draft Decision/Consequences/Verification (how we will check: metric, spike, test; when we revisit). Review per mode: `full` — `backend-lead`/`frontend-lead`/`security-lead` for affected areas; `lean` — `security-lead` when auth/data/network are affected; `solo` — none.
Reviews run **before** the write gate, in parallel, each as `Task` with an explicit `subagent_type` (`web-studio:backend-lead`, `web-studio:frontend-lead`, `web-studio:security-lead`) — never the default general-purpose agent, and never a generic agent with a model override standing in as an arbiter: "one more opinion" on a draft is one of these same reviewers, because an agent outside the roster carries none of the project's rules and leaves no roster name in the log (WS-104).
**The reviewer has to be able to read the draft.** A long draft does not fit a Task prompt, so the skill writes it to a session file first and passes **the path plus the requirement to quote the ADR title and the two lines of Decision back in the verdict** — that quote is the evidence the text was read. A verdict without it is returned once with the path repeated; a second one without it is reported as "reviewer did not read the draft", never counted as a review. Name the reviewers in the report exactly as `production/session-logs/agent-audit.log` records them. Conditions from the verdicts are applied to the draft first; only then Phase 4.

## Phase 4: Write
"May I write `docs/architecture/adr-NNNN-<slug>.md` and a line in the technical-preferences decision log?" — one `AskUserQuestion`: write (Recommended) · show the draft/diff first · not now. Status is `Proposed` until the user says `Accepted` — also for a decision that is already implemented and deployed (write `Proposed · implemented since <date>`); "implemented" is not "accepted". After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker).

When the project has `production/roadmap.md` (`roadmap-format: v3.1` or later) and this ADR reaches `Accepted`: add or update its row in the roadmap's `## Docs` → *docs/architecture/* block (✅, inline link, one-line summary) and refresh the block's `<summary>` count; any open task lines carrying `⛔ [ADR-NNNN](path)` now name an accepted decision, not a pending one — leave the marker (it still names *why* the dependency exists) but this is the moment a blocked story becomes unblockable-by-this-reason.

A decision **not** to take the ADR is an outcome, not a dead end: record it as a `D-NN` line in `production/decisions.md` (or as an ADR with status `Rejected` when a draft already exists), with the reason and the date. What must never happen is the discussion ending in code: if the answer turns out to be a change to the repository — a Dockerfile line, a healthcheck, a flag — this skill does not make it. It hands it over in the closing `AskUserQuestion`: `/impact "<change>"` for anything with an architecture or security surface, `/hotfix` for a one-liner in production, otherwise a story through `/create-stories`. Editing production files from a document session bypasses the review, the branch and the DoD of whatever story owns them.

Verdict: `ACCEPTED` | `PROPOSED` | `NEEDS REVISION`. Next step — one `AskUserQuestion`: `/api-contract` (Recommended) · `/data-model` · `/create-stories`.
