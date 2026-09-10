---
name: impact
description: "Classifies a change proposal before any code — architecture (ADR, boundary, stack, contract, data model, dependency, deployment), security (threat-model surface, security-sensitive path, auth, PII, secrets, CI permissions) or product scope — from the artifacts it touches, gets a short verdict from the owner of each triggered class (technical-director, security-lead, product-director) and hands off to the commands the verdict requires. Use when the user proposes a change outside the current story, before /dev-story picks it up, or whenever a change 'might touch architecture or security'."
argument-hint: "<the proposal in the user's words> [--classify-only]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Edit, Task, AskUserQuestion
model: sonnet
---

# Impact

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

Triage, not review: the skill decides **who** must look at a proposal and **what runs next**, in minutes. It produces no document — an ADR, a threat-model surface, a contract, a story is written by its own command with its own "May I write?" gate (rule 9); the only file this skill touches is `production/session-state/active.md` (one dated `Notes:` line, `Next:`), which needs no question. Coordination-rules rule 11; review-workflow.md § Change classes. After the "write" answer: `touch .claude/.write-consent` (rule 7).

## Phase 1: Proposal and scope
The proposal verbatim (the argument, else the user's last message — quote it back). The active story from `session-state/active.md` and its acceptance criteria; the review mode (`production/review-mode.txt`). A proposal fully inside the active story's criteria is `ROUTINE`: say so in one line and hand off to `/dev-story` — no verifier is spawned for work a story already approved. A **trivial** change — a comment, a typo, formatting, a log message or docstring text, with no behavioural change — is `ROUTINE` too, whatever path it touches: one line, no verifier (the `security-sensitive` rule's review-before-merge applies to the PR, not to triage).

## Phase 2: Classification from evidence
Every class is claimed only with the artifact or path it touches, rendered as a table (class · trigger · evidence) before anything else happens (rule 7). Grep, do not guess:
- **architecture** — an accepted ADR names or contradicts it (`docs/architecture/adr-*.md`, `decisions.md`); a system boundary or module ownership moves; the stack or a pinned version in `technical-preferences.md`; the API contract (`schema.graphql`, `openapi.*`); the data model or a migration; a new runtime dependency (manifest); the deployment topology (Dockerfile, compose, workflows).
- **security** — a surface in `docs/architecture/threat-model.md`; a path matching the globs of `.claude/rules/security-sensitive.md`; authentication, sessions, authorisation; PII, secrets, tokens; CI permissions; network, proxy, TLS; uploads, webhooks, WebSocket.
- **product** — user-visible behaviour absent from the feature spec; a changed acceptance criterion; scope the product spec lists as out.
- **routine** — none of the above: a change inside existing decisions and surfaces.
`--classify-only`: stop after the table with the verdict `CLASSIFIED (<classes>)` and the hand-off below; useful when the user only wants to know whether a director must look.

## Phase 3: Verification by the class owner
Only the triggered classes, in one parallel `Task` batch: architecture → `technical-director`, security → `security-lead`, product → `product-director`. The brief per verifier: the proposal, that class's evidence rows, the artifacts to read by path, the review mode. Review mode scopes this step (review-workflow.md): `full` — every triggered class; `lean` — architecture and security, product shown as classification only unless asked; `solo` — classification shown, verification only after one `AskUserQuestion` (verify (Recommended) · skip).
The verifier's contract — quoted verbatim in the brief — is exactly four blocks and nothing else, 15 lines in total: `Verdict:` one of `APPROVED` · `APPROVED WITH CONDITIONS (…)` · `NEEDS ADR` · `BLOCKED (reason)`; `Why:` at most two lines; `Artifacts:` the ones that must change (ADR, threat-model surface, contract, data model, spec, stories); `Commands:` numbered, in pipeline order. No observations, no background, no list of files read. A reply without commands, or longer than 15 lines, goes back once with the four blocks quoted; a second miss is reported as such — the skill never pads or trims a verdict itself. A `BLOCKED` from any verifier is surfaced immediately with the reason.

## Phase 4: Decision and hand-off
One table: verifier · verdict · artifacts to change · commands. Session state: `Notes:` gets `impact: <proposal> → <verdicts>` with the date, `Next:` the first command; then `touch .claude/.impact-verdict` (the impact-guard hook checks the marker for architecture/security paths; warn-only). Commands in the pipeline's order: `/architecture-decision` → `/threat-model` → `/api-contract` / `/data-model` → `/feature-spec` / `/create-stories` → `/dev-story`. May I write? never arises here: every document above is written by its own command.

Verdict: `ROUTINE` | `CLASSIFIED (…)` | `APPROVED` | `APPROVED WITH CONDITIONS` | `NEEDS ADR` | `BLOCKED`. Next step — one `AskUserQuestion`: the first command the verdicts require (Recommended) · show the verifiers' full replies · stop here. On `BLOCKED`: revise the proposal (Recommended) · record the rejection as an ADR (`/architecture-decision`) · stop here.
