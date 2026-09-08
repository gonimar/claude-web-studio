#!/bin/bash
# Executable behaviour tests (testing/e2e/). NOT part of run-all.sh: each branch spends real
# model turns. Run before a release or after editing a skill a branch covers.
#   tests/e2e.sh --branch B9 [--keep]
#   tests/e2e.sh --all
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
E2E="$ROOT/testing/e2e"
WORK="${E2E_WORKDIR:-$(mktemp -d)}"
BRANCH=""; KEEP=0; ALL=0
while [ $# -gt 0 ]; do case "$1" in
  --branch) BRANCH="$2"; shift 2;;
  --all) ALL=1; shift;;
  --keep) KEEP=1; shift;;
  *) echo "unknown arg $1"; exit 2;;
esac; done
[ -n "$BRANCH" ] || [ "$ALL" = 1 ] || { echo "usage: e2e.sh --branch BX | --all"; exit 2; }

fixture() { # fixture <name> <mode> -> dir; studio installed in copy mode
  local d="$WORK/$1"
  bash "$E2E/fixtures/make-brownfield.sh" "$d" "$2"
  "$ROOT/install.sh" "$d" >/dev/null
  echo "$d"
}

run_b9() {
  local d; d="$(fixture b9 --git)"
  mkdir -p "$d/docs/architecture" "$d/production/stories/F-001"
  printf '# Threat model\nSTRIDE stub for e2e.\n' > "$d/docs/architecture/threat-model.md"
  printf 'build\n' > "$d/production/stage.txt"
  for n in 1 2 3 4; do printf '# S-00%s\nStatus: Ready\n' "$n" > "$d/production/stories/F-001/S-00$n-stub.md"; done
  printf '# CLAUDE.md\n## Language\nConversation language: English.\n' > "$d/CLAUDE.md"
  bash "$E2E/drive.sh" "$d" "/dev-story S-001" 1 "--lang en"
  python3 "$E2E/check.py" --branch B9 "$d" "$d".t*.jsonl
}

run_b4() {
  local d; d="$(fixture b4 --no-git)"
  bash "$E2E/drive.sh" "$d" "/adopt full" 3 "--lang en"
  python3 "$E2E/check.py" --branch B4 "$d" "$d".t*.jsonl
}

case "${BRANCH^^}" in
  B9) run_b9;;
  B4) run_b4;;
  "") ;;
  *) echo "branch $BRANCH: no automated flow yet — drive it manually with testing/e2e/drive.sh and assert with check.py (see scenario-pipeline.md)"; exit 2;;
esac
if [ "$ALL" = 1 ]; then run_b9; run_b4; fi
[ "$KEEP" = 1 ] || rm -rf "$WORK"
echo "E2E DONE"
