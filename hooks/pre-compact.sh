#!/bin/bash
# PreCompact: log the moment. Nothing printed here reaches anyone — PreCompact stdout goes to the debug
# log only and the event discards systemMessage (WS-080); the recovery context after compaction comes
# from session-start.sh, which runs again as SessionStart with source "compact".
# Work from the project root: the session cwd may be a subdirectory.
cd "${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}" 2>/dev/null || exit 0
mkdir -p production/session-logs 2>/dev/null; echo "compaction $(date '+%F %T')" >> production/session-logs/compaction.log 2>/dev/null
exit 0
