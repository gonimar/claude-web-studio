# Web Studio Testing Framework — instructions for Claude

This folder is the QA layer for the studio's skills/agents. It is not part of any project.

| File | Purpose |
|---|---|
| `catalog.yaml` | Registry of every skill and agent: category/tier, `spec:` (authoritative path), `last_*` fields. Read first in any test mode. |
| `quality-rubric.md` | Metrics per category (`### <category>`) and agent tier (`### agents:<tier>`). |
| `skills/<category>/<name>.md`, `agents/<tier>/<name>.md` | Behavioural specs: 5 cases + protocol. |
| `templates/*.md` | Templates for new specs. |
| `results/` | Output of `/skill-test spec` (gitignored). |

Rules: the spec path comes from the catalog's `spec:`, never guessed; when evaluating an assertion,
quote the skill/agent line; write results only after "May I write?"; never modify skills from a test
mode (use `/skill-improve` for edits).
