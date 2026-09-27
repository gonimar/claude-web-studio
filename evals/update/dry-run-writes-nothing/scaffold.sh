#!/bin/bash
set -euo pipefail
bash "$(dirname "$0")/../../_lib/story-fixture.sh" happy
# copy-mode markers the skill detects: an older version stamp and the director agent
KIT="$(cd "$(dirname "$0")/../../.." && pwd)"
mkdir -p .claude/agents && cp "$KIT/agents/technical-director.md" .claude/agents/
printf '0.12.0\n' > .claude/.web-studio-version
