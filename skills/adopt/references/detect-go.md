# /adopt — Go detection (Phase 1 step 3)

Read from `SKILL.md` Phase 1 step 3 when `go.mod` exists. Record the fields named in bold; findings go into the facts table and the adoption plan.

- Layout: compare the tree with `go.md` "Project layout" (golang-standards/project-layout adapted). `src/`, `utils/`/`common/`, logic in `cmd/`, an unused `pkg/` → INFO/MEDIUM findings with a migration note. Record the actual variant as **`go_layout`**; never restructure during adoption.
- Architecture style, from the tree and the dependency graph, never from a wish or from folder names alone:
  - `internal/domain/` + `internal/usecase/` present (or the go-clean-template spelling `internal/entity/` + `internal/usecase/` + `internal/repo/`) **and** the graph is clean → **`go_architecture: layered`**. Clean means `go list -deps ./internal/domain/... | grep '<module>/internal/' | grep -v internal/domain` prints nothing (`internal/entity` in the go-clean-template spelling), and usecase reaches neither infrastructure nor app (the `arch-check` target).
  - A layered tree with cross-layer imports → `modular`, with an INFO "layered by name, N cross-layer imports — /refactor layout".
  - Otherwise `modular`.
- **`go_router`** from `go.mod` (chi; none → ServeMux).
- **`graphql_models`** from `gqlgen.yml` (`models:` bound to `internal/domain` → bind, else dto).
- A `.golangci.yml` in v1 format (`linters-settings:`, no `version: "2"`) → MEDIUM finding: golangci-lint v2 rejects it.
- Moving to `layered` is offered as `/refactor layout` in the adoption plan, never done here.
