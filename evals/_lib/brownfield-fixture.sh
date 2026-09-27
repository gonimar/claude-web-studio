#!/bin/bash
# Scaffold helper: the synthetic brownfield Go service of testing/e2e/fixtures/make-brownfield.sh
# in the run's empty workspace (cwd). Usage: bash "$(dirname "$0")/../../_lib/brownfield-fixture.sh" --git|--no-git
set -euo pipefail
KIT="$(cd "$(dirname "$0")/../.." && pwd)"
MODE="${1:---git}"
WS="$PWD"
T="$(mktemp -d)"
bash "$KIT/testing/e2e/fixtures/make-brownfield.sh" "$T/fx" "$MODE" >/dev/null
cp -a "$T/fx/." "$WS/"
rm -rf "$T"
