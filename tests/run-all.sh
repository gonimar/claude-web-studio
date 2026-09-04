#!/bin/bash
# Runs every local test. Usage: tests/run-all.sh
cd "$(dirname "$0")/.." || exit 1
rc=0
echo "== syntax"; for f in hooks/*.sh templates/statusline.sh install.sh tests/*.sh; do bash -n "$f" || { echo "syntax error: $f"; rc=1; }; done
echo "== structure"; python3 tests/validate-structure.py || rc=1
echo "== hooks"; bash tests/hooks.sh || rc=1
echo "== installer"; bash tests/installer.sh || rc=1
if command -v claude >/dev/null 2>&1; then echo "== claude plugin validate"; claude plugin validate . || rc=1; else echo "== claude CLI not found, skipping plugin validate"; fi
[ $rc = 0 ] && echo "ALL TESTS PASSED" || echo "TESTS FAILED"; exit $rc
