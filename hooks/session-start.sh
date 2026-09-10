#!/bin/bash
# SessionStart: project context for Claude + a three-line summary for the user.
# Plain stdout of a SessionStart hook reaches Claude's context only (neither the VS Code extension nor
# the terminal shows it — WS-079), so the hook prints one JSON object: `hookSpecificOutput.additionalContext`
# carries the full block for Claude, `systemMessage` the summary Claude Code shows to the user.
# On `source: compact` the block also carries the whole active.md and the modified files (the recovery
# context — PreCompact stdout reaches nobody, WS-080).
# Work from the project root: the session cwd may be a subdirectory.
cd "${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}" 2>/dev/null || exit 0
INPUT=""; [ -t 0 ] || INPUT=$(cat)
SOURCE=$(printf '%s' "$INPUT" | grep -oE '"source"[[:space:]]*:[[:space:]]*"[a-z]+"' | head -1 | sed -E 's/.*"([a-z]+)"$/\1/')
[ -n "$SOURCE" ] || SOURCE=startup
BLOCK=""; SUM1=""; SUM2=""; SUM3=""
line() { BLOCK="$BLOCK$1"$'\n'; }
warn3() { SUM3="${SUM3:+$SUM3 · }$1"; }
line "=== Web Studio — session context (source: $SOURCE) ==="
[ -n "${CLAUDE_PLUGIN_ROOT:-}" ] && line "Plugin root: $CLAUDE_PLUGIN_ROOT"
BRANCH=$(git symbolic-ref -q --short HEAD 2>/dev/null || git rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ -n "$BRANCH" ]; then
  line "Branch: $BRANCH"; line "Recent commits:"; line "$(git log --oneline -5 2>/dev/null | sed 's/^/  /')"
  DIRTY=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' '); [ "$DIRTY" -gt 0 ] && line "Uncommitted changes: $DIRTY"
  SUM1="$BRANCH · $DIRTY uncommitted"
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
        [ "${BEHIND:-0}" -gt 0 ] && { line "Branch '$DEF' is $BEHIND commits behind origin/$DEF — run: git pull --ff-only"; SUM1="$SUM1 · $BEHIND behind origin/$DEF → git pull --ff-only"; }
      else
        [ "${AHEAD:-0}" = 0 ] && { line "Branch '$BRANCH' has no commits beyond origin/$DEF (merged or empty) — start the next story on a fresh branch: git switch $DEF && git pull --ff-only && git switch -c feat/S-NNN-slug"; SUM1="$SUM1 · merged into origin/$DEF — start a fresh branch"; }
        [ "${AHEAD:-0}" -gt 0 ] && [ "${BEHIND:-0}" -gt 0 ] && { line "Branch '$BRANCH': $AHEAD ahead, $BEHIND behind origin/$DEF"; SUM1="$SUM1 · $AHEAD ahead / $BEHIND behind origin/$DEF"; }
      fi
      STRANDED=$(git for-each-ref --format='%(refname:short) %(upstream:track)' refs/heads 2>/dev/null | grep -v "^$BRANCH " | grep -E '\[ahead' | cut -d' ' -f1 | tr '\n' ' ')
      [ -n "$STRANDED" ] && { line "Local branches with unpushed commits: $STRANDED"; warn3 "unpushed: $STRANDED"; }
    fi
  fi
else
  SUM1="not a git repository"
fi
STAGE=""; [ -f production/stage.txt ] && { STAGE=$(head -1 production/stage.txt); line "Stage: $STAGE"; }
if [ ! -f .claude/docs/technical-preferences.md ]; then
  line "Web Studio is not initialised in this project — run /web-studio:init (or /init in copy mode)."; warn3 "not initialised → /init"
elif grep -q 'TO BE CONFIGURED' .claude/docs/technical-preferences.md; then
  line "Stack not configured — run /setup-stack (new project) or /adopt (existing project)."; warn3 "stack not configured → /setup-stack or /adopt"
fi
[ -f CLAUDE.md ] && grep -q 'One paragraph: what it is' CLAUDE.md && { line "CLAUDE.md: the Project section is still the template placeholder — fill it in (one paragraph)."; warn3 "CLAUDE.md Project section is a placeholder"; }
[ -f production/roadmap.md ] && line "Roadmap: $(grep -c '^- \[ \]' production/roadmap.md 2>/dev/null) open items"
IDX=.claude/docs/stack-reference/index.md
if [ -f "$IDX" ]; then
  UPD=$(sed -n 's/^updated: *//p' "$IDX" | head -1)
  if [ -n "$UPD" ]; then
    AGE=$(( ( $(date +%s) - $(date -d "$UPD" +%s 2>/dev/null || date +%s) ) / 86400 ))
    if [ "$AGE" -gt 60 ]; then line "Stack reference is $AGE days old — consider /stack-update."; warn3 "stack reference $AGE days old → /stack-update"; else line "Stack reference: $UPD ($AGE days old)"; fi
  fi
fi
[ -f .claude/.web-studio-version ] && line "Web Studio v$(cat .claude/.web-studio-version)"
STATE=production/session-state/active.md
SUM2="Stage ${STAGE:-not set}"
if [ -f "$STATE" ]; then
  line ""
  if [ "$SOURCE" = compact ]; then
    line "=== ACTIVE SESSION STATE after compaction ($STATE, whole file) ==="; line "$(cat "$STATE")"
    line "=== Modified files ==="; line "$(git status --porcelain 2>/dev/null | sed 's/^/  /')"
    line "=== context was compacted: read $STATE and the files above before continuing ==="
  else
    line "=== ACTIVE SESSION STATE ($STATE) ==="; line "$(tail -20 "$STATE")"; line "=== read the whole file to resume ==="
  fi
  TSK=$(sed -n 's/^Task: *//p' "$STATE" | head -1); NXT=$(sed -n 's/^Next: *//p' "$STATE" | head -1)
  [ -n "$TSK" ] && SUM2="$SUM2 · Task: $TSK"; [ -n "$NXT" ] && SUM2="$SUM2 · Next: $NXT"
  G=$(sed -n 's/^Gate: *//p' "$STATE" | head -1)
  case "$G" in ""|"—"|"-"|"["*) ;; *) line "OPEN GATE (rule 7): $G — the next answer continues that skill, it is not a new task from Next:"; SUM3="OPEN GATE: $G${SUM3:+ · $SUM3}";; esac
else
  [ "$SOURCE" = compact ] && line "=== context was compacted, no $STATE — re-read the modified files: $(git status --porcelain 2>/dev/null | awk '{print $2}' | tr '\n' ' ') ==="
fi
[ "$SOURCE" = compact ] && SUM2="context compacted · $SUM2"
line "===================================="
# JSON out: additionalContext for Claude, systemMessage for the user. Works without jq (same escaping as the other hooks).
esc() { printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/\t/  /g' | awk 'NR>1{printf "\\n"} {printf "%s", $0}'; }
SUMMARY="Web Studio · $SUM1"$'\n'"$SUM2"; [ -n "$SUM3" ] && SUMMARY="$SUMMARY"$'\n'"$SUM3"
printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"},"systemMessage":"%s"}\n' "$(esc "$BLOCK")" "$(esc "$SUMMARY")"
exit 0
