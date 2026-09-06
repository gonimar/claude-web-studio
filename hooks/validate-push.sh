#!/bin/bash
# PreToolUse(Bash): block force-push, warn on direct push to protected branches.
# Only real `git push` command segments are inspected — heredoc bodies and other commands in the
# same Bash call (e.g. `rm -f`, documentation text quoting `git push --force`) are ignored.
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
CMD=$(jget .tool_input.command)
# Drop heredoc bodies (<<TAG … TAG, <<'TAG', <<-TAG) so quoted text never looks like a command.
STRIPPED=$(printf '%s\n' "$CMD" | awk '
  hd != "" { if ($0 == hd) hd = ""; next }
  {
    if (match($0, /<<-?[ \t]*["'"'"']?[A-Za-z_][A-Za-z0-9_]*/)) {
      t = substr($0, RSTART, RLENGTH); sub(/<<-?[ \t]*["'"'"']?/, "", t); hd = t
    }
    print
  }')
# Command segments that are actually `git push …` (start of line or after ; & |).
PUSHES=$(printf '%s\n' "$STRIPPED" | grep -oE '(^|[;&|][[:space:]]*)git[[:space:]]+push[^;&|]*' || true)
[ -z "$PUSHES" ] && exit 0
echo "$PUSHES" | grep -qE -- '(--force|--force-with-lease)([[:space:]=]|$)|[[:space:]]-f([[:space:]]|$)' && { echo "BLOCKED: force-push is not allowed by studio rules." >&2; exit 2; }
BR=$(git symbolic-ref -q --short HEAD 2>/dev/null || git rev-parse --abbrev-ref HEAD 2>/dev/null)
case "$BR" in main|master|production|release) echo "WARNING: pushing directly to '$BR'. Studio rule: open a PR from a feature branch (.claude/docs/git-workflow.md)." >&2;; esac
exit 0
