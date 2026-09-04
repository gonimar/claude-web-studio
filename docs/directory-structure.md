# Directory Layout (recommended, not enforced)

The studio does not dictate where code lives: real paths are recorded in
`.claude/docs/technical-preferences.md` (section "Layout"), and rules in `.claude/rules/`
are bound to file extensions, not directories.

```text
/
├── CLAUDE.md                     # project rules (language, stack, principles)
├── .claude/                      # docs (stack-reference, templates, roster…), rules; agents/skills/hooks in copy mode
├── docs/
│   ├── specs/                    # product-spec.md, features/*.md, ux/*.md, design-system.md, game-concept.md
│   ├── architecture/             # adr-NNNN-*.md, api/schema.graphql | openapi.yaml, data-model.md, threat-model.md, test-strategy.md
│   ├── security/                 # audits, pentest reports, hardening checklist
│   ├── ops/                      # runbooks, deploy.md, perf audits, incidents/
│   └── web-studio/README.md      # how the studio is used in this project
├── production/
│   ├── roadmap.md                # plan source of truth (checkbox list)
│   ├── stage.txt                 # discovery | specification | architecture | build | hardening | release | operate
│   ├── review-mode.txt           # full | lean | solo
│   ├── sprints/ stories/ releases/
│   ├── session-state/active.md   # session state (gitignored)
│   └── session-logs/             # agent audit trail (gitignored)
├── backend/ | api/ | src/        # server code (Go: cmd/, internal/; PHP: src/, config/, public/)
├── frontend/ | web/ | src/app/   # client (Angular / Vue / Nuxt)
├── game/                         # game client (three.js / Pixi) when the game is a separate package
├── packages/                     # shared monorepo packages (types, contracts, UI kit)
├── tests/ e2e/                   # integration and e2e tests
├── docker/ Dockerfile* compose*  # containers
└── .github/workflows/            # CI
```

Monorepo (pnpm workspaces / Go workspace) is the default for projects with a client and a
server; separate repositories when release cycles differ.
