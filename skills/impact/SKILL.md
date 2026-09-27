---
name: impact
description: "Classifies a change proposal before any code — architecture (ADR, boundary, stack, contract, data model, dependency, deployment), security (threat-model surface, security-sensitive path, auth, PII, secrets, CI permissions) or product scope — from the artifacts it touches, gets a short verdict from the owner of each triggered class (technical-director, security-lead, product-director) and hands off to the commands the verdict requires. Use when the user proposes a change outside the current story, before /dev-story picks it up, or whenever a change 'might touch architecture or security'."
argument-hint: "<the proposal in the user's words> [--classify-only]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Edit, Task, AskUserQuestion
---

# Impact

Language, `<hooks>`, agent and command namespaces, gate mechanics, the documents-lane commit gate and the consent marker: `docs/coordination-rules.md` § Skill conventions (verifiers: § Subagents).

Triage, not review: the skill decides **who** must look at a proposal and **what runs next**, in minutes (rule 11; review-workflow.md § Change classes).

It produces no document (rule 9: an ADR, threat-model surface, contract or story comes from its own command and gate). It writes only: a dated `Notes:` line via the state writer, no question needed (Phase 4 step 4); a findings/backlog row behind the Phase 4 step 3 gates; the `.claude/.impact-verdict` marker on approval (step 6); `Next:` on the user's pick (closing block).
`--classify-only`, a `ROUTINE` run and a `solo` skip write nothing: no note, no marker, no row.

## Phase 1: Proposal and scope
1. **The proposal verbatim**: the argument, else the user's last message; quote it back.
2. **Read** the active story `production/session-state/active.md` names (`<story>`; its file is `production/stories/F-NNN/S-NNN-*.md`), its acceptance criteria and the review mode (`production/review-mode.txt`).
3. **Inside the active story.** A proposal fully inside `<story>`'s criteria is `ROUTINE`: one line, no verifier (the story already approved it), and the run ends with the text line `Next step: /dev-story <story>` (namespaced) instead of the closing question.
4. **Trivial change.** A comment, typo, formatting, log message or docstring text with no behavioural change is `ROUTINE` too, whatever path it touches: one line, no classification table, no verifier, the same ending (`Next step: proceed` with no active story). The `security-sensitive` review-before-merge applies to the PR, not to triage.

## Phase 2: Classification from evidence
1. **Grep, do not guess.** Every class is claimed only with the artifact or path it touches:
   - **architecture** — an accepted ADR names or contradicts it (`docs/architecture/adr-*.md`, `production/decisions.md`); a system boundary or module ownership moves; the stack or a pinned version in `technical-preferences.md`; the API contract (`schema.graphql`, `openapi.*`); the data model or a migration; a new runtime dependency (manifest); the deployment topology (Dockerfile, compose, workflows).
   - **security** — a surface in `docs/architecture/threat-model.md`; a path matching the globs of `.claude/rules/security-sensitive.md`; authentication, sessions, authorisation; PII, secrets, tokens; CI permissions; network, proxy, TLS; uploads, webhooks, WebSocket.
   - **product** — user-visible behaviour absent from the feature spec; a changed acceptance criterion; scope the product spec lists as out.
   - **routine** — none of the above: a change inside existing decisions and surfaces.
2. **Render the table** (class · trigger · evidence) in the chat before anything else happens (rule 7).
3. **`--classify-only`**: stop after the table with the verdict `CLASSIFIED (<classes>)` and go to the closing question — no Phase 3, no `Task`, nothing written (no note, no marker, no row): a classification is not a verdict, so the impact-guard keeps warning until a verifier approves (absent a marker still fresh, Phase 4 step 6).

## Phase 3: Verification by the class owner
1. **Review mode scopes the step** (review-workflow.md):
   - `full` — every triggered class.
   - `lean` — architecture and security; a triggered product class stays classification only unless the pre-spawn `AskUserQuestion`, asked only when product is triggered — verify architecture and security (Recommended) · product too — adds it.
   - `solo` — the classification is shown; before any spawn, one `AskUserQuestion`: verify (Recommended) · skip, which ends like `--classify-only`: `CLASSIFIED (<classes>)`, no note, no marker, the closing question.
