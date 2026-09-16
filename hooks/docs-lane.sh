#!/bin/bash
# The documents lane (docs/git-workflow.md § Documents), shared by validate-commit.sh (may this
# commit sit on the default branch?) and validate-push.sh (may this push go straight to it?).
# Kept in one file so the two hooks can never disagree about what a document is.
DOC_SUBJECT_RE='^docs(\([A-Za-z0-9/_.-]+\))?!?: '
DOC_PATH_RE='^(docs/|production/|CLAUDE\.md$|\.claude/docs/|\.claude/rules/|\.claude/\.web-studio-version$|README|CHANGELOG\.md$)'

# docs_lane_paths: reads paths on stdin, returns 0 when every one of them is a pipeline document.
docs_lane_paths() { ! grep -v '^$' | grep -qvE "$DOC_PATH_RE"; }

# docs_lane_commit <sha>: 0 when the commit's subject is a docs: one and it touches documents only.
docs_lane_commit() {
  git log -1 --format=%s "$1" 2>/dev/null | grep -qE "$DOC_SUBJECT_RE" || return 1
  git show --name-only --format= "$1" 2>/dev/null | docs_lane_paths
}
