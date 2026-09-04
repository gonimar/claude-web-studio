#!/bin/bash
# PostToolUse(Write|Edit): format and quick-check the edited file when tools are available. Never blocks.
INPUT=$(cat)
# --- json helper: jq -> python3 -> grep ---
jget() {
  if command -v jq >/dev/null 2>&1; then echo "$INPUT" | jq -r "$1 // empty" 2>/dev/null; return; fi
  if command -v python3 >/dev/null 2>&1; then
    echo "$INPUT" | python3 -c 'import sys,json
p=sys.argv[1].strip(".").split(".");d=json.load(sys.stdin)
for k in p:
  d=d.get(k) if isinstance(d,dict) else None
print(d if isinstance(d,str) else ("" if d is None else json.dumps(d)))' "$1" 2>/dev/null; return
  fi
  key="${1##*.}"; echo "$INPUT" | grep -oE "\"$key\"[[:space:]]*:[[:space:]]*\"([^\"\\\\]|\\\\.)*\"" | head -1 | sed -E "s/^\"$key\"[[:space:]]*:[[:space:]]*\"//;s/\"$//;s/\\\\\"/\"/g"
}
FILE=$(jget .tool_input.file_path)
[ -f "$FILE" ] || exit 0
OUT=""
case "$FILE" in
  *.go)
    command -v gofmt >/dev/null && gofmt -l -w "$FILE" >/dev/null 2>&1
    command -v go >/dev/null && { V=$(cd "$(dirname "$FILE")" && go vet ./... 2>&1 | head -10); [ -n "$V" ] && OUT="go vet:\n$V"; } ;;
  *.php)
    command -v php >/dev/null && { L=$(php -l "$FILE" 2>&1 | grep -v 'No syntax errors'); [ -n "$L" ] && OUT="php -l:\n$L"; }
    [ -x vendor/bin/php-cs-fixer ] && vendor/bin/php-cs-fixer fix "$FILE" -q >/dev/null 2>&1 ;;
  *.ts|*.tsx|*.vue|*.js|*.mjs|*.scss|*.css|*.json|*.md|*.yaml|*.yml)
    if [ -f node_modules/.bin/prettier ]; then node_modules/.bin/prettier --write --log-level silent "$FILE" >/dev/null 2>&1;
    elif [ -f node_modules/.bin/biome ]; then node_modules/.bin/biome format --write "$FILE" >/dev/null 2>&1; fi
    case "$FILE" in
      *.json) command -v python3 >/dev/null && ! python3 -m json.tool "$FILE" >/dev/null 2>&1 && OUT="Invalid JSON: $FILE" ;;
      *.ts|*.tsx|*.vue|*.js|*.mjs) [ -f node_modules/.bin/eslint ] && { E=$(node_modules/.bin/eslint --no-warn-ignored --format unix "$FILE" 2>/dev/null | grep -E 'error' | head -8); [ -n "$E" ] && OUT="eslint:\n$E"; } ;;
    esac ;;
esac
[ -n "$OUT" ] && echo -e "=== post-edit ($FILE) ===\n$OUT" >&2
exit 0
