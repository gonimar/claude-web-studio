#!/bin/bash
# PreToolUse(Bash): git commit checks — secret files, secret-like strings, lockfiles, TODO owners,
# Conventional Commits, branch hygiene (default branch, already-merged branch — docs/git-workflow.md)
INPUT=$(cat)
# --- json helper: jq -> python3 -> grep ---
jget() {
  if command -v jq >/dev/null 2>&1; then echo "$INPUT" | jq -r "$1 // empty" 2>/dev/null; return; fi
  if command -v python3 >/dev/null 2>&1; then
    echo "$INPUT" | python3 -c 'import sys,json
p=sys.argv[1].strip(".").split(".");d=json.load(sys.stdin)
for k in p:
  d=d.get(k) if isinstance(d,dict) else None
print(d if isinstance(d,str) else ("" if d is None else json.dumps(d)))' "$1" 2>/dev/null; return
  fi
  key="${1##*.}"; echo "$INPUT" | grep -oE "\"$key\"[[:space:]]*:[[:space:]]*\"([^\"\\\\]|\\\\.)*\"" | head -1 | sed -E "s/^\"$key\"[[:space:]]*:[[:space:]]*\"//;s/\"$//;s/\\\\\"/\"/g"
}
CMD=$(jget .tool_input.command)
echo "$CMD" | grep -qE '(^|[;&|][[:space:]]*)git[[:space:]]+commit' || exit 0
STAGED=$(git diff --cached --name-only 2>/dev/null); [ -z "$STAGED" ] && exit 0
WARN=""
SECRET_FILES=$(echo "$STAGED" | grep -E '(^|/)\.env(\..+)?$|\.pem$|\.key$|id_rsa|\.p12$|\.pfx$' | grep -vE '\.env\.(example|dist|template|sample)$' || true)
if [ -n "$SECRET_FILES" ]; then echo "BLOCKED: secret files are staged:" >&2; echo "$SECRET_FILES" | sed 's/^/  /' >&2; exit 2; fi
DIFF=$(git diff --cached -U0 2>/dev/null | grep '^+' | grep -v '^+++')
if echo "$DIFF" | grep -qE 'AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{20,}|sk-[A-Za-z0-9]{20,}|xox[baprs]-[A-Za-z0-9-]{10,}|-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----|(password|passwd|secret|api[_-]?key|token)[[:space:]]*[:=][[:space:]]*["'"'"'][^"'"'"']{12,}["'"'"']'; then
  echo "BLOCKED: staged changes contain a secret-like string. Move it to the environment (.env is not committed)." >&2
  echo "$DIFF" | grep -nE 'AKIA|ghp_|github_pat_|sk-|xox[baprs]-|PRIVATE KEY|(password|passwd|secret|api[_-]?key|token)[[:space:]]*[:=]' | head -5 | cut -c1-160 >&2
  exit 2
fi
for pair in "package.json:pnpm-lock.yaml package-lock.json yarn.lock bun.lock" "composer.json:composer.lock" "go.mod:go.sum"; do
  m=${pair%%:*}; locks=${pair#*:}
  if echo "$STAGED" | grep -qx "$m"; then ok=0; for l in $locks; do echo "$STAGED" | grep -qx "$l" && ok=1; done; [ $ok = 0 ] && WARN="$WARN\nDEPS: $m changed but no lockfile ($locks) is staged."; fi
done
for f in $(echo "$STAGED" | grep -E '\.(go|php|ts|tsx|vue|js|scss|css)$'); do
  [ -f "$f" ] && grep -nE '(TODO|FIXME|HACK)[^(]' "$f" >/dev/null 2>&1 && WARN="$WARN\nSTYLE: $f has TODO/FIXME without an owner — use TODO(name)."
done
MSG=$(echo "$CMD" | grep -oE -- "-m[[:space:]]+[\"'][^\"']*" | head -1 | sed -E "s/^-m[[:space:]]+[\"']//")
if [ -n "$MSG" ] && ! echo "$MSG" | grep -qE '^(feat|fix|perf|refactor|docs|test|build|ci|chore|style|revert)(\([a-z0-9/_-]+\))?!?: .+'; then
  WARN="$WARN\nCOMMIT: message is not Conventional Commits: '$MSG'"
fi
# Branch hygiene (docs/git-workflow.md): one story = one branch; never commit on the default
# branch or on a branch that origin's default branch already contains (the commit would strand).
BR=$(git symbolic-ref -q --short HEAD 2>/dev/null || git rev-parse --abbrev-ref HEAD 2>/dev/null)
case "$BR" in main|master|production|release) WARN="$WARN\nBRANCH: committing directly to '$BR' — studio rule: one story = one branch (feat/S-NNN-slug), see .claude/docs/git-workflow.md.";; esac
DEF=$(git symbolic-ref -q --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##')
if [ -z "$DEF" ]; then for b in master main; do git show-ref -q --verify "refs/remotes/origin/$b" && { DEF=$b; break; }; done; fi
if [ -n "$DEF" ] && [ -n "$BR" ] && [ "$BR" != "$DEF" ] && git merge-base --is-ancestor "$BR" "origin/$DEF" 2>/dev/null; then
  WARN="$WARN\nBRANCH: '$BR' is already merged into origin/$DEF — this commit will strand; start a new branch from $DEF (git switch $DEF && git pull --ff-only && git switch -c feat/S-NNN-slug)."
fi
[ -n "$WARN" ] && echo -e "=== Commit warnings ===$WARN\n=======================" >&2
exit 0
