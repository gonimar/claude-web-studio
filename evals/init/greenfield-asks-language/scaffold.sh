#!/bin/bash
set -euo pipefail
git init -q . && git -c user.email=e2e@test -c user.name=e2e commit -q --allow-empty -m init
