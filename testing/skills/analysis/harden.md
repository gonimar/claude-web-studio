# Skill Spec: /harden

> **Category**: analysis · **Priority**: critical · **Spec written**: 2026-09-05

## Summary
Headers/TLS/proxy/Docker/CI with live verification.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path
**Fixture**: Caddy + compose. **Expected**: checklist with commands; curl before/after.
- [ ] phase order followed · [ ] output matches the expectation · [ ] writes only after consent
### 2. Refusal / BLOCKED
**Fixture**: no URL access. **Expected**: static config analysis with a note.
- [ ] stops or explicitly flags the limitation · [ ] names the command/reason · [ ] writes no files
### 3. Mode/argument variant
**Fixture**: --apply → edits after consent. **Expected**: behaviour differs from case 1 according to the argument.
- [ ] argument parsed · [ ] the difference matches the skill description
### 4. Edge case
**Fixture**: Angular CSP nonce considered. **Expected**: handled explicitly, never silently skipped.
- [ ] the case is mentioned in the instructions · [ ] correct message/action
### 5. Gate / protocol
**Fixture**: hardening checklist with consent. **Expected**: the user decides; stage/statuses never change automatically.
- [ ] no self-advancing · [ ] verdict from the skill's vocabulary

### 6. Proxy in another repository
**Fixture A**: `Infra repo` and `Proxy config` set → diffs proposed there with "May I write?", live `curl -I` before/after. **Fixture B**: not set and no proxy config here → the limitation is stated, snippet for the owner, live check only.
- [ ] infra repo edited only with consent · [ ] live headers are the evidence · [ ] missing field named

### 7. `secrets` rotation checklist
**Fixture**: `/harden secrets` after `/incident` on a leaked registry token; deploy contract lists four secrets; one workflow uses `secrets.GHCR_TOKEN`. **Expected**: an inventory table (secret → where it lives → who reads it → rotation steps → last rotation), the rotation order, verification per secret (gitleaks / history search by pattern, `docker history`, CI permissions); no secret value ever appears in a command or the chat; written into `hardening-checklist.md` § Secrets behind the write gate.
- [ ] inventory without values · [ ] order and verification · [ ] write gate

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
