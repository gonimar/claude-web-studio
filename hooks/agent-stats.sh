#!/bin/bash
# Who actually did the work? A summary of production/session-logs/agent-audit.log, the trail the
# log-agent hook leaves. Not a hook — a tool `/sprint-status` and `/help` call, so the numbers are
# computed the same way everywhere.
#
#   agent-stats.sh            # all time + the last 7 days
#   agent-stats.sh --since 2026-09-09
#   agent-stats.sh --since 14d
#
# Two of its lines are the point. A start with no stop is an agent cut off at its turn limit (or
# still running) — that is how four stories in a row came to be written by the parent with nobody
# noticing (WS-087). A run of a non-studio agent means routing went around the roster (WS-001).
set -u
cd "${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}" 2>/dev/null || exit 0
LOG=production/session-logs/agent-audit.log
[ -f "$LOG" ] || { echo "Agents: no $LOG yet"; exit 0; }

SINCE=$(date -d '7 days ago' +%F 2>/dev/null || echo "")
LABEL="last 7 days"
if [ "${1:-}" = "--since" ] && [ -n "${2:-}" ]; then
  case "$2" in
    *d) SINCE=$(date -d "${2%d} days ago" +%F 2>/dev/null || echo "$SINCE"); LABEL="last ${2%d} days";;
    *)  SINCE="$2"; LABEL="since $2";;
  esac
fi

# The same agent appears as `go-engineer` (copy mode) and `web-studio:go-engineer` (plugin mode);
# counted apart, one agent looks like two.
awk -F'|' -v since="$SINCE" -v label="$LABEL" '
  function short(n) { sub(/^[[:space:]]+/, "", n); sub(/[[:space:]]+$/, "", n); sub(/^web-studio:/, "", n); return n }
  {
    date = substr($1, 1, 10); ev = $2; gsub(/ /, "", ev); name = short($3)
    aid = $4; sub(/.*aid=/, "", aid); sub(/ .*/, "", aid)
  }
  ev == "SubagentStart" {
    total++; runs[name]++
    if (since != "" && date >= since) window++
    open[aid] = name
    if (name == "general-purpose" || name == "Explore" || name == "claude" || name == "general purpose") foreign++
  }
  ev == "SubagentStop" { delete open[aid] }
  END {
    if (total == 0) { print "Agents: the log has no runs yet"; exit }
    printf "Agents: %d runs all-time", total
    if (since != "") printf " · %d in the %s", window + 0, label
    printf "\n"
    n = 0
    for (a in runs) { order[++n] = a }
    for (i = 1; i < n; i++) for (j = i + 1; j <= n; j++) if (runs[order[j]] > runs[order[i]]) { t = order[i]; order[i] = order[j]; order[j] = t }
    line = ""
    for (i = 1; i <= n && i <= 5; i++) line = line (i > 1 ? " · " : "") order[i] " " runs[order[i]]
    print "  " line
    unpaired = 0
    for (a in open) if (a != "-" && a != "") unpaired++
    if (unpaired > 0) printf "  %d start(s) without a stop — cut off at the turn limit, or still running\n", unpaired
    if (foreign > 0) printf "  ! %d run(s) of non-studio agents — routing went around the roster\n", foreign
  }' "$LOG"
