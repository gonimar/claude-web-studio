---
name: changelog
description: "Generates or updates CHANGELOG.md from Conventional Commits since the last tag (Keep a Changelog format, SemVer bump proposal). Use before a release."
argument-hint: "[version | --unreleased]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Write, Edit
model: haiku
agent: tech-writer
---

# Changelog

## Phase 1: Commits
`git describe --tags --abbrev=0` → `git log <tag>..HEAD --pretty=format:'%h %s'`; group by type (feat → Added, fix → Fixed, perf → Changed, `!`/BREAKING → Breaking, security fixes → Security). Non-standard messages go to "Other" with a note.

## Phase 2: Version
Propose the bump (breaking → major, feat → minor, else patch); the argument's version wins.

## Phase 3: Write
Draft the `## [X.Y.Z] — YYYY-MM-DD` section in Keep a Changelog format; "May I write `CHANGELOG.md`?" No tag is created here.

Verdict: `COMPLETE`. Next step: `/release-checklist X.Y.Z`.
