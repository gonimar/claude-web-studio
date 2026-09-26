#!/bin/bash
# The documents lane (docs/git-workflow.md § Documents), shared by validate-commit.sh (may this
# commit sit on the default branch?) and validate-push.sh (may this push go straight to it?).
# Kept in one file so the two hooks can never disagree about what a document is.
DOC_SUBJECT_RE='^docs(\([A-Za-z0-9/_.-]+\))?!?: '
# The API contract is a pipeline document wherever /setup-stack or /adopt put it (`api_contract_path`): a Go
# module keeps the SDL at api/schema.graphqls so gqlgen reads it in place, gqlgen's own default is
# graph/schema.graphqls, a REST contract sits at api/openapi.yaml (go.md § api/), every other stack under
# docs/architecture/api/ (already inside docs/, listed for clarity). Other files under api/ and graph/ are
# code, and a contract at any path not listed here is outside the lane: /api-contract commits it as
# chore(contract) on a chore/<slug> branch. This list is the source of truth for docs/git-workflow.md § Rules.
# Agent memory (.claude/agent-memory/**, `memory: project`) changes on every agent run and rides the commit of the
# work that produced it (git-workflow § Agent memory); a docs: commit of an audit that only moved memory files is the
# documents lane too. .claude/agent-memory-local/ is gitignored and never committed.
DOC_PATH_RE='^(docs/|docs/architecture/api/|production/|CLAUDE\.md$|\.claude/docs/|\.claude/rules/|\.claude/agent-memory/|\.claude/\.web-studio-version$|README|CHANGELOG\.md$|api/schema\.graphqls$|graph/schema\.graphqls$|api/openapi\.yaml$)'

# docs_lane_paths: reads paths on stdin, returns 0 when every one of them is a pipeline document.
docs_lane_paths() { ! grep -v '^$' | grep -qvE "$DOC_PATH_RE"; }

# docs_lane_commit <sha>: 0 when the commit's subject is a docs: one and it touches documents only.
docs_lane_commit() {
  git log -1 --format=%s "$1" 2>/dev/null | grep -qE "$DOC_SUBJECT_RE" || return 1
  git show --name-only --format= "$1" 2>/dev/null | docs_lane_paths
}
