# Skill Spec: /data-model

> **Category**: authoring · **Priority**: high · **Spec written**: 2026-09-05

## Summary
ER, DDL with justified indexes, expand/contract migrations, PII, backups.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path
**Fixture**: F-002. **Expected**: query table → indexes; EXPLAIN with a DB.
- [ ] phase order followed · [ ] output matches the expectation · [ ] writes only after consent
### 2. Refusal / BLOCKED
**Fixture**: no feature spec. **Expected**: stops.
- [ ] stops or explicitly flags the limitation · [ ] names the command/reason · [ ] writes no files
### 3. Mode/argument variant
**Fixture**: full → the whole schema. **Expected**: behaviour differs from case 1 according to the argument.
- [ ] argument parsed · [ ] the difference matches the skill description
### 4. Edge case
**Fixture**: change to an existing table → expand/contract. **Expected**: handled explicitly, never silently skipped.
- [ ] the case is mentioned in the instructions · [ ] correct message/action
### 5. Gate / protocol
**Fixture**: written after consent. **Expected**: the user decides; stage/statuses never change automatically.
- [ ] no self-advancing · [ ] verdict from the skill's vocabulary

### 6. Retention and deletion per PII field
**Fixture**: feature stores e-mail, IP address and payment reference. **Expected**: §6 table lists each field with class, retention (what ends it), deletion method for table, backups and logs; the missing deletion path becomes the "Data deletion" story proposal; export on request described.
- [ ] every PII field in the table · [ ] retention and method · [ ] deletion story proposed

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
