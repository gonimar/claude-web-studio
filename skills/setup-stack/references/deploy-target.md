# Deploy target — read from Phase 2 step 7

Contract: `.claude/docs/deploy-target-contract.md` (the declaration fields, the two delegate forms, the verbs).

- **Deploy target**, one `AskUserQuestion`: `compose-ssh` (reference script shipped — recommended for a single server) · `kubernetes` · `cloud:<name>` · a container-platform kit if one is installed (e.g. `portainer`) · `manual`. A kit counts as installed when a `.claude/agents/*-ops.md` carries `deploy-target:` in its frontmatter or `claude plugin list --json` has a row for it; otherwise the option is not offered.
- **Deploy delegate** follows from the target: `agent <name>` (from `.claude/agents/*-ops.md` with `deploy-target:`), `script scripts/deploy/<target>.sh`, or `none`.
- `compose-ssh` adds two files to the Phase 3 write: `.claude/docs/templates/deploy/compose-ssh.sh` copied to `scripts/deploy/compose-ssh.sh`, and a new `docs/deploy/compose-ssh.md`.
- A shared host with its own proxy repository → also ask `Infra repo` and `Proxy config`.
- `--quick`: the target has no universal default, so this question is asked even in quick mode.
