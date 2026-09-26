#!/bin/bash
set -euo pipefail
bash "$(dirname "$0")/../../_lib/story-fixture.sh" happy
# a recorded Go stack with the layout fields unset (spec case 1 fixture)
mkdir -p .claude/docs
cat > .claude/docs/technical-preferences.md <<'EOF'
# Technical preferences — weather
Mode: copy · Type: service
Backend: Go 1.22, stdlib `net/http`, no database · Tests: `go test ./...` (httptest tables) · Lint: `go vet ./...` · CI: GitHub Actions
go_router: ServeMux · go_domain_allow: none · Coverage gate: handler code 80 %
(`go_architecture`, `go_composition_root`, `graphql_models`: not recorded — no layout ADR yet)
EOF
git -c user.email=e2e@test -c user.name=e2e add .claude/docs/technical-preferences.md
git -c user.email=e2e@test -c user.name=e2e commit -qm "docs: technical preferences"
