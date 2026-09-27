#!/bin/bash
# PreToolUse(mcp__(plugin_web-studio_)?github__.*): the GitHub MCP server's `repos` toolset can commit
# to any branch through the API (push_files, create_or_update_file, delete_file) — past validate-commit,
# validate-push and the branch rules. Commits go through git; the API is for PRs, reviews and runs.
INPUT=$(cat)
TOOL=$(echo "$INPUT" | grep -oE '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/^"tool_name"[[:space:]]*:[[:space:]]*"//;s/"$//')
case "$TOOL" in
  mcp__*github__push_files|mcp__*github__create_or_update_file|mcp__*github__delete_file)
    echo "BLOCKED: $TOOL writes to the repository through the GitHub API, past the commit and push hooks. Commit on a branch with git and push; the GitHub MCP is for PRs, reviews and runs." >&2; exit 2;;
esac
exit 0
