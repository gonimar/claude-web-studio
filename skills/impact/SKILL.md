---
name: impact
description: "Classifies a change proposal before any code — architecture (ADR, boundary, stack, contract, data model, dependency, deployment), security (threat-model surface, security-sensitive path, auth, PII, secrets, CI permissions) or product scope — from the artifacts it touches, gets a short verdict from the owner of each triggered class (technical-director, security-lead, product-director) and hands off to the commands the verdict requires. Use when the user proposes a change outside the current story, before /dev-story picks it up, or whenever a change 'might touch architecture or security'."
argument-hint: "<the proposal in the user's words> [--classify-only]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Edit, Task, AskUserQuestion
---

# Impact

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

Triage, not review: the skill decides **who** must look at a proposal and **what runs next**, in minutes. Coordination-rules rule 11; review-workflow.md § Change classes.

It produces no document. An ADR, a threat-model surface, a contract or a story is written by its own command with its own "May I write?" gate (rule 9). The files this skill touches:
- `production/session-state/active.md`, through the writer: one dated `Notes:` line after a verification (Phase 4 step 4), and `Next:` only when the user picks a command (Phase 4 step 5). This needs no question.
- `production/findings.md` (a row for a finding ID a verdict names) and `production/backlog.md` (the verdict line of a backlog idea), only when the case arises and only after the Phase 4 "May I write?" gate, each followed by its commit gate (Phase 4 step 3).
- `.claude/.impact-verdict`, the marker, only on an approving verdict (Phase 4 step 6).

`--classify-only` and a `ROUTINE` answer touch none of them: no note, no marker, no row.

In the commands below, `<hooks>` is `.claude/hooks/` in copy mode and `${CLAUDE_PLUGIN_ROOT}/hooks/` in plugin mode; a studio agent is `web-studio:<name>` in plugin mode and `<name>` in copy mode.

## Phase 1: Proposal and scope
1. **The proposal verbatim**: the argument, else the user's last message. Quote it back.
2. **Read** the active story from `production/session-state/active.md` and its acceptance criteria, and the review mode (`production/review-mode.txt`).
3. **Inside the active story.** A proposal fully inside the active story's criteria is `ROUTINE`: say so in one line and hand off to `/dev-story <story>`; the skill ends here. No verifier is spawned for work a story already approved.
4. **Trivial change.** A comment, a typo, formatting, a log message or docstring text, with no behavioural change, is `ROUTINE` too, whatever path it touches: one line, no classification table, no verifier. The `security-sensitive` rule's review-before-merge applies to the PR, not to triage.

## Phase 2: Classification from evidence
1. **Grep, do not guess.** Every class is claimed only with the artifact or path it touches:
   - **architecture** — an accepted ADR names or contradicts it (`docs/architecture/adr-*.md`, `production/decisions.md`); a system boundary or module ownership moves; the stack or a pinned version in `technical-preferences.md`; the API contract (`schema.graphql`, `openapi.*`); the data model or a migration; a new runtime dependency (manifest); the deployment topology (Dockerfile, compose, workflows).
   - **security** — a surface in `docs/architecture/threat-model.md`; a path matching the globs of `.claude/rules/security-sensitive.md`; authentication, sessions, authorisation; PII, secrets, tokens; CI permissions; network, proxy, TLS; uploads, webhooks, WebSocket.
   - **product** — user-visible behaviour absent from the feature spec; a changed acceptance criterion; scope the product spec lists as out.
   - **routine** — none of the above: a change inside existing decisions and surfaces.
2. **Render the table** (class · trigger · evidence) in the chat message before anything else happens (rule 7).
3. **`--classify-only`**: stop after the table with the verdict `CLASSIFIED (<classes>)` and go to the closing Next-step question; Phase 3 does not run and no `Task` is spawned. Nothing is written either: no session note, no `.claude/.impact-verdict` marker, no findings or backlog row — a classification is not a verdict, and the impact-guard hook must keep warning until a verifier has approved. Useful when the user only wants to know whether a director must look.

## Phase 3: Verification by the class owner
1. **Review mode scopes the step** (review-workflow.md):
   - `full` — every triggered class.
   - `lean` — architecture and security; product is shown as classification only unless the user asks.
   - `solo` — the classification is shown; before any spawn, one `AskUserQuestion`: verify (Recommended) · skip.
2. **Spawn** only the triggered classes in scope, in one parallel `Task` batch: architecture → `technical-director`, security → `security-lead`, product → `product-director`.
3. **The brief per verifier**: the proposal, that class's evidence rows, the artifacts to read by path, the review mode, and the verifier's contract quoted verbatim.
4. **The verifier's contract** is exactly four blocks and nothing else, 15 lines in total:
   - `Verdict:` one of `APPROVED` · `APPROVED WITH CONDITIONS (…)` · `NEEDS ADR` · `BLOCKED (reason)`;
   - `Why:` at most two lines;
   - `Artifacts:` the ones that must change (ADR, threat-model surface, contract, data model, spec, stories);
   - `Commands:` numbered, in pipeline order.

   No observations, no background, no list of files read.
