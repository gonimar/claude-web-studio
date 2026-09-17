#!/bin/bash
# coverage-gate.sh — fails when a layer's statement coverage is below its threshold.
# Web Studio template (stack-reference/go.md "Tests by layer"); installed as scripts/coverage-gate.sh
# (chmod +x) and called from `make coverage-gate`. Run from the Go root (the directory with go.mod).
#
# Usage: scripts/coverage-gate.sh [--profile=coverage.out] <layer>=<min-percent> [...]
#   --profile=FILE  read an existing `go test -coverprofile` file (what `make test` wrote) instead of
#                   running the tests again; without it the layer's packages are tested here (-race, cgo).
#   a layer is the directory internal/<layer>/...; a layer with no packages is an error — a project
#   without that layer removes the gate from `ci` instead of letting it pass on nothing.
#   The thresholds come from the Makefile variables /test-setup set from technical-preferences.
set -u
profile=""; gates=()
for arg in "$@"; do
  case "$arg" in
    --profile=*) profile="${arg#--profile=}" ;;
    *=*) layer="${arg%%=*}"; min="${arg#*=}"
         case "$min" in ''|*[!0-9.]*) echo "coverage-gate: bad threshold in '$arg' (want <layer>=<percent>)"; exit 2 ;; esac
         [ -n "$layer" ] || { echo "coverage-gate: bad argument '$arg' (want <layer>=<percent>)"; exit 2; }
         gates+=("$arg") ;;
    *) echo "coverage-gate: bad argument '$arg' (want <layer>=<percent> or --profile=FILE)"; exit 2 ;;
  esac
done
[ "${#gates[@]}" -gt 0 ] || { echo "coverage-gate: no gates given (e.g. domain=90 usecase=80)"; exit 2; }
[ -f go.mod ] || { echo "coverage-gate: no go.mod here — run from the Go root"; exit 2; }
mod="$(go list -m)" || exit 2
if [ -n "$profile" ] && [ ! -f "$profile" ]; then echo "coverage-gate: profile $profile not found — run make test first"; exit 2; fi
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
rc=0
for gate in "${gates[@]}"; do
  layer="${gate%%=*}"; min="${gate#*=}"
  pkgs="$(go list "./internal/$layer/..." 2>/dev/null)"
  if [ -z "$pkgs" ]; then echo "coverage-gate: $layer — no packages under internal/$layer; remove the gate or add the layer"; rc=2; continue; fi
  if [ -n "$profile" ]; then
    { head -n 1 "$profile"; grep "^$mod/internal/$layer/" "$profile"; } > "$tmp/$layer.out"
  else
    # shellcheck disable=SC2086
    if ! CGO_ENABLED=1 go test -race -covermode=atomic -coverprofile="$tmp/$layer.out" $pkgs >"$tmp/$layer.log" 2>&1; then
      echo "coverage-gate: $layer — tests failed:"; tail -n 20 "$tmp/$layer.log"; rc=1; continue
    fi
  fi
  pct="$(go tool cover -func="$tmp/$layer.out" 2>/dev/null | awk '/^total:/ { sub("%", "", $3); print $3 }')"
  pct="${pct:-0}"
  if awk -v p="$pct" -v m="$min" 'BEGIN { exit !(p >= m) }'; then
    echo "coverage-gate: $layer ${pct}% >= ${min}% OK"
  else
    echo "coverage-gate: $layer ${pct}% < ${min}% — add tests to internal/$layer before this change lands"; rc=1
  fi
done
exit $rc
