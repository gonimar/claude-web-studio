#!/bin/bash
# Web Studio — copy-mode installer (alternative to the Claude Code plugin).
#
#   ./install.sh /path/to/project                 install or update into <project>/.claude
#   ./install.sh /path/to/project --with-testing  also copy the agent testing framework
#   ./install.sh /path/to/project --dry-run       show what would happen
#   ./install.sh --new /path/to/new-project       create a new project from the template (git init + install)
#   ./install.sh /path/to/project --seed-only     seed docs/ and rules/ only — what plugin mode needs after
#                                                 `claude plugin update` (agents/skills/hooks come from the plugin)
#
# Copies ONLY managed files: agents, skills, hooks, rules, docs (stack-reference, templates,
# roster…), statusline, settings.json (only when absent). Project data — docs/specs,
# docs/architecture, production/, a configured technical-preferences.md, CLAUDE.md — is never
# overwritten. Prefer the plugin route when possible (see README).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
if [ "${1:-}" = "--new" ]; then NEW="${2:?Usage: ./install.sh --new /path/to/new-project}"; mkdir -p "$NEW"; [ -d "$NEW/.git" ] || git -C "$NEW" init -q; [ -f "$NEW/.gitignore" ] || printf "node_modules/\nvendor/\n.env\n.env.*\n!.env.example\n" > "$NEW/.gitignore"; set -- "$NEW" "${@:3}"; fi
TARGET="${1:?Usage: ./install.sh /path/to/project [--dry-run] [--with-testing] [--seed-only] | --new /path}"
DRY=0; WITH_TESTING=0; SEED_ONLY=0
for a in "${@:2}"; do case "$a" in --dry-run) DRY=1;; --with-testing) WITH_TESTING=1;; --seed-only) SEED_ONLY=1;; esac; done
TARGET="$(cd "$TARGET" && pwd)"
VERSION="$(python3 -c "import json;print(json.load(open('$ROOT/.claude-plugin/plugin.json'))['version'])" 2>/dev/null || grep -oE '"version": *"[^"]+"' "$ROOT/.claude-plugin/plugin.json" | head -1 | sed 's/.*"\([^"]*\)"$/\1/')"
STAMP="$TARGET/.claude/.web-studio-version"
[ -d "$TARGET/.git" ] || { echo "ERROR: $TARGET is not a git repository"; exit 1; }
MODE="install"; [ -f "$STAMP" ] && [ $SEED_ONLY = 0 ] && MODE="update ($(cat "$STAMP") -> $VERSION)"
LABEL="copy mode"; [ $SEED_ONLY = 1 ] && LABEL="seed only: docs/ and rules/"
echo "Web Studio v$VERSION ($LABEL): $MODE -> $TARGET"; [ $DRY = 1 ] && echo "(dry-run: nothing is written)"
run() { [ $DRY = 1 ] && { echo "  + $*"; return; }; "$@"; }
copy_tree() { # src dst [exclude]
  if [ $DRY = 1 ]; then echo "  + copy $1 -> $2 ${3:+(excluding $3)}"; return; fi
  mkdir -p "$2"
  if [ "${WS_NO_RSYNC:-0}" != 1 ] && command -v rsync >/dev/null 2>&1; then rsync -a ${3:+--exclude "$3"} "$1/" "$2/"; return; fi
  # No rsync: keep the excluded file byte for byte instead of warning that it may be gone.
  if [ -n "${3:-}" ] && [ -f "$2/$3" ]; then
    keep="$(mktemp)"; cp "$2/$3" "$keep"; cp -r "$1/." "$2/"; cp "$keep" "$2/$3"; rm -f "$keep"
  else cp -r "$1/." "$2/"; fi
}
# A technical-preferences.md counts as configured when its Type field is filled — the same predicate
# docs/workflow-catalog.yaml uses. A whole-file grep for the placeholder never sees a configured file:
# the template's own header comment says "While [TO BE CONFIGURED] remains…" and projects keep that line.
configured_prefs() { # file
  [ -f "$1" ] && grep -qE '^[[:space:]]*-[[:space:]]*\*\*Type\*\*:' "$1" \
    && ! grep -qE '^[[:space:]]*-[[:space:]]*\*\*Type\*\*:[[:space:]]*\[TO BE CONFIGURED\]' "$1"
}
if [ $SEED_ONLY = 0 ]; then
  copy_tree "$ROOT/agents" "$TARGET/.claude/agents"
  copy_tree "$ROOT/skills" "$TARGET/.claude/skills"
  copy_tree "$ROOT/hooks"  "$TARGET/.claude/hooks" "hooks.json"
