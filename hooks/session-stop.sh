#!/bin/bash
# Stop: remind to record session state when there are uncommitted changes
D=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
S=production/session-state/active.md
if [ "$D" -gt 0 ] && [ ! -f "$S" ]; then
  echo "There are $D uncommitted changes and no $S — record where you stopped (Task:, Next:) so the next session can resume." >&2
fi
exit 0