2. **Spawn** the triggered classes in scope in one parallel `Task` batch: architecture → `technical-director`, security → `security-lead`, product → `product-director`.
3. **The brief per verifier**: the template in `references/verifier-brief.md` (the proposal, the class's evidence rows, the artifacts to read by path, the review mode, the contract quoted verbatim).
4. **The verifier's contract** — four blocks, at most 15 lines, nothing else: `Verdict:` (`APPROVED` · `APPROVED WITH CONDITIONS (…)` · `NEEDS ADR` · `BLOCKED (reason)`) · `Why:` (≤ 2 lines) · `Artifacts:` (those that must change) · `Commands:` (numbered, pipeline order); no observations, background or file lists.
5. **Check each reply.** No commands, or over 15 lines: back once with the four blocks quoted; a second miss is reported as incomplete, never padded or trimmed by the skill.
6. **`BLOCKED`** from any verifier is surfaced immediately, with the reason.

## Phase 4: Decision and hand-off
1. **One table**: verifier · verdict · artifacts to change · commands, in pipeline order: `/architecture-decision` → `/threat-model` → `/api-contract` / `/data-model` → `/feature-spec` / `/create-stories` → `/dev-story`.
2. **Measurements.** A verdict resting on a measurement names its file (`docs/ops/measurements/…`, rule 12), never a number from memory in `Notes:`.
3. **Records the verdict creates** — only when a verdict names a finding ID (`ARCH-004`, `SEC-002` → its row in `production/findings.md`, same turn, or the ID has no authority) or the proposal came from `production/backlog.md` (`I-NNN` in the argument or a matching entry → one line: date, verdict, next command, or the idea returns). Read `references/records.md`, then:
   1. Show the row/line; one `AskUserQuestion`: "May I write <the row in `production/findings.md` / the line in `production/backlog.md`>?" — write (Recommended) · show the draft/diff first · not now; after "write" `touch .claude/.write-consent`, then `Edit`.
   2. Record the commit gate: `<hooks>session-state.sh set Gate "/impact Phase 4: commit <ID>?"`.
   3. Ask, **one** `AskUserQuestion` that names the message and the branch (rule 7: one turn, one gate): `docs: impact <ID> — <verdict>` (a backlog line: `docs: backlog I-NNN — impact verdict`), staging exactly the written file(s); the branch per § Documents-lane commit gate — `<default>` when no story work is in progress; a story-branch HEAD (usual: the triage interrupted `/dev-story`) is named in the question, whose options are switch to `<default>` and commit there (Recommended: the document is pipeline-wide) · commit here · leave uncommitted.
   4. On "switch": `git switch <default> && git pull --ff-only origin <default>`, the commit, `git switch <story branch>` back, so the interrupted story continues on its branch.
   6. Clear the gate: `<hooks>session-state.sh set Gate "—"`. Nothing is committed without the answer; code or configs never ride the `docs:` commit.
4. **Session note**: `<hooks>session-state.sh note "impact: <proposal> → <verdicts>; next: <commands>"` (dated; the writer keeps ten, archives older ones to `production/session-state/archive/`, and refuses a file not in its format — then `<hooks>session-state.sh migrate` once, which archives the previous file, or add the line by hand).
5. **Never write `Next:` yourself**: a triage is usually a detour, and a detour never overwrites the interrupted intent (rule 7); the required commands go into the note and the closing question.
6. **Marker**, only on an approving verdict: `touch .claude/.impact-verdict` when every verifier in scope answered `APPROVED` or `APPROVED WITH CONDITIONS` (read by the warn-only impact-guard on architecture/security paths). Never after `BLOCKED` (it would silence the guard for the rejected change) nor `NEEDS ADR` (the ADR and its story earn it: `/dev-story` touches it at story start); `CLASSIFIED` and `ROUTINE` end earlier. An existing marker is never removed and counts as fresh for four hours, so the guard may stay silent during a running story even after `BLOCKED`: it nudges to classify; the rejection lives in the note and the closing question.

Verdict: `ROUTINE` | `CLASSIFIED (…)` | `APPROVED` | `APPROVED WITH CONDITIONS` | `NEEDS ADR` | `BLOCKED`.

Next step — one `AskUserQuestion`: the first command the verdicts require (Recommended) · show the verifiers' full replies · stop here; on `BLOCKED`: revise the proposal (Recommended) · record the rejection as an ADR (`/architecture-decision`) · stop here. On a command pick: `<hooks>session-state.sh set Next "<command>"` — that choice makes it the task.
