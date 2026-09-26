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

# Can this writer round-trip the file? Only its own seven fields, their Notes entries, the header
# comment and blank lines. A project whose state carries headings, bold fields or prose — a real
# working document — is NOT rewritten: the writer would replace it with a seven-line skeleton and
# every other line would be gone, with the file gitignored and no archive to fall back on. That is
# exactly what happened on the first day this script shipped: 148 lines became 9 (WS-115).
canonical() { # <file>
  awk '
    /^<!--/                                       { next }
    /^[[:space:]]*$/                              { next }
    /^(Task|Branch|Next|Gate|Blocked|Files|Notes):/ { next }
    /^  - /                                       { next }
                                                  { bad++ }
    END { exit (bad > 0) }
  ' "$1"
}

refuse_if_foreign() {
  [ -f "$STATE" ] || return 0
  canonical "$STATE" && return 0
  n=$(awk '
    /^<!--/ { next } /^[[:space:]]*$/ { next }
    /^(Task|Branch|Next|Gate|Blocked|Files|Notes):/ { next } /^  - / { next }
    { n++ } END { print n+0 }' "$STATE")
  {
    echo "session-state.sh: $STATE holds $n line(s) this writer cannot round-trip (headings, bold fields, prose)."
    echo "Rewriting it would leave the seven-field skeleton and drop them — the file is gitignored, so nothing would bring them back."
    echo "Nothing was written. Edit the file with Write/Edit, or move its durable parts to their own documents"
    echo "(sprint file, findings, backlog, agent memory) and leave the seven fields here."
  } >&2
  exit 2
}

backup() { # keep the last five, so even a correct write is undoable
  [ -f "$STATE" ] || return 0
  mkdir -p "$ARCHIVE" 2>/dev/null || return 0
  cp "$STATE" "$ARCHIVE/active-$(date '+%Y%m%dT%H%M%S').md" 2>/dev/null || true
  ls -1t "$ARCHIVE"/active-*.md 2>/dev/null | tail -n +6 | while read -r old; do rm -f "$old"; done
}

case "${1:-}" in
  set)
    shift
    refuse_if_foreign; backup
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
    refuse_if_foreign; backup
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
  migrate)
    # A file that grew into a working document is converted once, deliberately, and nothing is
    # thrown away: the whole of it is parked in the archive first, the fields the writer can
    # recognise (including the bold `**Task**:` spelling) are carried over, and what is left is
    # the project's to move into its own documents.
    [ -f "$STATE" ] || { echo "no $STATE — nothing to migrate"; exit 0; }
    if canonical "$STATE"; then echo "$STATE is already in the writer's format — nothing to migrate"; exit 0; fi
    mkdir -p "$ARCHIVE"
    DEST="$ARCHIVE/active-$(date '+%Y%m%dT%H%M%S')-premigration.md"
    cp "$STATE" "$DEST"
    LINES=$(grep -c . "$DEST")
    for f in $FIELDS; do
      v=$(grep -m1 -E "^(\*\*)?$f(\*\*)?:" "$DEST" | sed -E "s/^(\*\*)?$f(\*\*)?:[[:space:]]*//")
      eval "V_$f=\$v"
    done
    NOTES_TAIL=""
    write_state
    cat "$STATE"
    echo
    echo "Migrated. The previous $LINES-line file is archived whole at:"
    echo "  $DEST"
    echo "Its durable parts belong in documents that survive the session — sprint status in the sprint file,"
    echo "lessons in agent memory, tech debt in production/findings.md, plans in production/backlog.md."
    echo "Move them from the archive; this file keeps the seven fields and dated notes only."
    ;;
  show) [ -f "$STATE" ] && cat "$STATE" || echo "no $STATE";;
  clear)
    refuse_if_foreign; backup
    NOTES_TAIL=""; for f in $FIELDS; do eval "V_$f="; done
    write_state; cat "$STATE"
    ;;
  *)
    echo "usage: session-state.sh set <Field> <value> [<Field> <value>…] | note <text> | migrate | show | clear" >&2
    echo "fields: $FIELDS" >&2
    exit 2;;
esac
