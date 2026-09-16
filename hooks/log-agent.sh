#!/bin/bash
# SubagentStart/SubagentStop: audit trail of agent invocations
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
EV=$(jget .hook_event_name); [ -z "$EV" ] && EV="?"
AG=$(jget .agent_type)
# A Stop with no agent type is not a studio agent that vanished: it is built-in tooling (a plain
# Task, compaction) whose Start the hook never saw. Calling it "unknown" made the log look like a
# trail of lost agents and broke Start/Stop pairing in the stats (WS-089).
[ -z "$AG" ] && AG=builtin
SID=$(jget .session_id); AID=$(jget .agent_id); TID=$(jget .tool_use_id)
# Always log at the project root: the session cwd may be a subdirectory (cd backend && …).
cd "${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}" 2>/dev/null || exit 0
mkdir -p production/session-logs 2>/dev/null
# A second Start for an agent whose Stop never came is a resumption, not a new agent: mark it so the
# pairs stay countable and a session that silently re-spawned an agent is visible afterwards (WS-088).
RESUME=""
if [ "$EV" = SubagentStart ] && [ -n "${AID:-}" ] && [ -f production/session-logs/agent-audit.log ]; then
  LAST=$(grep -F "aid=$AID" production/session-logs/agent-audit.log 2>/dev/null | tail -1)
  case "$LAST" in *SubagentStart*) RESUME=" resume=1";; esac
fi
echo "$(date '+%F %T') | $EV | $AG | sid=${SID:--} aid=${AID:--} tuid=${TID:--}$RESUME" >> production/session-logs/agent-audit.log 2>/dev/null
exit 0
