#!/bin/bash
# PostToolUse(Write|Edit): after a dependency manifest changes, dry-run the resolver so
# invented versions and conflicts surface immediately (WS: coordinator-invented versions).
# Warn-only: findings go to the model as JSON additionalContext; never blocks (resolvers may be offline).
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
  */composer.json|composer.json)
    command -v composer >/dev/null 2>&1 || exit 0
    cd "$(dirname "$FP")" || exit 0
    OUT=$(composer update --dry-run --no-interaction --no-plugins --no-scripts 2>&1 | tail -15)
    echo "$OUT" | grep -qiE "could not be found|does not exist|conflicts|problem" && {
      warn PostToolUse "DEPS: composer dry-run flags problems in $FP — a version may be invented or incompatible:
$(echo "$OUT" | grep -iE "could not be found|does not exist|conflict|problem" | head -5)"; }
    ;;
  */go.mod|go.mod)
    command -v go >/dev/null 2>&1 || exit 0
    cd "$(dirname "$FP")" || exit 0
    OUT=$(go mod tidy -diff 2>&1 | tail -10)
    echo "$OUT" | grep -qiE "unknown revision|not found|invalid version" && {
      warn PostToolUse "DEPS: go mod tidy flags problems in $FP — a version may not exist:
$(echo "$OUT" | grep -iE "unknown revision|not found|invalid version" | head -5)"; }
    ;;
  */package.json|package.json)
    command -v npm >/dev/null 2>&1 || exit 0
    cd "$(dirname "$FP")" || exit 0
    OUT=$(npm install --dry-run --ignore-scripts 2>&1 | tail -10)
    echo "$OUT" | grep -qiE "No matching version|404|ETARGET|ERESOLVE" && {
      warn PostToolUse "DEPS: npm dry-run flags problems in $FP — a version may not exist or conflicts:
$(echo "$OUT" | grep -iE "No matching version|404|ETARGET|ERESOLVE" | head -5)"; }
    ;;
esac
exit 0
