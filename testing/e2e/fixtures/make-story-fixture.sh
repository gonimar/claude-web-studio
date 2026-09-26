#!/bin/bash
# Story-ready fixture for pipeline skill runs (/dev-story, /code-review, /story-done): the synthetic
# brownfield service plus a copy-mode studio install, architecture documents, a contract, a Ready
# story S-002 and a CI workflow that only pull_request starts. Entirely synthetic.
# Usage: make-story-fixture.sh <new-dir> <variant>
#   happy         all prerequisites present, on master
#   no-strategy   docs/architecture/test-strategy.md missing (expects BLOCKED)
#   merged-spike  left on a story branch already merged at origin, local master stale and without
#                 an upstream; the story carries an open question that needs a throwaway spike
# The project lands in <new-dir>/app with a bare remote at <new-dir>/origin.git.
set -euo pipefail
KIT="$(cd "$(dirname "$0")/../../.." && pwd)"
DIR="${1:?usage: make-story-fixture.sh <new-dir> happy|no-strategy|merged-spike}"; V="${2:?variant}"
case "$V" in happy|no-strategy|merged-spike) ;; *) echo "unknown variant: $V" >&2; exit 2;; esac
[ -e "$DIR" ] && { echo "$DIR exists — pass a new directory" >&2; exit 2; }
mkdir -p "$DIR"; DIR="$(cd "$DIR" && pwd)"
bash "$KIT"/testing/e2e/fixtures/make-brownfield.sh "$DIR/app" --no-git >/dev/null
cd "$DIR/app"
G="git -c user.email=e2e@test -c user.name=e2e"
# copy-mode studio install (hooks, docs, rules)
mkdir -p .claude/hooks .claude/docs .claude/rules
cp "$KIT"/hooks/*.sh .claude/hooks/; cp "$KIT"/docs/*.md .claude/docs/; cp "$KIT"/rules/go-code.md "$KIT"/rules/tests.md "$KIT"/rules/api-contracts.md .claude/rules/
cat > CLAUDE.md <<'EOF'
# weather — project instructions
## Language
Conversation: English. Code, identifiers, commits: English.
## Project
Type: service · Stage: build · Mode: copy · go_architecture: flat (single package, legacy)
Stack: Go (stdlib net/http), no database.
EOF
cat > .gitignore <<'EOF'
production/session-state/
production/session-logs/
tools/spike-*/
.claude/.write-consent
.claude/.impact-verdict
EOF
mkdir -p docs/architecture/adr docs/specs docs/api production/stories production/session-state production/session-logs .github/workflows
cat > docs/architecture/threat-model.md <<'EOF'
# Threat model — weather
Surfaces: public GET /forecast (query params). Risks: unbounded input (city length), reflected content in JSON. Mitigations: validate city (1–64 chars, letters/space/hyphen), JSON encoding only.
EOF
cat > docs/architecture/test-strategy.md <<'EOF'
# Test strategy — weather
Unit: table-driven `go test ./...` for handlers via httptest. No e2e. Lint: `go vet ./...`. Coverage target 80 % for handler code.
EOF
cat > docs/architecture/adr/ADR-001-stdlib-http.md <<'EOF'
# ADR-001: stay on net/http, no router dependency
Status: Accepted. Handlers live in package main; each endpoint has a handler func and httptest table tests.
EOF
cat > docs/api/openapi.yaml <<'EOF'
openapi: 3.1.0
info: {title: weather, version: 0.2.0}
paths:
  /forecast:
    get:
      parameters:
        - {name: city, in: query, required: true, schema: {type: string, minLength: 1, maxLength: 64}}
        - {name: days, in: query, required: false, schema: {type: integer, minimum: 1, maximum: 7, default: 1}}
      responses:
        "200": {description: forecast list, content: {application/json: {schema: {type: object, properties: {city: {type: string}, days: {type: array, items: {type: object, properties: {day: {type: integer}, forecast: {type: string}, temp_c: {type: number}}}}}}}}}
        "400": {description: invalid city or days, content: {application/json: {schema: {type: object, properties: {error: {type: string}}}}}}
