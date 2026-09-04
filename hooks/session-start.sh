#!/bin/bash
# SessionStart: project context, stack-reference freshness, plugin root for /init
echo "=== Web Studio — session context ==="
[ -n "${CLAUDE_PLUGIN_ROOT:-}" ] && echo "Plugin root: $CLAUDE_PLUGIN_ROOT"
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ -n "$BRANCH" ]; then
  echo "Branch: $BRANCH"; echo "Recent commits:"; git log --oneline -5 2>/dev/null | sed 's/^/  /'
  DIRTY=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' '); [ "$DIRTY" -gt 0 ] && echo "Uncommitted changes: $DIRTY"
fi
[ -f production/stage.txt ] && echo "Stage: $(head -1 production/stage.txt)"
if [ ! -f .claude/docs/technical-preferences.md ]; then
  echo "Web Studio is not initialised in this project — run /web-studio:init (or /init in copy mode)."
elif grep -q 'TO BE CONFIGURED' .claude/docs/technical-preferences.md; then
  echo "Stack not configured — run /setup-stack (new project) or /adopt (existing project)."
fi
[ -f production/roadmap.md ] && echo "Roadmap: $(grep -c '^- \[ \]' production/roadmap.md 2>/dev/null) open items"
IDX=.claude/docs/stack-reference/index.md
if [ -f "$IDX" ]; then
  UPD=$(sed -n 's/^updated: *//p' "$IDX" | head -1)
  if [ -n "$UPD" ]; then
    AGE=$(( ( $(date +%s) - $(date -d "$UPD" +%s 2>/dev/null || date +%s) ) / 86400 ))
    if [ "$AGE" -gt 60 ]; then echo "Stack reference is $AGE days old — consider /stack-update."; else echo "Stack reference: $UPD ($AGE days old)"; fi
  fi
fi
[ -f .claude/.web-studio-version ] && echo "Web Studio v$(cat .claude/.web-studio-version)"
STATE=production/session-state/active.md
if [ -f "$STATE" ]; then echo; echo "=== ACTIVE SESSION STATE ($STATE) ==="; tail -20 "$STATE"; echo "=== read the whole file to resume ==="; fi
echo "===================================="
exit 0
