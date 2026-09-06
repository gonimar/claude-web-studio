#!/bin/bash
# SessionStart: project context, branch hygiene vs origin, stack-reference freshness, plugin root for /init
echo "=== Web Studio — session context ==="
[ -n "${CLAUDE_PLUGIN_ROOT:-}" ] && echo "Plugin root: $CLAUDE_PLUGIN_ROOT"
BRANCH=$(git symbolic-ref -q --short HEAD 2>/dev/null || git rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ -n "$BRANCH" ]; then
  echo "Branch: $BRANCH"; echo "Recent commits:"; git log --oneline -5 2>/dev/null | sed 's/^/  /'
  DIRTY=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' '); [ "$DIRTY" -gt 0 ] && echo "Uncommitted changes: $DIRTY"
  # Branch hygiene (docs/git-workflow.md): compare with origin's default branch so a session never
  # continues on a branch that is already merged, or on a stale default branch.
  if git remote get-url origin >/dev/null 2>&1; then
    if command -v timeout >/dev/null 2>&1; then timeout 5 git fetch -q origin 2>/dev/null || true; else git fetch -q origin 2>/dev/null || true; fi
    DEF=$(git symbolic-ref -q --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##')
    if [ -z "$DEF" ]; then for b in master main; do git show-ref -q --verify "refs/remotes/origin/$b" && { DEF=$b; break; }; done; fi
    if [ -n "$DEF" ]; then
      AB=$(git rev-list --left-right --count "$BRANCH...origin/$DEF" 2>/dev/null)
      AHEAD=${AB%%[[:space:]]*}; BEHIND=${AB##*[[:space:]]}
      if [ "$BRANCH" = "$DEF" ]; then
        [ "${BEHIND:-0}" -gt 0 ] && echo "Branch '$DEF' is $BEHIND commits behind origin/$DEF — run: git pull --ff-only"
      else
        [ "${AHEAD:-0}" = 0 ] && echo "Branch '$BRANCH' has no commits beyond origin/$DEF (merged or empty) — start the next story on a fresh branch: git switch $DEF && git pull --ff-only && git switch -c feat/S-NNN-slug"
        [ "${AHEAD:-0}" -gt 0 ] && [ "${BEHIND:-0}" -gt 0 ] && echo "Branch '$BRANCH': $AHEAD ahead, $BEHIND behind origin/$DEF"
      fi
      STRANDED=$(git for-each-ref --format='%(refname:short) %(upstream:track)' refs/heads 2>/dev/null | grep -v "^$BRANCH " | grep -E '\[ahead' | cut -d' ' -f1 | tr '\n' ' ')
      [ -n "$STRANDED" ] && echo "Local branches with unpushed commits: $STRANDED"
    fi
  fi
fi
[ -f production/stage.txt ] && echo "Stage: $(head -1 production/stage.txt)"
if [ ! -f .claude/docs/technical-preferences.md ]; then
  echo "Web Studio is not initialised in this project — run /web-studio:init (or /init in copy mode)."
elif grep -q 'TO BE CONFIGURED' .claude/docs/technical-preferences.md; then
  echo "Stack not configured — run /setup-stack (new project) or /adopt (existing project)."
fi
[ -f CLAUDE.md ] && grep -q 'One paragraph: what it is' CLAUDE.md && echo "CLAUDE.md: the Project section is still the template placeholder — fill it in (one paragraph)."
[ -f production/roadmap.md ] && echo "Roadmap: $(grep -c '^- \[ \]' production/roadmap.md 2>/dev/null) open items"
IDX=.claude/docs/stack-reference/index.md
if [ -f "$IDX" ]; then
  UPD=$(sed -n 's/^updated: *//p' "$IDX" | head -1)
  if [ -n "$UPD" ]; then
    AGE=$(( ( $(date +%s) - $(date -d "$UPD" +%s 2>/dev/null || date +%s) ) / 86400 ))
    if [ "$AGE" -gt 60 ]; then echo "Stack reference is $AGE days old — consider /stack-update."; else echo "Stack reference: $UPD ($AGE days old)"; fi
  fi
fi
[ -f .claude/.web-studio-version ] && echo "Web Studio v$(cat .claude/.web-studio-version)"
STATE=production/session-state/active.md
if [ -f "$STATE" ]; then echo; echo "=== ACTIVE SESSION STATE ($STATE) ==="; tail -20 "$STATE"; echo "=== read the whole file to resume ==="; fi
echo "===================================="
exit 0
