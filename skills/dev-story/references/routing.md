# Routing — which engineer, in which order

Read from `/dev-story` Phase 3 step 2 while building the plan table: take the agent for each step's stack and layer, the layer order for a layered Go or PHP project, the lines the story result must quote, and the reviewer a public page or i18n copy adds as a step. Agent names follow coordination-rules § Skill conventions (`web-studio:<name>` in plugin mode, `<name>` in copy mode).

- Backend: `go-engineer` / `php-engineer` / `node-engineer`; GraphQL `graphql-engineer`; DB `database-engineer`.
  - Go under `go_architecture: layered`: the plan names the layer of every step, in the order domain → use case → infrastructure → composition root → transport for a vertical slice. A domain or use-case step includes its tests. The story result quotes the `coverage-gate` lines and the `golangci-lint` count. A story that would restructure existing packages is not a story: it stops here and hands off to `/refactor` in a closing `AskUserQuestion` (`/web-studio:refactor` in plugin mode; rule 11) — a refactoring has its own plan, story and branch, so it is not run from inside this one.
  - PHP under `php_architecture: layered`: the same step order by layer (domain → application → infrastructure → composition root → transport). Domain and application steps include their tests. The story result quotes the `coverage-gate:` lines and the deptrac violation count. A schema change is a migration file in the story, never DDL in a class.
- Frontend: `angular-engineer` / `vue-engineer`; styles `css-engineer`. On public pages of a content site (`Type: site`, SSR/SSG), `seo-specialist` reviews title/meta/canonical, structured data, sitemap and hreflang before the story closes; internal SPAs get no SEO review. User-facing copy with i18n keys: `accessibility-specialist` reviews the states and copy.
- Game: `threejs-engineer` / `web-game-engineer` / `multiplayer-engineer`.
- Tests: the engineers write their own; `test-engineer` handles e2e.
