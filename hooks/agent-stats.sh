#!/bin/bash
# Who actually did the work? A summary of production/session-logs/agent-audit.log, the trail the
# log-agent hook leaves. Not a hook — a tool `/sprint-status` and `/help` call, so the numbers are
# computed the same way everywhere.
#
#   agent-stats.sh            # all time + the last 7 days
#   agent-stats.sh --since 2026-09-09
#   agent-stats.sh --since 14d
#
# What the log can and cannot say. A run of a non-studio agent means routing went around the roster
# (WS-001) — that one is certain, the name is in the line. The gap between starts and stops is NOT:
# the log carries two formats (older lines have no `aid`), and even among lines that do, stops
# arrive about half the time and sometimes twice. So the gap is reported as a gap — starts, stops,
# difference — with both readings named, never as "N agents were cut off" (WS-117).
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
    # Older lines are `date | event | agent` with no id at all; newer ones add `sid=… aid=… tuid=…`.
    aid = ""
    if (NF >= 4) { aid = $4; sub(/.*aid=/, "", aid); sub(/ .*/, "", aid) }
  }
  ev == "SubagentStart" {
    starts++; runs[name]++
    if (since != "" && date >= since) window++
    if (aid != "" && aid != "-") { if (!(aid in seen_start)) { seen_start[aid] = name; agents++ }; openids[aid] = name }
    if (name == "general-purpose" || name == "Explore" || name == "claude") foreign++
  }
  ev == "SubagentStop" {
    stops++
    if (aid != "" && aid != "-") delete openids[aid]
  }
  END {
    if (starts == 0) { print "Agents: the log has no runs yet"; exit }
    printf "Agents: %d runs all-time", starts
    if (since != "") printf " · %d in the %s", window + 0, label
    printf "\n"
    n = 0
    for (a in runs) { order[++n] = a }
    for (i = 1; i < n; i++) for (j = i + 1; j <= n; j++) if (runs[order[j]] > runs[order[i]]) { t = order[i]; order[i] = order[j]; order[j] = t }
    line = ""
    for (i = 1; i <= n && i <= 5; i++) line = line (i > 1 ? " · " : "") order[i] " " runs[order[i]]
    print "  " line
    gap = starts - stops
    if (gap > 0) {
      unpaired = 0
      for (a in openids) unpaired++
      printf "  %d start(s) vs %d stop(s) — %d more starts than stops", starts, stops, gap
      if (agents > 0) printf "; of the %d agents the log identifies by id, %d were never closed", agents, unpaired
      printf "\n"
      print "  read it as: agents cut off at their turn limit (check the story results), or stop events that never reached the log — the log cannot tell you which"
    }
    if (foreign > 0) printf "  ! %d run(s) of non-studio agents — routing went around the roster\n", foreign
  }' "$LOG"
