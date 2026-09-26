# Deploy target — read from Phase 2 step 7

Contract: `.claude/docs/deploy-target-contract.md` (the declaration fields, the two delegate forms, the verbs).

- **Deploy target**, one `AskUserQuestion`: `compose-ssh` (reference script shipped — recommended for a single server) · `kubernetes` · `cloud:<name>` · a container-platform kit if one is installed (e.g. `portainer`) · `manual`. A kit counts as installed when a `.claude/agents/*-ops.md` carries `deploy-target:` in its frontmatter or `claude plugin list --json` has a row for it; otherwise the option is not offered.
- **Deploy delegate** follows from the target: `agent <name>` (from `.claude/agents/*-ops.md` with `deploy-target:`), `script scripts/deploy/<target>.sh`, or `none`.
- `compose-ssh` adds two files to the Phase 3 write: `.claude/docs/templates/deploy/compose-ssh.sh` copied to `scripts/deploy/compose-ssh.sh`, and a new `docs/deploy/compose-ssh.md`.
- A shared host with its own proxy repository → also ask `Infra repo` and `Proxy config`.
- `--quick`: the target has no universal default, so this question is asked even in quick mode.

## Kubernetes (target `kubernetes`)
Reference: `.claude/docs/stack-reference/kubernetes.md` (versions, the deploy shape, the commands the delegate runs). One `AskUserQuestion` each, recommendation first; the answers fill the `Kubernetes` sub-block of technical-preferences (`n/a` for every other target):
- `k8s_chart_path`: **`deploy/k8s/charts/<service>`** — one chart per service (Recommended) | `charts/<service>` for a single-service repository.
- `k8s_environments`: **`staging, prod`** as `values-<env>.yaml` per chart and one namespace per environment (Recommended) | the owner's names — they must match **Environments** and the runbook.
- `k8s_secrets`: **external-secrets** — `ExternalSecret` objects against the owner's vault or cloud secret manager (Recommended) | sealed-secrets when no secret manager exists (`kubeseal`, `SealedSecret` in git) — the reason is recorded with the value.
- `k8s_routing`: **gateway-api** — `HTTPRoute` on the cluster's `Gateway` (Recommended; Ingress is frozen, ingress-nginx retired) | ingress only for a cluster without a Gateway controller — the reason and an ADR.
- The delegate is `script scripts/deploy/kubernetes.sh`, written by `devops-engineer` from `kubernetes.md` § Rollout and rollback in the story that sets up the cluster — the plugin ships no reference script for this target, so Phase 3 writes no extra file; `none` until the script exists, and the result says so.
- `--quick`: takes every Recommended value above without asking.
