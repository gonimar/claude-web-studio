# Skill Spec: /init

> **Category**: onboarding · **Priority**: critical · **Spec written**: 2026-09-05

## Summary
Scaffolds studio files, asks the conversation language and review mode, updates CLAUDE.md, merges settings.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path
**Fixture**: plugin installed, empty project. **Expected**: asks language and review mode; shows the plan; writes after consent; version stamp.
- [ ] phase order followed · [ ] output matches the expectation · [ ] writes only after consent
### 2. Refusal / BLOCKED
**Fixture**: plugin root not found and no --plugin-root. **Expected**: asks for the path.
- [ ] stops or explicitly flags the limitation · [ ] names the command/reason · [ ] writes no files
### 3. Mode/argument variant
**Fixture**: --language English --review solo → no questions. **Expected**: behaviour differs from case 1 according to the argument.
- [ ] argument parsed · [ ] the difference matches the skill description
### 4. Edge case
**Fixture**: CLAUDE.md exists without studio sections → insertion shown, nothing else changed. **Expected**: handled explicitly, never silently skipped.
- [ ] the case is mentioned in the instructions · [ ] correct message/action
### 5. Gate / protocol
**Fixture**: no writes before "May I write?". **Expected**: the user decides; stage/statuses never change automatically.
- [ ] no self-advancing · [ ] verdict from the skill's vocabulary

### 6. Brownfield hand-off
**Fixture**: `composer.json` with sources, `docker-compose.prod.yml`, 40 commits in git. **Expected**: the plan proposes the stage from the facts (`operate`), never writes `discovery` over a running project; the hand-off is one `AskUserQuestion` with `/adopt full` Recommended (`/start` · `/help` · stop as alternatives), not a text line.
- [ ] brownfield detected before the plan · [ ] stage proposed from facts and confirmed · [ ] hand-off is an `AskUserQuestion` with `/adopt full` Recommended

### 7. Bare command, no prose
**Fixture**: `/init` invoked as a bare slash command — no user messages to infer a language from; project README in a non-English language. **Expected**: the language question still offers at least two named options (English plus the README/CLAUDE.md language); a single-option language question is a failure even though the UI adds its own free-text escape.
- [ ] ≥ 2 named options in the language question · [ ] inferred option comes from project/user docs, not a hardcoded default

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
