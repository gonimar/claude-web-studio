---
name: changelog
description: "Generates or updates CHANGELOG.md from Conventional Commits since the last tag (Keep a Changelog format, SemVer bump proposal). Use before a release."
argument-hint: "[version | --unreleased]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Write, Edit, AskUserQuestion
model: haiku
agent: tech-writer
---

# Changelog

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

**Arguments**: `X.Y.Z` — the version to release: the section `## [X.Y.Z] — YYYY-MM-DD` is drafted from the commits since the last tag **and** from the entries already under `## [Unreleased]` (they move under the new version heading; the `## [Unreleased]` heading stays, empty). `--unreleased` (no version) — only the commits since the last tag are listed under `## [Unreleased]` (created below the title when missing), grouped the same way; no version heading, no bump applied (the bump is still proposed as information), no tag. Entries already there are kept and deduplicated by commit hash. Both at once (`X.Y.Z --unreleased`) → the version wins and `--unreleased` is ignored with a note.

In the commands below, `<hooks>` is `.claude/hooks/` in copy mode and `${CLAUDE_PLUGIN_ROOT}/hooks/` in plugin mode. This skill is also run through the `Skill` tool by `/team-release` and `/hotfix`; its gates are asked here either way.

## Phase 1: Commits
`git describe --tags --abbrev=0` → `git log <tag>..HEAD --pretty=format:'%h %s'`. No tag yet (`git describe` fails) → `git log HEAD --pretty=format:'%h %s'`, the whole history, and say so. Then group by type (feat → Added, fix → Fixed, perf → Changed, `!`/BREAKING → Breaking, security fixes → Security). Non-standard messages go to "Other" with a note. Read the existing `## [Unreleased]` block of `CHANGELOG.md` (if any): with a version its entries join the draft; with `--unreleased` they are merged with the new ones.

## Phase 2: Version
Propose the bump (breaking → major, feat → minor, else patch); the argument's version wins. With `--unreleased` the bump is only shown ("next version would be X.Y.Z") — nothing is versioned.

## Phase 3: Write
1. Draft the `## [X.Y.Z] — YYYY-MM-DD` section (or the `## [Unreleased]` block with `--unreleased`) in Keep a Changelog format and render it in the chat; "May I write `CHANGELOG.md`?" as one `AskUserQuestion`: write (Recommended) · adjust the draft first · not now. No tag is created here. After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker).
2. **Commit gate** (rule 7 (4), `.claude/docs/git-workflow.md` § Documents), recorded before it is asked — `<hooks>session-state.sh set Gate "/changelog Phase 3: commit?"` — and cleared after the answer (`<hooks>session-state.sh set Gate "—"`), so an open gate survives the next turn; one `AskUserQuestion`: `docs: changelog vX.Y.Z` (`docs: changelog unreleased` with `--unreleased`) staging exactly `CHANGELOG.md`, on the branch HEAD decides:
   - **the default branch** (no story work in progress): commit here (a release is tagged there, and `/release-checklist` reads the committed changelog);
   - **a story branch**: name it and offer: switch to the default branch and commit there (Recommended — a pipeline-wide document) · commit here (the entry belongs to this story) · leave uncommitted;
   - **a `hotfix/*` branch** (`/hotfix` Phase 3 runs this skill there): name it and offer: commit here (Recommended — the patch tag `vX.Y.Z` is created on the hotfix branch and must contain this commit; the backport PR carries it to `<default>`) · switch to the default branch and commit there (the tag will not contain the entry — say so) · leave uncommitted.
   Nothing else rides this commit; nothing is committed without the answer.

Verdict: `COMPLETE`. Next step — one `AskUserQuestion`: `/release-checklist X.Y.Z` (Recommended; with `--unreleased`: `/changelog X.Y.Z` when the release is due) · stop here.
