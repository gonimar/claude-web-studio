#!/bin/bash
# PostToolUse(Write|Edit|Bash): format and quick-check the edited file when tools are available. Never blocks.
# A document written with `cat > … <<EOF` gets the document-format checks too (WS-085); the code
# formatters stay on the Write/Edit path, where the call names one file and means exactly it.
. "$(dirname "$0")/written-paths.sh"
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
FILE=$(jget .tool_input.file_path)
DOCS_ONLY=0
if [ -z "$FILE" ]; then
  CMD=$(jget .tool_input.command); [ -z "$CMD" ] && exit 0
  FILE=$(written_paths "$CMD" | grep -E '(^|/)(docs|production)/' | head -1)
  [ -z "$FILE" ] && exit 0
  DOCS_ONLY=1
fi
# warn <PreToolUse|PostToolUse> <message>: a warning as JSON on stdout — additionalContext reaches the model,
# systemMessage the user; exit 0 keeps the tool allowed. stderr with exit 0 reaches neither (WS-050).
warn() {
  local m; m=$(printf '%s' "$2" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/\t/  /g' | awk 'NR>1{printf "\\n"} {printf "%s", $0}')
  printf '{"hookSpecificOutput":{"hookEventName":"%s","additionalContext":"%s"},"systemMessage":"%s"}\n' "$1" "$m" "$m"
}
[ -f "$FILE" ] || exit 0
OUT=""
# Document structure (rules/docs-format.md, warn-only, language-independent: section count and format markers, never heading text).
docfmt() { # <min second-level sections> <hint>
  local n; n=$(grep -c '^## ' "$FILE" 2>/dev/null); [ "${n:-0}" -lt "$1" ] && OUT="DOCS-FORMAT: $FILE has $n second-level sections, its template has at least $1 — $2 (rules/docs-format.md; /migrate converts, a section that does not apply stays as 'n/a — reason')"; }
case "$FILE" in
  */production/roadmap.md|production/roadmap.md) grep -q 'roadmap-format: v3' "$FILE" || OUT="DOCS-FORMAT: $FILE has no 'roadmap-format: v3.1' header — /help and /sprint-plan read the roadmap by that format; run /migrate roadmap --dry-run (rules/docs-format.md)";;
  */docs/architecture/adr-*.md|docs/architecture/adr-*.md) docfmt 5 "Context, Options (≥ 2), Decision, Consequences, Verification";;
  */docs/architecture/threat-model.md|docs/architecture/threat-model.md) docfmt 5 "Assets, boundaries, Attack surfaces, Threats (STRIDE), Verification";;
  */docs/architecture/data-model.md|docs/architecture/data-model.md) docfmt 6 "Entities, Tables, Key queries, Invariants, Migrations, Personal data (retention and deletion), Backups";;
  */docs/specs/concept-brief.md|docs/specs/concept-brief.md) docfmt 7 "the eight sections: essence, personas, pain, differentiation, MVP candidate, hypotheses, risks, next step";;
  */docs/specs/product-spec.md|docs/specs/product-spec.md) docfmt 9 "the ten numbered sections";;
  */docs/specs/features/*.md|docs/specs/features/*.md) docfmt 10 "the twelve numbered sections, Acceptance criteria as Given/When/Then";;
  */production/stories/*.md|production/stories/*.md) docfmt 5 "Goal, Context, Tasks, Acceptance criteria (table), Security and accessibility, Definition of Done";;
  */production/sprints/sprint-*.md|production/sprints/sprint-*.md) docfmt 5 "Goal, Stories, Dependency updates, Risks, QA plan, Actions, Retrospective";;
esac
[ -n "$OUT" ] && { warn PostToolUse "$OUT"; exit 0; }
[ "$DOCS_ONLY" = 1 ] && exit 0   # a Bash write names no single file to format — documents only
case "$FILE" in
  *.go)
    command -v gofmt >/dev/null && gofmt -l -w "$FILE" >/dev/null 2>&1
    command -v go >/dev/null && { V=$(cd "$(dirname "$FILE")" && go vet ./... 2>&1 | head -10); [ -n "$V" ] && OUT="go vet:\n$V"; } ;;
  *.php)
    command -v php >/dev/null && { L=$(php -l "$FILE" 2>&1 | grep -v 'No syntax errors'); [ -n "$L" ] && OUT="php -l:\n$L"; }
    [ -x vendor/bin/php-cs-fixer ] && vendor/bin/php-cs-fixer fix "$FILE" -q >/dev/null 2>&1 ;;
  *.ts|*.tsx|*.vue|*.js|*.mjs|*.scss|*.css|*.json|*.md|*.yaml|*.yml)
    if [ -f node_modules/.bin/prettier ]; then node_modules/.bin/prettier --write --log-level silent "$FILE" >/dev/null 2>&1;
    elif [ -f node_modules/.bin/biome ]; then node_modules/.bin/biome format --write "$FILE" >/dev/null 2>&1; fi
    case "$FILE" in
      *.json) command -v python3 >/dev/null && ! python3 -m json.tool "$FILE" >/dev/null 2>&1 && OUT="Invalid JSON: $FILE" ;;
      *.ts|*.tsx|*.vue|*.js|*.mjs) [ -f node_modules/.bin/eslint ] && { E=$(node_modules/.bin/eslint --no-warn-ignored --format unix "$FILE" 2>/dev/null | grep -E 'error' | head -8); [ -n "$E" ] && OUT="eslint:\n$E"; } ;;
    esac ;;
esac
[ -n "$OUT" ] && warn PostToolUse "$(printf '=== post-edit (%s) ===\n%s' "$FILE" "$OUT")"
exit 0
