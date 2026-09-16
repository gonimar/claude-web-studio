#!/bin/bash
# Writes production/session-state/active.md. Not a hook — a tool the skills call instead of
# hand-written `sed -i` and `python3 -c` one-liners inside double quotes, which is how the file
# used to be updated: unreadable, unverifiable, and silently a no-op when the quoting went wrong
# (WS-095). It lives here because hooks/ is the one directory present in both modes — as
# `.claude/hooks/session-state.sh` in copy mode, as `${CLAUDE_PLUGIN_ROOT}/hooks/session-state.sh`
# in plugin mode.
#
#   session-state.sh set Task "S-012 repository layer" Branch feat/S-012-repo Next "/code-review"
#   session-state.sh note "impact: new dependency chi v5 → APPROVED WITH CONDITIONS"
#   session-state.sh show
#   session-state.sh clear
#
# Every field of the template is kept in its order; a field that was never set reads "—".
# `set` prints the resulting file, so the skill can render it and the user can see what happened.
set -u
cd "${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}" 2>/dev/null || exit 1
STATE=production/session-state/active.md
ARCHIVE=production/session-state/archive
FIELDS="Task Branch Next Gate Blocked Files Notes"
NOTES_KEEP=10

get() { # <field> — its current value, empty when the file or the field is absent
  [ -f "$STATE" ] || return 0
  awk -v f="$1:" 'index($0, f) == 1 { sub(/^[^:]*:[[:space:]]*/, ""); print; exit }' "$STATE"
}

notes_body() { # every Notes line after the first (the block's continuation)
  [ -f "$STATE" ] || return 0
  awk '/^Notes:/ { seen = 1; next } seen && /^[A-Za-z]+:/ { exit } seen { print }' "$STATE"
}

write_state() { # <<< field values held in the V_* variables
  mkdir -p "$(dirname "$STATE")"
  {
    echo "<!-- production/session-state/active.md — current work state (gitignored) -->"
    for f in $FIELDS; do
      eval "v=\${V_$f:-}"
      # Notes carries its entries on the following lines, so the field itself stays empty then.
      if [ "$f" = Notes ] && [ -n "${NOTES_TAIL:-}" ]; then
        echo "Notes:"; printf '%s' "$NOTES_TAIL"; continue
      fi
      [ -z "${v:-}" ] && v="—"
      echo "$f: $v"
    done
  } > "$STATE"
}

load() {
  for f in $FIELDS; do eval "V_$f=\$(get \"$f\")"; done
  NOTES_TAIL=$(notes_body)
  [ -n "$NOTES_TAIL" ] && NOTES_TAIL="$NOTES_TAIL
"
}

case "${1:-}" in
  set)
    shift
    [ $(($# % 2)) -eq 0 ] || { echo "session-state.sh set: fields come in pairs (Task \"…\" Next \"…\")" >&2; exit 2; }
    load
    while [ $# -gt 0 ]; do
      case " $FIELDS " in *" $1 "*) ;; *) echo "session-state.sh: unknown field '$1' (known: $FIELDS)" >&2; exit 2;; esac
      eval "V_$1=\$2"; shift 2
    done
    write_state
    cat "$STATE"
    ;;
  note)
    shift
    [ -n "${1:-}" ] || { echo "session-state.sh note: nothing to write" >&2; exit 2; }
    load
    NEW="  - $(date '+%F') $1"
    # Newest first; anything past NOTES_KEEP moves to the archive rather than disappearing.
    ALL=$(printf '%s\n%s' "$NEW" "$NOTES_TAIL" | grep -v '^[[:space:]]*$')
    KEPT=$(printf '%s\n' "$ALL" | head -n "$NOTES_KEEP")
    DROPPED=$(printf '%s\n' "$ALL" | tail -n +$((NOTES_KEEP + 1)))
    if [ -n "$DROPPED" ]; then
      mkdir -p "$ARCHIVE"; printf '%s\n' "$DROPPED" >> "$ARCHIVE/$(date '+%Y-%m').md"
    fi
    NOTES_TAIL="$KEPT
"
    # The entries live in NOTES_TAIL; the field itself stays empty (write_state renders it).
    # shellcheck disable=SC2034  # read through the eval in write_state
    V_Notes=""
    write_state
    cat "$STATE"
    ;;
  show) [ -f "$STATE" ] && cat "$STATE" || echo "no $STATE";;
  clear)
    NOTES_TAIL=""; for f in $FIELDS; do eval "V_$f="; done
    write_state; cat "$STATE"
    ;;
  *)
    echo "usage: session-state.sh set <Field> <value> [<Field> <value>…] | note <text> | show | clear" >&2
    echo "fields: $FIELDS" >&2
    exit 2;;
esac
