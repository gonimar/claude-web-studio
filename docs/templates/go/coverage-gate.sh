#!/bin/bash
# coverage-gate.sh — fails when a layer's statement coverage is below its threshold.
# Web Studio template (stack-reference/go.md "Tests by layer"); installed as scripts/coverage-gate.sh
# and called from `make ci`. Run from the Go root (the directory with go.mod).
#
# Usage: scripts/coverage-gate.sh [<layer>=<min-percent> ...]
#   default: domain=90 usecase=80  (technical-preferences: go_coverage_domain / go_coverage_usecase)
#   a layer is the directory internal/<layer>/...; a layer with no packages is reported and skipped.
set -u
gates="$*"; [ -z "$gates" ] && gates="domain=90 usecase=80"
[ -f go.mod ] || { echo "coverage-gate: no go.mod here — run from the Go root"; exit 2; }
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
rc=0
for gate in $gates; do
  layer="${gate%%=*}"; min="${gate#*=}"
  pkgs="$(go list "./internal/$layer/..." 2>/dev/null)"
  if [ -z "$pkgs" ]; then echo "coverage-gate: $layer — no packages under internal/$layer, skipped"; continue; fi
  # shellcheck disable=SC2086
  if ! go test -race -covermode=atomic -coverprofile="$tmp/$layer.out" $pkgs >"$tmp/$layer.log" 2>&1; then
    echo "coverage-gate: $layer — tests failed:"; tail -n 20 "$tmp/$layer.log"; rc=1; continue
  fi
  pct="$(go tool cover -func="$tmp/$layer.out" | awk '/^total:/ { sub("%", "", $3); print $3 }')"
  if awk -v p="${pct:-0}" -v m="$min" 'BEGIN { exit !(p + 0 >= m + 0) }'; then
    echo "coverage-gate: $layer ${pct}% >= ${min}% OK"
  else
    echo "coverage-gate: $layer ${pct:-0}% < ${min}% — add tests to internal/$layer before this change lands"; rc=1
  fi
done
exit $rc
