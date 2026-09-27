#!/bin/bash
set -euo pipefail
bash "$(dirname "$0")/../../_lib/story-fixture.sh" happy
# on master with an origin remote, no v* tag and no production/releases/: the deployed release the
# hotfix branches from cannot be resolved, so the skill has to stop before any branch or write
