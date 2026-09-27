#!/bin/bash
set -euo pipefail
bash "$(dirname "$0")/../../_lib/story-fixture.sh" happy
cat >> production/stories/S-002-forecast-days.md <<'EOS'

## Acceptance criteria (addendum)
- [ ] `GET /forecast` gains a required `units` query parameter (`metric|imperial`) — add it to `docs/api/openapi.yaml` and reject requests without it with 400.
EOS
git -c user.email=e2e@test -c user.name=e2e commit -qam 'docs: S-002 criteria addendum'
