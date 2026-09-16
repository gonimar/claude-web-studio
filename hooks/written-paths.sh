#!/bin/bash
# Which files would this Bash command write?
#
# The studio's own skills author documents with `cat > file <<EOF` and `python3 - <<PY`, not with
# Write/Edit — so the whole Write|Edit hook lane (consent, secrets, impact, document format) saw
# nothing at all: one real session logged 588 Bash calls, 15 Writes (all into a scratchpad), zero
# Edits, and not a single guard line, while `touch .claude/.write-consent` appeared 176 times
# (WS-085). The guards therefore read Bash commands too, and this is the one place that says what
# a command writes.
#
# Best effort by construction: a path found here is checked like any Write, a path missed leaves
# things exactly as they were. Paths built from shell or Python variables cannot be resolved —
# that is why the rules also ask skills to use Write/Edit for documents.

written_paths() { # <command text> -> one path per line
  local cmd="$1"
  {
    # Redirections: `> file`, `>> file`. Not `2>`, not `>&2`, not `>(…)`.
    printf '%s\n' "$cmd" | grep -oE '(^|[^0-9&>])>>?[[:space:]]*"?'"'"'?[A-Za-z0-9_./~$-]+' \
      | sed -E 's/.*>>?[[:space:]]*["'"'"']?//'
    # tee [-a] file …
    printf '%s\n' "$cmd" | grep -oE '\btee\b([[:space:]]+-[A-Za-z]+)*[[:space:]]+"?'"'"'?[A-Za-z0-9_./~-]+' \
      | sed -E 's/.*[[:space:]]["'"'"']?//'
    # cp / mv / install: the destination is the last argument of that segment
    printf '%s\n' "$cmd" | tr ';&|' '\n' | grep -E '^[[:space:]]*(cp|mv|install)[[:space:]]' | awk '{print $NF}'
    # sed -i … file
    printf '%s\n' "$cmd" | tr ';&|' '\n' | grep -E '^[[:space:]]*sed[[:space:]]+-i' | awk '{print $NF}'
    # A heredoc body that writes a file itself: open('f','w'), io.open("f","a"), writeFileSync('f'
    printf '%s\n' "$cmd" | grep -oE "open\(['\"][^'\"]+['\"][[:space:]]*,[[:space:]]*['\"][wax]" \
      | sed -E "s/^.*open\(['\"]//; s/['\"].*$//"
    printf '%s\n' "$cmd" | grep -oE "writeFileSync\(['\"][^'\"]+" | sed -E "s/^.*\(['\"]//"
  } 2>/dev/null \
    | sed -e 's#^\./##' -e 's/["'"'"']$//' \
    | grep -vE '^(/dev/[a-z]+|&[0-9]|-|)$' \
    | grep -v '\$' \
    | sort -u
}

# affected_paths: the paths this hook event touches — the Write/Edit target, or what the Bash
# command would write. Callers loop over the result; empty means "nothing to check".
affected_paths() { # <file_path> <command>
  if [ -n "$1" ]; then printf '%s\n' "$1"; return; fi
  [ -n "$2" ] && written_paths "$2"
}
