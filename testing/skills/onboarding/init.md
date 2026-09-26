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

### 8. Chosen language binds immediately
**Fixture**: the user answers the Phase 2 question with a non-English language (option or reply text). **Expected**: every subsequent /init output — the stage question, the write plan, "May I write?", the hand-off — is in that language, even though CLAUDE.md is not written yet; a later skill in the same session must not inherit an English tone from /init.
- [ ] first post-answer question already in the chosen language · [ ] write plan and hand-off in the chosen language

- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)

### 9. Repeated /init on a deployed project
**Fixture**: studio already initialised, `.claude/.web-studio-version` older than the plugin, `technical-preferences.md` filled. **Expected**: verdict `ALREADY INITIALISED (N files differ)` and the hand-off recommends `/update` (or `/adopt full` when preferences are a placeholder), never "do nothing".
- [ ] verdict names the differing files · [ ] recommended option follows the facts · [ ] no code written

### 10. Two facts, one Recommended
**Fixture**: `.claude/.web-studio-version` older than the plugin **and** `technical-preferences.md` still `[TO BE CONFIGURED]` on a project with code; the studio block already in `CLAUDE.md`. **Expected**: verdict `ALREADY INITIALISED (…)` (the block was present before the run — `INITIALISED` only when neither the block nor a seeded `.claude/docs/` existed); the closing question marks exactly one option Recommended, `/update` (version drift comes first), with `/adopt full` as the second option noted "after /update"; never two Recommended options.
- [ ] verdict word chosen by the pre-run state · [ ] `/update` Recommended over `/adopt full` · [ ] one Recommended only

### 11. Documents lane (commit after write)
**Fixture**: `INITIALISED`; `CLAUDE.md`, `.claude/docs/`, `.claude/rules/`, `production/stage.txt`, `production/review-mode.txt`, `.claude/.web-studio-version`, `.claude/settings.json`, `.claude/statusline.sh` and `.gitignore` lines written; HEAD is `feat/S-003-…`. **Expected**: right after the write one commit gate offers `docs: initialise web studio` staging exactly the documents (the empty seeded `docs/*` and `production/*` folders are not listed — git stages no empty folder), names the branch and asks where it belongs (switch to the default branch Recommended · commit here · leave uncommitted); `Gate: /init Phase 5: commit?` is recorded in session-state before the question and cleared after the answer; `settings.json`, `statusline.sh` and `.gitignore` are named for the chore lane and never staged in the `docs:` commit; nothing is committed without the answer; `ALREADY INITIALISED` with nothing written has no commit gate.
- [ ] commit gate follows the write · [ ] exact documents staged, no empty folders · [ ] settings/statusline/.gitignore kept out · [ ] gate recorded and cleared · [ ] no gate when nothing was written
