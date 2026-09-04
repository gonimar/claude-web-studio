#!/bin/bash
# Installer tests: --new, copy mode into an existing repo, preservation on re-install, dry-run.
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; T="$(mktemp -d)"; failn=0
check() { if eval "$2"; then :; else failn=$((failn+1)); echo "FAIL $1"; fi; }
"$ROOT/install.sh" --new "$T/new" --with-testing >/dev/null
check "new: agents copied" '[ "$(ls "$T/new/.claude/agents" | wc -l)" = "$(ls "$ROOT/agents" | wc -l)" ]'
check "new: skills copied" '[ "$(ls "$T/new/.claude/skills" | wc -l)" = "$(ls "$ROOT/skills" | wc -l)" ]'
check "new: hooks.json not copied" '[ ! -f "$T/new/.claude/hooks/hooks.json" ]'
check "new: settings.json created" '[ -f "$T/new/.claude/settings.json" ]'
check "new: CLAUDE.md from template" 'grep -q "\[LANGUAGE\]" "$T/new/CLAUDE.md"'
check "new: testing copied" '[ -f "$T/new/web-studio-testing/catalog.yaml" ]'
check "new: version stamp" '[ -f "$T/new/.claude/.web-studio-version" ]'
check "new: gitignore entries" 'grep -q "production/session-state/" "$T/new/.gitignore"'
mkdir -p "$T/ex/.claude" && (cd "$T/ex" && git init -q && echo '{"hooks":{}}' > .claude/settings.json && echo "# Mine" > CLAUDE.md)
"$ROOT/install.sh" "$T/ex" --dry-run > "$T/dry.log"
check "dry-run writes nothing" '[ ! -d "$T/ex/.claude/agents" ]'
"$ROOT/install.sh" "$T/ex" >/dev/null
check "existing: settings untouched" '[ "$(cat "$T/ex/.claude/settings.json")" = "{\"hooks\":{}}" ]'
check "existing: reference settings saved" '[ -f "$T/ex/.claude/settings.web-studio.json" ]'
check "existing: CLAUDE.md untouched" '[ "$(cat "$T/ex/CLAUDE.md")" = "# Mine" ]'
sed -i 's/\[TO BE CONFIGURED\] (site/fullstack (site/; s/TO BE CONFIGURED/Go 1.27/' "$T/ex/.claude/docs/technical-preferences.md"; echo "LOCAL-MARK" >> "$T/ex/.claude/docs/technical-preferences.md"
"$ROOT/install.sh" "$T/ex" >/dev/null
check "re-install preserves configured technical-preferences" 'grep -q LOCAL-MARK "$T/ex/.claude/docs/technical-preferences.md"'
mkdir -p "$T/nogit"; "$ROOT/install.sh" "$T/nogit" >/dev/null 2>&1; check "refuses non-git dir" '[ $? != 0 ]'
rm -rf "$T"; echo "installer: $failn failed"; [ $failn = 0 ]
