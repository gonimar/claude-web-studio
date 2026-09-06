#!/bin/bash
# Stop: remind to record session state when there are uncommitted changes
# Work from the project root: the session cwd may be a subdirectory.
cd "${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}" 2>/dev/null || exit 0
D=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
S=production/session-state/active.md
if [ "$D" -gt 0 ] && [ ! -f "$S" ]; then
  echo "There are $D uncommitted changes and no $S — record where you stopped (Task:, Next:) so the next session can resume." >&2
fi
exit 0
