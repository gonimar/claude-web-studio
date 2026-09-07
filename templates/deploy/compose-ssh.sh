#!/usr/bin/env bash
# Reference deploy delegate for the `compose-ssh` target (docs/deploy-target-contract.md).
# Copied by /setup-stack to scripts/deploy/compose-ssh.sh. Configuration: docs/deploy/compose-ssh.md
# (parsed below: Host, Path, Compose file, Healthz) — no secrets; ssh uses the user's keys.
#   compose-ssh.sh status | create | deploy <tag> [--confirmed] | rollback [tag] [--confirmed] | logs [service] [--since 1h]
# The verdict line is the LAST line of stdout; exit 0 on success, 1 on FAILED.
set -euo pipefail
ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
CFG="$ROOT/docs/deploy/compose-ssh.md"
cfg() { sed -n "s/^| *$1 *| *\([^|]*\) *|.*/\1/p" "$CFG" | head -1 | sed 's/[` ]*$//;s/^[` ]*//'; }
[ -f "$CFG" ] || { echo "NOT CONFIGURED (missing $CFG)"; exit 1; }
HOST=$(cfg Host); DIR=$(cfg Path); FILE=$(cfg "Compose file"); HEALTHZ=$(cfg Healthz)
FILE=${FILE:-compose.prod.yaml}
VERB="${1:-}"; shift || true
CONFIRMED=0; ARGS=()
for a in "$@"; do case "$a" in --confirmed) CONFIRMED=1;; *) ARGS+=("$a");; esac; done
run() { ssh -o BatchMode=yes "$HOST" "cd '$DIR' && $*"; }
need_confirm() { [ "$CONFIRMED" = 1 ] || { echo "FAILED (not confirmed) — the calling skill must ask 'Proceed?' and pass --confirmed"; exit 1; }; }
case "$VERB" in
  status)
    out=$(run "docker compose -f '$FILE' ps --format 'table {{.Name}}\t{{.Image}}\t{{.Status}}'") || { echo "DEGRADED (compose ps failed)"; exit 1; }
    echo "$out"; n=$(printf '%s\n' "$out" | tail -n +2 | wc -l | tr -d ' ')
    if printf '%s' "$out" | grep -qiE 'unhealthy|restarting|exited'; then echo "DEGRADED ($n services, see above)"; exit 1; fi
    echo "RUNNING ($n services)";;
  create)
    need_confirm
    run "test -f '$FILE'" || { echo "FAILED ($FILE missing on $HOST:$DIR)"; exit 1; }
    run "docker compose -f '$FILE' up -d" && echo "CREATED";;
  deploy)
    need_confirm; TAG="${ARGS[0]:-}"; [ -n "$TAG" ] || { echo "FAILED (tag required)"; exit 1; }
    run "TAG='$TAG' docker compose -f '$FILE' pull && TAG='$TAG' docker compose -f '$FILE' up -d --remove-orphans" || { echo "FAILED (compose up, tag $TAG)"; exit 1; }
    run "docker compose -f '$FILE' ps --format 'table {{.Name}}\t{{.Image}}\t{{.Status}}'"
    if [ -n "$HEALTHZ" ]; then curl -fsS --max-time 10 "$HEALTHZ" >/dev/null && echo "healthz: ok" || { echo "FAILED (healthz $HEALTHZ, stack up with $TAG)"; exit 1; }; fi
    echo "DEPLOYED $TAG";;
  rollback)
    need_confirm; TAG="${ARGS[0]:-}"
    [ -n "$TAG" ] || TAG=$(ls "$ROOT"/production/releases/v*.md 2>/dev/null | sed 's#.*/##;s/\.md$//' | sort -V | tail -2 | head -1)
    [ -n "$TAG" ] || { echo "FAILED (no previous release tag)"; exit 1; }
    run "TAG='$TAG' docker compose -f '$FILE' pull && TAG='$TAG' docker compose -f '$FILE' up -d" || { echo "FAILED (rollback to $TAG)"; exit 1; }
    echo "ROLLED BACK $TAG";;
  logs)
    SVC=""; SINCE="1h"; i=0
    while [ $i -lt ${#ARGS[@]} ]; do case "${ARGS[$i]}" in --since) SINCE="${ARGS[$((i+1))]}"; i=$((i+2));; *) SVC="${ARGS[$i]}"; i=$((i+1));; esac; done
    out=$(run "docker compose -f '$FILE' logs --since '$SINCE' --no-color $SVC 2>&1 | tail -500"); echo "$out"; echo "LOGS ($(printf '%s\n' "$out" | wc -l | tr -d ' ') lines)";;
  env|backup) echo "NOT SUPPORTED";;
  *) sed -n 2,6p "$0"; exit 1;;
esac