EOF
cat > docs/specs/F-001-forecast.md <<'EOF'
# F-001 Forecast API
§2 `/forecast?city=&days=` returns a list of daily forecasts (canned data is fine for now). §3 Invalid input → 400 with `{"error": "..."}`. Contract: docs/api/openapi.yaml.
EOF
cat > production/stories/S-001-health.md <<'EOF'
# Story: Health endpoint (S-001)
> Feature: F-001 · ADR: ADR-001 · Layer: backend · Size: XS · Status: Done · Started: 2026-09-20T10:00 · Actual: 0.5h
EOF
cat > production/stories/S-002-forecast-days.md <<'EOF'
# Story: Multi-day forecast endpoint (S-002)

> Feature: F-001 · ADR: ADR-001 · Layer: backend · Size: S · Status: Ready · Started: (set by `/dev-story`) · Actual: (set by `/story-done`, ⏱ on the roadmap)

## Goal
As an API client, I want `/forecast?city=X&days=N`, so that I can show a week ahead.

## Context
Contract docs/api/openapi.yaml `/forecast`; spec F-001 §2–3. Today main.go serves a single canned forecast on `/`.

## Tasks
- [ ] `/forecast` handler in its own file with input validation
- [ ] table tests with httptest

## Acceptance criteria
| # | Given / When / Then | Test (level, file) |
|---|---|---|
| 1 | GET /forecast?city=Oslo&days=3 → 200, `days` has 3 entries numbered 1..3 | unit, forecast_test.go |
| 2 | days omitted → 1 entry | unit, forecast_test.go |
| 3 | days=0 or days=8 or days=abc → 400 `{"error": …}` | unit, forecast_test.go |
| 4 | city missing or longer than 64 chars → 400 | unit, forecast_test.go |

## Security and accessibility
City validated per threat model (1–64 chars, letters/space/hyphen).
EOF
cat > .github/workflows/ci.yml <<'EOF'
name: ci
on:
  pull_request:
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with: {go-version: "1.23"}
      - run: go vet ./... && go test ./...
EOF
cat > production/session-state/active.md <<'EOF'
Task: —
Branch: —
Next: /dev-story S-002
Gate: —
Blocked: —
Files: —
Notes: —
EOF
sed -i 's/^go 1.16/go 1.22/' go.mod
if [ "$V" = no-strategy ]; then rm docs/architecture/test-strategy.md; fi
if [ "$V" = merged-spike ]; then
  cat >> production/stories/S-002-forecast-days.md <<'EOF'

## Open question
Unknown whether `encoding/json` renders a `float64` temp of `21.0` as `21` or `21.0` — clients parse `temp_c` as a number either way, but the team wants to know before choosing `float64` vs `int`. Settle it with a throwaway check before writing the handler.
EOF
fi
$G init -q -b master; $G add -A; $G commit -qm "import legacy weather service with studio docs"
git init -q --bare ../origin.git; git remote add origin ../origin.git; git config push.negotiate false; git push -q origin master
if [ "$V" = merged-spike ]; then
  git switch -q -c feat/S-001-health
  printf 'package main\n\nimport "net/http"\n\nfunc health(w http.ResponseWriter, _ *http.Request) { w.WriteHeader(http.StatusNoContent) }\n' > health.go
  $G add health.go; $G commit -qm "feat(S-001): health endpoint"; git push -q -u origin feat/S-001-health
  git switch -q master; $G merge -q --no-ff feat/S-001-health -m "Merge S-001"; git push -q origin master
  git switch -q feat/S-001-health   # left on the merged branch
  # master moved on at origin only: local master is stale
  git switch -q master; git reset -q --hard HEAD~1; git switch -q feat/S-001-health
fi
echo "fixture $V ready at $DIR/app (branch $(git branch --show-current))"
