---
paths: ["**/charts/**", "**/deploy/k8s/**", "**/Chart.yaml", "**/values*.yaml", "**/kustomization.yaml"]
---
# Kubernetes rules
- One Helm chart per service at `k8s_chart_path` (`Chart.yaml` `apiVersion: v2`, `appVersion` = the release tag); `values.yaml` holds safe defaults, `values-<env>.yaml` only the differences; keys camelCase, nested by concern.
- Image pinned by digest (`@sha256:…`), never `:latest` or a floating tag; the release workflow writes the digest, a human never types it.
- Probes: `startupProbe` and `livenessProbe` → `GET /healthz`, `readinessProbe` → `GET /readyz`, `httpGet` with timeouts — the endpoints of `observability.md`; `/healthz` never checks a dependency.
- `requests` and `limits` on every container (memory request = limit); `PodDisruptionBudget` for `replicas ≥ 2`; HPA `autoscaling/v2`; `RollingUpdate` with `maxUnavailable: 0`; migrations as a `pre-upgrade` hook `Job`.
- Routing through Gateway API `HTTPRoute` unless `k8s_routing: ingress` names the reason; `/metrics`, the Collector and Prometheus get no route from outside.
- Secrets only as `ExternalSecret` (or `SealedSecret` per `k8s_secrets`); nothing secret in values files, `--set`, CI logs or templated manifests.
- Restricted Pod Security on pod and containers: `runAsNonRoot`, `allowPrivilegeEscalation: false`, `capabilities.drop: [ALL]`, `seccompProfile: RuntimeDefault`, `readOnlyRootFilesystem` with an `emptyDir` scratch; `automountServiceAccountToken: false` unless the app calls the API; `NetworkPolicy` default-deny plus allow-lists per namespace.
- Labels `app.kubernetes.io/{name,instance,version,component,part-of,managed-by}` on every object.
- `helm lint` and `helm template … | kubectl apply --dry-run=server` in CI for every environment values file; a story that touches a chart reports both outputs.
- Rollout and rollback commands live in `kubernetes.md` § Rollout and rollback and in `scripts/deploy/kubernetes.sh` (the deploy delegate) — never restated in skills or runbooks by hand; production mutations only through `/deploy`.
- Reference: `.claude/docs/stack-reference/kubernetes.md`; endpoints and metrics: `observability.md`; images and CI: `rules/ci-docker.md`.
