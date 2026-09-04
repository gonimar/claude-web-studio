#!/bin/bash
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
case "$FILE" in
  */skills/*/SKILL.md|*/agents/*.md)
    head -1 "$FILE" 2>/dev/null | grep -q '^---$' || echo "WARNING: $FILE — frontmatter must start with '---' on line 1." >&2
    grep -q '^name:' "$FILE" 2>/dev/null || echo "WARNING: $FILE — missing name: field; the file will be ignored." >&2
    echo "Changed $FILE — consider /skill-test static <name>." >&2 ;;
esac
exit 0
