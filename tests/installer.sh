#!/bin/bash
# Installer tests: --new, copy mode into an existing repo, preservation on re-install, dry-run, --seed-only.
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
check "new: gitignore consent/impact markers" 'grep -q ".claude/.write-consent" "$T/new/.gitignore" && grep -q ".claude/.impact-verdict" "$T/new/.gitignore"'
mkdir -p "$T/ex/.claude" && (cd "$T/ex" && git init -q && echo '{"hooks":{}}' > .claude/settings.json && echo "# Mine" > CLAUDE.md)
"$ROOT/install.sh" "$T/ex" --dry-run > "$T/dry.log"
check "dry-run writes nothing" '[ ! -d "$T/ex/.claude/agents" ]'
"$ROOT/install.sh" "$T/ex" >/dev/null
check "existing: settings untouched" '[ "$(cat "$T/ex/.claude/settings.json")" = "{\"hooks\":{}}" ]'
check "existing: reference settings saved" '[ -f "$T/ex/.claude/settings.web-studio.json" ]'
check "existing: CLAUDE.md untouched" '[ "$(cat "$T/ex/CLAUDE.md")" = "# Mine" ]'
# A real configured file fills the fields but keeps the template's header comment, which itself
# mentions [TO BE CONFIGURED] — a whole-file grep for the placeholder would call it unconfigured.
sed -i 's/^- \*\*Type\*\*: \[TO BE CONFIGURED\]/- **Type**: fullstack/; s/^- \*\*Language\/runtime\*\*: \[TO BE CONFIGURED\]/- **Language\/runtime**: Go 1.27/' "$T/ex/.claude/docs/technical-preferences.md"
echo "LOCAL-MARK" >> "$T/ex/.claude/docs/technical-preferences.md"
check "fixture keeps the template header comment" 'grep -q "While \[TO BE CONFIGURED\] remains" "$T/ex/.claude/docs/technical-preferences.md"'
"$ROOT/install.sh" "$T/ex" > "$T/reinstall.log"
check "re-install preserves configured technical-preferences" 'grep -q LOCAL-MARK "$T/ex/.claude/docs/technical-preferences.md"'
check "re-install keeps the configured Type field" 'grep -q "^- \*\*Type\*\*: fullstack" "$T/ex/.claude/docs/technical-preferences.md"'
check "re-install reports the file as kept" 'grep -q "technical-preferences.md: kept (configured)" "$T/reinstall.log"'
WS_NO_RSYNC=1 "$ROOT/install.sh" "$T/ex" >/dev/null
check "no rsync: configured technical-preferences still preserved" 'grep -q LOCAL-MARK "$T/ex/.claude/docs/technical-preferences.md"'
check "no rsync: other docs still seeded" '[ -f "$T/ex/.claude/docs/playbook.md" ]'
# --seed-only (plugin mode): docs/ and rules/ only, project data kept, agents left to the plugin
"$ROOT/install.sh" --new "$T/seed" >/dev/null
echo "AGENT-MARK" >> "$T/seed/.claude/agents/technical-director.md"
sed -i 's/^- \*\*Type\*\*: \[TO BE CONFIGURED\]/- **Type**: api/' "$T/seed/.claude/docs/technical-preferences.md"
echo "PREFS-MARK" >> "$T/seed/.claude/docs/technical-preferences.md"
rm -f "$T/seed/.claude/docs/playbook.md"
"$ROOT/install.sh" "$T/seed" --seed-only > "$T/seed.log"
check "seed-only: docs seeded" '[ -f "$T/seed/.claude/docs/playbook.md" ]'
check "seed-only: rules seeded" '[ -d "$T/seed/.claude/rules" ]'
check "seed-only: agents left to the plugin" 'grep -q AGENT-MARK "$T/seed/.claude/agents/technical-director.md"'
check "seed-only: configured technical-preferences kept" 'grep -q PREFS-MARK "$T/seed/.claude/docs/technical-preferences.md"'
check "seed-only: reports the file as kept" 'grep -q "technical-preferences.md: kept (configured)" "$T/seed.log"'
# --seed-only is plugin mode: the stamp belongs to copy mode only (WS-111)
rm -f "$T/seed/.claude/.web-studio-version"
"$ROOT/install.sh" "$T/seed" --seed-only > "$T/seed2.log"
check "seed-only: no version stamp written" '[ ! -f "$T/seed/.claude/.web-studio-version" ]'
check "seed-only: says so in the output" 'grep -q "no version stamp written" "$T/seed2.log"'
mkdir -p "$T/nogit"; "$ROOT/install.sh" "$T/nogit" >/dev/null 2>&1; check "refuses non-git dir" '[ $? != 0 ]'
rm -rf "$T"; echo "installer: $failn failed"; [ $failn = 0 ]
