#!/bin/bash
set -euo pipefail
bash "$(dirname "$0")/../../_lib/brownfield-fixture.sh" --git
