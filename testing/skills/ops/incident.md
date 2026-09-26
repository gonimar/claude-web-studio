# Skill Spec: /incident

> **Category**: ops · **Priority**: high · **Spec written**: 2026-09-05

## Summary
Response and blameless postmortem.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path
**Fixture**: S2 500 errors. **Expected**: containment → diagnosis → fix → postmortem.
- [ ] phase order followed · [ ] output matches the expectation · [ ] writes only after consent
### 2. Refusal / BLOCKED
**Fixture**: data leak. **Expected**: security-lead immediately; secret rotation.
- [ ] stops or explicitly flags the limitation · [ ] names the command/reason · [ ] writes no files
### 3. Mode/argument variant
**Fixture**: --sev 1. **Expected**: behaviour differs from case 1 according to the argument.
- [ ] argument parsed · [ ] the difference matches the skill description
### 4. Edge case
**Fixture**: no logs (delegate `logs` → `NOT SUPPORTED`). **Expected**: the diagnosis says "no logs: <reason>" in one line and continues from metrics, deploys and `git log`; hypotheses that needed logs are marked unverified; the postmortem notes it under "What did not work" with a `detect` action; never a diagnosis written as if logs had been read.
- [ ] the case is mentioned in the instructions · [ ] correct message/action · [ ] noted in the postmortem with a detect action
### 5. Gate / protocol
**Fixture**: written with consent. **Expected**: the user decides; stage/statuses never change automatically.
- [ ] no self-advancing · [ ] verdict from the skill's vocabulary

### 6. Postmortem commit gate, then the actions become backlog items
**Fixture**: postmortem with three actions (fix — already the hotfix PR; prevent; detect); HEAD is `hotfix/…`. **Expected**: the "May I write" question names only `docs/ops/incidents/INC-NNN.md` (owners and due dates live in its Actions table; no line is written to `production/roadmap.md` — a roadmap line is `- [ ] [ID](path) · Title` + markers with `🏷` as the layer, and `/create-stories` does not read Backlog lines); after the write, one `docs: postmortem INC-NNN` commit gate, recorded as `Gate "/incident Phase 4: commit?"` through `session-state.sh` before it is asked and cleared to `—` after the answer, stages exactly that file, names the hotfix branch and offers: switch to the default branch (Recommended) · commit here · leave uncommitted; the fix's code is named and left to the hotfix PR. After the commit gate: `/backlog add "<action> 🔗 INC-NNN"` (`/web-studio:backlog add` in plugin mode) through the `Skill` tool, one call per action, one after another, each with `/backlog`'s own write and commit gate — two items here (the fix action links the PR in the Actions table and gets none); the result lists each `I-NNN` next to its action; a project without `production/backlog.md` gets it created by `/backlog`. The skill names its commands as `/web-studio:<name>` in plugin mode and `/<name>` in copy mode.
- [ ] only the postmortem in the write gate, no roadmap line · [ ] commit gate after the write, branch named, gate recorded and cleared · [ ] code never in the docs commit · [ ] one `/backlog add` per action through `Skill`, after the commit gate · [ ] plugin-mode naming line present

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
