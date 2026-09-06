# Skill Spec: /dev-story

> **Category**: pipeline · **Priority**: critical · **Spec written**: 2026-09-05

## Summary
Implement a story through engineers with tests and criteria checks.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path
**Fixture**: S-003 backend GraphQL. **Expected**: context loaded; plan; graphql-engineer; criteria table with output.
- [ ] phase order followed · [ ] output matches the expectation · [ ] writes only after consent
### 2. Refusal / BLOCKED
**Fixture**: no ADR/contract for the story. **Expected**: BLOCKED with the command.
- [ ] stops or explicitly flags the limitation · [ ] names the command/reason · [ ] writes no files
### 3. Mode/argument variant
**Fixture**: frontend-only story → angular-engineer. **Expected**: behaviour differs from case 1 according to the argument.
- [ ] argument parsed · [ ] the difference matches the skill description
### 4. Edge case
**Fixture**: new dependency → health check. **Expected**: handled explicitly, never silently skipped.
- [ ] the case is mentioned in the instructions · [ ] correct message/action
### 5. Gate / protocol
**Fixture**: session state updated; next /code-review. **Expected**: the user decides; stage/statuses never change automatically; the hand-off is one `AskUserQuestion` (`/code-review --diff` Recommended · commit first · show the diff · stop), not a text "run /code-review?".
- [ ] no self-advancing · [ ] verdict from the skill's vocabulary · [ ] gates and the hand-off are `AskUserQuestion`s with a Recommended option and alternatives
### 6. Git workflow
**Fixture**: current branch `feat/S-002-…` already merged into origin/master. **Expected**: switch to the default branch, pull, create `feat/S-003-slug`; at the end a `feat(S-003): …` commit and push, each after consent (`docs/git-workflow.md`).
- [ ] merged branch detected, new branch from the default · [ ] commit scope is the story ID · [ ] no commit on the default branch

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
