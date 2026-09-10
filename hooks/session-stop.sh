#!/bin/bash
# Stop: remind to record session state when there are uncommitted changes (visible channel: JSON systemMessage)
# Work from the project root: the session cwd may be a subdirectory.
cd "${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}" 2>/dev/null || exit 0
D=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
S=production/session-state/active.md
if [ "$D" -gt 0 ] && [ ! -f "$S" ]; then
  # JSON on stdout: systemMessage reaches the user; stderr with exit 0 reaches nobody (WS-050/WS-053).
  printf '{"systemMessage":"Web Studio: %s uncommitted changes and no %s — record where you stopped (Task:, Next:, Gate:) so the next session can resume."}\n' "$D" "$S"
fi
exit 0