5. **Check each reply.** A reply without commands, or longer than 15 lines, goes back once with the four blocks quoted. A second miss is reported as incomplete; the skill never pads or trims a verdict itself.
6. **`BLOCKED`** from any verifier is surfaced immediately, with the reason.

## Phase 4: Decision and hand-off
1. **One table**: verifier · verdict · artifacts to change · commands. Commands in the pipeline's order: `/architecture-decision` → `/threat-model` → `/api-contract` / `/data-model` → `/feature-spec` / `/create-stories` → `/dev-story`.
2. **Measurements.** A verdict that rests on a measurement names the file it lives in (`docs/ops/measurements/…`, rule 12), never a number typed from memory into `Notes:`.
3. **Records the verdict creates** — only when one of these applies:
   - **A finding ID is never minted without the line it names.** A verdict that says `ARCH-004` or `SEC-002` gets that row in `production/findings.md` in the same turn (any severity; status `planned (S-NNN)` when a story will carry it). Otherwise the next session greps the ID, finds nothing, and the verdict loses its authority.
   - **A backlog idea gets its verdict back.** When the proposal came from `production/backlog.md` (an `I-NNN` in the argument, or an entry whose text this proposal repeats), add one line to that entry: date, verdict, next command. An idea that has been through triage and is still listed as untouched will be proposed again.

   Show the row/line, then one `AskUserQuestion`: "May I write <the row in `production/findings.md` / the line in `production/backlog.md`>?" — write (Recommended) · show the draft/diff first · not now. After the "write" answer: `touch .claude/.write-consent` (rule 7), then `Edit`.

   **Commit gate** right after the write (rule 7 (4), `.claude/docs/git-workflow.md` § Documents), recorded first as `Gate "/impact Phase 4: commit <ID>?"` through `<hooks>session-state.sh set` and cleared after the answer (`set Gate "—"`; an open gate survives the next turn), one `AskUserQuestion`: `docs: impact <ID> — <verdict>` (a backlog line: `docs: backlog I-NNN — impact verdict`) staging exactly the written file(s). On the default branch when no story work is in progress. When HEAD is a story branch — the usual case for a triage that interrupted `/dev-story` — name it and offer: switch to the default branch and commit there (Recommended — a findings row or a backlog line is a pipeline-wide document) · commit here (the row belongs to this story) · leave uncommitted. On "switch": `git switch <default> && git pull --ff-only origin <default>`, the commit, then `git switch <story branch>` back, so the interrupted story continues on its own branch. Nothing is committed without the answer; code or configs never ride the `docs:` commit.
4. **Session note** through the studio's writer: `<hooks>session-state.sh note "impact: <proposal> → <verdicts>; next: <commands>"`. It dates the line, keeps the last ten and moves older ones to `production/session-state/archive/`. If the state file is not in the writer's format, the writer refuses: run `<hooks>session-state.sh migrate` once (it archives the whole previous file), or add the line by hand.
5. **This skill never writes `Next:` on its own.** `Next:` is where the session was heading, and a triage is usually a detour from it (rule 7: a detour never overwrites the interrupted intent). The required commands go into the note and into the closing `AskUserQuestion`. `Next:` changes only when the user picks one of them there (`<hooks>session-state.sh set Next "<command>"`), because that choice is what makes it the task.
6. **Marker**, only on an approving verdict: `touch .claude/.impact-verdict` when every verifier in scope answered `APPROVED` or `APPROVED WITH CONDITIONS` (the impact-guard hook checks it for architecture/security paths; warn-only). Never after `BLOCKED` — a marker there would silence the guard for exactly the change that was rejected — and not after `NEEDS ADR` either: the ADR, and the story that follows it, earn the marker (`/dev-story` touches it at story start). `CLASSIFIED` and `ROUTINE` end before this step. A marker that already exists (a running story's, or an earlier approval's — the hook treats it as fresh for four hours) is not removed: the guard is a nudge to classify, and the rejection lives in the session note and the closing question.

Verdict: `ROUTINE` | `CLASSIFIED (…)` | `APPROVED` | `APPROVED WITH CONDITIONS` | `NEEDS ADR` | `BLOCKED`.

Next step — one `AskUserQuestion`: the first command the verdicts require (Recommended) · show the verifiers' full replies · stop here. On `BLOCKED`: revise the proposal (Recommended) · record the rejection as an ADR (`/architecture-decision`) · stop here.
