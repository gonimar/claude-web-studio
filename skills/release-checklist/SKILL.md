---
name: release-checklist
description: "Runs the release gate — verifies stories done, audits (security/deps/harden/perf/a11y) without blocking findings, migration compatibility, changelog, secrets/env, backup; writes production/releases/vX.Y.Z.md with deploy and rollback steps."
argument-hint: "[version]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Write, Task, AskUserQuestion
---

# Release Checklist

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

Template `release-checklist.md`; supply-chain commands from `stack-reference/supply-chain.md` (SC-06, SC-08…SC-10). In the commands below, `<hooks>` is `.claude/hooks/` in copy mode and `${CLAUDE_PLUGIN_ROOT}/hooks/` in plugin mode.

## Phase 1: Evidence
A **first release** is one with no earlier release tag (`git tag --list 'v*'` is empty); two gates below apply only to it.
1. **Stories**: the release stories are Done; check their CI tests (`gh run` if available).
2. **Audits**: the latest `docs/security/security-audit-*`, `docs/security/hardening-checklist.md`, `docs/ops/perf-audit-*` and `docs/ops/a11y-audit-*` reports; run the `/dependency-audit` tools now.
3. **Changelog**: `CHANGELOG.md` contains the version.
4. **Migrations** since the last tag: backward compatibility, checked by `database-engineer` via Task.
5. **Env**: new env variables are documented and present in `.env.example` / the deploy instructions.
6. **Backup and restore**: the backup and the date of the last tested restore. On the first release of a project with a database the restore drill is a gate: no date in `data-model.md` §7 or the runbook → ❌ with the story to run ("Backup & restore drill", `/create-stories` adds it). Later releases show the date and warn when it is older than 90 days.
7. **Observability**: `/healthz` with dependency checks, structured logs, an alert on error rate. On the first release when technical-preferences has a Deploy target this is a gate: missing → ❌ with the story to run ("Observability", `/create-stories` adds it).
8. **Security verdict**: `security-lead` via Task gives the final security verdict.
9. **Supply-chain artefacts** of the release image (the digest from the release workflow summary or `docker buildx imagetools inspect <image>:vX.Y.Z`). Scope first: no release image (a static site, a library) → the three items read `n/a`; technical-preferences without a Supply chain block, or a field recorded as `none — <reason>` → one ⚠ line per artefact with the reason, never a gate; only an artefact the block promises can be ❌:
   - **SBOM attached to the release** (SC-06): `gh release view vX.Y.Z --json assets -q '.assets[].name'` lists `sbom.cdx.json` (or the SPDX file); ❌ when `sbom_tool` is not `none` and the release has no SBOM asset.
   - **Image signed and verified by digest** (SC-08, SC-09): `bash .claude/docs/templates/supply-chain/verify-image.sh <image>@sha256:<digest> <owner>/<repo>` (or the equivalent `cosign verify … --certificate-oidc-issuer https://token.actions.githubusercontent.com --certificate-identity-regexp <release workflow>`); the output is the evidence, ❌ on a failed verify or an image signed only by tag.
   - **Provenance attestation present** (SC-10): `gh attestation verify oci://<image>:vX.Y.Z -R <owner>/<repo>`; ❌ when missing, unless technical-preferences (Supply chain) records `provenance: none — <reason>` (a plan without attestations), then ⚠ with the reason.
   Nothing configured at all (no block, or every field `none`) → one ⚠ line "supply chain: not configured — `/harden supply-chain`", not a gate; configured but failing → ❌ (a broken promise is worse than none).

## Phase 2: Checklist
Every item ✅/❌ with a link to evidence. Any ❌ in the gates → `NOT READY`. The verdict is written into the release file as its `Verdict:` line (template): `Verdict: READY` or `Verdict: NOT READY (<the ❌ items>)` — `/deploy` Phase 1 reads that line, so the file's presence alone never proves readiness (`/hotfix` writes `Verdict: READY (hotfix)` for a patch release).

## Phase 3: Write and tag
**The release file is written on `READY` and on `NOT READY` alike.** The checklist with its ❌ gates is the record of what blocks the release — the next run of `/release-checklist vX.Y.Z` re-checks the evidence and updates the file in place; only the tag is withheld on `NOT READY`. Steps 1–2 therefore run for both verdicts; step 3 only on `READY`.
1. Show the checklist in the chat, then ask "May I write `production/releases/vX.Y.Z.md` (with deploy/rollback steps)?" — one `AskUserQuestion`: write (Recommended) · show the draft/diff first · not now. On `NOT READY` the question says so ("NOT READY — the checklist is written with its ❌ gates, no tag"). After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker). The written file carries the `Verdict:` line of Phase 2; a **re-run** (the file already exists from an earlier `NOT READY`) updates it in place, `Verdict:` included.
2. **Commit gate** (rule 7 (4), documents lane), recorded before it is asked — `<hooks>session-state.sh set Gate "/release-checklist Phase 3: commit?"` — and cleared after the answer (`<hooks>session-state.sh set Gate "—"`), so an open gate survives the next turn; one `AskUserQuestion`: commit `docs: release vX.Y.Z` on `<default>` and push (Recommended) · commit on the current branch · leave uncommitted. On a re-run the subject is `docs: release vX.Y.Z (re-check)` — the plain subject is already in the history. On the first option: `git switch <default> && git pull --ff-only origin <default>` (the new file travels with the switch), `git add production/releases/vX.Y.Z.md`, `git commit -m "docs: release vX.Y.Z"` (or `… (re-check)`), `git push`. The tag must contain the release document, so this commit comes before the tag.
3. **Tag**, only on `READY` (on `NOT READY` this step is skipped and the verdict names the ❌ items to fix), only after the step 2 commit is on `<default>`, and as its own `AskUserQuestion` (recorded as `Gate "/release-checklist Phase 3: tag?"` and cleared after the answer, as the commit gate above): tag and push now (Recommended) · not now. Releases are tags on the default branch, never on a story branch (git-workflow): `git tag -a vX.Y.Z -m "Release vX.Y.Z"`, then `git push origin vX.Y.Z` — `/deploy` checks CI on the tag, which runs only once the tag is on origin. Without `-m`, `git tag -a` opens an editor the session cannot use. The release document left uncommitted or on another branch → no tag; say why.

Verdict: `READY` | `NOT READY (…)`. Next step — one `AskUserQuestion`: `/deploy vX.Y.Z` (Recommended on `READY`) · fix the NOT READY items, then re-run `/release-checklist vX.Y.Z` (Recommended on `NOT READY`) · stop here.
