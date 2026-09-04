# Skill Spec: /[skill-name]

> **Category**: [onboarding | authoring | review | pipeline | sprint | analysis | team | ops]
> **Priority**: [critical | high | medium | low]
> **Spec written**: YYYY-MM-DD

## Summary
[What the skill does, inputs, outputs, agents involved.]

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases; a verdict word; "May I write?" with Write/Edit; a next step; a reference/template link

## Cases
### 1. Happy path — [name]
**Fixture**: [project state] · **Expected**: [steps] · **Assertions**: [ ] … [ ] …
### 2. Refusal / BLOCKED — [name]
**Fixture**: [what is missing] · **Expected**: stops with a message naming what to run · **Assertions**: [ ] writes no files [ ] names the command
### 3. Mode/argument variant — [name]
### 4. Edge case — [name]
### 5. Gate / review / escalation — [name]

## Protocol
- [ ] "May I write?" before writes · [ ] draft before approval · [ ] next step · [ ] never advances the stage itself

## Coverage notes
