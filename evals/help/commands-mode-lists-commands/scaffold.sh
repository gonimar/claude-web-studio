#!/bin/bash
set -euo pipefail
bash "$(dirname "$0")/../../_lib/story-fixture.sh" happy
# `help commands` groups the list by the phases of the workflow catalog; the story fixture seeds docs/*.md only
KIT="$(cd "$(dirname "$0")/../../.." && pwd)"
cp "$KIT/docs/workflow-catalog.yaml" .claude/docs/
