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
git commit -q -m "feat: y"; git checkout -q -b feat/merged; git update-ref refs/remotes/origin/master HEAD; printf 'y\n' > e.txt; git add e.txt
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
out=$(CLAUDE_PLUGIN_ROOT="$ROOT" bash "$H/session-start.sh" 2>&1); echo "$out" | grep -q "Plugin root: $ROOT" && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL session-start: plugin root not printed"; }
bash "$H/pre-compact.sh" >/dev/null 2>&1; expect "pre-compact runs" 0 $?
bash "$H/session-stop.sh" >/dev/null 2>&1; expect "session-stop runs" 0 $?
echo '{"tool_input":{"file_path":"/x/skills/foo/SKILL.md"}}' | bash "$H/validate-skill-change.sh" >/dev/null 2>&1; expect "validate-skill-change runs" 0 $?
echo '{"model":{"display_name":"M"},"context_window":{"used_percentage":5},"workspace":{"current_dir":"'"$T"'"}}' | bash "$ROOT/templates/statusline.sh" | grep -q 'ctx: 5% | M' && pass=$((pass+1)) || { failn=$((failn+1)); echo "FAIL statusline"; }
cd /; rm -rf "$T"
echo "hooks: $pass passed, $failn failed"; [ $failn = 0 ]
