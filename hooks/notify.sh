#!/usr/bin/env bash
# Notification: desktop toast on Windows/WSL (PowerShell), macOS (osascript) or Linux (notify-send). Silent otherwise.
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
MSG=$(jget .message); [ -z "$MSG" ] && MSG="Claude Code needs your attention"
SAFE=$(echo "$MSG" | sed "s/'/''/g" | head -c 200)
if command -v powershell.exe >/dev/null 2>&1; then
  powershell.exe -NonInteractive -WindowStyle Hidden -Command "Add-Type -AssemblyName System.Windows.Forms; \$n=New-Object System.Windows.Forms.NotifyIcon; \$n.Icon=[System.Drawing.SystemIcons]::Information; \$n.BalloonTipTitle='Claude Code'; \$n.BalloonTipText='$SAFE'; \$n.Visible=\$true; \$n.ShowBalloonTip(5000); Start-Sleep 6; \$n.Dispose()" >/dev/null 2>&1 &
elif command -v osascript >/dev/null 2>&1; then osascript -e "display notification \"$SAFE\" with title \"Claude Code\"" 2>/dev/null
elif command -v notify-send >/dev/null 2>&1; then notify-send "Claude Code" "$SAFE" 2>/dev/null; fi
exit 0
