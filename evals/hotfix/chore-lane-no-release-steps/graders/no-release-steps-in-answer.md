---
type: regex
pattern: "READY \\(hotfix\\)|docs: release v|DEPLOYED v"
target: last_message
match: not_contains
---
