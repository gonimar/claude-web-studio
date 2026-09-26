---
name: product-spec
description: "Authors the product specification (goals, users, scope, NFRs, risks, MVP acceptance) section by section with the user. Produces docs/specs/product-spec.md. Required before feature specs."
argument-hint: "[product name] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion, Task
model: sonnet
agent: product-director
---

# Product Spec

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

Template: `.claude/docs/templates/product-spec.md` (sections 1–10). Section by section: questions → section draft → edits → next.
The file is written once at the end (or per section, the user's choice), always after "May I write?".

## Phase 1: Context
1. **Read** `docs/specs/concept-brief.md` (if any), `technical-preferences.md`, `production/roadmap.md` and `production/stage.txt`.
2. **Stack.** When the stack is not configured, suggest `/setup-stack` before or after this skill (not blocking).
3. **No clear product.** When there is no concept brief and the user cannot say what the product is and for whom, stop before any section: suggest `/brainstorm` and write nothing.
4. **Pick the mode.**
   - **Retrofit mode** — stage `build` or later, with code and a deployment that already exist. The spec documents what runs, not what is planned. Sources are `CLAUDE.md`, the roadmap, the deployed configuration and the code. Phase 2 becomes one pass: draft all sections from those sources, show the draft as a whole, and ask questions only where the facts are silent (goals, audience, out-of-scope). The Phase 3 review verifies claims against the repository: a claimed fact the repository contradicts is BLOCKING.
   - **New spec** — every other case: Phase 2 as written.

## Phase 2: Sections 1–10
For each section, in template order:
1. Ask 1–3 `AskUserQuestion`s.
2. Draft the section and ask "like this?"; apply the edits.
3. Section-specific rules:
   - **§4 Scope**: insist on In / Later / Out. Every Out item has a reason; a feature the user places out of scope is recorded under Out with that reason, never dropped.
   - **§6 Non-functional requirements**: propose the studio defaults (CWV, WCAG 2.2 AA, OWASP baseline); the user confirms. §6 always answers localisation, SEO and product analytics explicitly — `n/a — reason` is an answer, silence is not. Analytics events map to the §2 metrics when there are any.

## Phase 3: Review
1. **Mode**: `--review`, else `production/review-mode.txt`, else `lean`.
   - `full`: `technical-director` (feasibility, stack risks) and `security-lead` (data, jurisdiction) in parallel via Task, each with a verdict PASS/CONCERNS/FAIL and reasons.
   - `lean`: `technical-director` only if there are non-trivial NFRs or integrations.
   - `solo`: no review.
2. **CONCERNS/FAIL**: show the findings and propose edits. Never advance the stage automatically.
3. **Re-review the edits.** The edits go back to the same verifier (same contract, a short answer to one question: "do the findings still stand?"). The document's verdict is the verdict of the **last** review, not the first one with a list of fixes claimed against it: a spec rewritten "according to all eight comments" has been checked by nobody. When the user chooses to skip the second review, say so plainly and record the verdict as `FAIL (edits unverified)`.
4. **Open items reach `production/findings.md`.** For every BLOCKING and HIGH item of the verdict, one `AskUserQuestion`: record it in `production/findings.md` (template `findings.md`; id `ARCH-NNN`, severity, area/feature, the decision needed) (Recommended) · story stubs now via `/create-stories` · keep it in the spec only. Write the row only after the "record" answer; that answer is the write consent, so `touch .claude/.write-consent` first (rule 7). A BLOCKING that is neither recorded nor turned into a story is named as such in the verdict line: `/create-stories`, `/sprint-plan` and `/help` read `production/findings.md`, and nobody reads §8 of the spec for open decisions.

## Phase 4: Write
1. Render the draft (or the diff) in the chat.
2. "May I write `docs/specs/product-spec.md`?" — one `AskUserQuestion`: write (Recommended) · show the draft/diff first · not now.
3. After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker), then write.
4. **Stage.** Propose `production/stage.txt` = `specification` **only when the current stage is earlier than `specification` in the catalog**. On a project already in `build`/`operate` the stage is never proposed backwards.

Verdict: `APPROVED` | `NEEDS REVISION`. Next step — one `AskUserQuestion`: `/feature-spec` for the Must features (Recommended) · `/game-concept` (game) · revise the spec.
