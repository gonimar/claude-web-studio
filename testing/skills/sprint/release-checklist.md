# Skill Spec: /release-checklist

> **Category**: sprint · **Priority**: critical · **Spec written**: 2026-09-05

## Summary
Release gate from evidence.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path
**Fixture**: audits clean. **Expected**: READY; release file with rollback and the line `Verdict: READY` (the template's line, which `/deploy` reads).
- [ ] phase order followed · [ ] output matches the expectation · [ ] writes only after consent
### 2. Refusal / BLOCKED
**Fixture**: security-audit FAIL. **Expected**: `NOT READY (security-audit FAIL)`; the checklist with its ❌ gate is still offered for writing to `production/releases/vX.Y.Z.md` — with the line `Verdict: NOT READY (security-audit FAIL)`, so `/deploy` blocks on the file — and for the `docs: release vX.Y.Z` commit, each after consent; the tag step is skipped and the reason named; the next step recommends fixing the items and re-running the checklist, not `/deploy`.
- [ ] stops or explicitly flags the limitation · [ ] names the command/reason · [ ] the release file only after consent, no tag · [ ] `Verdict: NOT READY (…)` in the file
### 3. Mode/argument variant
**Fixture**: migrations present → database-engineer. **Expected**: behaviour differs from case 1 according to the argument.
- [ ] argument parsed · [ ] the difference matches the skill description
### 4. Edge case
**Fixture**: new env variable undocumented → ❌. **Expected**: handled explicitly, never silently skipped.
- [ ] the case is mentioned in the instructions · [ ] correct message/action
### 5. Gate / protocol
**Fixture**: tag with consent. **Expected**: the user decides; stage/statuses never change automatically.
- [ ] no self-advancing · [ ] verdict from the skill's vocabulary

### 6. First release: restore drill and observability gates
**Fixture**: first tag of a project with a database; `data-model.md` §7 has no restore date; no `/healthz`. **Expected**: `NOT READY` with two ❌ gates naming the stories ("Backup & restore drill", "Observability"); on a later release the restore date is shown and a >90-day date is a warning, not a gate.
- [ ] gates on the first release · [ ] warning only later · [ ] stories named

### The tag contains the release document (0.13)
**Fixture**: READY, `production/releases/v1.2.0.md` written on a story branch. **Expected**: a `docs: release v1.2.0` commit gate on the default branch comes before the tag question; the tag is created with `-m` on the default branch after that commit and pushed (`git push origin v1.2.0`); a release document left uncommitted → no tag, with the reason.
- [ ] commit before tag · [ ] tag on the default branch with -m, pushed · [ ] no tag without the committed document · [ ] `Gate "/release-checklist Phase 3: commit?"` (and `… tag?`) recorded through `session-state.sh` before each question and cleared to `—` after the answer

### Re-run after `NOT READY`
**Fixture**: `production/releases/v1.2.0.md` exists from an earlier run with `Verdict: NOT READY (security-audit FAIL)` committed as `docs: release v1.2.0`; the audit is now clean. **Expected**: the file is updated in place, `Verdict: READY`; the commit gate offers the subject `docs: release v1.2.0 (re-check)` (the plain subject is already in the history); the tag follows that commit on `<default>`.
- [ ] file updated in place with the new verdict · [ ] `(re-check)` subject · [ ] tag after the re-check commit

### Supply-chain artefacts of the release image
**Fixture A**: technical-preferences Supply chain has `signing: cosign keyless`, `provenance: actions/attest`; the release `v1.3.0` carries `sbom.cdx.json` as an asset, `verify-image.sh <image>@sha256:… <owner>/<repo>` passes, `gh attestation verify oci://<image>:v1.3.0 -R <owner>/<repo>` passes. **Expected**: three ✅ items ("SBOM attached to the release", "image signed and verified by digest", "provenance attestation present") each with the command output as evidence, in the release file (template items SC-06, SC-08/SC-09, SC-10). **Fixture B**: same preferences, but the release has no SBOM asset and `cosign verify` fails. **Expected**: `NOT READY (SBOM missing, image signature not verified)` — configured-but-failing is a gate. **Fixture C**: `signing: none`, `provenance: none — private repo without Enterprise Cloud`. **Expected**: one ⚠ line pointing at `/harden supply-chain` and the recorded reason; not a gate.
- [ ] commands run, output quoted · [ ] configured-but-failing → ❌ gate · [ ] not configured → ⚠, never a silent skip · [ ] the three template items filled
## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
