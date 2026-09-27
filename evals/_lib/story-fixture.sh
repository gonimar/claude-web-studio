#!/bin/bash
# Scaffold helper for eval cases: builds the synthetic story-ready project of
# testing/e2e/fixtures/make-story-fixture.sh in the run's empty workspace (cwd).
# Usage (from a case's scaffold.sh): bash "$(dirname "$0")/../../_lib/story-fixture.sh" happy|no-strategy|merged-spike
set -euo pipefail
KIT="$(cd "$(dirname "$0")/../.." && pwd)"
V="${1:?variant}"
WS="$PWD"
T="$(mktemp -d)"
bash "$KIT/testing/e2e/fixtures/make-story-fixture.sh" "$T/fx" "$V" >/dev/null
cp -a "$T/fx/app/." "$WS/"
mv "$T/fx/origin.git" "$WS/.origin.git"
rm -rf "$T"
cd "$WS"
git remote set-url origin "$WS/.origin.git"
echo '.origin.git/' >> .git/info/exclude
