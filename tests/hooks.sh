#!/bin/bash
# Smoke tests for hooks with sample PreToolUse/PostToolUse payloads. Works without jq.
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; H="$ROOT/hooks"
T="$(mktemp -d)"; cd "$T" && git init -q && git config user.email t@t && git config user.name t
pass=0; failn=0
expect() { # name expected-exit actual-exit
  if [ "$2" = "$3" ]; then pass=$((pass+1)); else failn=$((failn+1)); echo "FAIL $1: expected exit $2, got $3"; fi; }
printf 'k = "ghp_%s"\n' "$(printf 'A%.0s' $(seq 1 36))" > a.ts; git add a.ts
echo '{"tool_input":{"command":"git commit -m \"feat: x\""}}' | bash "$H/validate-commit.sh" >/dev/null 2>&1; expect "commit blocks secret-like string" 2 $?
git rm -q --cached a.ts; echo "X=1" > .env; git add .env
echo '{"tool_input":{"command":"git commit -m \"chore: x\""}}' | bash "$H/validate-commit.sh" >/dev/null 2>&1; expect "commit blocks .env" 2 $?
git rm -q --cached .env; printf 'x := 1 // TODO fix\n' > b.go; git add b.go
out=$(echo '{"tool_input":{"command":"git commit -m \"added stuff\""}}' | bash "$H/validate-commit.sh" 2>&1); code=$?
expect "commit allows with warnings" 0 $code; echo "$out" | grep -q 'Conventional Commits' || { failn=$((failn+1)); echo "FAIL commit: no Conventional Commits warning"; }
echo '{"tool_input":{"command":"git commit -m \"feat(api): add users\""}}' | bash "$H/validate-commit.sh" 2>&1 | grep -q 'COMMIT:' && { failn=$((failn+1)); echo "FAIL commit: false positive on valid message"; } || pass=$((pass+1))
echo '{"tool_input":{"command":"git push --force origin main"}}' | bash "$H/validate-push.sh" >/dev/null 2>&1; expect "push blocks --force" 2 $?
echo '{"tool_input":{"command":"git push origin feat/x"}}' | bash "$H/validate-push.sh" >/dev/null 2>&1; expect "push allows feature branch" 0 $?
echo '{"tool_input":{"command":"git push -f origin feat/x"}}' | bash "$H/validate-push.sh" >/dev/null 2>&1; expect "push blocks -f" 2 $?
printf '%s' '{"tool_input":{"command":"cat > doc.md <<EOF\nrun: git push --force origin main\nEOF\nrm -f tmp && git push origin feat/x"}}' | bash "$H/validate-push.sh" >/dev/null 2>&1; expect "push ignores heredoc text and rm -f" 0 $?
git checkout -q -b master 2>/dev/null || git checkout -q master; printf 'x\n' > d.txt; git add d.txt
out=$(echo '{"tool_input":{"command":"git commit -m \"feat: y\""}}' | bash "$H/validate-commit.sh" 2>&1); echo "$out" | grep -q 'BRANCH: committing directly' && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL commit: no warning on default branch"; }
# consent-guard: protected doc without fresh marker -> warning; with marker -> silent
out=$(echo '{"tool_input":{"file_path":"docs/architecture/adr-0001-x.md"}}' | bash "$H/consent-guard.sh" 2>&1); echo "$out" | grep -q 'CONSENT:' && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL consent: no warning without marker"; }
mkdir -p .claude && touch .claude/.write-consent
out=$(echo '{"tool_input":{"file_path":"docs/architecture/adr-0001-x.md"}}' | bash "$H/consent-guard.sh" 2>&1); echo "$out" | grep -q 'CONSENT:' && { failn=$((failn+1)); echo "FAIL consent: warned despite fresh marker"; } || pass=$((pass+1))
rm -f .claude/.write-consent
# WS-050: warnings are JSON on stdout (additionalContext + systemMessage), never bare stderr with exit 0
isjson() { python3 -c 'import json,sys; d=json.load(sys.stdin); assert d["hookSpecificOutput"]["hookEventName"]==sys.argv[1] and sys.argv[2] in d["hookSpecificOutput"]["additionalContext"] and sys.argv[2] in d["systemMessage"]' "$1" "$2" 2>/dev/null; }
echo '{"tool_input":{"file_path":"docs/architecture/adr-0001-x.md"}}' | bash "$H/consent-guard.sh" 2>/dev/null | isjson PreToolUse "CONSENT:" && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL consent: warning is not JSON additionalContext on stdout"; }
echo '{"tool_input":{"file_path":"backend/internal/auth/session.go"}}' | bash "$H/impact-guard.sh" 2>/dev/null | isjson PreToolUse "IMPACT:" && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL impact: warning is not JSON additionalContext on stdout"; }
echo '{"tool_input":{"file_path":"/x/skills/foo/SKILL.md"}}' | bash "$H/validate-skill-change.sh" 2>/dev/null | isjson PostToolUse "skill-test" && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL skill-change: warning is not JSON additionalContext on stdout"; }
echo '{"tool_input":{"command":"git push origin master"}}' | bash "$H/validate-push.sh" 2>/dev/null | isjson PreToolUse "WARNING: pushing directly" && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL push: direct-push warning is not JSON on stdout"; }
for h in consent-guard impact-guard validate-commit validate-push validate-deps validate-skill-change post-edit-check; do grep -qE '^[^#]*>&2' "$H/$h.sh" | grep -v 'exit 2' >/dev/null; if grep -nE '>&2' "$H/$h.sh" | grep -vqE 'BLOCKED|exit 2|^[0-9]+:#'; then failn=$((failn+1)); echo "FAIL $h: still warns on stderr (only exit-2 blocks may use stderr)"; else pass=$((pass+1)); fi; done
# impact-guard: security/architecture surface without fresh marker -> warning; with marker -> silent; other paths -> silent
out=$(echo '{"tool_input":{"file_path":"backend/internal/auth/session.go"}}' | bash "$H/impact-guard.sh" 2>&1); echo "$out" | grep -q 'IMPACT:' && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL impact: no warning without marker"; }
mkdir -p .claude && touch .claude/.impact-verdict
out=$(echo '{"tool_input":{"file_path":"backend/internal/auth/session.go"}}' | bash "$H/impact-guard.sh" 2>&1); echo "$out" | grep -q 'IMPACT:' && { failn=$((failn+1)); echo "FAIL impact: warned despite fresh marker"; } || pass=$((pass+1))
rm -f .claude/.impact-verdict
out=$(echo '{"tool_input":{"file_path":"frontend/src/components/Button.vue"}}' | bash "$H/impact-guard.sh" 2>&1); echo "$out" | grep -q 'IMPACT:' && { failn=$((failn+1)); echo "FAIL impact: warned on a routine path"; } || pass=$((pass+1))
out=$(echo '{"tool_input":{"file_path":"docs/architecture/threat-model.md"}}' | bash "$H/impact-guard.sh" 2>&1); echo "$out" | grep -q 'IMPACT:' && { failn=$((failn+1)); echo "FAIL impact: warned on a document (consent-guard territory)"; } || pass=$((pass+1))
# validate-deps: non-manifest path -> silent exit 0
echo '{"tool_input":{"file_path":"docs/readme.md"}}' | bash "$H/validate-deps.sh" >/dev/null 2>&1; expect "deps hook ignores non-manifests" 0 $?
# docs lane: docs: commit touching only pipeline documents on the default branch → no BRANCH warning
git commit -q -m "feat: y"; mkdir -p docs; printf 'd\n' > docs/note.md; git add docs/note.md
out=$(echo '{"tool_input":{"command":"git commit -m \"docs: threat model refresh\""}}' | bash "$H/validate-commit.sh" 2>&1); echo "$out" | grep -q 'BRANCH:' && { failn=$((failn+1)); echo "FAIL commit: docs-lane commit warned on default branch"; } || pass=$((pass+1))
git commit -q -m "docs: note"; git checkout -q -b feat/merged; printf 'm\n' > m.txt; git add m.txt; git commit -q -m "feat: merged work"; git update-ref refs/remotes/origin/master HEAD; printf 'y\n' > e.txt; git add e.txt
out=$(echo '{"tool_input":{"command":"git commit -m \"feat: z\""}}' | bash "$H/validate-commit.sh" 2>&1); echo "$out" | grep -q 'already merged into origin/master' && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL commit: no warning on merged branch"; }
git rm -q --cached e.txt; rm -f e.txt
echo '{"tool_input":{"file_path":"/x/.env","content":"A=1"}}' | bash "$H/secret-guard.sh" >/dev/null 2>&1; expect "secret-guard blocks .env" 2 $?
echo '{"tool_input":{"file_path":"/x/.env.example","content":"A="}}' | bash "$H/secret-guard.sh" >/dev/null 2>&1; expect "secret-guard allows .env.example" 0 $?
echo '{"tool_input":{"file_path":"/x/a.ts","new_string":"-----BEGIN RSA PRIVATE KEY-----"}}' | bash "$H/secret-guard.sh" >/dev/null 2>&1; expect "secret-guard blocks private key" 2 $?
echo '{"tool_input":{"file_path":"/x/a.ts","new_string":"const x = 1"}}' | bash "$H/secret-guard.sh" >/dev/null 2>&1; expect "secret-guard allows normal code" 0 $?
echo '{bad' > c.json
out=$(echo "{\"tool_input\":{\"file_path\":\"$T/c.json\"}}" | bash "$H/post-edit-check.sh" 2>&1); code=$?
expect "post-edit never blocks" 0 $code; echo "$out" | grep -q 'Invalid JSON' && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL post-edit: invalid JSON not reported"; }
# Go test smells (rules/tests.md): time.Sleep and string-compared errors in a _test.go -> warning; a clean test -> silent
printf 'package x\n\nimport ("errors"; "testing"; "time")\n\nfunc TestA(t *testing.T) {\n\ttime.Sleep(time.Second)\n\terr := errors.New("x")\n\tif err.Error() == "x" {\n\t\tt.Log("y")\n\t}\n}\n' > smell_test.go
out=$(echo "{\"tool_input\":{\"file_path\":\"$T/smell_test.go\"}}" | bash "$H/post-edit-check.sh" 2>/dev/null); code=$?
expect "post-edit test smells never block" 0 $code
echo "$out" | grep -q 'TEST-SLEEP' && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL post-edit: time.Sleep in a test not flagged"; }
echo "$out" | grep -q 'TEST-ERRSTR' && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL post-edit: string-compared error not flagged"; }
printf 'package x\n\nimport ("errors"; "testing")\n\nvar errX = errors.New("x")\n\nfunc TestB(t *testing.T) {\n\tif !errors.Is(errX, errX) {\n\t\tt.Fatal("no")\n\t}\n}\n' > clean_test.go
printf 'package x\n\nimport ("testing"; "testing/synctest"; "time")\n\n// time.Sleep(1) in a comment\nfunc TestC(t *testing.T) {\n\tsynctest.Test(t, func(t *testing.T) { time.Sleep(time.Second) })\n}\n' > synctest_test.go
out=$(echo "{\"tool_input\":{\"file_path\":\"$T/synctest_test.go\"}}" | bash "$H/post-edit-check.sh" 2>/dev/null)
echo "$out" | grep -q 'TEST-SLEEP' && { failn=$((failn+1)); echo "FAIL post-edit: time.Sleep inside synctest flagged (false positive)"; } || pass=$((pass+1))
printf 'type Subscription {\n    id: ID!\n    balance: Int!\n}\n\ntype Query {\n    getSubscription(id: ID!): Subscription\n}\n' > schema.graphqls
out=$(echo "{\"tool_input\":{\"file_path\":\"$T/schema.graphqls\"}}" | bash "$H/post-edit-check.sh" 2>/dev/null); code=$?
expect "post-edit graphql never blocks" 0 $code; echo "$out" | grep -q 'GQL-ROOT' && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL post-edit: entity named Subscription not flagged"; }
printf 'type Subscription {\n    membershipActivated: ID!\n}\n\ntype Query {\n    ping: Boolean!\n}\n' > root.graphqls
out=$(echo "{\"tool_input\":{\"file_path\":\"$T/root.graphqls\"}}" | bash "$H/post-edit-check.sh" 2>/dev/null)
echo "$out" | grep -q 'GQL-ROOT' && { failn=$((failn+1)); echo "FAIL post-edit: real root Subscription flagged (false positive)"; } || pass=$((pass+1))
out=$(echo "{\"tool_input\":{\"file_path\":\"$T/clean_test.go\"}}" | bash "$H/post-edit-check.sh" 2>/dev/null)
echo "$out" | grep -q 'TEST-' && { failn=$((failn+1)); echo "FAIL post-edit: clean test flagged (false positive)"; } || pass=$((pass+1))
# docs-format (rules/docs-format.md): structure warnings, language-independent, warn-only
mkdir -p docs/architecture production; printf '# ADR-0001: x\n\n## Context\nc\n## Decision\nd\n' > docs/architecture/adr-0001-x.md
out=$(echo "{\"tool_input\":{\"file_path\":\"$T/docs/architecture/adr-0001-x.md\"}}" | bash "$H/post-edit-check.sh" 2>/dev/null); code=$?
expect "post-edit docs-format never blocks" 0 $code; echo "$out" | grep -q 'DOCS-FORMAT' && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL post-edit: ADR with 2 sections not flagged"; }
printf '# ADR-0002: y\n\n## Kontext\nc\n## Optionen\n### 1. a\n### 2. b\n## Entscheidung\nd\n## Konsequenzen\ne\n## Verifikation\nf\n' > docs/architecture/adr-0002-y.md
out=$(echo "{\"tool_input\":{\"file_path\":\"$T/docs/architecture/adr-0002-y.md\"}}" | bash "$H/post-edit-check.sh" 2>/dev/null); echo "$out" | grep -q 'DOCS-FORMAT' && { failn=$((failn+1)); echo "FAIL post-edit: complete ADR in another language flagged (false positive)"; } || pass=$((pass+1))
printf '# Roadmap\n\n- [ ] T-1 · x\n' > production/roadmap.md
out=$(echo "{\"tool_input\":{\"file_path\":\"$T/production/roadmap.md\"}}" | bash "$H/post-edit-check.sh" 2>/dev/null); echo "$out" | grep -q 'roadmap-format' && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL post-edit: roadmap without format header not flagged"; }
printf '# R\n\n<!-- roadmap-format: v3.1 -->\n' > production/roadmap.md
out=$(echo "{\"tool_input\":{\"file_path\":\"$T/production/roadmap.md\"}}" | bash "$H/post-edit-check.sh" 2>/dev/null); echo "$out" | grep -q 'DOCS-FORMAT' && { failn=$((failn+1)); echo "FAIL post-edit: v3.1 roadmap flagged"; } || pass=$((pass+1))
rm -rf docs production
echo '{"hook_event_name":"SubagentStart","agent_type":"go-engineer"}' | bash "$H/log-agent.sh"; grep -q 'SubagentStart | go-engineer' production/session-logs/agent-audit.log && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL log-agent"; }
# Hooks must resolve the project root, not the session cwd (a subdirectory after `cd backend && …`).
mkdir -p sub; (cd sub && echo '{"hook_event_name":"SubagentStart","agent_type":"vue-engineer"}' | CLAUDE_PROJECT_DIR="$T" bash "$H/log-agent.sh")
[ -e sub/production ] && { failn=$((failn+1)); echo "FAIL log-agent: wrote relative to cwd despite CLAUDE_PROJECT_DIR"; } || { grep -q 'SubagentStart | vue-engineer' production/session-logs/agent-audit.log && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL log-agent: no entry at the project root (CLAUDE_PROJECT_DIR)"; }; }
(cd sub && echo '{"hook_event_name":"SubagentStop","agent_type":"vue-engineer"}' | env -u CLAUDE_PROJECT_DIR bash "$H/log-agent.sh")
[ -e sub/production ] && { failn=$((failn+1)); echo "FAIL log-agent: wrote relative to cwd without CLAUDE_PROJECT_DIR"; } || { grep -q 'SubagentStop | vue-engineer' production/session-logs/agent-audit.log && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL log-agent: git-toplevel fallback did not reach the root"; }; }
# session-start (WS-079): one JSON object — additionalContext for Claude, systemMessage for the user; never plain text.
jfield() { python3 -c 'import sys,json; d=json.load(sys.stdin); k=sys.argv[1]; print(d["hookSpecificOutput"]["additionalContext"] if k=="ctx" else d["systemMessage"])' "$1" 2>/dev/null; }
out=$(cd sub && echo '{"source":"startup"}' | CLAUDE_PLUGIN_ROOT="$ROOT" bash "$H/session-start.sh" 2>/dev/null); echo "$out" | jfield ctx | grep -q "Plugin root: $ROOT" && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL session-start: fails from a subdirectory or not JSON"; }
out=$(echo '{"source":"startup"}' | CLAUDE_PLUGIN_ROOT="$ROOT" bash "$H/session-start.sh" 2>/dev/null); echo "$out" | jfield ctx | grep -q "Plugin root: $ROOT" && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL session-start: plugin root not in additionalContext"; }
echo "$out" | jfield msg | grep -q "^Web Studio · " && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL session-start: no systemMessage summary for the user"; }
out=$(bash "$H/session-start.sh" </dev/null 2>/dev/null); echo "$out" | jfield msg | grep -q "Web Studio" && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL session-start: breaks without stdin"; }
mkdir -p production/session-state; printf 'Task: /sprint-plan Phase 2\nNext: x\nGate: /sprint-plan Phase 2: merge #13?\n' > production/session-state/active.md
out=$(echo '{"source":"resume"}' | CLAUDE_PLUGIN_ROOT="$ROOT" bash "$H/session-start.sh" 2>/dev/null)
echo "$out" | jfield ctx | grep -q "OPEN GATE" && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL session-start: open gate not in additionalContext"; }
echo "$out" | jfield msg | grep -q "OPEN GATE: /sprint-plan Phase 2: merge #13?" && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL session-start: open gate not in systemMessage"; }
echo "$out" | jfield msg | grep -q "Task: /sprint-plan Phase 2" && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL session-start: Task not in systemMessage"; }
# WS-080: after compaction the whole active.md and the modified files come through session-start (source compact)
printf 'Task: t\nNext: n\nGate: —\nNotes: line-21-marker\n%s\n' "$(seq 1 25 | sed 's/^/filler /')" > production/session-state/active.md; echo x > modified.txt
out=$(echo '{"source":"compact"}' | bash "$H/session-start.sh" 2>/dev/null); ctx=$(echo "$out" | jfield ctx)
echo "$ctx" | grep -q "line-21-marker" && echo "$ctx" | grep -q "modified.txt" && echo "$ctx" | grep -q "context was compacted" && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL session-start: compact source does not carry the whole active.md and modified files"; }
echo "$out" | jfield msg | grep -q "context compacted" && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL session-start: compact not named in systemMessage"; }
rm -f modified.txt; rm -rf production
bash "$H/pre-compact.sh" >/dev/null 2>&1; expect "pre-compact runs" 0 $?
[ -z "$(bash "$H/pre-compact.sh" 2>/dev/null)" ] && grep -q '^compaction ' production/session-logs/compaction.log && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL pre-compact: should only log (stdout reaches nobody)"; }
rm -rf production
bash "$H/session-stop.sh" >/dev/null 2>&1; expect "session-stop runs" 0 $?
echo '{"tool_input":{"file_path":"/x/skills/foo/SKILL.md"}}' | bash "$H/validate-skill-change.sh" >/dev/null 2>&1; expect "validate-skill-change runs" 0 $?
echo '{"model":{"display_name":"M"},"context_window":{"used_percentage":5},"workspace":{"current_dir":"'"$T"'"}}' | bash "$ROOT/templates/statusline.sh" | grep -q 'ctx: 5% | M' && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL statusline"; }
# --- 0.8.2 cases (WS-053/054/056/067/069/070) ---
echo '{}' | bash "$H/session-stop.sh" 2>/dev/null | grep -q '"systemMessage"' && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL session-stop: no JSON systemMessage"; }
bash "$H/session-stop.sh" </dev/null 2>&1 >/dev/null | grep -q . && { failn=$((failn+1)); echo "FAIL session-stop: still writes to stderr"; } || pass=$((pass+1))
rm -f .claude/.write-consent; out=$(echo '{"tool_input":{"file_path":"docs/adoption-plan-2026-01-01.md"}}' | bash "$H/consent-guard.sh" 2>&1); echo "$out" | grep -q 'CONSENT:' && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL consent-guard: adoption-plan not covered"; }
out=$(echo '{"tool_input":{"file_path":"production/roadmap.md"}}' | bash "$H/consent-guard.sh" 2>&1); echo "$out" | grep -q 'CONSENT:' && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL consent-guard: roadmap not covered"; }
echo '{"tool_input":{"command":"git push origin --delete feat/x"}}' | bash "$H/validate-push.sh" >/dev/null 2>&1; expect "push blocks --delete" 2 $?
echo '{"tool_input":{"command":"git push origin :feat/x"}}' | bash "$H/validate-push.sh" >/dev/null 2>&1; expect "push blocks :branch deletion" 2 $?
printf 'h\n' > h.txt; git add h.txt
out=$(printf '%s' '{"tool_input":{"command":"git commit -m \"$(cat <<'"'"'EOF'"'"'\ndocs: heredoc message\n\nbody line\nEOF\n)\""}}' | bash "$H/validate-commit.sh" 2>&1); echo "$out" | grep -q 'COMMIT: message is not' && { failn=$((failn+1)); echo "FAIL commit: heredoc message flagged as non-conventional"; } || pass=$((pass+1))
git commit -q -m "chore: base" 2>/dev/null; git branch -q -f master 2>/dev/null; git update-ref refs/remotes/origin/master HEAD; git checkout -q -b docs/fresh master; printf 'z\n' > f.txt; git add f.txt
out=$(echo '{"tool_input":{"command":"git commit -m \"docs: on a fresh branch\""}}' | bash "$H/validate-commit.sh" 2>&1); echo "$out" | grep -q 'already merged' && { failn=$((failn+1)); echo "FAIL commit: fresh branch reported as already merged"; } || pass=$((pass+1))
git checkout -q -b docs/lane master; printf 'v\n' > .claude-version-test; mkdir -p .claude; printf '0.8.2' > .claude/.web-studio-version; git add .claude/.web-studio-version
out=$(echo '{"tool_input":{"command":"git commit -m \"docs: sync docs\""}}' | bash "$H/validate-commit.sh" 2>&1); echo "$out" | grep -q 'BRANCH: committing directly' && { failn=$((failn+1)); echo "FAIL commit: version marker breaks the docs lane"; } || pass=$((pass+1))
# WS-101: `git add … && git commit …` in one call — the index is still empty when the hook runs
git reset -q; git checkout -q master 2>/dev/null
printf 'X=1\n' > .env
echo '{"tool_input":{"command":"git add .env && git commit -m \"feat: x\""}}' | bash "$H/validate-commit.sh" >/dev/null 2>&1; expect "commit blocks a secret file staged in the same call" 2 $?
rm -f .env
printf 'k = "ghp_%s"\n' "$(printf 'A%.0s' $(seq 1 36))" > leak.ts
echo '{"tool_input":{"command":"git add -A && git commit -m \"feat: x\""}}' | bash "$H/validate-commit.sh" >/dev/null 2>&1; expect "commit blocks a secret-like string staged in the same call" 2 $?
rm -f leak.ts
printf 'ok\n' > plain.txt
echo '{"tool_input":{"command":"git add plain.txt && git commit -m \"feat: x\""}}' | bash "$H/validate-commit.sh" >/dev/null 2>&1; expect "commit allows a clean file staged in the same call" 0 $?
# WS-102: a story ID in the scope is valid Conventional Commits, a capitalised type is not
git add plain.txt
out=$(echo '{"tool_input":{"command":"git commit -m \"feat(S-019): capitals in the scope\""}}' | bash "$H/validate-commit.sh" 2>&1); echo "$out" | grep -q 'COMMIT: message is not' && { failn=$((failn+1)); echo "FAIL commit: feat(S-019) flagged as non-conventional"; } || pass=$((pass+1))
out=$(echo '{"tool_input":{"command":"git commit -m \"Feat: capital type\""}}' | bash "$H/validate-commit.sh" 2>&1); echo "$out" | grep -q 'COMMIT: message is not' && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL commit: a capitalised type passes as Conventional Commits"; }
git reset -q
# WS-103: the documents lane reaches the push hook, everything else on the default branch still warns
git checkout -q master 2>/dev/null; git update-ref refs/remotes/origin/master HEAD
mkdir -p docs; printf 'x\n' > docs/x.md; git add docs/x.md; git commit -q -m "docs: add x"
out=$(echo '{"tool_input":{"command":"git push origin master"}}' | bash "$H/validate-push.sh" 2>&1); echo "$out" | grep -q 'WARNING: pushing directly' && { failn=$((failn+1)); echo "FAIL push: docs-lane push to master warned"; } || pass=$((pass+1))
printf 'package main\n' > app.go; git add app.go; git commit -q -m "feat: code"
out=$(echo '{"tool_input":{"command":"git push origin master"}}' | bash "$H/validate-push.sh" 2>&1); echo "$out" | grep -q 'WARNING: pushing directly' && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL push: a non-docs push to master is not warned"; }
# WS-089: a Stop with no agent type is built-in tooling, not a lost studio agent
echo '{"hook_event_name":"SubagentStop"}' | bash "$H/log-agent.sh"
grep -q 'SubagentStop | builtin' production/session-logs/agent-audit.log && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL log-agent: a Stop without a type is not marked builtin"; }
grep -q '| unknown |' production/session-logs/agent-audit.log && { failn=$((failn+1)); echo "FAIL log-agent: still writes unknown"; } || pass=$((pass+1))
# WS-085: the guards see a document written through Bash, not only through Write/Edit
rm -f .claude/.write-consent
out=$(printf '%s' '{"tool_input":{"command":"cat > production/roadmap.md <<EOF\n# Roadmap\nEOF"}}' | bash "$H/consent-guard.sh" 2>&1); echo "$out" | grep -q 'CONSENT:' && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL consent-guard: a heredoc write to a protected document is invisible"; }
out=$(printf '%s' '{"tool_input":{"command":"python3 - <<PY\nimport io\nio.open(\"docs/architecture/adr-0002-x.md\",\"w\").write(\"x\")\nPY"}}' | bash "$H/consent-guard.sh" 2>&1); echo "$out" | grep -q 'CONSENT:' && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL consent-guard: a python heredoc write is invisible"; }
mkdir -p .claude && touch .claude/.write-consent
out=$(printf '%s' '{"tool_input":{"command":"cat > production/roadmap.md <<EOF\n# Roadmap\nEOF"}}' | bash "$H/consent-guard.sh" 2>&1); echo "$out" | grep -q 'CONSENT:' && { failn=$((failn+1)); echo "FAIL consent-guard: warned on a Bash write despite a fresh marker"; } || pass=$((pass+1))
rm -f .claude/.write-consent
out=$(printf '%s' '{"tool_input":{"command":"go build ./... > /tmp/build.log 2>&1"}}' | bash "$H/consent-guard.sh" 2>&1); echo "$out" | grep -q 'CONSENT:' && { failn=$((failn+1)); echo "FAIL consent-guard: warned on an ordinary command with a redirect"; } || pass=$((pass+1))
rm -f .claude/.impact-verdict
out=$(printf '%s' '{"tool_input":{"command":"cat > backend/internal/auth/session.go <<EOF\npackage auth\nEOF"}}' | bash "$H/impact-guard.sh" 2>&1); echo "$out" | grep -q 'IMPACT:' && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL impact-guard: a heredoc write to a security surface is invisible"; }
printf '%s' '{"tool_input":{"command":"cat > .env <<EOF\nTOKEN=x\nEOF"}}' | bash "$H/secret-guard.sh" >/dev/null 2>&1; expect "secret-guard blocks a heredoc write to .env" 2 $?
printf '%s' '{"tool_input":{"command":"cat > config.yml <<EOF\ntoken: ghp_AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nEOF"}}' | bash "$H/secret-guard.sh" >/dev/null 2>&1; expect "secret-guard blocks a token inside a heredoc body" 2 $?
printf '%s' '{"tool_input":{"command":"echo ok > notes.txt"}}' | bash "$H/secret-guard.sh" >/dev/null 2>&1; expect "secret-guard allows an ordinary Bash write" 0 $?
mkdir -p production && printf '# Roadmap\n' > production/roadmap.md
out=$(printf '%s' '{"tool_input":{"command":"cat > production/roadmap.md <<EOF\n# Roadmap\nEOF"}}' | bash "$H/post-edit-check.sh" 2>&1); echo "$out" | grep -q 'DOCS-FORMAT' && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL post-edit-check: a document written through Bash is not format-checked"; }
# WS-112: `git commit -F <file>` and `-F -` — the message is read, not skipped
git checkout -q master 2>/dev/null; git reset -q
mkdir -p .claude/docs && printf 'x\n' > .claude/docs/coordination-rules.md && git add .claude/docs/coordination-rules.md
printf 'docs: update Web Studio 0.10.1 -> 0.10.2\n\nbody with `inline code`\n' > "$T/msg.txt"
out=$(echo "{\"tool_input\":{\"command\":\"git commit -F $T/msg.txt\"}}" | bash "$H/validate-commit.sh" 2>&1)
echo "$out" | grep -q 'BRANCH: committing directly' && { failn=$((failn+1)); echo "FAIL commit: -F file, docs lane not recognised"; } || pass=$((pass+1))
echo "$out" | grep -q 'COMMIT: message is not' && { failn=$((failn+1)); echo "FAIL commit: -F file message read as non-conventional"; } || pass=$((pass+1))
printf 'sync stuff\n' > "$T/bad.txt"
out=$(echo "{\"tool_input\":{\"command\":\"git commit -F $T/bad.txt\"}}" | bash "$H/validate-commit.sh" 2>&1)
echo "$out" | grep -q 'COMMIT: message is not' && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL commit: -F file with a bad message is not checked at all"; }
out=$(printf '%s' '{"tool_input":{"command":"git commit -q -F - <<EOF\ndocs: heredoc through -F\n\nbody\nEOF"}}' | bash "$H/validate-commit.sh" 2>&1)
echo "$out" | grep -q 'COMMIT: message is not' && { failn=$((failn+1)); echo "FAIL commit: -F - heredoc message read as non-conventional"; } || pass=$((pass+1))
echo "$out" | grep -q 'BRANCH: committing directly' && { failn=$((failn+1)); echo "FAIL commit: -F - heredoc, docs lane not recognised"; } || pass=$((pass+1))
git reset -q
# WS-113: the startup banner judges the stack by the Type field, not by a whole-file grep
mkdir -p .claude/docs
printf '# Technical Preferences\n\n<!-- While [TO BE CONFIGURED] remains, skills treat the stack as not chosen. -->\n\n## Project type\n- **Type**: fullstack\n' > .claude/docs/technical-preferences.md
out=$(echo '{"hook_event_name":"SessionStart","source":"startup"}' | bash "$H/session-start.sh" 2>&1)
echo "$out" | grep -q 'Stack not configured' && { failn=$((failn+1)); echo "FAIL session-start: a configured stack reported as not configured"; } || pass=$((pass+1))
printf '# Technical Preferences\n\n<!-- While [TO BE CONFIGURED] remains, skills treat the stack as not chosen. -->\n\n## Project type\n- **Type**: [TO BE CONFIGURED] (site | spa | api)\n' > .claude/docs/technical-preferences.md
out=$(echo '{"hook_event_name":"SessionStart","source":"startup"}' | bash "$H/session-start.sh" 2>&1)
echo "$out" | grep -q 'Stack not configured' && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL session-start: an unconfigured stack is not reported"; }
rm -rf .claude/docs
# WS-095: the session-state writer keeps every field, dates notes and archives the overflow
S="$H/session-state.sh"
CLAUDE_PROJECT_DIR="$T" bash "$S" set Task "S-012 repo layer" Branch feat/S-012 Next "/code-review" >/dev/null
if grep -q "^Task: S-012 repo layer" "$T/production/session-state/active.md" && grep -q "^Branch: feat/S-012" "$T/production/session-state/active.md"; then pass=$((pass+1)); else failn=$((failn+1)); echo "FAIL session-state: fields written"; fi
if grep -q "^Blocked: —" "$T/production/session-state/active.md"; then pass=$((pass+1)); else failn=$((failn+1)); echo "FAIL session-state: untouched fields kept as —"; fi
CLAUDE_PROJECT_DIR="$T" bash "$S" note "impact: chi v5 approved" >/dev/null
CLAUDE_PROJECT_DIR="$T" bash "$S" set Next "/story-done" >/dev/null
if grep -q "impact: chi v5 approved" "$T/production/session-state/active.md"; then pass=$((pass+1)); else failn=$((failn+1)); echo "FAIL session-state: a set after a note keeps the note"; fi
if grep -qE "^  - [0-9]{4}-[0-9]{2}-[0-9]{2} impact:" "$T/production/session-state/active.md"; then pass=$((pass+1)); else failn=$((failn+1)); echo "FAIL session-state: note is dated"; fi
for i in 1 2 3 4 5 6 7 8 9 10 11; do CLAUDE_PROJECT_DIR="$T" bash "$S" note "note $i" >/dev/null; done
if [ "$(grep -c "^  - " "$T/production/session-state/active.md")" = 10 ]; then pass=$((pass+1)); else failn=$((failn+1)); echo "FAIL session-state: notes capped at ten"; fi
if grep -rq "impact: chi v5 approved" "$T/production/session-state/archive/"; then pass=$((pass+1)); else failn=$((failn+1)); echo "FAIL session-state: overflow archived, not lost"; fi
CLAUDE_PROJECT_DIR="$T" bash "$S" set Nonsense x >/dev/null 2>&1; expect "session-state: unknown field refused" 2 $?
out=$(echo "{\"tool_input\":{\"file_path\":\"$T/production/session-state/active.md\"}}" | bash "$H/post-edit-check.sh" 2>&1)
echo "$out" | grep -q 'STATE:' && { failn=$((failn+1)); echo "FAIL post-edit-check: complete state reported as missing a field"; } || pass=$((pass+1))
printf 'Task: x\nNext: y\n' > "$T/production/session-state/active.md"
out=$(echo "{\"tool_input\":{\"file_path\":\"$T/production/session-state/active.md\"}}" | bash "$H/post-edit-check.sh" 2>&1)
echo "$out" | grep -q 'STATE:' && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL post-edit-check: a state missing five fields passes"; }
# WS-088: a second Start for an agent whose Stop never came is marked as a resumption
echo '{"hook_event_name":"SubagentStart","agent_type":"go-engineer","agent_id":"aid-budget-1"}' | bash "$H/log-agent.sh"
echo '{"hook_event_name":"SubagentStart","agent_type":"go-engineer","agent_id":"aid-budget-1"}' | bash "$H/log-agent.sh"
if [ "$(grep -c 'resume=1' production/session-logs/agent-audit.log)" = 1 ]; then pass=$((pass+1)); else failn=$((failn+1)); echo "FAIL log-agent: a repeated Start is not marked resume=1"; fi
echo '{"hook_event_name":"SubagentStop","agent_type":"go-engineer","agent_id":"aid-budget-1"}' | bash "$H/log-agent.sh"
echo '{"hook_event_name":"SubagentStart","agent_type":"go-engineer","agent_id":"aid-budget-1"}' | bash "$H/log-agent.sh"
if [ "$(grep -c 'resume=1' production/session-logs/agent-audit.log)" = 1 ]; then pass=$((pass+1)); else failn=$((failn+1)); echo "FAIL log-agent: a Start after a proper Stop marked as a resumption"; fi
# WS-115: the writer refuses a state file it cannot round-trip, and backs up the ones it can
printf '# Active session\n\n**Task**: rich markdown\n\n## Sprint 03 status\n- done\n' > "$T/production/session-state/active.md"
CLAUDE_PROJECT_DIR="$T" bash "$S" note "x" >/dev/null 2>&1; expect "session-state refuses a foreign file" 2 $?
if [ "$(grep -c 'Sprint 03 status' "$T/production/session-state/active.md")" = 1 ]; then pass=$((pass+1)); else failn=$((failn+1)); echo "FAIL session-state: a foreign file was overwritten"; fi
printf '<!-- x -->\nTask: —\nBranch: —\nNext: —\nGate: —\nBlocked: —\nFiles: —\nNotes: —\n' > "$T/production/session-state/active.md"
CLAUDE_PROJECT_DIR="$T" bash "$S" set Task "S-040" >/dev/null
if grep -q "^Task: S-040" "$T/production/session-state/active.md"; then pass=$((pass+1)); else failn=$((failn+1)); echo "FAIL session-state: a canonical file is no longer written"; fi
if ls "$T/production/session-state/archive"/active-*.md >/dev/null 2>&1; then pass=$((pass+1)); else failn=$((failn+1)); echo "FAIL session-state: no backup before the write"; fi
# WS-115: migrate converts a grown state file once, archiving the whole of it first
printf '# Active session\n\n**Task**: rich markdown\n**Next**: /sprint-plan 04\n\n## Sprint 03 status\n- done\n' > "$T/production/session-state/active.md"
CLAUDE_PROJECT_DIR="$T" bash "$S" migrate >/dev/null
if grep -q "^Task: rich markdown" "$T/production/session-state/active.md" && grep -q "^Next: /sprint-plan 04" "$T/production/session-state/active.md"; then pass=$((pass+1)); else failn=$((failn+1)); echo "FAIL session-state migrate: bold fields not carried over"; fi
if ls "$T/production/session-state/archive"/*premigration.md >/dev/null 2>&1 && grep -q "Sprint 03 status" "$T/production/session-state/archive"/*premigration.md; then pass=$((pass+1)); else failn=$((failn+1)); echo "FAIL session-state migrate: the previous file was not archived whole"; fi
CLAUDE_PROJECT_DIR="$T" bash "$S" note "after migration" >/dev/null
if grep -q "after migration" "$T/production/session-state/active.md"; then pass=$((pass+1)); else failn=$((failn+1)); echo "FAIL session-state: writer still refuses after a migration"; fi
# agent-stats: the numbers come from the log, prefixed and bare names are one agent
A="$H/agent-stats.sh"
mkdir -p "$T/production/session-logs"
{
  echo "2026-09-10 10:00:00 | SubagentStart | go-engineer | sid=s1 aid=a1 tuid=-"
  echo "2026-09-10 10:05:00 | SubagentStop | go-engineer | sid=s1 aid=a1 tuid=-"
  echo "2026-09-10 11:00:00 | SubagentStart | web-studio:go-engineer | sid=s1 aid=a2 tuid=-"
  echo "2026-09-10 11:30:00 | SubagentStop | web-studio:go-engineer | sid=s1 aid=a2 tuid=-"
  echo "2026-09-10 12:00:00 | SubagentStart | general-purpose | sid=s1 aid=a3 tuid=-"
  echo "2026-09-10 12:10:00 | SubagentStart | vue-engineer | sid=s1 aid=a4 tuid=-"
} > "$T/production/session-logs/agent-audit.log"
# an older line has no id field at all: `date | event | agent`
echo "2026-09-09 09:00:00 | SubagentStart | web-studio:vue-engineer" >> "$T/production/session-logs/agent-audit.log"
out=$(CLAUDE_PROJECT_DIR="$T" bash "$A" --since 2026-01-01 2>&1)
echo "$out" | grep -q "5 runs all-time" && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL agent-stats: id-less lines not counted"; }
echo "$out" | grep -q "predate the agent ids" && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL agent-stats: id-less lines not declared unmeasurable"; }
echo "$out" | grep -q "more starts than stops" && { failn=$((failn+1)); echo "FAIL agent-stats: the starts-minus-stops gap is back (it counts resumes, not losses)"; } || pass=$((pass+1))
echo "$out" | grep -q "go-engineer 2" && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL agent-stats: prefixed and bare names not merged"; }
echo "$out" | grep -q "2 agent(s) started and never closed" && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL agent-stats: unclosed agents not counted by id"; }
echo "$out" | grep -q "1 run(s) of non-studio agents" && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL agent-stats: non-studio agents not flagged"; }
rm -f "$T/production/session-logs/agent-audit.log"
out=$(CLAUDE_PROJECT_DIR="$T" bash "$A" 2>&1); echo "$out" | grep -q "no production" && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL agent-stats: no graceful message without a log"; }
cd /; rm -rf "$T"
echo "hooks: $pass passed, $failn failed"; [ $failn = 0 ]
