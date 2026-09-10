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

Template: `.claude/docs/templates/product-spec.md`. Section by section: questions → section draft → edits → next.
The file is written once at the end (or per section, the user's choice), always after "May I write?".

## Phase 1: Context
Read `docs/specs/concept-brief.md` (if any), `technical-preferences.md`, `production/roadmap.md`.
If the stack is not configured — suggest `/setup-stack` before or after (not blocking).

## Phase 2: Sections 1–10
Per section: 1–3 `AskUserQuestion`s → draft → "like this?". Non-functional requirements get the studio defaults
(CWV, WCAG 2.2 AA, OWASP baseline) — the user confirms. Scope: insist on In/Later/Out; every Out item has a reason.

## Phase 3: Review
Mode (`--review` or `production/review-mode.txt`, default `lean`):
- `full`: `technical-director` (feasibility, stack risks) and `security-lead` (data, jurisdiction) in parallel via Task, verdict PASS/CONCERNS/FAIL with reasons.
- `lean`: `technical-director` only if there are non-trivial NFRs/integrations.
- `solo`: no review.
CONCERNS/FAIL — show, propose edits, never advance the stage automatically.
Then, for every BLOCKING and HIGH item of the verdict, one `AskUserQuestion`: record it in `production/findings.md`
(template `findings.md`; id `ARCH-NNN`, severity, area/feature, the decision needed) (Recommended) · story stubs now
via `/create-stories` · keep it in the spec only. A BLOCKING that is neither recorded nor turned into a story is
named as such in the verdict line — it must not silently stay in the document (`/create-stories`, `/sprint-plan`
and `/help` read `production/findings.md`, nobody reads §8 of the spec for open decisions).

## Phase 4: Write
"May I write `docs/specs/product-spec.md`?" — one `AskUserQuestion`: write (Recommended) · show the draft/diff first · not now; propose `production/stage.txt` = `specification` **only when the current stage is earlier than `specification` in the catalog** — on a project already in `build`/`operate` the stage is never proposed backwards. After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker).

**Retrofit mode** (stage `build` or later, code and deployment exist): the spec documents what runs, not what is planned — sources are `CLAUDE.md`, the roadmap, the deployed configuration and the code; one pass with the draft shown as a whole, questions only where the facts are silent (goals, audience, out-of-scope), and the review verifies claims against the repository (a claimed fact the repository contradicts is BLOCKING).

Verdict: `APPROVED` | `NEEDS REVISION`. Next step — one `AskUserQuestion`: `/feature-spec` for the Must features (Recommended) · `/game-concept` (game) · revise the spec.