fi
copy_tree "$ROOT/rules"  "$TARGET/.claude/rules"
if configured_prefs "$TARGET/.claude/docs/technical-preferences.md"; then
  copy_tree "$ROOT/docs" "$TARGET/.claude/docs" "technical-preferences.md"
  echo "  technical-preferences.md: kept (configured)"
else
  copy_tree "$ROOT/docs" "$TARGET/.claude/docs"
fi
if [ $SEED_ONLY = 1 ]; then
  # No stamp here. --seed-only *is* plugin mode, where `claude plugin list --json` is the source of
  # truth; a stamp would send the next /update down the copy-mode branch and, worse, would name a
  # version whose agents and skills are not in the project at all (WS-109, WS-111).
  echo; echo "Done (docs/ and rules/ seeded; agents, skills and hooks come from the plugin; no version stamp written)."; exit 0
fi
run cp "$ROOT/templates/statusline.sh" "$TARGET/.claude/statusline.sh"
[ $DRY = 1 ] || chmod +x "$TARGET/.claude/hooks/"*.sh "$TARGET/.claude/statusline.sh" 2>/dev/null || true
if [ $WITH_TESTING = 1 ]; then copy_tree "$ROOT/testing" "$TARGET/web-studio-testing" "results"; [ $DRY = 1 ] || mkdir -p "$TARGET/web-studio-testing/results"; echo "  web-studio-testing/ installed (/skill-test, /skill-improve)"; fi
if [ ! -f "$TARGET/.claude/settings.json" ]; then run cp "$ROOT/templates/settings.json" "$TARGET/.claude/settings.json"; echo "  .claude/settings.json created (hooks, permissions, statusline)"
else run cp "$ROOT/templates/settings.json" "$TARGET/.claude/settings.web-studio.json"; echo "  .claude/settings.json exists — reference saved as .claude/settings.web-studio.json; merge hooks/permissions/statusLine manually or via /adopt"; fi
if [ ! -f "$TARGET/CLAUDE.md" ]; then run cp "$ROOT/templates/CLAUDE.md.template" "$TARGET/CLAUDE.md"; echo "  CLAUDE.md created from template — set the Language section (/init asks for it)"
elif ! grep -q 'web-studio' "$TARGET/CLAUDE.md"; then echo "  CLAUDE.md exists — add the Studio/Stack/Language sections from templates/CLAUDE.md.template (/adopt offers this)"; fi
for d in docs/specs docs/architecture docs/security docs/ops production/sprints production/stories production/session-state production/session-logs; do [ -d "$TARGET/$d" ] || run mkdir -p "$TARGET/$d"; done
GI="$TARGET/.gitignore"
for line in "production/session-state/" "production/session-logs/" ".claude/settings.local.json" ".claude/agent-memory-local/" ".claude/.write-consent" ".claude/.impact-verdict" "web-studio-testing/results/" "tools/spike-*/" "*.spike/" "scratch/"; do
  if [ -f "$GI" ] && ! grep -qxF "$line" "$GI"; then [ $DRY = 1 ] && echo "  + .gitignore += $line" || echo "$line" >> "$GI"; fi
done
[ $DRY = 1 ] || printf '%s' "$VERSION" > "$STAMP"
echo; echo "Done. Next: commit, open Claude Code and run /init (sets language, then /start or /adopt)."
exit 0
