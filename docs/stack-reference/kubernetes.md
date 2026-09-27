---
updated: 2026-09-26
sources: [https://github.com/kubernetes/website/blob/main/data/releases/schedule.yaml (kubernetes.io/releases), https://github.com/kubernetes/website/blob/main/content/en/releases/version-skew-policy.md, https://github.com/kubernetes/website/blob/main/content/en/releases/release.md, https://github.com/kubernetes/website/blob/main/content/en/releases/patch-releases.md, https://dl.k8s.io/release/stable.txt, https://github.com/kubernetes/kubernetes (tags v1.37.1, v1.34.12), https://github.com/kubernetes/website/blob/main/content/en/docs/concepts/workloads/pods/probes.md, https://github.com/kubernetes/website/blob/main/content/en/docs/concepts/workloads/pods/pod-lifecycle.md, https://github.com/kubernetes/website/blob/main/content/en/docs/concepts/security/pod-security-standards.md, https://github.com/kubernetes/website/blob/main/content/en/docs/concepts/services-networking/ingress.md, https://github.com/kubernetes/website/blob/main/content/en/docs/concepts/services-networking/network-policies.md, https://github.com/kubernetes/website/blob/main/content/en/docs/reference/access-authn-authz/rbac.md, https://github.com/kubernetes/website/blob/main/content/en/docs/concepts/containers/images.md, https://github.com/kubernetes/website/blob/main/content/en/docs/concepts/workloads/controllers/deployment.md, https://github.com/kubernetes/website/blob/main/content/en/docs/tasks/run-application/configure-pdb.md, https://github.com/kubernetes/website/blob/main/content/en/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough.md, https://github.com/kubernetes/website/blob/main/content/en/docs/tasks/configure-pod-container/configure-service-account.md, https://github.com/kubernetes-sigs/gateway-api (README.md, tag v1.6.2), https://github.com/kubernetes/ingress-nginx/blob/main/README.md, https://github.com/helm/helm-www (docs/topics/version_skew.mdx, blog/2025-11-17-helm-4-released, blog/2026-06-02-helm3-eol.md, docs/helm/helm_upgrade.md, docs/helm/helm_rollback.md, docs/chart_best_practices/values.md, docs/chart_best_practices/labels.md), https://github.com/helm/helm (tags v4.0.0, v4.3.0, v3.22.0), https://github.com/external-secrets/external-secrets (tag v2.11.0), https://github.com/bitnami-labs/sealed-secrets (README.md, tag v0.40.0)]
---
# Kubernetes — versions, the studio deploy shape, practices

The `kubernetes` deploy target (`technical-preferences.md` → Infrastructure; contract `deploy-target-contract.md`).
Everything here assumes the endpoints of `observability.md` (`/healthz`, `/readyz`, `/metrics`) and the images of
`tooling-devops.md` (multi-stage, non-root, digest-pinned). On the date kubernetes.io and helm.sh were unreachable from
the refresh environment; the facts come from the sites' source repositories (`kubernetes/website`, `helm/helm-www`),
`dl.k8s.io` and the git tag dates.

## Versions and support dates (2026-09-26)
| Minor | Released | Latest patch | Maintenance mode from | End of life |
|---|---|---|---|---|
| **1.37** | 2026-08-26 | 1.37.1 (2026-09-23) — `dl.k8s.io/release/stable.txt` | 2027-08-28 | 2027-10-28 |
| 1.36 | 2026-04-22 | 1.36.5 (2026-09-23) | 2027-04-28 | 2027-06-28 |
| 1.35 | 2025-12-17 | 1.35.9 (2026-09-23) | 2026-12-28 | 2027-02-28 |
| 1.34 | 2025-08-27 | 1.34.12 (2026-09-23) | **in maintenance mode since 2026-08-27** | **2026-10-27** |

- About three minor releases a year; each receives patches for about 12 months, then a two-month maintenance mode
  (critical fixes only), then EOL — roughly 14 months in all. Patch releases are monthly.
- **`kubectl` is supported within one minor version (older or newer) of `kube-apiserver`**; the studio pins the `kubectl`
  minor to the cluster's minor in CI (`.tool-versions`/the workflow) and moves both together.
- **Helm 4.3.0** (2026-09-09; Helm 4.0.0 was released 2025-11-12) is the studio's Helm. Skew policy: a Helm 4 release supports
  the Kubernetes minor it was compiled against and three earlier (`n-3`) — 4.3.x: 1.37–1.34, 4.2.x: 1.36–1.33; never a cluster
  newer than the Helm build. **Helm 3 is ending**: 3.22.0 (2026-09-09) is the final Helm 3 feature release (Kubernetes
  client updates only); security fixes end **2027-02-10**; after that no updates at all. Charts with `apiVersion: v2` run
  unchanged on Helm 4; CLI renames: `--atomic` → `--rollback-on-failure`, `--force` → `--force-replace` (old flags warn);
  server-side apply is the default for new releases; values may be split across several YAML files; post-renderers are plugins.
- **Gateway API v1.6.2** (2026-09-03), `v1` GA resources: `GatewayClass`, `Gateway`, `ListenerSet`, `HTTPRoute`, `GRPCRoute`,
  `TLSRoute`, `TCPRoute`, `UDPRoute`, `BackendTLSPolicy`, `ReferenceGrant`. **The Ingress API is frozen** — GA, never removed,
  no further development — and the Kubernetes project recommends Gateway instead. **ingress-nginx is retired**: best-effort
  maintenance ended March 2026, no further releases or security fixes; its README says not to deploy it and to pick a
  Gateway API implementation.
- Secrets operators: **External Secrets Operator v2.11.0** (2026-09-18); **Sealed Secrets v0.40.0** (2026-09-10, `kubeseal`).

## Studio deploy shape (`Deploy target: kubernetes`)
| Item | Choice | Why |
|---|---|---|
| Packaging | **One Helm chart per service** in `deploy/k8s/charts/<service>/` (`Chart.yaml` `apiVersion: v2`, `templates/`, `values.yaml`); shared bits in a library chart `deploy/k8s/charts/common/` (`type: library`) | A chart is the unit `helm rollback` restores; one chart per service keeps a rollback from touching its neighbours. `charts/<service>/` at the root is the accepted alternative for a single-service repository (`k8s_chart_path`) |
| Environments | `values.yaml` = safe defaults; **`values-<env>.yaml` per environment** next to it (`values-staging.yaml`, `values-prod.yaml`); one **namespace per environment** (`<project>-staging`, `<project>-prod`), or one cluster per environment when the owner has them; the environment names are the runbook's (`docs/ops/deploy.md`), never a fixed list | Helm merges values files in order, so an environment file holds only the differences; a namespace is the boundary for RBAC, NetworkPolicy, quotas and Pod Security |
| Values keys | camelCase, nested by concern (`image.repository`, `image.tag`, `image.digest`, `resources.requests.cpu`, `env.LOG_LEVEL`, `secrets.storeRef`) — Helm chart best practices; no secret values in any values file | The chart is the contract of the deploy; a value name that follows the Helm convention needs no comment |
| Workload | `Deployment` with `strategy: RollingUpdate` (`maxUnavailable: 0`, `maxSurge: 1` for a stateless API), `replicas ≥ 2` in prod, `revisionHistoryLimit: 5`; a `Job` (Helm `pre-upgrade` hook) runs the migrations before the new pods; `StatefulSet` only for what owns storage | Zero-downtime rollouts need an old pod alive while the new one passes readiness; expand/contract migrations (`database.md`) let the old and new version coexist |
| Service and routing | `Service` `ClusterIP`; **Gateway API `HTTPRoute`** attached to the cluster's `Gateway` (the platform's implementation, or the one the ADR names), TLS terminated at the Gateway; `Ingress` only on a cluster that offers no Gateway controller and cannot get one — recorded in the layout/infra ADR | Ingress is frozen and its most used controller is retired; HTTPRoute is GA and portable across implementations |
| Probes | `startupProbe` → `GET /healthz` (`failureThreshold: 30`, `periodSeconds: 10` — up to five minutes for migrations or cache warm-up); `livenessProbe` → `GET /healthz` (`periodSeconds: 10`, `timeoutSeconds: 3`, `failureThreshold: 3`); `readinessProbe` → `GET /readyz` (`periodSeconds: 5`, `timeoutSeconds: 3`); `httpGet` on the app port, never `exec` | The probes page: liveness restarts the container, readiness removes the pod from the Service; a liveness that checks dependencies causes cascading restarts, so `/healthz` is process-only and `/readyz` carries the dependencies (`observability.md`); `exec` probes fork a process per check |
| Resources | `requests` and `limits` on every container; **memory `limits` = `requests`**; CPU `requests` always, CPU `limits` only when the ADR says so (noisy neighbours); numbers from a load test, revisited by `/perf-audit` | A pod without requests is scheduled blind and evicted first; equal memory request and limit removes the surprise OOM at the limit |
| Availability | `PodDisruptionBudget` `minAvailable: 1` for every Deployment with `replicas ≥ 2`; `topologySpreadConstraints` across nodes/zones in prod | Node drains and upgrades respect the PDB; without one a drain can take every replica at once |
| Autoscaling | `HorizontalPodAutoscaler` `autoscaling/v2`, `minReplicas` 2 (prod), `maxReplicas` from the load test, CPU utilisation target first; a custom metric from `/metrics` (queue lag, RPS) only with an adapter the platform provides | CPU is available on every cluster; a custom metric needs the metrics pipeline of `observability.md` first |
| Configuration | Non-secret config in `ConfigMap`/`env` from values; **secrets through `ExternalSecret`** objects (External Secrets Operator, `SecretStore`/`ClusterSecretStore` pointing at the owner's vault or cloud secret manager) — the **studio default**; **Sealed Secrets** (`kubeseal`, the `SealedSecret` is safe in git) when there is no secret manager; never a plain `Secret` manifest or a secret value in values files or CI variables pasted into `--set` | The secret lives in one place with rotation and audit; the chart holds only references. Sealed Secrets keeps the git workflow when nothing else exists, at the price of re-sealing on rotation and a per-cluster key |
| Images | `image: <registry>/<name>@sha256:<digest>` — **pinned by digest**, the tag (`vX.Y.Z`) kept in `app.kubernetes.io/version`; the release workflow writes the digest into `values-<env>.yaml` (or passes `--set image.digest=`); `imagePullPolicy: IfNotPresent`; the pull secret via `ExternalSecret` | Tags move, digests are immutable (images concept page); a rollback to a digest is exact |
| Labels | `app.kubernetes.io/name`, `instance` (`.Release.Name`), `version` (`.Chart.AppVersion`), `component`, `part-of`, `managed-by` (`.Release.Service`) on every object — the Helm best-practice set | Dashboards, NetworkPolicy selectors and `kubectl` filters share one vocabulary |
| Observability wiring | `prometheus.io/scrape` annotations or a `PodMonitor` (when the Prometheus Operator is present) on the internal metrics port; `OTEL_EXPORTER_OTLP_ENDPOINT` pointing at the Collector `Service` (`otelcol-k8s` or `otelcol-contrib`); logs stay on stdout for the cluster's log agent | `observability.md` |
| Delegate | `Deploy delegate: script scripts/deploy/kubernetes.sh` implementing the contract verbs (`status`, `deploy <tag> --env`, `rollback [tag] --env`, `logs`) with the commands below; written by `devops-engineer` for the project (the plugin ships a reference script for `compose-ssh` only) | `/deploy` calls one verb with `--confirmed`; the script is where `helm` and `kubectl` live, the skill never restates them |

## Rollout and rollback commands (what the delegate script runs)
```
helm lint deploy/k8s/charts/<svc> -f deploy/k8s/charts/<svc>/values-<env>.yaml          # CI, every PR
helm template <svc> deploy/k8s/charts/<svc> -f …/values-<env>.yaml | kubectl apply --dry-run=server -f -   # CI, schema check against the cluster
helm upgrade --install <svc> deploy/k8s/charts/<svc> -n <ns> \
  -f deploy/k8s/charts/<svc>/values.yaml -f deploy/k8s/charts/<svc>/values-<env>.yaml \
  --set image.digest=sha256:<digest> --wait --timeout 5m --rollback-on-failure --history-max 10   # Helm 3: --atomic
kubectl -n <ns> rollout status deployment/<svc>                                             # evidence for DEPLOYED
helm -n <ns> history <svc>                                                                  # revisions = rollback targets
helm -n <ns> rollback <svc> [revision] --wait --timeout 5m                                  # ROLLED BACK; default = previous revision
kubectl -n <ns> rollout undo deployment/<svc> [--to-revision=N]                             # only for a change made outside Helm
kubectl -n <ns> logs deployment/<svc> --since=15m                                           # the logs verb
```
- `--wait` in Helm 4 takes a strategy (`watcher` when the flag is given alone; `hookOnly` when omitted); `--rollback-on-failure`
  forces `watcher` — the release is marked failed and rolled back when readiness never comes.
- A rollback restores the image and config, **not the data**: the plan states whether the migrations since the target
  revision are reversible (expand/contract) — `/deploy` Phase 2.
- Smoke checks after `DEPLOYED` are the caller's (`/deploy` Phase 3): `/healthz`, `/readyz`, the key journey through the Gateway.

## Security notes
- **Pod Security Standards "Restricted"** enforced on the app namespaces through Pod Security Admission; the chart sets what
  Restricted requires — `securityContext.runAsNonRoot: true`, `allowPrivilegeEscalation: false`, `capabilities.drop: [ALL]`,
  `seccompProfile.type: RuntimeDefault`, only the permitted volume types (`configMap`, `secret`, `emptyDir`, `projected`,
  `persistentVolumeClaim`, `csi`, `downwardAPI`, `ephemeral`) — plus the studio's own `readOnlyRootFilesystem: true` with an
  `emptyDir` for `/tmp` (not part of Restricted, but free with distroless/alpine images that write nothing).
- **NetworkPolicy default-deny** for ingress and egress in every app namespace, then allow-lists: Gateway → app port, app →
  DB/cache/Collector, app → DNS; a pod with no policy is non-isolated (everything allowed) by the concept page's definition.
- **RBAC least privilege**: one `ServiceAccount` per workload with `automountServiceAccountToken: false` unless the app calls
  the API; the CI deployer is a namespace-scoped `Role` (`deployments`, `services`, `configmaps`, `secrets`, `jobs`,
  `httproutes`, …), never `cluster-admin`; `helm` runs with that identity.
- **No `:latest`, no floating tags** — an image name without a tag *is* `:latest` (images page); digests in production values.
- Secrets: never in `values*.yaml`, git, CI logs or `helm get values` output — references only (`ExternalSecret`/`SealedSecret`);
  `helm` release history stores rendered manifests, so a secret templated into a manifest leaks into every revision.
- The Collector, Prometheus and the app's `/metrics` port have no `HTTPRoute`; `/metrics` is scraped in-cluster only.
- Cluster minor within support (table above); upgrade before maintenance mode; `kubectl`/`helm` pinned in CI.

## Review checklist
1. `Chart.yaml` `apiVersion: v2`, `appVersion` = the release tag; `helm lint` and the server dry-run pass in CI for every environment values file.
2. Image pinned by digest; no `:latest`; pull secret via `ExternalSecret`.
3. `startupProbe`/`livenessProbe` → `/healthz`, `readinessProbe` → `/readyz`, `httpGet`, timeouts set; `/healthz` is process-only in the app.
4. `requests`/`limits` on every container, memory request = limit; PDB for `replicas ≥ 2`; HPA `autoscaling/v2` with a tested `maxReplicas`.
5. Restricted-profile `securityContext` on pod and containers; `readOnlyRootFilesystem` with an `emptyDir` for scratch.
6. `NetworkPolicy` default-deny + allow-lists; the metrics port and the Collector have no route from outside.
7. Secrets only as `ExternalSecret`/`SealedSecret`; nothing secret in values, CI variables passed to `--set`, or manifests.
8. `RollingUpdate` with `maxUnavailable: 0`; migrations as a pre-upgrade `Job`; the rollback note states data reversibility.
9. The delegate script implements the contract verbs with `--confirmed`, the commands above, and returns evidence (`rollout status`, `helm history`).
10. Cluster minor supported; Helm 4 (not 3), `kubectl` within one minor of the API server; `HTTPRoute`, not `Ingress`, unless the ADR says why.
