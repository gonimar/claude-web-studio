#!/bin/bash
# Synthetic brownfield fixture for e2e runs: a tiny legacy-looking Go HTTP service.
# Usage: make-brownfield.sh <target-dir> [--no-git|--empty]
# Entirely synthetic — no real domains, names or credentials.
set -euo pipefail
DIR="${1:?usage: make-brownfield.sh <target-dir> [--no-git|--empty]}"
MODE="${2:---git}"
mkdir -p "$DIR"
cd "$DIR"

if [ "$MODE" = "--empty" ]; then
  exit 0
fi

cat > go.mod <<'EOF'
module weather

go 1.16
EOF

cat > main.go <<'EOF'
package main

import (
	"encoding/json"
	"log"
	"net/http"
)

// Legacy demo service: returns a canned forecast. Deployed at api.example-corp.test/weather.
func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		city := r.URL.Query().Get("city")
		if city == "" {
			city = "Springfield"
		}
		json.NewEncoder(w).Encode(map[string]any{"city": city, "forecast": "sunny", "temp_c": 21})
	})
	log.Fatal(http.ListenAndServe(":8080", nil))
}
EOF

cat > main_test.go <<'EOF'
package main

import "testing"

func TestPlaceholder(t *testing.T) {}
EOF

cat > Dockerfile <<'EOF'
FROM golang:1.16
COPY . /src
WORKDIR /src
RUN go build -o /weather .
ENTRYPOINT ["/weather"]
EOF

cat > README.md <<'EOF'
# weather

Legacy forecast service. Production: https://api.example-corp.test/weather?city=NAME
EOF

cat > .legacy-ci.yml <<'EOF'
# leftover pipeline from a previous forge
image: golang:1.16
test:
  script: [go test ./...]
EOF

if [ "$MODE" = "--git" ]; then
  git init -q
  git -c user.email=e2e@test -c user.name=e2e add -A
  git -c user.email=e2e@test -c user.name=e2e commit -qm "import legacy weather service"
fi
