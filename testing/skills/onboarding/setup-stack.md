# Skill Spec: /setup-stack

> **Category**: onboarding · **Priority**: critical · **Spec written**: 2026-09-05

## Summary
Choose and pin the stack with versions from the reference; write technical-preferences.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path
**Fixture**: type fullstack, Go + Angular + GraphQL. **Expected**: technical-preferences without TO BE CONFIGURED, versions = index.md, GraphQL by default, `go_layout: project-layout` proposed with a directory tree.
- [ ] phase order followed · [ ] output matches the expectation · [ ] writes only after consent
### 2. Refusal / BLOCKED
**Fixture**: reference older than 60 days. **Expected**: suggests /stack-update first (not blocking).
- [ ] stops or explicitly flags the limitation · [ ] names the command/reason · [ ] writes no files
### 3. Mode/argument variant
**Fixture**: --quick → recommendations without questions. **Expected**: behaviour differs from case 1 according to the argument.
- [ ] argument parsed · [ ] the difference matches the skill description
### 4. Edge case
**Fixture**: node missing on the system → BLOCKED tools reported. **Expected**: handled explicitly, never silently skipped.
- [ ] the case is mentioned in the instructions · [ ] correct message/action
### 5. Gate / protocol
**Fixture**: ADRs proposed for forks; stage changes with consent. **Expected**: the user decides; stage/statuses never change automatically.
- [ ] no self-advancing · [ ] verdict from the skill's vocabulary

### 6. Deploy target
**Fixture**: single VPS, no kit. **Expected**: one `AskUserQuestion` for the target with `compose-ssh` recommended; `templates/deploy/compose-ssh.sh` copied to `scripts/deploy/`, `docs/deploy/compose-ssh.md` created, `Deploy target`/`Deploy delegate` written; shared host → `Infra repo`/`Proxy config` asked.
- [ ] question with options · [ ] script copied · [ ] fields written

### 7. Decision log and the spec-aware hand-off
**Fixture**: `docs/specs/product-spec.md` exists, no feature specs; stack chosen. **Expected**: the write gate names both `technical-preferences.md` and the `D-NN` line in `production/decisions.md` (a decided entry pointing at the preferences, not a copy of them); the closing question recommends `/feature-spec`, never `/product-spec` over the existing spec (`/create-stories` Recommended instead when `docs/specs/features/*.md` exist; `/product-spec` Recommended only when no spec exists).
- [ ] decisions.md named as the log's file · [ ] D-NN entry gated with the write · [ ] recommendation follows the spec's existence

### 8. Documents lane (commit after write)
**Fixture**: `compose-ssh` chosen; `technical-preferences.md`, `production/decisions.md`, `production/stage.txt`, `docs/deploy/compose-ssh.md` and `scripts/deploy/compose-ssh.sh` written, HEAD is `feat/S-002-…`. **Expected**: right after the write one commit gate offers `docs: stack decision` staging exactly the four documents, names the branch and asks where it belongs (switch to the default branch Recommended · commit here · leave uncommitted); the script is named for the chore lane, never staged in the `docs:` commit; nothing is committed without the answer.
- [ ] commit gate follows the write · [ ] exact documents staged · [ ] script kept out of the docs commit

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
