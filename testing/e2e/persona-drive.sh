#!/bin/bash
# See testing/e2e/personas/README.md for the method, profiles and result-storage convention.
# Persona-driven headless run: the studio session's questions are answered by a haiku
# "user simulator" playing a profile. Usage: persona-drive.sh <dir> <profile-file> <first-prompt> [max-turns]
set -u
DIR="$1"; PROFILE="$2"; FIRST="$3"; MAX="${4:-14}"
mkdir -p "$DIR"; cd "$DIR" || exit 1
N=0; LAST=""

persona_answer() {
  local question="$1"
  env -u CLAUDE_CODE_SESSION_ID -u CLAUDE_CODE_CHILD_SESSION -u CLAUDE_CODE_MESSAGING_SOCKET -u CLAUDE_PID \
  claude -p "$(cat "$PROFILE")

The studio just asked you (or ended its turn) with this text:
---
$question
---
Reply with ONE user message in character (1-3 sentences, no third-person narration, no quotes around the whole reply). If the message offers options, pick one that fits your character and say it in your own words. Reply in the project's conversation language, as your profile instructs." \
    --model haiku 2>>"$DIR.persona.err" | tail -c 500
}

run_turn() {
  N=$((N+1))
  local prompt="$1" flag="${2:-}"
  local out="$DIR.t$N.jsonl"
  env -u CLAUDE_CODE_SESSION_ID -u CLAUDE_CODE_CHILD_SESSION -u CLAUDE_CODE_MESSAGING_SOCKET -u CLAUDE_PID \
    claude -p $flag "$prompt" --output-format stream-json --verbose \
    --permission-mode acceptEdits --allowedTools "Write,Edit" > "$out" 2>>"$DIR.err.log"
  LAST=$(jq -r 'select(.type=="result") | .result // ""' "$out" 2>/dev/null | tail -c 2500)
  { echo "=== turn $N USER: ${prompt:0:120}"; echo "--- STUDIO: $(echo "$LAST" | tail -c 400)"; } >> "$DIR.turns.md"
}

awaiting_input() {
  # The turn expects a reply if it asks (?), lists options, or uses gate/hand-off vocabulary.
  echo "$1" | grep -qiE $'\\?|recommended|\u0440\u0435\u043a\u043e\u043c\u0435\u043d\u0434|review mode|\u0440\u0435\u0436\u0438\u043c|May I write|\u0437\u0430\u043f\u0438\u0441|pick|\u0432\u044b\u0431\u0435\u0440|next step|\u0447\u0442\u043e \u0434\u0430\u043b\u044c\u0448\u0435|- \\*\\*|\u2022 ' && return 0
  return 1
}
run_turn "$FIRST"
while [ $N -lt "$MAX" ]; do
  awaiting_input "$LAST" || break
  A=$(persona_answer "$LAST")
  [ -n "$A" ] || A=$'\u0414\u0430.'
  run_turn "$A" -c
done
echo "DONE after $N turns" >> "$DIR.turns.md"
