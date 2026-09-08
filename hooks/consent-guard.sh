#!/bin/bash
# PreToolUse(Write|Edit): warn-only consent sentinel for pipeline documents.
# The write gate (coordination-rules rule 7) ends with the user's "write" answer; the skill
# then touches .claude/.write-consent (Bash). A Write/Edit to a protected document without a
# fresh marker gets a warning — a nudge against write-then-ask, never a block.
INPUT=$(cat)
jget() {
  if command -v jq >/dev/null 2>&1; then echo "$INPUT" | jq -r "$1 // empty" 2>/dev/null; return; fi
  key="${1##*.}"; echo "$INPUT" | grep -oE "\"$key\"[[:space:]]*:[[:space:]]*\"([^\"\\\\]|\\\\.)*\"" | head -1 | sed -E "s/^\"$key\"[[:space:]]*:[[:space:]]*\"//;s/\"$//"
}
FP=$(jget .tool_input.file_path)
case "$FP" in
  */docs/architecture/*|docs/architecture/*|*/docs/specs/*|docs/specs/*|*/technical-preferences.md|technical-preferences.md|*/production/sprints/*|production/sprints/*|*/production/stories/*|production/stories/*) ;;
  *) exit 0;;
esac
cd "${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}" 2>/dev/null || exit 0
M=.claude/.write-consent
if [ -f "$M" ]; then
  age=$(( $(date +%s) - $(stat -c %Y "$M" 2>/dev/null || echo 0) ))
  [ "$age" -le 600 ] && exit 0
fi
echo "CONSENT: writing a pipeline document ($FP) without a fresh consent marker — did the \"May I write?\" answer happen? After the answer, run: touch .claude/.write-consent (rule 7)." >&2
exit 0
