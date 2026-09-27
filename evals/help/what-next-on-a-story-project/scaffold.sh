#!/bin/bash
set -euo pipefail
bash "$(dirname "$0")/../../_lib/story-fixture.sh" happy
# /help reads the workflow catalog; the story fixture seeds docs/*.md only
KIT="$(cd "$(dirname "$0")/../../.." && pwd)"
cp "$KIT/docs/workflow-catalog.yaml" .claude/docs/
# the kit's technical-preferences.md is a placeholder; a configured Type keeps NEXT on the pipeline, not on /adopt full
sed -i 's/^- \*\*Type\*\*: \[TO BE CONFIGURED\].*/- **Type**: api/' .claude/docs/technical-preferences.md
