#!/bin/bash
set -euo pipefail
bash "$(dirname "$0")/../../_lib/story-fixture.sh" happy
printf 'Task: S-002 Multi-day forecast endpoint\nBranch: —\nNext: /story-done\nGate: —\n' > production/session-state/active.md
