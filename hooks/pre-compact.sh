#!/bin/bash
echo "=== SESSION STATE BEFORE COMPACTION ($(date '+%F %T')) ==="
S=production/session-state/active.md
if [ -f "$S" ]; then echo "## $S"; head -100 "$S"; else echo "## No $S — keep it to recover context after compaction."; fi
echo; echo "## Modified files"; git status --porcelain 2>/dev/null | sed 's/^/  /' || echo "  (not a git repo)"
mkdir -p production/session-logs 2>/dev/null; echo "compaction $(date '+%F %T')" >> production/session-logs/compaction.log 2>/dev/null
echo; echo "After compaction: read $S and the files listed above."
exit 0
