#!/bin/bash
# PreToolUse(Write|Edit): warn-only impact sentinel for architecture/security surfaces.
# A change proposal that touches an ADR-covered decision or a security surface is classified
# by /impact (coordination-rules rule 11); /impact and /dev-story (at story start) touch
# .claude/.impact-verdict. A Write/Edit to such a path without a fresh marker gets a warning —
# a nudge to classify first, never a block. Documents are consent-guard's business, not this hook's.
INPUT=$(cat)
jget() {
  if command -v jq >/dev/null 2>&1; then echo "$INPUT" | jq -r "$1 // empty" 2>/dev/null; return; fi
  key="${1##*.}"; echo "$INPUT" | grep -oE "\"$key\"[[:space:]]*:[[:space:]]*\"([^\"\\\\]|\\\\.)*\"" | head -1 | sed -E "s/^\"$key\"[[:space:]]*:[[:space:]]*\"//;s/\"$//"
}
FP=$(jget .tool_input.file_path)
# warn <PreToolUse|PostToolUse> <message>: a warning as JSON on stdout — additionalContext reaches the model,
# systemMessage the user; exit 0 keeps the tool allowed. stderr with exit 0 reaches neither (WS-050).
warn() {
  local m; m=$(printf '%s' "$2" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/\t/  /g' | awk 'NR>1{printf "\\n"} {printf "%s", $0}')
  printf '{"hookSpecificOutput":{"hookEventName":"%s","additionalContext":"%s"},"systemMessage":"%s"}\n' "$1" "$m" "$m"
}
case "$FP" in
  */docs/*|docs/*|*/production/*|production/*|*/.claude/*|.claude/*|*/node_modules/*|*/vendor/*) exit 0;;
esac
case "$FP" in
  */auth/*|*/security/*|*/middleware/*|*/nginx/*|*/Caddyfile|*.conf|*/payments/*|*/upload*/*|*/webhook*/*) ;;   # rules/security-sensitive.md globs
  */migrations/*|*/.github/workflows/*|.github/workflows/*|*/Dockerfile*|Dockerfile*|*compose*.yml|*compose*.yaml) ;;
  */go.mod|go.mod|*/package.json|package.json|*/composer.json|composer.json|*/schema.graphql|schema.graphql|*/openapi.yaml|openapi.yaml|*/openapi.json|openapi.json) ;;
  *) exit 0;;
esac
cd "${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}" 2>/dev/null || exit 0
M=.claude/.impact-verdict
if [ -f "$M" ]; then
  age=$(( $(date +%s) - $(stat -c %Y "$M" 2>/dev/null || echo 0) ))
  [ "$age" -le 14400 ] && exit 0
fi
warn PreToolUse "IMPACT: $FP is an architecture/security surface and no fresh impact verdict exists — was the change classified (/impact) or is it inside an approved story (/dev-story sets the marker at story start)? Warn-only, coordination-rules rule 11."
exit 0
