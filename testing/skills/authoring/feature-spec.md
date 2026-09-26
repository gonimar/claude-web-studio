# Skill Spec: /feature-spec

> **Category**: authoring · **Priority**: critical · **Spec written**: 2026-09-05

## Summary
Feature spec: scenarios, rules, data, contract, states, edge cases, security, a11y, criteria.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path
**Fixture**: F-002 "cart", GraphQL. **Expected**: section 5 as SDL sketches; Given/When/Then criteria; security-lead for payments.
- [ ] phase order followed · [ ] output matches the expectation · [ ] writes only after consent
### 2. Refusal / BLOCKED
**Fixture**: no product spec. **Expected**: stops with the command.
- [ ] stops or explicitly flags the limitation · [ ] names the command/reason · [ ] writes no files
### 3. Mode/argument variant
**Fixture**: REST project → endpoints. **Expected**: behaviour differs from case 1 according to the argument.
- [ ] argument parsed · [ ] the difference matches the skill description
### 4. Edge case
**Fixture**: feature not in scope → asks whether to add. **Expected**: handled explicitly, never silently skipped.
- [ ] the case is mentioned in the instructions · [ ] correct message/action
### 5. Gate / protocol
**Fixture**: review per mode. **Expected**: the user decides; stage/statuses never change automatically.
- [ ] no self-advancing · [ ] verdict from the skill's vocabulary

### 6. Events, copy keys and SEO in section 6
**Fixture**: a public article page on a localised content site. **Expected**: section 6 lists the product events (name · trigger · properties), the copy keys, and the SEO requirements (title/meta, structured data, canonical) that `seo-specialist` checks in `/dev-story`.
- [ ] events listed · [ ] copy keys · [ ] SEO requirements

### Sections 10 and 12 are drafted by name
**Fixture**: a feature that calls an external payment provider and leaves one pricing rule undecided. **Expected**: section 10 lists the provider and the packages with how each one's health is checked; section 12 lists the undecided rule with who answers it and by when, named next to the criterion it blocks; neither section is left as a template stub.
- [ ] §10 dependencies with health checks · [ ] §12 open questions with owner and date · [ ] "none" written explicitly when empty

### Commit gate on the documents lane
**Fixture**: F-012 (and the product spec feature index) is written while HEAD is `feat/S-001-…` (a story branch). **Expected**: right after the write one commit gate offers `docs: feature spec F-012` staging exactly the written files (the spec and the product spec's index, nothing else); the current branch is named and the question offers the three options — switch to the default branch and commit there (Recommended) · commit here · leave uncommitted; nothing is committed without the answer.
- [ ] commit gate follows the write · [ ] only the written files staged · [ ] three options, default branch Recommended · [ ] nothing committed without the answer

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
