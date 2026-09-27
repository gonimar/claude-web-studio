#!/bin/bash
set -euo pipefail
bash "$(dirname "$0")/../../_lib/brownfield-fixture.sh" --no-git
mkdir -p .claude/docs && printf '# technical preferences\n[TO BE CONFIGURED]\n' > .claude/docs/technical-preferences.md
