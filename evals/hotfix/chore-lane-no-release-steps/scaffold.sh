#!/bin/bash
set -euo pipefail
bash "$(dirname "$0")/../../_lib/story-fixture.sh" happy
# the toolchain the chore is about: a pinned golangci-lint in CI that is red, on master with an origin remote
cat > .golangci.yml <<'EOY'
run:
  timeout: 3m
linters:
  enable: [govet, staticcheck]
EOY
python3 - <<'PYX'
p='.github/workflows/ci.yml'; s=open(p).read()
s=s.replace('      - run: go vet ./... && go test ./...\n',
            '      - uses: golangci/golangci-lint-action@v3\n        with: {version: v1.54.2}\n      - run: go vet ./... && go test ./...\n')
open(p,'w').write(s)
PYX
git -c user.email=e2e@test -c user.name=e2e add .golangci.yml .github/workflows/ci.yml
git -c user.email=e2e@test -c user.name=e2e commit -qm "ci: pin golangci-lint v1.54.2"
git push -q origin master
