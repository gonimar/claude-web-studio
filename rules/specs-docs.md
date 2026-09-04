---
paths: ["docs/specs/**", "docs/architecture/**", "docs/security/**", "production/stories/**"]
---
# Document rules
- Specifications follow the templates in `.claude/docs/templates/`; mandatory sections are filled or marked "n/a — reason".
- Feature spec: scenarios, rules, edge cases *with concrete behaviour*, Given/When/Then acceptance criteria, security and accessibility requirements.
- ADR: Status, Context, Options (≥ 2), Decision, Consequences, Verification; links to affected feature specs.
- Story: ID, links to the feature spec and ADR, acceptance criteria, test plan, size.
- Absolute dates (2026-09-05), never "next week". Prose in the project's conversation language, identifiers in English.
