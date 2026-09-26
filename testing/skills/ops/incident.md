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

### 6. Actions reach the roadmap, then the commit gate
**Fixture**: postmortem with three actions (fix/prevent/detect); HEAD is `hotfix/…`. **Expected**: one "May I write" question names both `docs/ops/incidents/INC-NNN.md` and the `🏷 incident INC-NNN` lines in `production/roadmap.md`; after the write, one `docs: postmortem INC-NNN` commit gate names the hotfix branch and offers: switch to the default branch (Recommended) · commit here · leave uncommitted; the fix's code is named and left to the hotfix PR; a project without `production/roadmap.md` keeps the actions in the postmortem table and says so.
- [ ] roadmap file named in the gate · [ ] commit gate after the write, branch named · [ ] code never in the docs commit

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
