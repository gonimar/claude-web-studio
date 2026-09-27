# Go interview — read from Phase 2 when Go is the backend

Ask the questions in order, one `AskUserQuestion` each, recommendation first. Versions come from `stack-reference/go.md` at question time.

## Layout (Phase 2 step 8)
`go_layout`, with the directory tree shown:
- **project-layout** (golang-standards/project-layout adapted in `go.md`: `cmd/`, `internal/`, `pkg/` only when exported, `api/`, `configs/`, `scripts/`, `build/`, `deployments/`, `test/`) — recommended for services;
- **minimal** (`main.go` + `go.mod`) for a single tool/PoC.

## Architecture (Phase 2 step 9)
**Go architecture** (`go.md` "Architecture style"), one `AskUserQuestion` each, recommendation first:
- `go_architecture`: **layered** (`internal/domain` → `usecase` → `infrastructure`, depguard-enforced — Recommended for a service with business rules or several entry points) | modular (`internal/<domain>/`, handler → service → repository — a tool or a small service).
- When layered, the directory shape: **one use-case package per context** (Recommended) | one `usecase` package. It is shown as the tree and recorded in the layout ADR that Phase 5 proposes, not as a field.
- `go_composition_root`: **internal/app** (Recommended, the `cmd/` contract by numbers) | main (the classic shape, recorded as an accepted deviation in the layout ADR that Phase 5 proposes).
- `go_router`: **chi v5** (Recommended) | net/http ServeMux.
- `go_domain_allow`: value libraries the domain may import (default `none`, stdlib only; e.g. `github.com/google/uuid`).
- Coverage gate: **domain 90 % / usecase 80 %** (Recommended) | other numbers.
- Show the resulting tree for the chosen shape. The `.golangci.yml`, `scripts/coverage-gate.sh` and Makefile targets come from `.claude/docs/templates/go/` in `/test-setup`.
