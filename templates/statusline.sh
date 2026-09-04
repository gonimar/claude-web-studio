#!/usr/bin/env bash
# Web Studio status line: ctx% | model | branch | stage | active task
input=$(cat)
if command -v jq &>/dev/null; then
  model=$(echo "$input" | jq -r '.model.display_name // "?"'); used=$(echo "$input" | jq -r '.context_window.used_percentage // empty'); cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // "."')
else
  model=$(echo "$input" | grep -oE '"display_name"\s*:\s*"[^"]*"' | head -1 | sed 's/.*: *"//;s/"//'); [ -z "$model" ] && model="?"
  used=$(echo "$input" | grep -oE '"used_percentage"\s*:\s*[0-9]+' | head -1 | sed 's/.*: *//')
  cwd=$(echo "$input" | grep -oE '"current_dir"\s*:\s*"[^"]*"' | head -1 | sed 's/.*: *"//;s/"//'); [ -z "$cwd" ] && cwd="."
fi
ctx="ctx: ${used:-–}%"
branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null)
stage=""; [ -f "$cwd/production/stage.txt" ] && stage=$(head -1 "$cwd/production/stage.txt" | tr -d '\r\n')
if [ -z "$stage" ]; then
  if   [ -f "$cwd/docs/specs/product-spec.md" ] && ls "$cwd/docs/architecture/"adr-*.md >/dev/null 2>&1; then stage="build"
  elif [ -f "$cwd/docs/specs/product-spec.md" ]; then stage="architecture"
  elif [ -f "$cwd/.claude/docs/technical-preferences.md" ] && ! grep -q 'TO BE CONFIGURED' "$cwd/.claude/docs/technical-preferences.md" 2>/dev/null; then stage="specification"
  else stage="discovery"; fi
fi
task=""; sf="$cwd/production/session-state/active.md"; [ -f "$sf" ] && task=$(sed -n 's/^Task: *//p' "$sf" | head -1)
out="${ctx} | ${model}"; [ -n "$branch" ] && [ "$branch" != "HEAD" ] && out="$out | $branch"; out="$out | $stage"; [ -n "$task" ] && out="$out | $task"
printf "%s" "$out"
