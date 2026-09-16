#!/bin/bash
# Who actually did the work? A summary of production/session-logs/agent-audit.log, the trail the
# log-agent hook leaves. Not a hook — a tool `/sprint-status` and `/help` call, so the numbers are
# computed the same way everywhere.
#
#   agent-stats.sh            # all time + the last 7 days
#   agent-stats.sh --since 2026-09-09
#   agent-stats.sh --since 14d
#
# What the log can and cannot say (WS-117, measured on two real projects):
#   * a run of a non-studio agent is a fact — the name is in the line (WS-001);
#   * `SubagentStart` fires per invocation, including every resume of the same agent: one `aid` in a
#     real log carries eight starts and no stop. So starts minus stops is NOT a count of anything —
#     it is mostly resumes, and reading it as lost work is how a recount arrived at 126 where the
#     truth was 5;
#   * what does mean something is the agent: an `aid` that was started and never closed (WS-087);
#   * lines written before the id fields existed (`date | event | agent`) cannot be paired at all.
#     Where the log has such lines, say so — a silent zero reads as "clean" when it means "blind".
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
    if (aid != "" && aid != "-") { if (!(aid in seen)) { seen[aid] = 1; agents++ }; openids[aid] = name }
    else noid++
    if (name == "general-purpose" || name == "Explore" || name == "claude") foreign++
  }
  ev == "SubagentStop" { if (aid != "" && aid != "-") delete openids[aid] }
  END {
    if (starts == 0) { print "Agents: the log has no runs yet"; exit }
    printf "Agents: %d runs all-time", starts
    if (since != "") printf " · %d in the %s", window + 0, label
    if (agents > 0) printf " · %d agents", agents
    printf "\n"
    n = 0
    for (a in runs) { order[++n] = a }
    for (i = 1; i < n; i++) for (j = i + 1; j <= n; j++) if (runs[order[j]] > runs[order[i]]) { t = order[i]; order[i] = order[j]; order[j] = t }
    line = ""
    for (i = 1; i <= n && i <= 5; i++) line = line (i > 1 ? " · " : "") order[i] " " runs[order[i]]
    print "  " line
    unpaired = 0
    for (a in openids) unpaired++
    if (agents > 0 && unpaired > 0)
      printf "  %d agent(s) started and never closed — cut off at the turn limit, or still running: check what their stories say\n", unpaired
    if (noid > 0)
      printf "  %d run(s) predate the agent ids in the log — they cannot be paired, so \"never closed\" is measured only over the %d that can\n", noid, agents
    if (foreign > 0) printf "  ! %d run(s) of non-studio agents — routing went around the roster\n", foreign
  }' "$LOG"
