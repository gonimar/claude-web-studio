#!/bin/bash
# PreToolUse(Write|Edit|Bash): never write secrets into tracked files. A heredoc is a write too:
# `cat > .env <<EOF`, and a token pasted into a `python3 - <<PY` body, used to pass unseen (WS-085).
. "$(dirname "$0")/written-paths.sh"
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
# The GitHub MCP server: every input leaves the machine — a file content (create_or_update_file,
# push_files), but also an issue, a PR body, a review comment — so a token or a key anywhere in the
# input is blocked (a public issue is a worse leak than a private file). The file-writing tools also
# get their path fields checked like a Write (github-mcp-guard blocks them outright when it is on).
TOOL=$(jget .tool_name)
case "$TOOL" in
  mcp__*github__*)
    if echo "$INPUT" | grep -qE 'AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{20,}|xox[baprs]-[A-Za-z0-9-]{10,}|-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----'; then
      echo "BLOCKED: the input of $TOOL looks like it carries a real key/token — it would be published on GitHub. Use environment variables and reference the secret by name." >&2; exit 2
    fi
    case "$TOOL" in
      mcp__*github__create_or_update_file|mcp__*github__push_files|mcp__*github__delete_file)
        MCP_PATHS=$(echo "$INPUT" | grep -oE '"path"[[:space:]]*:[[:space:]]*"[^"]*"' | sed -E 's/^"path"[[:space:]]*:[[:space:]]*"//;s/"$//' | grep -vE '\.env\.(example|dist|template|sample)$')
        if printf '%s\n' "$MCP_PATHS" | grep -qE '(^|/)\.env(\.[^/]+)?$|\.pem$|\.key$'; then
          echo "BLOCKED: writing a secrets file through $TOOL is not allowed — the user edits it directly." >&2; exit 2
        fi;;
    esac
    exit 0;;
  mcp__*) exit 0;;
esac
FILE=$(jget .tool_input.file_path)
CONTENT=$(jget .tool_input.content); [ -z "$CONTENT" ] && CONTENT=$(jget .tool_input.new_string)
CMD=$(jget .tool_input.command)
PATHS=$(affected_paths "$FILE" "$CMD")
[ -z "$PATHS" ] && exit 0
# For a Bash write the command text carries the heredoc body — that is the content being written.
[ -z "$CONTENT" ] && [ -n "$CMD" ] && CONTENT="$CMD"
SAFE=""
for f in $PATHS; do
  case "$f" in
    *.env.example|*.env.dist|*.env.template|*.env.sample) continue;;
    *.env|*/.env.*|*.pem|*.key) echo "BLOCKED: writing the secrets file '$f' through the agent is not allowed — the user edits it directly." >&2; exit 2;;
  esac
  SAFE="$SAFE $f"
done
[ -z "$SAFE" ] && exit 0
FILE=$(echo $SAFE)
if echo "$CONTENT" | grep -qE 'AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{20,}|xox[baprs]-[A-Za-z0-9-]{10,}|-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----'; then
  echo "BLOCKED: content for '$FILE' looks like a real key/token. Use environment variables." >&2; exit 2
fi
exit 0
