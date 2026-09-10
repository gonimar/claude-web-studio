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
cd /; rm -rf "$T"
echo "hooks: $pass passed, $failn failed"; [ $failn = 0 ]
