---
name: dependency-audit
description: "Audits the supply chain (OWASP A03) — lockfiles, vulnerability scans, abandoned packages, versions vs the stack reference, licences, Renovate/Dependabot config, SRI, image pinning — and reports upgrade/replace actions; `--fix-safe` applies patch/minor updates on a chore branch. Required before release; use for 'check the dependencies', 'any vulnerable packages', 'outdated deps'."
argument-hint: "[--fix-safe]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Write, WebFetch, Task, AskUserQuestion
---

# Dependency Audit

Reply in the project conversation language (CLAUDE.md → Language); code, identifiers, paths and commit messages stay in English.

Reference `stack-reference/index.md`, `tooling-devops.md`, `supply-chain.md` (SBOM scanning, update-bot policy); template `findings.md`. The report is `docs/ops/dependency-audit-<date>.md` (Phase 4); its high findings reach planning the way the sibling audits' do — as `production/findings.md` rows (`DEP-NNN`, Phase 4 step 2), because `/help`, `/create-stories` and `/sprint-plan` read that file and nobody reads the report for open actions (git-workflow § Chore / infra: a found problem is recorded there). In the commands below, `<hooks>` is `.claude/hooks/` in copy mode and `${CLAUDE_PLUGIN_ROOT}/hooks/` in plugin mode.

File writes and any mutation (git, deploy) happen only after an explicit "May I write?" / "Proceed?" — each one `AskUserQuestion` (proceed (Recommended) · show the draft/diff first · not now) → "yes". After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker). A subagent spawned through `Task` cannot ask the user: the parent's "yes" covers the packages and files it names, and a delegated agent that needs to go beyond that stops and reports back so the parent asks.

## Phase 1: Inventory
Manifests and lockfiles (`go.mod/go.sum`, `composer.lock`, `pnpm-lock.yaml`/`package-lock.json`), Dockerfile base images, external `<script src>` in HTML, GitHub Actions (pins).

## Phase 2: Checks (Bash, whatever is available)
- Go: `govulncheck ./...`.
- PHP: `composer audit`, `composer outdated --direct`, Packagist abandoned (`WebFetch` of the package's Packagist page when in doubt — the fetched status is quoted in the report, never assumed).
- JS: `pnpm audit`/`npm audit`, `pnpm outdated`.
- Versions vs `stack-reference/index.md`.
- Licences: `license-checker`/`composer licenses`/`go-licenses` when available.
- `renovate.json`/`dependabot.yml`: present, minors grouped per `tooling-devops.md`. The open update PRs themselves are `/sprint-plan`'s queue, not this report's.
- Images: `trivy image` when available.
- **SBOM-based scan** (option next to the ecosystem audits, `supply-chain.md` § SBOM): when a release SBOM exists (`gh release view <tag> --json assets`, or `syft <image>@<digest> -o cyclonedx-json=sbom.cdx.json` now), `grype sbom:sbom.cdx.json --fail-on high --only-fixed` or `trivy sbom sbom.cdx.json` — one scan covers OS packages of the base image and the app dependencies together; its findings join the same table with the source column `sbom`.

## Phase 3: Report
Table "package → version → problem (CVE/abandoned/outdated/licence) → action (upgrade/replace/accept risk) → effort", shown in the chat.

`--fix-safe`: propose applying only patch/minor updates without breaking changes (after "yes", with a test run). Dependency updates are toolchain work on the chore lane (git-workflow § Chore / infra): after the "yes", switch to a `chore/deps-<date>` branch from an up-to-date default branch, apply the updates, run the tests (output in the result), commit `chore(deps): safe updates <date>` and open the PR; `/code-review --diff` before the merge. The manifest and lockfile changes never land on the default branch and never ride the `docs:` commit of Phase 4. A failing test run reverts the update that broke it and lists it under "not applied".

## Phase 4: Write
1. "May I write `docs/ops/dependency-audit-<date>.md`?" — one `AskUserQuestion`: write (Recommended) · show the draft/diff first · not now. After the "write" answer: `touch .claude/.write-consent` (rule 7 — the consent-guard hook checks the marker).
2. **High findings reach `production/findings.md`.** For every high finding (a high/critical CVE, an abandoned package with no replacement, a licence conflict), one `AskUserQuestion`: record it in `production/findings.md` (template `findings.md`; id `DEP-NNN`, severity, area/package, source column pointing at the report, the action — upgrade/replace/accept risk) (Recommended) · story stubs now via `/create-stories` · report only. The "record" answer is the "May I write `production/findings.md`?" consent: `touch .claude/.write-consent` after it, then write the row. A high finding that is neither recorded nor turned into a story is named as such in the verdict line. Record the gate before asking — `<hooks>session-state.sh set Gate "/dependency-audit Phase 4: record DEP-NNN?"` — and clear it after the answer (`<hooks>session-state.sh set Gate "—"`).
3. **Commit gate** (rule 7 (4), `.claude/docs/git-workflow.md` § Documents), right after the write (and the findings rows, when any were recorded): `docs: dependency audit <date>`, staging exactly `docs/ops/dependency-audit-<date>.md`, `production/findings.md` when rows were added and `.claude/agent-memory/` when the run changed it (git-workflow § Agent memory). Record the gate before asking — `<hooks>session-state.sh set Gate "/dependency-audit Phase 4: commit?"` — and clear it after the answer (`<hooks>session-state.sh set Gate "—"`).
   - On the default branch when no story work is in progress: one `AskUserQuestion` — commit (Recommended) · leave uncommitted.
   - When HEAD is a story branch (or the `chore/deps-<date>` branch of `--fix-safe`), name it and ask one `AskUserQuestion`: switch to the default branch and commit there (Recommended — a pipeline-wide document) · commit here (the document belongs to this branch) · leave uncommitted.
   - Lockfile and manifest changes, a `renovate.json`/`dependabot.yml` added on request, image pins: not documents — they stay on the chore lane and never ride the `docs:` commit; name them in the result.

   Nothing is committed without the answer.

Verdict: `CLEAN` | `ACTION REQUIRED (N high)`. Next step — one `AskUserQuestion`: stories for the replacements/upgrades (Recommended) · `/stack-update` for outdated majors · report only.
