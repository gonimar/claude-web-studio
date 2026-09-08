#!/bin/bash
# Drive a multi-turn headless session against a fixture project.
# Usage: drive.sh <project-dir> <first-prompt> [max-turns] [--lang ru|en]
# Each turn's stream-json lands in <project-dir>.tN.jsonl; a turn log in <project-dir>.turns.log.
# Answers are plain user replies routed by keyword — they never restate studio rules
# (that would contaminate the test).
set -u
DIR="$1"; FIRST="$2"; MAX="${3:-10}"; LANG_OPT="${4:---lang ru}"
LANGV="${LANG_OPT#--lang }"
cd "$DIR" || exit 1
N=0; LAST=""

say() { # ru/en generic answers
  local key="$1"
  case "$LANGV:$key" in
    ru:yes)     printf '%s\n' $'\u0414\u0430, \u043f\u0440\u043e\u0434\u043e\u043b\u0436\u0430\u0439.' ;;
    ru:write)   printf '%s\n' $'\u0414\u0430, \u0437\u0430\u043f\u0438\u0441\u044b\u0432\u0430\u0439.' ;;
    ru:lang)    printf '%s\n' $'\u0420\u0443\u0441\u0441\u043a\u0438\u0439. \u0420\u0435\u0436\u0438\u043c \u0440\u0435\u0432\u044c\u044e lean. \u0421\u0442\u0430\u0434\u0438\u044f build.' ;;
    ru:git)     printf '%s\n' $'\u0414\u0430, \u0438\u043d\u0438\u0446\u0438\u0430\u043b\u0438\u0437\u0438\u0440\u0443\u0439 git.' ;;
    ru:deploy)  printf '%s\n' $'manual, \u0431\u0435\u0437 \u0438\u043d\u0444\u0440\u0430-\u0440\u0435\u043f\u043e\u0437\u0438\u0442\u043e\u0440\u0438\u044f.' ;;
    en:yes)     echo "Yes, go ahead." ;;
    en:write)   echo "Yes, write it." ;;
    en:lang)    echo "English. Review mode lean. Stage build." ;;
    en:git)     echo "Yes, initialise git." ;;
    en:deploy)  echo "manual, no infra repo." ;;
  esac
}

run_turn() {
  N=$((N+1))
  local prompt="$1" flag="${2:-}"
  local out="$DIR.t$N.jsonl"
  claude -p $flag "$prompt" --output-format stream-json --verbose \
    --permission-mode acceptEdits --allowedTools "Write,Edit" > "$out" 2>>"$DIR.err.log"
  LAST=$(jq -r 'select(.type=="result") | .result // ""' "$out" 2>/dev/null | tail -c 2000)
  { echo "--- turn $N prompt: ${prompt:0:70}"; echo "$LAST" | tail -c 500; } >> "$DIR.turns.log"
}

answer_for() {
  local t="$1"
  if   echo "$t" | grep -qiE $'language|\u044f\u0437\u044b\u043a';                 then say lang
  elif echo "$t" | grep -qiE $'git init|git repo|\u0440\u0435\u043f\u043e\u0437\u0438\u0442\u043e\u0440';   then say git
  elif echo "$t" | grep -qiE $'deploy|\u0434\u0435\u043f\u043b\u043e|target';           then say deploy
  elif echo "$t" | grep -qiE $'May I write|\u0437\u0430\u043f\u0438\u0441|write these'; then say write
  else say yes; fi
}

run_turn "$FIRST"
while [ $N -lt "$MAX" ]; do
  echo "$LAST" | grep -q "?" || break            # no open question -> scenario segment done
  run_turn "$(answer_for "$LAST")" -c
done
echo "DONE after $N turns" >> "$DIR.turns.log"
