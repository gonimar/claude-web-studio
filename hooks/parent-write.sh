#!/bin/bash
# PreToolUse(Write|Edit): warn-only observer for product code written by the session itself.
# The rule "the parent does not write product code" (coordination-rules § Subagents) had no observer:
# on a real project the session drifted into "faster to fix it myself" from the third review round and
# only the user noticed. This hook names the file, the engineer the roster has for it, and leaves a
# `ParentWrite` line in production/session-logs/agent-audit.log, which /sprint-status counts (WS-124).
# A subagent's transcript lives under <session>/subagents/ — its writes are the engineers' work and pass.
INPUT=$(cat)
jget() {
  if command -v jq >/dev/null 2>&1; then echo "$INPUT" | jq -r "$1 // empty" 2>/dev/null; return; fi
  key="${1##*.}"; echo "$INPUT" | grep -oE "\"$key\"[[:space:]]*:[[:space:]]*\"([^\"\\\\]|\\\\.)*\"" | head -1 | sed -E "s/^\"$key\"[[:space:]]*:[[:space:]]*\"//;s/\"$//"
}
# warn <PreToolUse|PostToolUse> <message>: a warning as JSON on stdout — additionalContext reaches the model,
# systemMessage the user; exit 0 keeps the tool allowed. stderr with exit 0 reaches neither (WS-050).
warn() {
  local m; m=$(printf '%s' "$2" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/\t/  /g' | awk 'NR>1{printf "\\n"} {printf "%s", $0}')
  printf '{"hookSpecificOutput":{"hookEventName":"%s","additionalContext":"%s"},"systemMessage":"%s"}\n' "$1" "$m" "$m"
}
TP=$(jget .transcript_path)
[ -z "$TP" ] && exit 0                       # cannot tell parent from subagent: stay silent
case "$TP" in */subagents/*) exit 0;; esac    # an engineer at work
[ -n "$(jget .agent_id)" ] && exit 0
FP=$(jget .tool_input.file_path); [ -z "$FP" ] && exit 0
case "$FP" in */.claude/*|.claude/*|*/docs/*|docs/*|*/tools/spike-*|tools/spike-*|*/production/*|production/*) exit 0;; esac
EXT="${FP##*.}"; [ "$EXT" = "$FP" ] && exit 0
case "$EXT" in
  go) ENG=go-engineer;; php) ENG=php-engineer;; vue) ENG=vue-engineer;;
  ts|tsx|js|jsx|mjs|cjs) ENG="typescript-engineer / angular-engineer / node-engineer";;
  sql) ENG=database-engineer;; graphql|graphqls) ENG=graphql-engineer;; css|scss) ENG=css-engineer;;
  *) exit 0;;
esac
cd "${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}" 2>/dev/null || exit 0
mkdir -p production/session-logs 2>/dev/null
echo "$(date '+%F %T') | ParentWrite | $FP | sid=$(jget .session_id) tool=$(jget .tool_name)" >> production/session-logs/agent-audit.log 2>/dev/null
warn PreToolUse "PARENT-WRITE: $FP is product code written by the session itself — the roster names $ENG for .$EXT. Brief and dispatch the engineer (dev-story Phase 4), resume a cut-off one from its Checkpoint:; a deliberate exception is declared in the result as 'written by the parent: <why>' (coordination-rules § Subagents)."
exit 0
