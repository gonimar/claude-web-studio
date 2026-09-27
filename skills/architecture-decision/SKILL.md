---
name: architecture-decision
description: "Creates an Architecture Decision Record (context, ≥2 options with costs, decision, consequences, verification) or retrofits an existing ADR to the template. Every significant technical choice (stack, API style, auth, data, engine, deployment) gets an ADR before code."
argument-hint: "[title] | retrofit [path] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, WebFetch, AskUserQuestion, Task
---

# Architecture Decision Record

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

Template `.claude/docs/templates/adr.md`; files `docs/architecture/adr-NNNN-<slug>.md`. Version facts come from `.claude/docs/stack-reference/` (`stack-reference/` below). A studio agent is `web-studio:<name>` in plugin mode and `<name>` in copy mode. The review mode is `--review`, else `production/review-mode.txt`. In the commands below, `<hooks>` is `.claude/hooks/` in copy mode and `${CLAUDE_PLUGIN_ROOT}/hooks/` in plugin mode.

## Phase 0: Mode
1. **`retrofit <path>`** (no path → ask which ADR): read the existing ADR and find the missing sections — Status is BLOCKING; Options, Consequences and Verification are HIGH.
2. Propose adding the missing sections without changing the existing text, then run the **Phase 3 review** (steps 2–9, per mode) before the Phase 4 gate for `<path>`. An implemented decision still gets its reviewers: the draft is labelled `retrofit`, so they judge **conformance** — whether the written Options, Consequences and Verification match what is implemented — not whether another option should have won. The Phase 4 status rule applies: a Status added here is `Proposed` unless the user says `Accepted`.
3. **A title** (or none — ask for it): a new ADR, Phase 1.

## Phase 1: Context
1. **Read**: technical-preferences, the product spec, related feature specs, existing ADRs.
2. **Existing ADRs**: note what this decision depends on and what it contradicts. A contradiction with an accepted ADR is flagged to the user and named in the draft.
3. **Versions**: the relevant `stack-reference/` file; when in doubt, `WebFetch` the official source. When the recommended version there is a major behind the registry's "latest on the date", the ADR states why the older one is chosen (or proposes `/stack-update` first).

## Phase 2: Options
1. **≥ 2 options** (including "do nothing" where relevant) with pros/cons/cost/risk/maturity.
2. **Known arguments** for the studio's typical forks: GraphQL vs REST (see `stack-reference/graphql.md`), Go vs PHP vs Node, Angular vs Vue, three.js vs Pixi vs Phaser, sessions vs JWT, monolith vs services, Caddy vs nginx.
3. **An explicit recommendation.**

## Phase 3: Decision, consequences and review
1. **Draft** Decision / Consequences / Verification (how we will check: metric, spike, test; when we revisit).
2. **Numbers.** A number in the draft — a latency, a size, a rate — links to `docs/ops/measurements/YYYY-MM-DD-<topic>.md` holding the command, the environment and the raw output (rule 12). A figure whose only home is the session state is quoted as "measured in session, not recorded", or not quoted at all.
3. **Reviewers per mode**: `full` — `backend-lead` / `frontend-lead` / `security-lead` for the affected areas; `lean` — `security-lead` when auth/data/network are affected; `solo` — none, go to Phase 4.
4. **Make the draft readable.** A long draft does not fit a `Task` prompt, so write it to a session file first (the session scratchpad, never `docs/architecture/`: the ADR path waits for the Phase 4 gate).
5. **Spawn the reviews before the write gate**, in parallel, each as `Task` with an explicit studio `subagent_type` (`web-studio:backend-lead`, `web-studio:frontend-lead`, `web-studio:security-lead`). Never the default general-purpose agent, and never a generic agent with a model override standing in as an arbiter: "one more opinion" on a draft is one of these same reviewers, because an agent outside the roster carries none of the project's rules and leaves no roster name in the log (WS-104).
6. **The brief** carries the draft's path plus the requirement to quote the ADR title and the two lines of Decision back in the verdict. That quote is the evidence the text was read.
7. **Check each verdict.** One without the quote is returned once with the path repeated; a second one without it is reported as "reviewer did not read the draft", never counted as a review.
8. **Name the reviewers** in the report exactly as `production/session-logs/agent-audit.log` records them.
9. **Apply the conditions** from the verdicts to the draft; only then Phase 4.

## Phase 4: Write
1. **Status** is `Proposed` until the user says `Accepted`. That holds for a decision that is already implemented and deployed too: write `Proposed · implemented since <date>`; "implemented" is not "accepted".
2. **Gate**, one `AskUserQuestion`: "May I write `docs/architecture/adr-NNNN-<slug>.md` and a line in the technical-preferences decision log?" — write (Recommended) · show the draft/diff first · not now. When the ADR is `Accepted` and the roadmap step below applies, the question names `production/roadmap.md` too.
3. After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker).
4. **Write** the ADR from the template and the line in `technical-preferences.md` → Architecture decision log.
5. **Roadmap**, when the project has `production/roadmap.md` (`roadmap-format: v3.1` or later) and this ADR reaches `Accepted`:
   - Add or update its row in the roadmap's `## Docs` → *docs/architecture/* block (✅, inline link, one-line summary) and refresh the block's `<summary>` count.
   - Open task lines carrying `⛔ [ADR-NNNN](path)` now name an accepted decision, not a pending one. Leave the marker, because it still names *why* the dependency exists; this decision no longer holds those stories back.

## Phase 5: Commit (documents lane)
Right after the write, one commit gate (rule 7 (4), `.claude/docs/git-workflow.md` § Documents): one `AskUserQuestion` offering `docs: ADR-NNNN <slug>`, staging exactly the written files — the ADR, the decision-log line in `technical-preferences.md` and, when the roadmap step applied, `production/roadmap.md`. Record the gate before asking — `<hooks>session-state.sh set Gate "/architecture-decision Phase 5: commit?"` — and clear it after the answer (`<hooks>session-state.sh set Gate "—"`).
- On the default branch when no story work is in progress.
- When HEAD is a story branch, name it and offer: switch to the default branch and commit there (Recommended — a pipeline-wide document) · commit here (the document belongs to this story) · leave uncommitted.
- Code, configs, workflows and scripts never ride the `docs:` commit.

Nothing is committed without the answer.

## When the answer is "no ADR"
A decision **not** to take the ADR is an outcome, not a dead end.
1. **Record it** as a `D-NN` line in `production/decisions.md` (or as an ADR with status `Rejected` when a draft already exists), with the reason and the date — after its own "May I write `<path>`?" gate, as in Phase 4, and followed by the Phase 5 commit gate (`docs: decision D-NN` or `docs: ADR-NNNN rejected`).
2. **Never end the discussion in code.** If the answer turns out to be a change to the repository — a Dockerfile line, a healthcheck, a flag — this skill does not make it. Editing production files from a document session bypasses the review, the branch and the DoD of whatever story owns them.
3. **Hand it over** in the closing `AskUserQuestion`: `/impact "<change>"` for anything with an architecture or security surface, `/hotfix` for a one-liner in production, otherwise a story through `/create-stories`.

Verdict: `ACCEPTED` | `PROPOSED` | `NEEDS REVISION` | `REJECTED`.

Next step — one `AskUserQuestion`: `/api-contract` (Recommended) · `/data-model` · `/create-stories`. On `REJECTED`: the hand-over command from the section above (Recommended) · stop here.
