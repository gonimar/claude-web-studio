---
name: harden
description: "Hardens the runtime and perimeter — security headers/CSP, TLS/HSTS, proxy (Caddy/nginx) config, rate/body limits, WebSocket protections, Docker network/container hardening, CI permissions, supply chain (update bot, SHA-pinned Actions, lockfile policy, SBOM and signing jobs), secrets hygiene; verifies with live curl/scanner output; writes docs/security/hardening-checklist.md."
argument-hint: "[full | headers | tls | proxy | docker | ci | supply-chain | secrets] [--apply]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Write, Edit, Task, AskUserQuestion
---

# Harden

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

References: `stack-reference/security-standards.md`, `stack-reference/supply-chain.md` (checklist `SC-01…SC-12`), `security-baseline.md` (headers, network), rules `rules/ci-docker.md`, `rules/security-sensitive.md`. In the commands below, `<hooks>` is `.claude/hooks/` in copy mode and `${CLAUDE_PLUGIN_ROOT}/hooks/` in plugin mode.

**Mode** (argument, default `full`): `full` runs every checklist group of Phase 2; `headers`, `tls`, `proxy`, `docker`, `ci`, `supply-chain` narrow it to that group; `secrets` runs the rotation checklist instead. `--apply` goes on to Phase 3 without a separate "apply?" question; every file write still has its own "May I write?".

## Phase 1: Inventory
1. **Where the config lives.** Proxy configs in this repository, or in the **Infra repo / Proxy config** from `technical-preferences.md` (Infrastructure) when the proxy lives elsewhere. Also compose/Dockerfile, workflows, and where TLS terminates.
2. **No infra repo declared and no proxy config here** → say so: the proxy checklist can only be verified live, not fixed here, and `/setup-stack` / `/adopt` records the field.
3. **Current headers**: `curl -sI <url>` on dev/staging/prod, with consent. No URL reachable (or consent declined) → continue with static analysis of the configs and say that every item is unverified live.

## Phase 2: Checklist
Per item: status and a verification command.
- **Headers**: HSTS, CSP nonce/strict-dynamic (mind Angular `ngCspNonce` / Nuxt), nosniff, Referrer-Policy, Permissions-Policy, COOP/CORP; cookie flags.
- **TLS**: the TLS profile.
- **Proxy**: `server_tokens` / `limit_req` / `client_max_body_size` / timeouts; WebSocket Origin checks and limits.
- **Docker**: networks, non-root, `cap_drop`, `read_only`, pins (base image digests → SC-11), health checks.
- **CI**: workflow `permissions` — this group owns SC-04 (`contents: read` at the top, raised only per job); the supply-chain group reports it by id but does not re-check it.
- **Supply chain**: read `references/supply-chain.md` and run its five checks — update bot config (`renovate.json` / `.github/dependabot.yml`), Actions pinned by SHA, lockfile policy in CI, SBOM job, signing job; every finding carries its `SC-NN` id from `stack-reference/supply-chain.md`. A missing job is a finding with the template to add (`docs/templates/supply-chain/`), proposed in Phase 3 like any other config diff.
- **Secrets hygiene**: `.env` ignored, gitleaks.

**`secrets` mode (rotation checklist)** — an inventory, never the values. Trigger: a leak (`/incident`), a departure, quarterly.
1. **Inventory** every secret the project uses, from the deploy contract's Prerequisites & secrets, `.env.example`, compose `environment:`/`env_file:`, workflow `secrets.*` references and the platform UI names.
2. **Per secret**: where it lives (platform env, `~/.config/<project>/*.env`, CI secret, registry token), which component reads it, the provider's rotation steps (issue new → deploy → verify → revoke old), the last rotation date if recorded.
3. **Checks**: `gitleaks` / `git log -p -S` for the old value's pattern (never the value itself on the command line); no secret in images (`docker history`, build args); CI `permissions` least-privilege; `.env` ignored.
4. **Output**: the rotation table, the order to rotate in (dependencies first) and the verification per secret; it goes into `docs/security/hardening-checklist.md` § Secrets (Phase 4).

## Phase 3: Changes (`--apply`, or with consent)
Without `--apply`, ask one `AskUserQuestion` after Phase 2: apply the fixes (Recommended) · checklist only · stop.
1. **Show the config diffs** and write each one only after its own "May I write `<path>`?" — one `AskUserQuestion` per file: write (Recommended) · show the full diff first · skip this file; `touch .claude/.write-consent` after the "write" answer:
   - config in this repository (proxy, compose, Dockerfile, workflows, `renovate.json` / `dependabot.yml`) → the diff here;
   - proxy in the declared infra repo → the diff there ("May I write `<infra repo path/file>`?");
   - neither → no write: the exact snippet for the owner of the proxy.
2. **Validate**: `nginx -t` / `caddy validate` / `docker compose config`; a workflow diff → `actionlint` when available, else `bash -n` on its `run:` blocks; `renovate.json` → `npx --yes renovate-config-validator` (or state that it was not validated).
3. **Re-check live**: repeat `curl -I` and show the before/after output. The live headers are the evidence in every case.

## Phase 4: Write
Render the checklist (and the § Secrets table in `secrets` mode) in the chat, then "May I write `docs/security/hardening-checklist.md`?" — one `AskUserQuestion`: write (Recommended) · show the draft/diff first · not now. After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker).

## Phase 5: Commit (documents lane)
Right after the write, one commit gate (rule 7 (4), `.claude/docs/git-workflow.md` § Documents): `docs: hardening checklist` (`docs: hardening checklist — secrets` in `secrets` mode), staging exactly `docs/security/hardening-checklist.md`. Record the gate before asking — `<hooks>session-state.sh set Gate "/harden Phase 5: commit?"` — and clear it after the answer (`<hooks>session-state.sh set Gate "—"`).
- On the default branch when no story work is in progress: one `AskUserQuestion` — commit (Recommended) · leave uncommitted.
- When HEAD is a story branch, name it and ask one `AskUserQuestion`: switch to the default branch and commit there (Recommended — a pipeline-wide document) · commit here (the document belongs to this story) · leave uncommitted.
- The Phase 3 config diffs (proxy, compose, Dockerfile, workflows) are infra, not documents: they never ride the `docs:` commit — name them in the result and offer the chore lane (git-workflow.md § Chore / infra: branch `chore/harden-<group>`, `ci(…)`/`chore(…)` commits, a PR, `/code-review --diff` before the merge, workflow files to `devops-engineer`). A diff written in the declared infra repo is committed there under that repository's rules, named in the result.

Nothing is committed without the answer.

Verdict: `HARDENED` | `PARTIAL (open: …)`. Next step — one `AskUserQuestion`: `/security-audit quick` (Recommended) · `/pentest` (optional) · stop here.
