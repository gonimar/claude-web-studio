#!/bin/bash
set -euo pipefail
bash "$(dirname "$0")/../../_lib/story-fixture.sh" happy
mkdir -p .claude/docs
cat > .claude/docs/technical-preferences.md <<'EOF'
# Technical preferences — weather
Mode: copy · Type: service
Backend: Go 1.22, stdlib `net/http`, no database · Tests: `go test ./...` (httptest tables) · Lint: `go vet ./...` · CI: GitHub Actions
go_router: ServeMux · go_domain_allow: none · Coverage gate: handler code 80 %
(`go_architecture`, `go_composition_root`, `graphql_models`: not recorded — no layout ADR yet)
EOF
# two test smells from rules/tests.md, in a test that still compiles and passes
cat > main_test.go <<'EOT'
package main

import (
	"errors"
	"testing"
	"time"
)

func TestPlaceholder(t *testing.T) {
	time.Sleep(time.Millisecond)
	err := errors.New("city missing")
	if err.Error() != "city missing" {
		t.Fatal(err)
	}
}
EOT
git -c user.email=e2e@test -c user.name=e2e add .claude/docs/technical-preferences.md main_test.go
git -c user.email=e2e@test -c user.name=e2e commit -qm "test: sleeping placeholder test; docs: technical preferences"
