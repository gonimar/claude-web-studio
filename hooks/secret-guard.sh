#!/bin/bash
# PreToolUse(Write|Edit): never write secrets into tracked files
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
CONTENT=$(jget .tool_input.content); [ -z "$CONTENT" ] && CONTENT=$(jget .tool_input.new_string)
[ -z "$FILE" ] && exit 0
case "$FILE" in
  *.env.example|*.env.dist|*.env.template|*.env.sample) exit 0;;
  *.env|*/.env.*|*.pem|*.key) echo "BLOCKED: writing the secrets file '$FILE' through the agent is not allowed — the user edits it directly." >&2; exit 2;;
esac
if echo "$CONTENT" | grep -qE 'AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{20,}|xox[baprs]-[A-Za-z0-9-]{10,}|-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----'; then
  echo "BLOCKED: content for '$FILE' looks like a real key/token. Use environment variables." >&2; exit 2
fi
exit 0
