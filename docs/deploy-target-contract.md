# Deploy target contract

How `/deploy`, `/team-release`, `/hotfix` and `/incident` hand the live-stack mutation to a
deployment delegate. A skill cannot call another skill, so a companion kit that only ships a
slash command (`/portainer deploy`) is **not** a usable delegate — it must also provide one of the
two forms below. Without a declared delegate the pipeline produces manual runbook steps, which
is a valid, explicit outcome.

## 1. Declaration (`technical-preferences.md` → Infrastructure)
```
- **Deploy target**: compose-ssh | kubernetes | cloud:<name> | portainer | manual
- **Deploy delegate**: agent <name> | script <path> | none
- **Infra repo**: <path or URL of the repository that holds the proxy/host config> | none
- **Proxy config**: <file inside the infra repo, e.g. caddy/Caddyfile> | none
```
`/setup-stack` asks for the target (one `AskUserQuestion`); `/adopt` fills it from what it finds
(`.claude/agents/*-ops.md` with `deploy-target:` in the frontmatter, `scripts/deploy/*.sh`, an
installed kit's docs). The roster's Tier 0 row lists the delegate.

## 2. Inputs the delegate may rely on
- `docs/ops/deploy.md` — the runbook (from `templates/deploy-runbook.md`): environments, domains,
  migration order, smoke checks, rollback.
- `docs/deploy/<target>.md` — target facts kept by the delegate: endpoint, stack/namespace name,
  image names, env-file location. **No secrets** — those come from the environment or a
  user-level file (`~/.config/<kit>/env`), never from the repository.
- The version to deploy (`vX.Y.Z` tag) and, for rollback, the previous tag from
  `production/releases/`.

## 3. Verbs (all delegates), arguments, verdict words
| Verb | Arguments | Mutates | Verdict words |
|---|---|---|---|
| `status` | — | no | `RUNNING (n services)` · `DEGRADED (…)` · `NOT CONFIGURED` |
| `create` | — | yes | `CREATED` · `EXISTS` · `FAILED (reason)` |
| `deploy` | `<tag>` | yes | `DEPLOYED <tag>` · `FAILED (reason, state)` |
| `rollback` | `[tag]` (default: previous release) | yes | `ROLLED BACK <tag>` · `FAILED (reason)` |
| `logs` | `[service] [--since <duration>]` | no | `LOGS (n lines)` |
| `env` (optional) | `list` · `set KEY` (value from stdin) | set: yes | `ENV (…)`; absent → `NOT SUPPORTED` |
| `backup` (optional) | — | no | `BACKUP <id>` ; absent → `NOT SUPPORTED` |
Every verb returns evidence, not only the verdict: container/service list, image tags, the smoke
request result. Unsupported optional verbs answer `NOT SUPPORTED`, never silently succeed.

## 4. Invocation forms
- **Agent**: `.claude/agents/<target>-ops.md` (kit or project) with frontmatter `deploy-target: <target>`
  and `tools: Bash, Read`. `/deploy` calls it via `Task` with the prompt
  `"<verb> <args> --confirmed"` and expects the verdict line first, evidence after.
- **Script**: `scripts/deploy/<target>.sh <verb> [args] [--confirmed]` via `Bash`; exit 0 on success,
  non-zero on `FAILED`; the verdict line is the last line of stdout.
The plugin ships a reference script for `compose-ssh` (`docs/templates/deploy/compose-ssh.sh`, seeded into
`.claude/docs/templates/deploy/`) which `/setup-stack` copies to `scripts/deploy/compose-ssh.sh` when that target is chosen.

## 5. Confirmation
Mutating verbs run only after the user's explicit "Proceed?" → "yes" **in the calling skill**;
the caller then passes `--confirmed`. A delegate invoked without `--confirmed` refuses a mutating
verb with `FAILED (not confirmed)`. A delegate never asks the user itself when called by a skill.

## 6. Verification by the caller
After `deploy`/`rollback`, `/deploy` runs the smoke checks from `docs/ops/deploy.md` itself
(`/healthz`, key journey) — the delegate's `DEPLOYED` is necessary, not sufficient.

## 7. Adopting a kit
A kit that wants to be a delegate adds the `deploy-target:` frontmatter to its agent (or ships the
script), implements the verbs with `--confirmed`, documents `docs/deploy/<target>.md`, and
registers itself through `/setup-stack`'s question. Companion kits keep their own slash commands
for interactive use; the contract is only for skill-to-delegate calls.
